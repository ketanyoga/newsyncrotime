import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Required for raw TCP Socket communication
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../models/category_model.dart';
import '../../models/period_model.dart';
import '../general/general_schedule_page.dart';
import '../week/week_schedule_page.dart';
import 'create_category_page.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<CategoryModel> categories = [];
  bool loading = true;
  final Set<int> _audioUploadedCategories = {};
  int? _activeUploadCategoryId;

  // ESP32 Connection Details
  static const String espIp = "192.168.4.1";
  static const int espPort = 23;

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
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
      await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadCategories();
    }
  }

  /// Standalone function to test the ESP32 connection.
  Future<void> _checkEspConnection() async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Checking ESP32 connection...')));

    Socket? socket;
    try {
      socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi and have tapped "Stay Connected". Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      socket?.destroy();
    }
  }

  String _getRingtoneName(String? ringtonePath) {
    if (ringtonePath == null || ringtonePath.trim().isEmpty) {
      return "default.mp3";
    }
    final filename = ringtonePath.split(r'\').last.split('/').last;
    // This handles the .mp3 error
    if (filename.endsWith('.mp3')) {
      return filename.substring(0, filename.length - 2);
    }
    return filename;
  }

  /// Shows a dialog listing audio files and initiates the upload.
  Future<void> _showAudioFilesDialog(CategoryModel category) async {
    if (!mounted) return;

    final db = await AppDB.instance.database;
    final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [category.id]);
    final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
    final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Audio Files for "${category.name}"'),
          content: SizedBox(
            width: double.maxFinite,
            child: uniqueRingtonePaths.isEmpty
                ? const Text("No audio files are assigned to periods in this category.")
                : ListView.builder(
              shrinkWrap: true,
              itemCount: uniqueRingtonePaths.length,
              itemBuilder: (context, index) {
                final path = uniqueRingtonePaths.elementAt(index);
                final fileName = _getRingtoneName(path);
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(fileName),
                  subtitle: Text('path: $path', style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (uniqueRingtonePaths.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _uploadAudioFiles(category, uniqueRingtonePaths);
                },
                child: Text('Upload ${uniqueRingtonePaths.length} Files'),
              ),
          ],
        );
      },
    );
  }

  /// REVISED: More robust version that skips files that can't be loaded.
  Future<void> _uploadAudioFiles(CategoryModel category, Set<String> uniqueRingtonePaths) async {
    if (!mounted) return;

    setState(() => _activeUploadCategoryId = category.id);
    final messenger = ScaffoldMessenger.of(context);
    final List<String> filesToUpload = uniqueRingtonePaths.toList();
    final List<String> failedFiles = [];

    // This logic now includes the default ringtone if needed
    if (filesToUpload.any((p) => p == null || p.trim().isEmpty)) {
      filesToUpload.removeWhere((p) => p == null || p.trim().isEmpty); // Remove placeholder
      if (!filesToUpload.contains('assets/audio/default.mp3')) {
        filesToUpload.add('assets/audio/default.mp3');
      }
    }


    int currentFileIndex = 0;
    int totalFiles = filesToUpload.length;
    String currentStatus = "Starting...";
    StateSetter? dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            dialogSetState = setState;
            return AlertDialog(
              title: Text('Uploading Files... ($currentFileIndex/$totalFiles)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(currentStatus, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      for (final path in filesToUpload) {
        currentFileIndex++;
        final fileName = _getRingtoneName(path);

        dialogSetState?.call(() => currentStatus = 'Preparing "$fileName"...');

        // --- START OF THE FIX ---
        Uint8List bytes;
        try {
          // Check if the path is a bundled asset or a local file path
          if (path.startsWith('assets/audio/')) {
            // It's a bundled asset, load with rootBundle
            final ByteData data = await rootBundle.load(path);
            bytes = data.buffer.asUint8List();
          } else {
            // It's a local file, load with Dart's File API
            final file = File(path);
            if (await file.exists()) {
              bytes = await file.readAsBytes();
            } else {
              throw Exception('File does not exist at path.');
            }
          }
        } catch (e) {
          // If loading fails for any reason, skip it and add to a failed list.
          failedFiles.add(fileName);
          dialogSetState?.call(() => currentStatus = 'Could not find "$fileName", skipping...');
          await Future.delayed(const Duration(seconds: 2)); // Give user time to read
          continue; // Move to the next file
        }
        // --- END OF THE FIX ---

        final fileSize = bytes.length;

        Socket? socket;
        try {
          dialogSetState?.call(() => currentStatus = 'Connecting to ESP32...');
          socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
          final reader = StreamIterator<List<int>>(socket);

          dialogSetState?.call(() => currentStatus = 'Sending header for "$fileName"...');
          final command = '\$FILE,$fileName,$fileSize#';
          socket.writeln(command);
          await socket.flush();

          dialogSetState?.call(() => currentStatus = 'Waiting for ESP32 to be ready...');
          if (await reader.moveNext().timeout(const Duration(seconds: 10))) {
            final response = utf8.decode(reader.current);
            if (!response.contains('READY')) {
              throw Exception('ESP32 not ready. Response: $response');
            }
          } else {
            throw Exception('ESP32 did not send READY signal.');
          }

          dialogSetState?.call(() => currentStatus = 'Sending data for "$fileName"...');
          socket.add(bytes);
          await socket.flush();

          dialogSetState?.call(() => currentStatus = 'Waiting for confirmation...');
          if (await reader.moveNext().timeout(const Duration(seconds: 45))) {
            final response = utf8.decode(reader.current);
            if (!response.contains('FILE UPLOAD COMPLETE')) {
              throw Exception('ESP32 did not confirm upload. Response: $response');
            }
          } else {
            throw Exception('ESP32 did not send completion signal.');
          }
        } catch (e) {
          throw Exception("Failed to upload '$fileName': $e");
        } finally {
          socket?.destroy();
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (mounted) Navigator.of(context).pop();

      if (failedFiles.isNotEmpty) {
        messenger.showSnackBar(SnackBar(
          content: Text('Upload complete, but failed to find: ${failedFiles.join(', ')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 8),
        ));
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('All audio files uploaded successfully!'), backgroundColor: Colors.green));
      }
      setState(() => _audioUploadedCategories.add(category.id!));

    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('UPLOAD ERROR: $e', style: const TextStyle(fontSize: 12)), backgroundColor: Colors.red, duration: const Duration(seconds: 10)),
      );
    } finally {
      if (mounted) setState(() => _activeUploadCategoryId = null);
    }
  }
  Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

      final db = await AppDB.instance.database;
      final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
      final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();

      List<String> commands = [];
      final DateFormat formatter = DateFormat('dd/MM/yy');
      commands.add('\$C,$categorySequence,${cat.name},${formatter.format(DateTime.parse(cat.startDate))},${formatter.format(DateTime.parse(cat.endDate))}#');

      final Map<String, List<PeriodModel>> periodsByDay = {};
      for (var p in periods) { (periodsByDay[p.day] ??= []).add(p); }

      String dayToCode(String day) {
        const map = {'sunday': 'U', 'monday': 'M', 'tuesday': 'T', 'wednesday': 'W', 'thursday': 'H', 'friday': 'F', 'saturday': 'S'};
        return map[day.toLowerCase()] ?? '?';
      }

      for (var entry in periodsByDay.entries) {
        final dayCode = dayToCode(entry.key);
        if (dayCode == '?') continue;
        final timeAndRingtonePairs = entry.value.map((p) => '${p.startTime},${_getRingtoneName(p.ringtone)}').join('!');
        final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
        commands.add('\$S,${fullPayload.length},$fullPayload#');
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      final bool? shouldSend = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Generated Commands for "${cat.name}"'),
          content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Text(commands.join('\n'), style: const TextStyle(fontFamily: 'monospace', fontSize: 14)))),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
          ],
        ),
      );

      if (shouldSend != true) return;

      showDialog(context: context, barrierDismissible: false, builder: (context) => const AlertDialog(title: Text('Sending Commands...'), content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")])));

      Socket? socket;
      try {
        socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
        for (final command in commands) {
          socket.writeln(command);
          await Future.delayed(const Duration(milliseconds: 50));
        }
        await socket.flush();
      } catch (e) {
        throw Exception("Failed to send commands: $e");
      } finally {
        socket?.destroy();
      }

      if (mounted) Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green));

    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      }
      messenger.showSnackBar(SnackBar(content: Text('COMMAND ERROR: $e'), backgroundColor: Colors.red));
    }
  }

  void _navigateAndRefresh() => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCategoryPage())).then((_) => _loadCategories());

  void _handleCategoryTap(CategoryModel cat) {
    if (cat.configured) {
      _openWeekSchedule(cat);
    } else {
      _openGeneralSchedule(cat);
    }
  }

  void _openGeneralSchedule(CategoryModel cat) => Navigator.push(context, MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!))).then((_) => _loadCategories());

  void _openWeekSchedule(CategoryModel cat) => Navigator.push(context, MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!))).then((_) => _loadCategories());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(icon: const Icon(Icons.wifi_tethering), tooltip: 'Check ESP32 Connection', onPressed: _checkEspConnection),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
              Text('Add a category to begin.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          final categorySequence = index + 1;
          final isUploading = _activeUploadCategoryId == cat.id;
          final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
              leading: CircleAvatar(backgroundColor: Color(cat.color), child: Text(cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Row(children: [
                Icon(cat.configured ? Icons.check_circle : Icons.pending, color: cat.configured ? Colors.green : Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(cat.configured ? "Ready to sync" : "Setup required"),
              ]),
              onTap: () => _handleCategoryTap(cat),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUploading)
                    const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()))
                  else
                    IconButton(
                      icon: Icon(Icons.music_note_outlined, color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary),
                      tooltip: 'Upload Audio Files to ESP32',
                      onPressed: cat.configured ? () => _showAudioFilesDialog(cat) : null,
                    ),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    tooltip: 'Send Commands to ESP32',
                    onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  PopupMenuButton<String>(
                    tooltip: "More Options",
                    onSelected: (value) {
                      if (value == 'edit_general') _openGeneralSchedule(cat);
                      if (value == 'delete') _deleteCategory(cat.id!);
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit_general',
                        child: ListTile(leading: Icon(Icons.edit_calendar_outlined), title: Text('Edit General')),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(leading: Icon(Icons.delete_forever_outlined, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndRefresh,
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}








