// import 'package:flutter/material.dart';
// import '../../database/app_database.dart';
// import '../../models/period_model.dart';
// import '../week/week_schedule_page.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
//
// class GeneralSchedulePage extends StatefulWidget {
//   final int categoryId;
//
//   const GeneralSchedulePage({super.key, required this.categoryId});
//
//   @override
//   State<GeneralSchedulePage> createState() => _GeneralSchedulePageState();
// }
//
// class _GeneralSchedulePageState extends State<GeneralSchedulePage> {
//   bool sundayEnabled = false;
//
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//   int periodMinutes = 60;
//
//   String? periodRingtonePath;
//   String? breakRingtonePath;
//
//   final List<_BreakData> breaks = [];
//
//   // ---------- HELPERS ----------
//   String _format(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
//
//   int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
//
//   TimeOfDay _fromMinutes(int m) =>
//       TimeOfDay(hour: m ~/ 60, minute: m % 60);
//
//   String _getFileName(String? path) {
//     if (path == null) return 'Not Selected';
//     return path.split('/').last;
//   }
//
//
//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('General Schedule')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           CheckboxListTile(
//             title: const Text('Include Sunday'),
//             value: sundayEnabled,
//             onChanged: (v) => setState(() => sundayEnabled = v ?? false),
//           ),
//
//           _timeTile('Start Time', startTime, (t) => setState(() => startTime = t)),
//           _timeTile('End Time', endTime, (t) => setState(() => endTime = t)),
//
//           const SizedBox(height: 12),
//
//           ListTile(
//             title: const Text('Period Duration (minutes)'),
//             trailing: DropdownButton<int>(
//               value: periodMinutes,
//               items: [30, 45, 60].map((e) {
//                 return DropdownMenuItem(value: e, child: Text('$e'));
//               }).toList(),
//               onChanged: (v) => setState(() => periodMinutes = v!),
//             ),
//           ),
//
//           const Divider(),
//
//           const Text('Default Ringtones', style: TextStyle(fontWeight: FontWeight.bold)),
//           _ringtoneTile(
//             'Period Ringtone',
//             periodRingtonePath,
//                 () async {
//               final path = await _pickRingtone();
//               if (path != null) {
//                 setState(() => periodRingtonePath = path);
//                 // Here you can also add logic to send the ringtone to ESP immediately if needed
//               }
//             },
//           ),
//           _ringtoneTile(
//             'Break Ringtone',
//             breakRingtonePath,
//                 () async {
//               final path = await _pickRingtone();
//               if (path != null) {
//                 setState(() => breakRingtonePath = path);
//               }
//             },
//           ),
//
//           const Divider(),
//
//           const Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold)),
//
//           ...breaks.map((b) => ListTile(
//             title: Text('Break at ${_format(b.start)}'),
//             subtitle: Text('${b.duration} min'),
//           )),
//
//           TextButton.icon(
//             icon: const Icon(Icons.add),
//             label: const Text('Add Break'),
//             onPressed: _addBreakDialog,
//           ),
//
//           const SizedBox(height: 24),
//
//           ElevatedButton(
//             onPressed: _saveAndGenerate,
//             child: const Text('GENERATE WEEK SCHEDULE'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------- TIME TILE ----------
//   Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
//     return ListTile(
//       title: Text(title),
//       trailing: Text(value == null ? '--:--' : _format(value)),
//       onTap: () async {
//         final t = await showTimePicker(
//           context: context,
//           initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
//         );
//         if (t != null) onPick(t);
//       },
//     );
//   }
//   // ---------- NEW WIDGET: RINGTONE TILE ----------
//   Widget _ringtoneTile(String title, String? filePath, VoidCallback onPick) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(
//         _getFileName(filePath),
//         style: const TextStyle(color: Colors.grey, fontSize: 12),
//         overflow: TextOverflow.ellipsis,
//       ),
//       trailing: const Icon(Icons.music_note),
//       onTap: onPick,
//     );
//   }
//
//   // ---------- NEW METHOD: PICK RINGTONE ----------
//   Future<String?> _pickRingtone() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.audio,
//       );
//       if (result != null && result.files.single.path != null) {
//         File file = File(result.files.single.path!);
//         // You would have your logic to send the file to the ESP here.
//         // For now, we just return the path to be stored in the database.
//         print('Selected file path: ${file.path}');
//         return file.path;
//       }
//     } catch (e) {
//       // Handle exceptions from file picking
//       print('Error picking file: $e');
//     }
//     return null;
//   }
//
//   // ---------- ADD BREAK ----------
//   void _addBreakDialog() async {
//     TimeOfDay? s;
//     int d = 30;
//
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add Break'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: const Text('Start Time'),
//               trailing: Text(s == null ? '--:--' : _format(s!)),
//               onTap: () async {
//                 s = await showTimePicker(
//                   context: context,
//                   initialTime: const TimeOfDay(hour: 13, minute: 0),
//                 );
//                 setState(() {});
//               },
//             ),
//             DropdownButton<int>(
//               value: d,
//               items: [15, 30, 45, 60].map((e) {
//                 return DropdownMenuItem(value: e, child: Text('$e min'));
//               }).toList(),
//               onChanged: (v) => d = v!,
//             )
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: const Text('ADD'),
//             onPressed: () {
//               if (s != null) {
//                 breaks.add(_BreakData(start: s!, duration: d));
//               }
//               Navigator.pop(context);
//               setState(() {});
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   // ---------- SAVE & GENERATE ----------
//   Future<void> _saveAndGenerate() async {
//     if (startTime == null || endTime == null) return;
//
//     final db = await AppDB.instance.database;
//
//     final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
//     if (sundayEnabled) days.add('SUNDAY');
//
//     for (final day in days) {
//       int current = _toMinutes(startTime!);
//       final end = _toMinutes(endTime!);
//
//       final breakMap = {
//         for (var b in breaks) _toMinutes(b.start): b.duration
//       };
//
//       int periodCount = 1;
//
//       while (current + periodMinutes <= end) {
//         if (breakMap.containsKey(current)) {
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Break',
//               startTime: _format(_fromMinutes(current)),
//               endTime: _format(_fromMinutes(current + breakMap[current]!)),
//               isBreak: true,
//               ringtone: breakRingtonePath,
//             ).toMap(),
//           );
//           current += breakMap[current]!;
//         } else {
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Period $periodCount',
//               startTime: _format(_fromMinutes(current)),
//               endTime: _format(_fromMinutes(current + periodMinutes)),
//               isBreak: false,
//               ringtone: periodRingtonePath,
//             ).toMap(),
//           );
//           current += periodMinutes;
//           periodCount++;
//         }
//       }
//     }
//
//     // Mark category as configured
//     await db.update(
//       'categories',
//       {'configured': 1},
//       where: 'id = ?',
//       whereArgs: [widget.categoryId],
//     );
//
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => WeekSchedulePage(categoryId: widget.categoryId),
//         ),
//       );
//     }
//   }
// }
//
// // ---------- BREAK DATA CLASS ----------
// class _BreakData {
//   final TimeOfDay start;
//   final int duration;
//
//   _BreakData({required this.start, required this.duration});
// }





import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/period_model.dart';
import '../week/week_schedule_page.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class GeneralSchedulePage extends StatefulWidget {
  final int categoryId;

  const GeneralSchedulePage({super.key, required this.categoryId});

  @override
  State<GeneralSchedulePage> createState() => _GeneralSchedulePageState();
}

class _GeneralSchedulePageState extends State<GeneralSchedulePage> {
  bool sundayEnabled = false;

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int periodMinutes = 60;

  String? periodRingtonePath;
  String? breakRingtonePath;

  final List<_BreakData> breaks = [];

  // ---------- HELPERS ----------
  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _fromMinutes(int m) =>
      TimeOfDay(hour: m ~/ 60, minute: m % 60);

  String _getFileName(String? path) {
    if (path == null) return 'Not Selected';
    return path.split('/').last;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Schedule')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // --- Schedule Time & Days ---
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _timeTile('Start Time', startTime, (t) => setState(() => startTime = t)),
                _timeTile('End Time', endTime, (t) => setState(() => endTime = t)),
                CheckboxListTile(
                  title: const Text('Include Sunday'),
                  value: sundayEnabled,
                  onChanged: (v) => setState(() => sundayEnabled = v ?? false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- Period Duration ---
          Card(
            child: ListTile(
              title: const Text('Period Duration'),
              trailing: DropdownButton<int>(
                value: periodMinutes,
                underline: const SizedBox.shrink(),
                items: [30, 45, 60].map((e) {
                  return DropdownMenuItem(value: e, child: Text('$e min'));
                }).toList(),
                onChanged: (v) => setState(() => periodMinutes = v!),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Ringtones ---
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Default Ringtones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _ringtoneTile('Period Ringtone', periodRingtonePath, () async {
                  final path = await _pickRingtone();
                  if (path != null) setState(() => periodRingtonePath = path);
                }),
                _ringtoneTile('Break Ringtone', breakRingtonePath, () async {
                  final path = await _pickRingtone();
                  if (path != null) setState(() => breakRingtonePath = path);
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- Breaks ---
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (breaks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(child: Text('No breaks added yet.', style: TextStyle(color: Colors.grey))),
                  ),
                ...breaks.map((b) => ListTile(
                  title: Text('Break at ${_format(b.start)}'),
                  subtitle: Text('Duration: ${b.duration} minutes'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => setState(() => breaks.remove(b)),
                  ),
                )),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Break'),
                    onPressed: _addBreakDialog,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: _saveAndGenerate,
            child: const Text('GENERATE WEEK SCHEDULE'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ---------- TIME TILE ----------
  Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
    return ListTile(
      title: Text(title),
      trailing: Text(value == null ? 'Not Set' : _format(value), style: Theme.of(context).textTheme.titleMedium),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (t != null) onPick(t);
      },
    );
  }

  // ---------- RINGTONE TILE ----------
  Widget _ringtoneTile(String title, String? filePath, VoidCallback onPick) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        _getFileName(filePath),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.music_note_outlined),
      onTap: onPick,
    );
  }

  // ---------- PICK RINGTONE ----------
  Future<String?> _pickRingtone() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
    return null;
  }

  // ---------- ADD BREAK DIALOG ----------
  void _addBreakDialog() async {
    TimeOfDay? breakStartTime;
    int breakDuration = 30;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Break'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Start Time'),
                    trailing: Text(breakStartTime == null ? 'Not Set' : _format(breakStartTime!)),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 13, minute: 0),
                      );
                      if (pickedTime != null) {
                        setDialogState(() => breakStartTime = pickedTime);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("Duration"),
                    trailing: DropdownButton<int>(
                      value: breakDuration,
                      items: [15, 30, 45, 60].map((e) {
                        return DropdownMenuItem(value: e, child: Text('$e min'));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => breakDuration = v!),
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(child: const Text('CANCEL'), onPressed: () => Navigator.pop(context)),
                TextButton(
                  child: const Text('ADD'),
                  onPressed: () {
                    if (breakStartTime != null) {
                      setState(() {
                        breaks.add(_BreakData(start: breakStartTime!, duration: breakDuration));
                        // Sort breaks by start time
                        breaks.sort((a, b) => _toMinutes(a.start).compareTo(_toMinutes(b.start)));
                      });
                    }
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  // ---------- SAVE & GENERATE ----------
  Future<void> _saveAndGenerate() async {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start and end time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final db = await AppDB.instance.database;

    // Clear previous schedule for this category
    await db.delete('periods', where: 'categoryId = ?', whereArgs: [widget.categoryId]);

    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    if (sundayEnabled) days.add('SUNDAY');

    for (final day in days) {
      int current = _toMinutes(startTime!);
      final end = _toMinutes(endTime!);

      final breakMap = { for (var b in breaks) _toMinutes(b.start): b.duration };
      int periodCount = 1;

      while (current < end) {
        if (breakMap.containsKey(current)) {
          final breakDuration = breakMap[current]!;
          if (current + breakDuration > end) break; // Avoid break exceeding end time
          await db.insert('periods', PeriodModel(
            categoryId: widget.categoryId,
            day: day,
            title: 'Break',
            startTime: _format(_fromMinutes(current)),
            endTime: _format(_fromMinutes(current + breakDuration)),
            isBreak: true,
            ringtone: breakRingtonePath,
          ).toMap());
          current += breakDuration;
        } else {
          if (current + periodMinutes > end) break; // Avoid period exceeding end time
          await db.insert('periods', PeriodModel(
            categoryId: widget.categoryId,
            day: day,
            title: 'Period $periodCount',
            startTime: _format(_fromMinutes(current)),
            endTime: _format(_fromMinutes(current + periodMinutes)),
            isBreak: false,
            ringtone: periodRingtonePath,
          ).toMap());
          current += periodMinutes;
          periodCount++;
        }
      }
    }

    // Mark category as configured
    await db.update('categories', {'configured': 1}, where: 'id = ?', whereArgs: [widget.categoryId]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule generated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: widget.categoryId)),
      );
    }
  }
}

// ---------- BREAK DATA CLASS ----------
class _BreakData {
  final TimeOfDay start;
  final int duration;

  _BreakData({required this.start, required this.duration});
}
