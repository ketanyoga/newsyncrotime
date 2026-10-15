import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../database/app_database.dart';
import '../../../services/esp32_api_service.dart';

class DeviceScheduleManagerSheet extends StatefulWidget {
  const DeviceScheduleManagerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DeviceScheduleManagerSheet(),
    );
  }

  @override
  State<DeviceScheduleManagerSheet> createState() => _DeviceScheduleManagerSheetState();
}

class _DeviceScheduleManagerSheetState extends State<DeviceScheduleManagerSheet> {
  String _status = "Connecting to device...";
  bool _fetching = true;
  List<Map<String, dynamic>> _discoveredCategories = [];
  Map<int, List<String>> _discoveredSchedules = {};
  Map<String, dynamic>? _previewingCat;
  String _selectedDayCode = "M";

  final Set<int> _importingSeqs = {};
  final Set<int> _importedSeqs = {};

  final Map<String, String> _dayNames = {
    'U': 'SUNDAY',
    'M': 'MONDAY',
    'T': 'TUESDAY',
    'W': 'WEDNESDAY',
    'H': 'THURSDAY',
    'F': 'FRIDAY',
    'S': 'SATURDAY',
  };

  @override
  void initState() {
    super.initState();
    _fetchDeviceData();
  }

  Future<void> _fetchDeviceData() async {
    setState(() {
      _status = "Connecting to SyncroBell...";
      _fetching = true;
    });

    try {
      bool connected = await Esp32ApiService.checkConnection();
      if (!connected) {
        throw Exception("Cannot reach SyncroBell Wi-Fi (192.168.4.1). Please connect your Wi-Fi.");
      }

      final List<String> lines = [];
      bool finished = false;

      // Attach listener FIRST before sending command
      final sub = Esp32ApiService.listen().listen((msg) {
        if (msg.contains("EXPORT_DONE")) {
          finished = true;
        }
        // Split multi-line TCP packet by newlines
        final rawLines = msg.split(RegExp(r'[\r\n]+'));
        for (var l in rawLines) {
          l = l.trim();
          if (l.startsWith("\$")) {
            lines.add(l);
          }
        }
      });

      setState(() => _status = "Requesting schedules from device...");
      await Esp32ApiService.sendRaw("\$EXPORT#");

      int waited = 0;
      while (!finished && waited < 80) {
        await Future.delayed(const Duration(milliseconds: 150));
        waited++;
        if (mounted) {
          setState(() => _status = "Reading Machine Memory (${lines.length} items)...");
        }
      }
      await sub.cancel();

      List<Map<String, dynamic>> cats = [];
      Map<int, List<String>> scheds = {};
      Map<int, List<DateTime>> hols = {};

      for (final line in lines) {
        if (line.startsWith("\$C,")) {
          final parts = line.replaceAll("\$", "").replaceAll("#", "").split(",");
          if (parts.length >= 5) {
            cats.add({
              'seq': int.tryParse(parts[1]) ?? 1,
              'name': parts[2],
              'start': parts[3],
              'end': parts[4],
            });
          }
        } else if (line.startsWith("\$H,")) {
          final parts = line.replaceAll("\$", "").replaceAll("#", "").split(",");
          if (parts.length >= 3) {
            try {
              final date = DateFormat('dd/MM/yy').parse(parts[2]);
              (hols[0] ??= []).add(date);
            } catch (_) {}
          }
        } else if (line.startsWith("\$P,")) {
          final String content = line.replaceAll("\$", "").replaceAll("#", "");
          final firstComma = content.indexOf(',');
          final secondComma = content.indexOf(',', firstComma + 1);
          if (secondComma != -1) {
            final seq = int.tryParse(content.substring(firstComma + 1, secondComma)) ?? 1;
            (scheds[seq] ??= []).add(line);
          }
        }
      }

      // Query local database for existing category names to mark as imported
      final db = await AppDB.instance.database;
      final localCats = await db.query('categories', columns: ['name']);
      final localNames = localCats.map((c) => (c['name'] as String).trim().toLowerCase()).toSet();

      final Set<int> alreadyImportedSeqs = {};
      for (final cat in cats) {
        final name = (cat['name'] as String).trim().toLowerCase();
        final seq = cat['seq'] as int;
        if (localNames.contains(name)) {
          alreadyImportedSeqs.add(seq);
        }
      }

      if (mounted) {
        setState(() {
          _discoveredCategories = cats;
          _discoveredSchedules = scheds;
          _importedSeqs.addAll(alreadyImportedSeqs);
          _fetching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Error: $e";
          _fetching = false;
        });
      }
    }
  }

  Future<void> _deleteCategoryFromMachine(int seq, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete from Machine?"),
        content: Text("Are you sure you want to delete category '$name' (Slot $seq) from SyncroBell device memory?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Esp32ApiService.sendRaw("\$DELC,$seq#");
      if (mounted) {
        setState(() {
          _discoveredCategories.removeWhere((c) => c['seq'] == seq);
          _discoveredSchedules.remove(seq);
          _importedSeqs.remove(seq);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted '$name' from machine")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _importCategoryToApp(Map<String, dynamic> cat) async {
    final seq = cat['seq'] as int;
    if (_importingSeqs.contains(seq) || _importedSeqs.contains(seq)) {
      return;
    }

    if (mounted) {
      setState(() {
        _importingSeqs.add(seq);
      });
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = await AppDB.instance.database;

      final startParts = (cat['start'] as String).split('/');
      final endParts = (cat['end'] as String).split('/');

      final start = DateTime(2000 + int.parse(startParts[2]), int.parse(startParts[1]), int.parse(startParts[0]));
      final end = DateTime(2000 + int.parse(endParts[2]), int.parse(endParts[1]), int.parse(endParts[0]));

      final localId = await db.insert('categories', {
        'name': cat['name'],
        'color': const Color(0xFF007AFF).toARGB32(),
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'configured': 1,
        'synced': 1,
        'skippedDays': '',
        'skippedDates': '',
      });

      final pLines = _discoveredSchedules[seq] ?? [];

      for (final line in pLines) {
        final String content = line.replaceAll("\$", "").replaceAll("#", "");
        final firstComma = content.indexOf(',');
        final secondComma = content.indexOf(',', firstComma + 1);
        final thirdComma = content.indexOf(',', secondComma + 1);

        if (thirdComma == -1) continue;

        final dayCode = content.substring(secondComma + 1, thirdComma);
        final timingData = content.substring(thirdComma + 1);
        final dayName = _dayNames[dayCode] ?? 'MONDAY';
        final pairs = timingData.split("!");

        int pCount = 1;
        for (final pair in pairs) {
          final subParts = pair.split(",");
          if (subParts.length < 2) continue;
          final track = subParts[1];

          await db.insert('periods', {
            'categoryId': localId,
            'day': dayName,
            'title': track.contains("break") ? "Break" : "Period $pCount",
            'startTime': subParts[0],
            'endTime': subParts[0],
            'ringtone': track,
            'isBreak': track.contains("break") ? 1 : 0,
          });
          if (!track.contains("break")) pCount++;
        }
      }

      await AppDB.instance.cleanDuplicatePeriods();

      if (mounted) {
        setState(() {
          _importedSeqs.add(seq);
        });
      }

      messenger.showSnackBar(
        SnackBar(content: Text("Imported '${cat['name']}' into local app database!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Import failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _importingSeqs.remove(seq);
        });
      }
    }
  }

  Widget _buildImportButton(Map<String, dynamic> cat) {
    final seq = cat['seq'] as int;
    final bool isImporting = _importingSeqs.contains(seq);
    final bool isImported = _importedSeqs.contains(seq);

    if (isImporting) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
        ),
      );
    } else if (isImported) {
      return const IconButton(
        icon: Icon(Icons.check_circle_rounded, color: Colors.green),
        tooltip: "Already Imported",
        onPressed: null,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.download_rounded, color: Colors.green),
        tooltip: "Import to App",
        onPressed: () => _importCategoryToApp(cat),
      );
    }
  }

  Widget _buildPreviewImportButton(Map<String, dynamic> cat) {
    final seq = cat['seq'] as int;
    final bool isImporting = _importingSeqs.contains(seq);
    final bool isImported = _importedSeqs.contains(seq);

    if (isImporting) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        label: const Text("IMPORTING..."),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
        ),
      );
    } else if (isImported) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        label: const Text("IMPORTED"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () async {
          await _importCategoryToApp(cat);
          if (mounted) {
            setState(() => _previewingCat = null);
          }
        },
        icon: const Icon(Icons.download_rounded),
        label: const Text("IMPORT ALL"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.router_rounded, color: Color(0xFF007AFF), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _previewingCat == null ? "Machine Schedules" : "Preview: ${_previewingCat!['name']}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "SyncroBell Device Memory",
                        style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF007AFF)),
                  onPressed: _fetchDeviceData,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _fetching
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(_status, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : _previewingCat == null
                    ? _buildCategoryList()
                    : _buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_discoveredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off_outlined, size: 64, color: Color(0xFFC7C7CC)),
            const SizedBox(height: 16),
            const Text("No schedules saved on machine.", style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDeviceData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("RETRY DISCOVERY"),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _discoveredCategories.length,
      itemBuilder: (context, index) {
        final cat = _discoveredCategories[index];
        final seq = cat['seq'] as int;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF007AFF).withOpacity(0.1),
                  child: Text("$seq", style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat['name'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("${cat['start']} - ${cat['end']}",
                          style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, color: Color(0xFF007AFF)),
                  tooltip: "Inspect",
                  onPressed: () => setState(() => _previewingCat = cat),
                ),
                _buildImportButton(cat),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: "Delete from Machine",
                  onPressed: () => _deleteCategoryFromMachine(seq, cat['name']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreview() {
    final seq = _previewingCat!['seq'] as int;
    final lines = _discoveredSchedules[seq] ?? [];

    List<Map<String, String>> currentDaySlots = [];

    for (final line in lines) {
      final String content = line.replaceAll("\$", "").replaceAll("#", "");
      final firstComma = content.indexOf(',');
      final secondComma = content.indexOf(',', firstComma + 1);
      final thirdComma = content.indexOf(',', secondComma + 1);

      if (thirdComma == -1) continue;

      final dayCode = content.substring(secondComma + 1, thirdComma);
      if (dayCode == _selectedDayCode) {
        final timingData = content.substring(thirdComma + 1);
        final pairs = timingData.split("!");
        for (final pair in pairs) {
          final sub = pair.split(",");
          if (sub.length >= 2) {
            currentDaySlots.add({'time': sub[0], 'file': sub[1]});
          }
        }
      }
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _dayNames.entries.map((e) {
              final isSel = _selectedDayCode == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.key),
                  selected: isSel,
                  onSelected: (_) => setState(() => _selectedDayCode = e.key),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: currentDaySlots.isEmpty
              ? const Center(child: Text("No periods scheduled for this day."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: currentDaySlots.length,
                  itemBuilder: (context, index) {
                    final item = currentDaySlots[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.alarm_on_rounded, color: Color(0xFF007AFF)),
                        title: Text(item['time'] ?? "--:--", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item['file'] ?? "Ringtone"),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _previewingCat = null),
                  child: const Text("BACK"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPreviewImportButton(_previewingCat!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
