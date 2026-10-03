import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../models/category_model.dart';
import '../../models/period_model.dart';
import '../general/general_schedule_page.dart';
import '../week/week_schedule_page.dart';
import '../dashboard/dashboard_page.dart';
import '../dashboard/widgets/device_schedule_manager_sheet.dart';
import '../../services/esp32_api_service.dart';
import 'create_category_page.dart';
import 'edit_category_page.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<CategoryModel> categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => loading = true);
    final db = await AppDB.instance.database;
    final res = await db.query('categories', orderBy: 'name');
    if (mounted) {
      setState(() {
        categories = res.map((e) => CategoryModel.fromMap(e)).toList();
        loading = false;
      });
    }
  }

  Future<void> _deleteCategory(int id) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category and all associated data?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final db = await AppDB.instance.database;

      // 1. Identify the name (for hardware sync)
      final CategoryModel catToDelete = categories.firstWhere((c) => c.id == id);
      final String name = catToDelete.name;

      // 2. Send delete command by NAME to machine
      try {
        bool connected = await Esp32ApiService.checkConnection();
        if (!connected) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Device not connected. Could not delete from machine.'), backgroundColor: Colors.red),
            );
          }
          return; 
        }
        
        await Esp32ApiService.sendRaw("\$DELC,$name#");
        // Wait for acknowledgement
        await Esp32ApiService.waitForAnyResponse(["deleted", "OK", "ERROR"], timeout: const Duration(seconds: 3));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hardware error: $e'), backgroundColor: Colors.red),
          );
        }
        return; 
      }

      // 3. Perform Local Delete
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
      await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted from App & Device'), backgroundColor: Colors.green),
        );
      }
      _loadCategories();
    }
  }

  Future<void> _deleteAllCategories() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete ALL categories and schedules from both the app and the SyncroBell hardware. Are you absolutely sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => loading = true);
      try {
        await Esp32ApiService.sendRaw("\$ClearAll#");
        final db = await AppDB.instance.database;
        await db.delete('categories');
        await db.delete('periods');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SyncroBell could not be reset. Please check your connection.'), backgroundColor: Colors.orange),
          );
        }
        final db = await AppDB.instance.database;
        await db.delete('categories');
        await db.delete('periods');
      } finally {
        _loadCategories();
      }
    }
  }

  String _getRingtoneName(String? ringtonePath) {
    if (ringtonePath == null || ringtonePath.trim().isEmpty) {
      return "default.mp3";
    }
    return ringtonePath.split(r'\').last.split('/').last;
  }

  Future<void> _performFullSync(CategoryModel cat, int sequence) async {
    bool success = false;

    final db = await AppDB.instance.database;
    final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id]);
    final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
    
    // SMART SYNC: Collect unique ringtones + Essential system files
    final Set<String> uniqueRingtones = periods.map((p) => p.ringtone).whereType<String>().toSet();
    uniqueRingtones.add('assets/audio/SchoolBell.mp3');
    uniqueRingtones.add('assets/audio/Emergency.mp3');

    final DateFormat formatter = DateFormat('dd/MM/yy');
    final dayCodeMap = {'sunday': 'U', 'monday': 'M', 'tuesday': 'T', 'wednesday': 'W', 'thursday': 'H', 'friday': 'F', 'saturday': 'S'};
    final List<String> commandsToReview = [];
    
    final DateTime now = DateTime.now();
    final String rtcStr = DateFormat('dd/MM/yy,HH:mm:ss').format(now);
    commandsToReview.add('\$R,$rtcStr#');

    // 2. Wipe existing category from device first
    commandsToReview.add('\$DELC,$sequence#');

    commandsToReview.add('\$C,$sequence,${cat.name},${formatter.format(DateTime.parse(cat.startDate))},${formatter.format(DateTime.parse(cat.endDate))}#');
    
    if (cat.skippedDates.isNotEmpty) {
      for (int i = 0; i < cat.skippedDates.length && i < 10; i++) {
        final dateStr = formatter.format(cat.skippedDates[i]);
        commandsToReview.add('\$H,${(i + 1).toString().padLeft(2, '0')},$dateStr#');
      }
    }
    
    final Map<String, List<PeriodModel>> periodsByDay = {};
    for (var p in periods) { (periodsByDay[p.day] ??= []).add(p); }
    for (var entry in periodsByDay.entries) {
      final dayCode = dayCodeMap[entry.key.toLowerCase()] ?? '?';
      if (dayCode == '?') continue;
      final pairs = entry.value.map((p) => '${p.startTime},${_getRingtoneName(p.ringtone)}').join('!');
      commandsToReview.add('\$P,$sequence,$dayCode,$pairs#');
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    String status = "Connecting to SyncroBell...";
    bool started = false;
    bool dialogMounted = true;
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateState(VoidCallback fn) {
            if (mounted && dialogMounted) {
              try {
                setDialogState(fn);
              } catch (_) {}
            }
          }

          Future<void> run() async {
            try {
              updateState(() => status = "Connecting...");
              bool connected = await Esp32ApiService.checkConnection();
              if (!connected) throw Exception("Could not connect. Please check SyncroBell Wi-Fi.");

              int totalFiles = uniqueRingtones.length;
              int currentFile = 0;

              for (final path in uniqueRingtones) {
                currentFile++;
                final fileName = _getRingtoneName(path);

                // 1. SMART CHECK: Ask hardware if file already exists
                updateState(() => status = "Checking ($currentFile/$totalFiles):\n$fileName");
                await Esp32ApiService.sendRaw('\$CHECK,$fileName#');
                
                String checkResult = "";
                try {
                   // Hardware responds with "EXISTS" or "MISSING"
                   checkResult = await Esp32ApiService.waitForAnyResponse(
                     ["EXISTS", "MISSING"],
                     timeout: const Duration(seconds: 3),
                   );
                } catch (e) {
                   debugPrint("Check timeout for $fileName, assuming missing. $e");
                   checkResult = "MISSING";
                }

                if (checkResult.contains("EXISTS")) {
                  debugPrint("Smart Sync: Skipping $fileName (Already on device)");
                  continue;
                }

                // 2. Perform regular upload if missing
                updateState(() => status = "Uploading ($currentFile/$totalFiles):\n$fileName");

                Uint8List bytes;
                if (path.startsWith('assets/')) {
                  final data = await rootBundle.load(path);
                  bytes = data.buffer.asUint8List();
                } else {
                  bytes = await File(path).readAsBytes();
                }

                await Esp32ApiService.sendRaw('\$FILE,$fileName,${bytes.length}#');
                final readyResp = await Esp32ApiService.waitForAnyResponse(
                  ["READY", "ERROR"],
                  timeout: const Duration(seconds: 15),
                );
                if (readyResp.contains("ERROR")) {
                  throw Exception("Hardware error: $readyResp");
                }

                await Esp32ApiService.sendBytes(bytes);
                updateState(() => status = "Saving ($currentFile/$totalFiles):\n$fileName");
                final saveResp = await Esp32ApiService.waitForAnyResponse(
                  ["SUCCESS", "WARNING", "ERROR"],
                  timeout: const Duration(seconds: 20),
                );
                if (saveResp.contains("ERROR")) {
                  throw Exception("Hardware save error: $saveResp");
                }
                await Future.delayed(const Duration(milliseconds: 300));
              }

              updateState(() => status = "Updating Schedule...");
              for (var cmd in commandsToReview) {
                List<String> expected = ["OK:"]; 
                if (cmd.startsWith("\$R")) expected = ["RTC OK", "OK:"];
                if (cmd.startsWith("\$C,")) expected = ["OK: C", "OK:"]; 
                if (cmd.startsWith("\$H,")) expected = ["OK: H", "OK:"];
                if (cmd.startsWith("\$P,")) expected = ["OK: P", "OK:"];

                await Esp32ApiService.sendRaw(cmd);
                try {
                  await Esp32ApiService.waitForAnyResponse(expected, timeout: const Duration(seconds: 5));
                } catch (e) {
                  debugPrint("Handshake warning: $e");
                }
                await Future.delayed(const Duration(milliseconds: 100));
              }

              await db.update('categories', {'synced': 1}, where: 'id = ?', whereArgs: [cat.id]);
              success = true;
              if (mounted && dialogMounted) {
                dialogMounted = false;
                navigator.pop();
              }
            } catch (e) {
              updateState(() => status = "ERROR: $e");
              await Future.delayed(const Duration(seconds: 4));
              if (mounted && dialogMounted) {
                dialogMounted = false;
                navigator.pop();
              }
            }
          }

          if (!started) {
            started = true;
            run();
          }

          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              dialogMounted = false;
            },
            child: AlertDialog(
              title: const Text("Syncing to Device"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!status.startsWith("ERROR")) const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                ],
              ),
              actions: [
                if (status.startsWith("ERROR"))
                  TextButton(
                    onPressed: () {
                      dialogMounted = false;
                      navigator.pop();
                    },
                    child: const Text("CLOSE"),
                  )
              ],
            ),
          );
        },
      ),
    );

    if (success) {
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text("Sync completed successfully!"), backgroundColor: Colors.green));
      }
      _loadCategories();
    }
  }

  Widget _buildSyncDeviceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: const Color(0xFF007AFF),
      child: InkWell(
        onTap: () {
          DeviceScheduleManagerSheet.show(context).then((_) => _loadCategories());
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withAlpha((255 * 0.2).round()), shape: BoxShape.circle),
                child: const Icon(Icons.router_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sync Device Data",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Explore and import saved categories from SyncroBell",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF007AFF), size: 28),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Delete All Categories',
            onPressed: categories.isEmpty ? null : _deleteAllCategories,
          ),
          IconButton(
            icon: const Icon(Icons.wifi_tethering, color: Color(0xFF007AFF)),
            tooltip: 'Check Connection',
            onPressed: () async {
              bool ok = await Esp32ApiService.checkConnection();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? "Connected to SyncroBell!" : "Connection Failed"),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _buildSyncDeviceCard(),
                const SizedBox(height: 16),
                if (categories.isEmpty)
                  _buildEmptyState()
                else
                  ...categories.asMap().entries.map((entry) => _buildCategoryCard(entry.value, entry.key + 1)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCategoryPage())).then((_) => _loadCategories()),
        label: const Text('Add Category', style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.add,color: Colors.white,),
        backgroundColor: const Color(0xFF007AFF),
      ),
    );
  }

  Future<void> _duplicateCategory(CategoryModel cat) async {
    final db = await AppDB.instance.database;
    final newCatId = await db.insert('categories', {
      'name': '${cat.name} (Copy)',
      'startDate': cat.startDate,
      'endDate': cat.endDate,
      'configured': cat.configured ? 1 : 0,
      'synced': 0,
      'scheduleConfig': cat.scheduleConfig,
      'skippedDays': cat.skippedDays.join(','),
      'skippedDates': cat.skippedDates.map((d) => d.toIso8601String()).join(','),
    });

    final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id]);
    for (var p in periodMaps) {
      final mutableP = Map<String, dynamic>.from(p);
      mutableP.remove('id');
      mutableP['categoryId'] = newCatId;
      await db.insert('periods', mutableP);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duplicated "${cat.name}" as "${cat.name} (Copy)"')),
      );
    }
    _loadCategories();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Color(0xFFC7C7CC)),
          SizedBox(height: 16),
          Text('No Categories Found', style: TextStyle(fontSize: 18, color: Color(0xFF8E8E93), fontWeight: FontWeight.w600)),
          Text('Add a category to begin.', style: TextStyle(color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel cat, int sequence) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(cat.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF8E8E93)),
                  onSelected: (val) {
                    if (val == 'duplicate') {
                      _duplicateCategory(cat);
                    } else if (val == 'edit_schedule') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
                          settings: const RouteSettings(name: 'GeneralSchedulePage'),
                        ),
                      ).then((_) => _loadCategories());
                    } else if (val == 'edit_dates_range') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => EditCategoryPage(category: cat))).then((_) => _loadCategories());
                    } else if (val == 'delete') {
                      _deleteCategory(cat.id!);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'duplicate', child: Text("Duplicate Schedule")),
                    const PopupMenuItem(value: 'edit_schedule', child: Text("Edit Schedule")),
                    const PopupMenuItem(value: 'edit_dates_range', child: Text("Edit Dates")),
                    const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSetupProgress(cat),
            const SizedBox(height: 20),
            _buildActionButton(cat, sequence),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupProgress(CategoryModel cat) {
    return Row(
      children: [
        _stepItem("Created", true),
        _stepDivider(cat.configured),
        _stepItem("Configured", cat.configured),
        _stepDivider(cat.synced),
        _stepItem("Synced", cat.synced),
      ],
    );
  }

  Widget _stepItem(String label, bool done) {
    return Column(
      children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : const Color(0xFFC7C7CC), size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: done ? Colors.black87 : const Color(0xFF8E8E93), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _stepDivider(bool done) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: done ? Colors.green : const Color(0xFFE5E5EA),
      ),
    );
  }

  Widget _buildActionButton(CategoryModel cat, int sequence) {
    if (!cat.configured) {
      return _actionButton(
        "SETUP SCHEDULE",
        const Color(0xFF007AFF),
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
            settings: const RouteSettings(name: 'GeneralSchedulePage'),
          ),
        ).then((_) => _loadCategories()),
      );
    }
    if (!cat.synced) {
      return _actionButton(
        "SYNC TO DEVICE",
        Colors.orange,
        () => _performFullSync(cat, sequence),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            "VIEW WEEK SCHEDULE",
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WeekSchedulePage(categoryId: cat.id!),
                settings: const RouteSettings(name: 'WeekSchedulePage'),
              ),
            ).then((_) => _loadCategories()),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: const Icon(Icons.sync_rounded),
          tooltip: "Re-Sync to Device",
          style: IconButton.styleFrom(
            backgroundColor: Colors.orange.withOpacity(0.15),
            foregroundColor: Colors.orange,
            padding: const EdgeInsets.all(14),
          ),
          onPressed: () => _performFullSync(cat, sequence),
        ),
      ],
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}
