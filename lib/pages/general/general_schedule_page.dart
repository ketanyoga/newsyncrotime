// // // import 'package:flutter/material.dart';
// // // import '../../database/app_database.dart';
// // // import '../../models/period_model.dart';
// // // import '../week/week_schedule_page.dart';
// // // import 'package:file_picker/file_picker.dart';
// // // import 'dart:io';
// // //
// // // class GeneralSchedulePage extends StatefulWidget {
// // //   final int categoryId;
// // //
// // //   const GeneralSchedulePage({super.key, required this.categoryId});
// // //
// // //   @override
// // //   State<GeneralSchedulePage> createState() => _GeneralSchedulePageState();
// // // }
// // //
// // // class _GeneralSchedulePageState extends State<GeneralSchedulePage> {
// // //   bool sundayEnabled = false;
// // //
// // //   TimeOfDay? startTime;
// // //   TimeOfDay? endTime;
// // //   int periodMinutes = 60;
// // //
// // //   String? periodRingtonePath;
// // //   String? breakRingtonePath;
// // //
// // //   final List<_BreakData> breaks = [];
// // //
// // //   // ---------- HELPERS ----------
// // //   String _format(TimeOfDay t) =>
// // //       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
// // //
// // //   int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
// // //
// // //   TimeOfDay _fromMinutes(int m) =>
// // //       TimeOfDay(hour: m ~/ 60, minute: m % 60);
// // //
// // //   String _getFileName(String? path) {
// // //     if (path == null) return 'Not Selected';
// // //     return path.split('/').last;
// // //   }
// // //
// // //
// // //   // ---------- UI ----------
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('General Schedule')),
// // //       body: ListView(
// // //         padding: const EdgeInsets.all(16),
// // //         children: [
// // //           CheckboxListTile(
// // //             title: const Text('Include Sunday'),
// // //             value: sundayEnabled,
// // //             onChanged: (v) => setState(() => sundayEnabled = v ?? false),
// // //           ),
// // //
// // //           _timeTile('Start Time', startTime, (t) => setState(() => startTime = t)),
// // //           _timeTile('End Time', endTime, (t) => setState(() => endTime = t)),
// // //
// // //           const SizedBox(height: 12),
// // //
// // //           ListTile(
// // //             title: const Text('Period Duration (minutes)'),
// // //             trailing: DropdownButton<int>(
// // //               value: periodMinutes,
// // //               items: [30, 45, 60].map((e) {
// // //                 return DropdownMenuItem(value: e, child: Text('$e'));
// // //               }).toList(),
// // //               onChanged: (v) => setState(() => periodMinutes = v!),
// // //             ),
// // //           ),
// // //
// // //           const Divider(),
// // //
// // //           const Text('Default Ringtones', style: TextStyle(fontWeight: FontWeight.bold)),
// // //           _ringtoneTile(
// // //             'Period Ringtone',
// // //             periodRingtonePath,
// // //                 () async {
// // //               final path = await _pickRingtone();
// // //               if (path != null) {
// // //                 setState(() => periodRingtonePath = path);
// // //                 // Here you can also add logic to send the ringtone to ESP immediately if needed
// // //               }
// // //             },
// // //           ),
// // //           _ringtoneTile(
// // //             'Break Ringtone',
// // //             breakRingtonePath,
// // //                 () async {
// // //               final path = await _pickRingtone();
// // //               if (path != null) {
// // //                 setState(() => breakRingtonePath = path);
// // //               }
// // //             },
// // //           ),
// // //
// // //           const Divider(),
// // //
// // //           const Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold)),
// // //
// // //           ...breaks.map((b) => ListTile(
// // //             title: Text('Break at ${_format(b.start)}'),
// // //             subtitle: Text('${b.duration} min'),
// // //           )),
// // //
// // //           TextButton.icon(
// // //             icon: const Icon(Icons.add),
// // //             label: const Text('Add Break'),
// // //             onPressed: _addBreakDialog,
// // //           ),
// // //
// // //           const SizedBox(height: 24),
// // //
// // //           ElevatedButton(
// // //             onPressed: _saveAndGenerate,
// // //             child: const Text('GENERATE WEEK SCHEDULE'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ---------- TIME TILE ----------
// // //   Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
// // //     return ListTile(
// // //       title: Text(title),
// // //       trailing: Text(value == null ? '--:--' : _format(value)),
// // //       onTap: () async {
// // //         final t = await showTimePicker(
// // //           context: context,
// // //           initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
// // //         );
// // //         if (t != null) onPick(t);
// // //       },
// // //     );
// // //   }
// // //   // ---------- NEW WIDGET: RINGTONE TILE ----------
// // //   Widget _ringtoneTile(String title, String? filePath, VoidCallback onPick) {
// // //     return ListTile(
// // //       title: Text(title),
// // //       subtitle: Text(
// // //         _getFileName(filePath),
// // //         style: const TextStyle(color: Colors.grey, fontSize: 12),
// // //         overflow: TextOverflow.ellipsis,
// // //       ),
// // //       trailing: const Icon(Icons.music_note),
// // //       onTap: onPick,
// // //     );
// // //   }
// // //
// // //   // ---------- NEW METHOD: PICK RINGTONE ----------
// // //   Future<String?> _pickRingtone() async {
// // //     try {
// // //       FilePickerResult? result = await FilePicker.platform.pickFiles(
// // //         type: FileType.audio,
// // //       );
// // //       if (result != null && result.files.single.path != null) {
// // //         File file = File(result.files.single.path!);
// // //         // You would have your logic to send the file to the ESP here.
// // //         // For now, we just return the path to be stored in the database.
// // //         print('Selected file path: ${file.path}');
// // //         return file.path;
// // //       }
// // //     } catch (e) {
// // //       // Handle exceptions from file picking
// // //       print('Error picking file: $e');
// // //     }
// // //     return null;
// // //   }
// // //
// // //   // ---------- ADD BREAK ----------
// // //   void _addBreakDialog() async {
// // //     TimeOfDay? s;
// // //     int d = 30;
// // //
// // //     await showDialog(
// // //       context: context,
// // //       builder: (_) => AlertDialog(
// // //         title: const Text('Add Break'),
// // //         content: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             ListTile(
// // //               title: const Text('Start Time'),
// // //               trailing: Text(s == null ? '--:--' : _format(s!)),
// // //               onTap: () async {
// // //                 s = await showTimePicker(
// // //                   context: context,
// // //                   initialTime: const TimeOfDay(hour: 13, minute: 0),
// // //                 );
// // //                 setState(() {});
// // //               },
// // //             ),
// // //             DropdownButton<int>(
// // //               value: d,
// // //               items: [15, 30, 45, 60].map((e) {
// // //                 return DropdownMenuItem(value: e, child: Text('$e min'));
// // //               }).toList(),
// // //               onChanged: (v) => d = v!,
// // //             )
// // //           ],
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             child: const Text('ADD'),
// // //             onPressed: () {
// // //               if (s != null) {
// // //                 breaks.add(_BreakData(start: s!, duration: d));
// // //               }
// // //               Navigator.pop(context);
// // //               setState(() {});
// // //             },
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ---------- SAVE & GENERATE ----------
// // //   Future<void> _saveAndGenerate() async {
// // //     if (startTime == null || endTime == null) return;
// // //
// // //     final db = await AppDB.instance.database;
// // //
// // //     final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
// // //     if (sundayEnabled) days.add('SUNDAY');
// // //
// // //     for (final day in days) {
// // //       int current = _toMinutes(startTime!);
// // //       final end = _toMinutes(endTime!);
// // //
// // //       final breakMap = {
// // //         for (var b in breaks) _toMinutes(b.start): b.duration
// // //       };
// // //
// // //       int periodCount = 1;
// // //
// // //       while (current + periodMinutes <= end) {
// // //         if (breakMap.containsKey(current)) {
// // //           await db.insert(
// // //             'periods',
// // //             PeriodModel(
// // //               categoryId: widget.categoryId,
// // //               day: day,
// // //               title: 'Break',
// // //               startTime: _format(_fromMinutes(current)),
// // //               endTime: _format(_fromMinutes(current + breakMap[current]!)),
// // //               isBreak: true,
// // //               ringtone: breakRingtonePath,
// // //             ).toMap(),
// // //           );
// // //           current += breakMap[current]!;
// // //         } else {
// // //           await db.insert(
// // //             'periods',
// // //             PeriodModel(
// // //               categoryId: widget.categoryId,
// // //               day: day,
// // //               title: 'Period $periodCount',
// // //               startTime: _format(_fromMinutes(current)),
// // //               endTime: _format(_fromMinutes(current + periodMinutes)),
// // //               isBreak: false,
// // //               ringtone: periodRingtonePath,
// // //             ).toMap(),
// // //           );
// // //           current += periodMinutes;
// // //           periodCount++;
// // //         }
// // //       }
// // //     }
// // //
// // //     // Mark category as configured
// // //     await db.update(
// // //       'categories',
// // //       {'configured': 1},
// // //       where: 'id = ?',
// // //       whereArgs: [widget.categoryId],
// // //     );
// // //
// // //     if (mounted) {
// // //       Navigator.pushReplacement(
// // //         context,
// // //         MaterialPageRoute(
// // //           builder: (_) => WeekSchedulePage(categoryId: widget.categoryId),
// // //         ),
// // //       );
// // //     }
// // //   }
// // // }
// // //
// // // // ---------- BREAK DATA CLASS ----------
// // // class _BreakData {
// // //   final TimeOfDay start;
// // //   final int duration;
// // //
// // //   _BreakData({required this.start, required this.duration});
// // // }
// //
// //
// //
// //
// //
// // import 'package:flutter/material.dart';
// // import '../../database/app_database.dart';
// // import '../../models/period_model.dart';
// // import '../week/week_schedule_page.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'dart:io';
// //
// // class GeneralSchedulePage extends StatefulWidget {
// //   final int categoryId;
// //
// //   const GeneralSchedulePage({super.key, required this.categoryId});
// //
// //   @override
// //   State<GeneralSchedulePage> createState() => _GeneralSchedulePageState();
// // }
// //
// // class _GeneralSchedulePageState extends State<GeneralSchedulePage> {
// //   bool sundayEnabled = false;
// //
// //   TimeOfDay? startTime;
// //   TimeOfDay? endTime;
// //   int periodMinutes = 60;
// //
// //   String? periodRingtonePath;
// //   String? breakRingtonePath;
// //
// //   final List<_BreakData> breaks = [];
// //
// //   // ---------- HELPERS ----------
// //   String _format(TimeOfDay t) =>
// //       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
// //
// //   int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
// //
// //   TimeOfDay _fromMinutes(int m) =>
// //       TimeOfDay(hour: m ~/ 60, minute: m % 60);
// //
// //   String _getFileName(String? path) {
// //     if (path == null) return 'Not Selected';
// //     return path.split('/').last;
// //   }
// //
// //   // ---------- UI ----------
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('General Schedule')),
// //       body: ListView(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //         children: [
// //           // --- Schedule Time & Days ---
// //           Card(
// //             clipBehavior: Clip.antiAlias,
// //             child: Column(
// //               children: [
// //                 _timeTile('Start Time', startTime, (t) => setState(() => startTime = t)),
// //                 _timeTile('End Time', endTime, (t) => setState(() => endTime = t)),
// //                 CheckboxListTile(
// //                   title: const Text('Include Sunday'),
// //                   value: sundayEnabled,
// //                   onChanged: (v) => setState(() => sundayEnabled = v ?? false),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //
// //           // --- Period Duration ---
// //           Card(
// //             child: ListTile(
// //               title: const Text('Period Duration'),
// //               trailing: DropdownButton<int>(
// //                 value: periodMinutes,
// //                 underline: const SizedBox.shrink(),
// //                 items: [30, 45, 60].map((e) {
// //                   return DropdownMenuItem(value: e, child: Text('$e min'));
// //                 }).toList(),
// //                 onChanged: (v) => setState(() => periodMinutes = v!),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //
// //           // --- Ringtones ---
// //           Card(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Padding(
// //                   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
// //                   child: Text('Default Ringtones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //                 _ringtoneTile('Period Ringtone', periodRingtonePath, () async {
// //                   final path = await _pickRingtone();
// //                   if (path != null) setState(() => periodRingtonePath = path);
// //                 }),
// //                 _ringtoneTile('Break Ringtone', breakRingtonePath, () async {
// //                   final path = await _pickRingtone();
// //                   if (path != null) setState(() => breakRingtonePath = path);
// //                 }),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //
// //           // --- Breaks ---
// //           Card(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Padding(
// //                   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
// //                   child: Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //                 if (breaks.isEmpty)
// //                   const Padding(
// //                     padding: EdgeInsets.only(bottom: 16.0),
// //                     child: Center(child: Text('No breaks added yet.', style: TextStyle(color: Colors.grey))),
// //                   ),
// //                 ...breaks.map((b) => ListTile(
// //                   title: Text('Break at ${_format(b.start)}'),
// //                   subtitle: Text('Duration: ${b.duration} minutes'),
// //                   trailing: IconButton(
// //                     icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
// //                     onPressed: () => setState(() => breaks.remove(b)),
// //                   ),
// //                 )),
// //                 Center(
// //                   child: TextButton.icon(
// //                     icon: const Icon(Icons.add),
// //                     label: const Text('Add Break'),
// //                     onPressed: _addBreakDialog,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           const SizedBox(height: 24),
// //
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(
// //               padding: const EdgeInsets.symmetric(vertical: 16),
// //               textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             onPressed: _saveAndGenerate,
// //             child: const Text('GENERATE WEEK SCHEDULE'),
// //           ),
// //           const SizedBox(height: 8),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ---------- TIME TILE ----------
// //   Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
// //     return ListTile(
// //       title: Text(title),
// //       trailing: Text(value == null ? 'Not Set' : _format(value), style: Theme.of(context).textTheme.titleMedium),
// //       onTap: () async {
// //         final t = await showTimePicker(
// //           context: context,
// //           initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
// //         );
// //         if (t != null) onPick(t);
// //       },
// //     );
// //   }
// //
// //   // ---------- RINGTONE TILE ----------
// //   Widget _ringtoneTile(String title, String? filePath, VoidCallback onPick) {
// //     return ListTile(
// //       title: Text(title),
// //       subtitle: Text(
// //         _getFileName(filePath),
// //         style: const TextStyle(color: Colors.grey, fontSize: 12),
// //         overflow: TextOverflow.ellipsis,
// //       ),
// //       trailing: const Icon(Icons.music_note_outlined),
// //       onTap: onPick,
// //     );
// //   }
// //
// //   // ---------- PICK RINGTONE ----------
// //   Future<String?> _pickRingtone() async {
// //     try {
// //       FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
// //       if (result != null && result.files.single.path != null) {
// //         return result.files.single.path;
// //       }
// //     } catch (e) {
// //       print('Error picking file: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error picking file: $e')),
// //         );
// //       }
// //     }
// //     return null;
// //   }
// //
// //   // ---------- ADD BREAK DIALOG ----------
// //   void _addBreakDialog() async {
// //     TimeOfDay? breakStartTime;
// //     int breakDuration = 30;
// //
// //     await showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return StatefulBuilder(
// //           builder: (context, setDialogState) {
// //             return AlertDialog(
// //               title: const Text('Add Break'),
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   ListTile(
// //                     title: const Text('Start Time'),
// //                     trailing: Text(breakStartTime == null ? 'Not Set' : _format(breakStartTime!)),
// //                     onTap: () async {
// //                       final pickedTime = await showTimePicker(
// //                         context: context,
// //                         initialTime: const TimeOfDay(hour: 13, minute: 0),
// //                       );
// //                       if (pickedTime != null) {
// //                         setDialogState(() => breakStartTime = pickedTime);
// //                       }
// //                     },
// //                   ),
// //                   ListTile(
// //                     title: const Text("Duration"),
// //                     trailing: DropdownButton<int>(
// //                       value: breakDuration,
// //                       items: [15, 30, 45, 60].map((e) {
// //                         return DropdownMenuItem(value: e, child: Text('$e min'));
// //                       }).toList(),
// //                       onChanged: (v) => setDialogState(() => breakDuration = v!),
// //                     ),
// //                   )
// //                 ],
// //               ),
// //               actions: [
// //                 TextButton(child: const Text('CANCEL'), onPressed: () => Navigator.pop(context)),
// //                 TextButton(
// //                   child: const Text('ADD'),
// //                   onPressed: () {
// //                     if (breakStartTime != null) {
// //                       setState(() {
// //                         breaks.add(_BreakData(start: breakStartTime!, duration: breakDuration));
// //                         // Sort breaks by start time
// //                         breaks.sort((a, b) => _toMinutes(a.start).compareTo(_toMinutes(b.start)));
// //                       });
// //                     }
// //                     Navigator.pop(context);
// //                   },
// //                 )
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   // ---------- SAVE & GENERATE ----------
// //   Future<void> _saveAndGenerate() async {
// //     if (startTime == null || endTime == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please select a start and end time.'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }
// //
// //     final db = await AppDB.instance.database;
// //
// //     // Clear previous schedule for this category
// //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [widget.categoryId]);
// //
// //     final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
// //     if (sundayEnabled) days.add('SUNDAY');
// //
// //     for (final day in days) {
// //       int current = _toMinutes(startTime!);
// //       final end = _toMinutes(endTime!);
// //
// //       final breakMap = { for (var b in breaks) _toMinutes(b.start): b.duration };
// //       int periodCount = 1;
// //
// //       while (current < end) {
// //         if (breakMap.containsKey(current)) {
// //           final breakDuration = breakMap[current]!;
// //           if (current + breakDuration > end) break; // Avoid break exceeding end time
// //           await db.insert('periods', PeriodModel(
// //             categoryId: widget.categoryId,
// //             day: day,
// //             title: 'Break',
// //             startTime: _format(_fromMinutes(current)),
// //             endTime: _format(_fromMinutes(current + breakDuration)),
// //             isBreak: true,
// //             ringtone: breakRingtonePath,
// //           ).toMap());
// //           current += breakDuration;
// //         } else {
// //           if (current + periodMinutes > end) break; // Avoid period exceeding end time
// //           await db.insert('periods', PeriodModel(
// //             categoryId: widget.categoryId,
// //             day: day,
// //             title: 'Period $periodCount',
// //             startTime: _format(_fromMinutes(current)),
// //             endTime: _format(_fromMinutes(current + periodMinutes)),
// //             isBreak: false,
// //             ringtone: periodRingtonePath,
// //           ).toMap());
// //           current += periodMinutes;
// //           periodCount++;
// //         }
// //       }
// //     }
// //
// //     // Mark category as configured
// //     await db.update('categories', {'configured': 1}, where: 'id = ?', whereArgs: [widget.categoryId]);
// //
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Schedule generated successfully!'), backgroundColor: Colors.green),
// //       );
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: widget.categoryId)),
// //       );
// //     }
// //   }
// // }
// //
// // // ---------- BREAK DATA CLASS ----------
// // class _BreakData {
// //   final TimeOfDay start;
// //   final int duration;
// //
// //   _BreakData({required this.start, required this.duration});
// // }
//
//
//
//
//
//
//
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
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
//   // --- STATE VARIABLES ---
//   bool _isLoading = true; // Used to show a loading indicator
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
//   // ---------- LIFECYCLE METHODS ----------
//   @override
//   void initState() {
//     super.initState();
//     _loadExistingSchedule();
//   }
//
//   // ---------- DATABASE & DATA HANDLING ----------
//
//   /// Parses a time string 'HH:mm' into a TimeOfDay object.
//   TimeOfDay? _parseTime(String? timeString) {
//     if (timeString == null) return null;
//     final parts = timeString.split(':');
//     if (parts.length == 2) {
//       return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
//     }
//     return null;
//   }
//
//   /// Fetches the schedule details for the current categoryId from the database.
//   Future<void> _loadExistingSchedule() async {
//     try {
//       final db = await AppDB.instance.database;
//       final List<Map<String, dynamic>> periods = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [widget.categoryId],
//         orderBy: 'startTime ASC',
//       );
//
//       if (periods.isEmpty) {
//         // No existing data, remain in the "new entry" state.
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // Use a Set to find unique break times and durations.
//       final Set<_BreakData> uniqueBreaks = {};
//       String? firstPeriodRingtone;
//       String? firstBreakRingtone;
//
//       TimeOfDay? minTime;
//       TimeOfDay? maxTime;
//
//       for (var p in periods) {
//         final period = PeriodModel.fromMap(p);
//         final sTime = _parseTime(period.startTime)!;
//         final eTime = _parseTime(period.endTime)!;
//
//         if (period.isBreak) {
//           firstBreakRingtone ??= period.ringtone;
//           final duration = (_toMinutes(eTime) - _toMinutes(sTime));
//           uniqueBreaks.add(_BreakData(start: sTime, duration: duration));
//         } else {
//           firstPeriodRingtone ??= period.ringtone;
//           periodMinutes = (_toMinutes(eTime) - _toMinutes(sTime));
//         }
//
//         // Determine the overall start and end times for the day
//         if (minTime == null || _toMinutes(sTime) < _toMinutes(minTime!)) {
//           minTime = sTime;
//         }
//         if (maxTime == null || _toMinutes(eTime) > _toMinutes(maxTime!)) {
//           maxTime = eTime;
//         }
//
//         if (period.day.toUpperCase() == 'SUNDAY') {
//           sundayEnabled = true;
//         }
//       }
//
//       // Update the state with the loaded data
//       setState(() {
//         startTime = minTime;
//         endTime = maxTime;
//         periodRingtonePath = firstPeriodRingtone;
//         breakRingtonePath = firstBreakRingtone;
//         breaks.addAll(uniqueBreaks.toList());
//         _isLoading = false; // Stop loading
//       });
//
//     } catch (e) {
//       // In a real app, you might want to show a more user-friendly error.
//       debugPrint("Error loading schedule: $e");
//       setState(() => _isLoading = false); // Stop loading on error
//     }
//   }
//
//   // ---------- HELPERS ----------
//   String _format(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
//
//   int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
//
//   TimeOfDay _fromMinutes(int m) =>
//       TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);
//
//   String _getFileName(String? path) {
//     if (path == null || path.isEmpty) return 'Not Selected';
//     try {
//       return path.split(Platform.pathSeparator).last;
//     } catch (_) {
//       return path;
//     }
//   }
//
//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('General Schedule')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator()) // Show loading UI
//           : ListView(
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
//             trailing: IconButton(
//               icon: Icon(Icons.delete, color: Colors.red[300]),
//               onPressed: () {
//                 setState(() => breaks.remove(b));
//               },
//             ),
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
//   // ---------- WIDGETS & DIALOGS (Missing Methods) ----------
//
//   /// A reusable widget for picking a time.
//   Widget _timeTile(String title, TimeOfDay? time, Function(TimeOfDay) onTimeChanged) {
//     return ListTile(
//       title: Text(title),
//       trailing: Text(time?.format(context) ?? 'Not Set'),
//       onTap: () async {
//         final selectedTime = await showTimePicker(
//           context: context,
//           initialTime: time ?? TimeOfDay.now(),
//         );
//         if (selectedTime != null) {
//           onTimeChanged(selectedTime);
//         }
//       },
//     );
//   }
//
//   /// A reusable widget for showing the selected ringtone.
//   Widget _ringtoneTile(String title, String? filePath, VoidCallback onPressed) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(
//         _getFileName(filePath),
//         style: const TextStyle(color: Colors.grey),
//         overflow: TextOverflow.ellipsis,
//       ),
//       onTap: onPressed,
//     );
//   }
//
//   /// A helper that uses file_picker to select an audio file.
//   Future<String?> _pickRingtone() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.audio,
//       );
//
//       if (result != null && result.files.single.path != null) {
//         return result.files.single.path;
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error picking file: $e')),
//         );
//       }
//     }
//     return null;
//   }
//
//   /// Shows a dialog to add a new break.
//   Future<void> _addBreakDialog() async {
//     TimeOfDay? breakStart;
//     int breakDuration = 15; // Default break duration
//
//     await showDialog(
//       context: context,
//       // Use a StatefulWidget builder to manage the dialog's own state
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text('Add Break'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     title: const Text('Break Start Time'),
//                     trailing: Text(breakStart?.format(context) ?? 'Select Time'),
//                     onTap: () async {
//                       final time = await showTimePicker(
//                         context: context,
//                         initialTime: breakStart ?? TimeOfDay.now(),
//                       );
//                       if (time != null) {
//                         setDialogState(() {
//                           breakStart = time;
//                         });
//                       }
//                     },
//                   ),
//                   ListTile(
//                     title: const Text('Duration (minutes)'),
//                     trailing: DropdownButton<int>(
//                       value: breakDuration,
//                       items: [5, 10, 15, 20, 30].map((e) {
//                         return DropdownMenuItem(value: e, child: Text('$e'));
//                       }).toList(),
//                       onChanged: (v) {
//                         setDialogState(() {
//                           breakDuration = v!;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (breakStart != null) {
//                       setState(() {
//                         breaks.add(_BreakData(start: breakStart!, duration: breakDuration));
//                         // Sort breaks by start time to keep them in order
//                         breaks.sort((a, b) => _toMinutes(a.start).compareTo(_toMinutes(b.start)));
//                       });
//                       Navigator.of(context).pop();
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Please select a start time for the break.')),
//                       );
//                     }
//                   },
//                   child: const Text('Add'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // ---------- SAVE & GENERATE ----------
//   Future<void> _saveAndGenerate() async {
//     if (startTime == null || endTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a start and end time.')),
//       );
//       return;
//     }
//
//     final db = await AppDB.instance.database;
//
//     // Clear old periods for this category before inserting new ones
//     await db.delete('periods', where: 'categoryId = ?', whereArgs: [widget.categoryId]);
//
//     final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
//     if (sundayEnabled) days.add('SUNDAY');
//
//     for (final day in days) {
//       int current = _toMinutes(startTime!);
//       final end = _toMinutes(endTime!);
//
//       final breakMap = {for (var b in breaks) _toMinutes(b.start): b.duration};
//
//       int periodCount = 1;
//
//       while (current < end) {
//         if (breakMap.containsKey(current)) {
//           final breakDuration = breakMap[current]!;
//           final breakEndTime = (current + breakDuration > end) ? end : current + breakDuration;
//
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Break',
//               startTime: _format(_fromMinutes(current)),
//               endTime: _format(_fromMinutes(breakEndTime)),
//               isBreak: true,
//               ringtone: breakRingtonePath,
//             ).toMap(),
//             conflictAlgorithm: ConflictAlgorithm.replace,
//           );
//           current = breakEndTime;
//         } else {
//           final periodEndTime = (current + periodMinutes > end) ? end : current + periodMinutes;
//           if (periodEndTime <= current) break; // Avoid infinite loops if period is 0
//
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Period $periodCount',
//               startTime: _format(_fromMinutes(current)),
//               endTime: _format(_fromMinutes(periodEndTime)),
//               isBreak: false,
//               ringtone: periodRingtonePath,
//             ).toMap(),
//             conflictAlgorithm: ConflictAlgorithm.replace,
//           );
//           current = periodEndTime;
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
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Schedule generated successfully!'), backgroundColor: Colors.green),
//       );
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
// // Using '==' and 'hashCode' is crucial for using this class in a Set.
// class _BreakData {
//   final TimeOfDay start;
//   final int duration;
//
//   _BreakData({required this.start, required this.duration});
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is _BreakData &&
//               runtimeType == other.runtimeType &&
//               start.hour == other.start.hour &&
//               start.minute == other.start.minute &&
//               duration == other.duration;
//
//   @override
//   int get hashCode => start.hour.hashCode ^ start.minute.hashCode ^ duration.hashCode;
// }
















//
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
//   bool isLoading = true; // To show a loading indicator
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
//   @override
//   void initState() {
//     super.initState();
//     _loadExistingSchedule();
//   }
//
//   // ---------- NEW: LOAD EXISTING DATA ----------
//   Future<void> _loadExistingSchedule() async {
//     final db = await AppDB.instance.database;
//     final existingPeriods = await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [widget.categoryId],
//       orderBy: 'startTime ASC',
//       limit: 100, // Limit to avoid fetching too much data
//     );
//
//     if (existingPeriods.isNotEmpty) {
//       // Use the data from the first day (e.g., MONDAY) to populate the fields
//       final firstDayPeriods = existingPeriods.where((p) => p['day'] == 'MONDAY').toList();
//       if (firstDayPeriods.isEmpty) {
//          setState(() => isLoading = false);
//          return;
//       }
//
//       // Find start and end times
//       final firstPeriod = PeriodModel.fromMap(firstDayPeriods.first);
//       final lastPeriod = PeriodModel.fromMap(firstDayPeriods.last);
//
//       startTime = _parseTime(firstPeriod.startTime);
//       // The end time of the schedule is the end time of the last period
//       endTime = _parseTime(lastPeriod.endTime);
//
//       // Determine period duration from the first non-break period
//       final firstLecture = firstDayPeriods.firstWhere((p) => p['isBreak'] == 0, orElse: () => {});
//       if (firstLecture.isNotEmpty) {
//           final start = _toMinutes(_parseTime(firstLecture['startTime'] as String));
//           final end = _toMinutes(_parseTime(firstLecture['endTime'] as String));
//           periodMinutes = end - start;
//       }
//
//       // Populate breaks and ringtones
//       breaks.clear();
//       for (final periodMap in firstDayPeriods) {
//         final period = PeriodModel.fromMap(periodMap);
//         if (period.isBreak) {
//           final breakStart = _parseTime(period.startTime);
//           final breakEnd = _parseTime(period.endTime);
//           final duration = _toMinutes(breakEnd) - _toMinutes(breakStart);
//           breaks.add(_BreakData(start: breakStart, duration: duration));
//           breakRingtonePath = period.ringtone;
//         } else {
//           periodRingtonePath = period.ringtone;
//         }
//       }
//
//       // Check if Sunday is included
//       final sundaySchedule = existingPeriods.firstWhere((p) => p['day'] == 'SUNDAY', orElse: () => {});
//       sundayEnabled = sundaySchedule.isNotEmpty;
//     }
//
//     setState(() => isLoading = false);
//   }
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
//   // NEW Helper to parse time string "HH:mm" into TimeOfDay
//   TimeOfDay _parseTime(String timeStr) {
//     final parts = timeStr.split(':');
//     return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
//   }
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
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
//           : ListView(
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
//               items: [30, 45, 60, 90].toSet().toList().map((e) { // Use toSet() to avoid duplicate values if loaded value is already present
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
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => setState(() => breaks.remove(b)),
//             ),
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
//   // ---------- TIME TILE (No changes needed) ----------
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
//
//   // ---------- RINGTONE TILE (No changes needed) ----------
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
//   // ---------- PICK RINGTONE (No changes needed) ----------
//   Future<String?> _pickRingtone() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.audio,
//       );
//       if (result != null && result.files.single.path != null) {
//         File file = File(result.files.single.path!);
//         print('Selected file path: ${file.path}');
//         return file.path;
//       }
//     } catch (e) {
//       print('Error picking file: $e');
//     }
//     return null;
//   }
//
//   // ---------- MODIFIED: ADD BREAK DIALOG ----------
//   void _addBreakDialog() async {
//     TimeOfDay? breakStartTime;
//     int breakDuration = 30;
//
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // Use StatefulBuilder to manage the dialog's state independently
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text('Add Break'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     title: const Text('Start Time'),
//                     trailing: Text(breakStartTime == null ? '--:--' : _format(breakStartTime!)),
//                     onTap: () async {
//                       final pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: const TimeOfDay(hour: 13, minute: 0),
//                       );
//                       if (pickedTime != null) {
//                         setDialogState(() {
//                           breakStartTime = pickedTime;
//                         });
//                       }
//                     },
//                   ),
//                   DropdownButton<int>(
//                     value: breakDuration,
//                     items: [15, 30, 45, 60].map((e) {
//                       return DropdownMenuItem(value: e, child: Text('$e min'));
//                     }).toList(),
//                     onChanged: (v) {
//                       if (v != null) {
//                         setDialogState(() => breakDuration = v);
//                       }
//                     },
//                   )
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   child: const Text('CANCEL'),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 TextButton(
//                   child: const Text('ADD'),
//                   onPressed: () {
//                     if (breakStartTime != null) {
//                       // Update the main page state
//                       setState(() {
//                         breaks.add(_BreakData(start: breakStartTime!, duration: breakDuration));
//                         // Sort breaks by start time to keep them in order
//                         breaks.sort((a, b) => (_toMinutes(a.start)).compareTo(_toMinutes(b.start)));
//                       });
//                     }
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   // ---------- MODIFIED: SAVE & GENERATE ----------
//   Future<void> _saveAndGenerate() async {
//     if (startTime == null || endTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a start and end time.')),
//       );
//       return;
//     }
//
//     final db = await AppDB.instance.database;
//
//     // **IMPORTANT**: Clear old schedule for this category before inserting the new one
//     await db.delete(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [widget.categoryId],
//     );
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
//       while (current < end) {
//         if (breakMap.containsKey(current)) {
//           final breakDuration = breakMap[current]!;
//           if (current + breakDuration > end) break; // Avoids creating a break that exceeds the end time.
//
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Break',
//               startTime: _format(_fromMinutes(current)),
//               endTime: _format(_fromMinutes(current + breakDuration)),
//               isBreak: true,
//               ringtone: breakRingtonePath,
//             ).toMap(),
//           );
//           current += breakDuration;
//         } else {
//           if (current + periodMinutes > end) break; // Avoids creating a period that exceeds the end time.
//
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
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Schedule saved successfully!')),
//       );
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
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// import 'package:flutter/material.dart';
// import '../../database/app_database.dart';
// import '../../models/period_model.dart';
// import '../audio/audio_selection_page.dart';
// import '../week/week_schedule_page.dart';
// import 'dart:io';
//
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
//   String _formatTime(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
//
//   int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
//
//   TimeOfDay _fromMinutes(int m) =>
//       TimeOfDay(hour: m ~/ 60, minute: m % 60);
//
//   String _getFileName(String? path) {
//     if (path == null || path.isEmpty) return 'Not Selected';
//     // This handles both file paths and asset paths
//     return path.split('/').last;
//   }
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
//           // UPDATED: Ringtone tiles now use a callback with the selected path
//           _ringtoneTile(
//             'Period Ringtone',
//             periodRingtonePath,
//                 (selectedPath) {
//               if (selectedPath != null) {
//                 setState(() => periodRingtonePath = selectedPath);
//               }
//             },
//           ),
//           _ringtoneTile(
//             'Break Ringtone',
//             breakRingtonePath,
//                 (selectedPath) {
//               if (selectedPath != null) {
//                 setState(() => breakRingtonePath = selectedPath);
//               }
//             },
//           ),
//
//           const Divider(),
//
//           const Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold)),
//
//           ...breaks.map((b) => ListTile(
//             title: Text('Break at ${_formatTime(b.start)}'),
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
//   // ---------- TIME TILE WIDGET ----------
//   Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
//     return ListTile(
//       title: Text(title),
//       trailing: Text(value == null ? '--:--' : _formatTime(value)),
//       onTap: () async {
//         final t = await showTimePicker(
//           context: context,
//           initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
//         );
//         if (t != null) onPick(t);
//       },
//     );
//   }
//
//   // ---------- UPDATED RINGTONE TILE WIDGET ----------
//   Widget _ringtoneTile(String title, String? filePath, ValueChanged<String?> onRingtoneSelected) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(
//         _getFileName(filePath),
//         style: const TextStyle(color: Colors.grey, fontSize: 12),
//         overflow: TextOverflow.ellipsis,
//       ),
//       trailing: const Icon(Icons.music_note),
//       onTap: () async {
//         // Navigate to the new selection page and wait for a result
//         final selectedPath = await Navigator.push<String>(
//           context,
//           MaterialPageRoute(builder: (_) => const RingtoneSelectionPage()),
//         );
//         // Pass the result back to the callback
//         onRingtoneSelected(selectedPath);
//       },
//     );
//   }
//
//   // ---------- OLD METHOD (REMOVED) ----------
//   // The _pickRingtone method is no longer needed here.
//
//   // ---------- ADD BREAK DIALOG ----------
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
//               trailing: Text(s == null ? '--:--' : _formatTime(s!)),
//               onTap: () async {
//                 s = await showTimePicker(
//                   context: context,
//                   initialTime: const TimeOfDay(hour: 13, minute: 0),
//                 );
//                 // This requires a StatefulWidget to rebuild the dialog, which is complex.
//                 // For simplicity, this example doesn't update the dialog UI in real-time.
//                 // A better approach would use a state management solution or a StatefulBuilder.
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
//                 setState(() {
//                   breaks.add(_BreakData(start: s!, duration: d));
//                 });
//               }
//               Navigator.pop(context);
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   // ---------- SAVE & GENERATE ----------
//   Future<void> _saveAndGenerate() async {
//     if (startTime == null || endTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a start and end time.')),
//       );
//       return;
//     }
//
//     final db = await AppDB.instance.database;
//
//     // Clear any previously generated schedule for this category to avoid duplicates
//     await db.delete('periods', where: 'categoryId = ?', whereArgs: [widget.categoryId]);
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
//       while (current < end) {
//         // Check if the current time is a break time
//         if (breakMap.containsKey(current)) {
//           final breakDuration = breakMap[current]!;
//           if (current + breakDuration > end) break; // Don't add break if it exceeds end time
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Break',
//               startTime: _formatTime(_fromMinutes(current)),
//               endTime: _formatTime(_fromMinutes(current + breakDuration)),
//               isBreak: true,
//               ringtone: breakRingtonePath,
//             ).toMap(),
//           );
//           current += breakDuration;
//         } else {
//           // It's a regular period
//           if (current + periodMinutes > end) break; // Don't add period if it exceeds end time
//           await db.insert(
//             'periods',
//             PeriodModel(
//               categoryId: widget.categoryId,
//               day: day,
//               title: 'Period $periodCount',
//               startTime: _formatTime(_fromMinutes(current)),
//               endTime: _formatTime(_fromMinutes(current + periodMinutes)),
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
import '../audio/audio_selection_page.dart';
import '../week/week_schedule_page.dart';

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

  List<String>? sequentialRingtones; // To store sequential ringtones

  final List<_BreakData> breaks = [];

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _fromMinutes(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);

  String _getFileName(String? path) {
    if (path == null || path.isEmpty) return 'Not Selected';
    return path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CheckboxListTile(
            title: const Text('Include Sunday'),
            value: sundayEnabled,
            onChanged: (v) => setState(() => sundayEnabled = v ?? false),
          ),
          _timeTile('Start Time', startTime, (t) => setState(() => startTime = t)),
          _timeTile('End Time', endTime, (t) => setState(() => endTime = t)),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Period Duration (minutes)'),
            trailing: DropdownButton<int>(
              value: periodMinutes,
              items: [30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (v) => setState(() => periodMinutes = v!),
            ),
          ),
          const Divider(),
          const Text('Period Ringtones', style: TextStyle(fontWeight: FontWeight.bold)),
          _ringtoneTile(
            'Sequential Period Ringtones',
            sequentialRingtones != null ? "${sequentialRingtones!.length} ringtones selected" : null,
                (result) {
              if (result != null) {
                setState(() {
                  sequentialRingtones = result as List<String>;
                });
              }
            },
          ),
          const Divider(),
          const Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold)),
          ...breaks.map((b) => ListTile(
            title: Text('Break at ${_formatTime(b.start)}'),
            subtitle: Text('${b.duration} min - Audio: ${_getFileName(b.ringtone)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => breaks.remove(b)),
            ),
          )),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Break'),
            onPressed: _addBreakDialog,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveAndGenerate,
            child: const Text('GENERATE WEEK SCHEDULE'),
          ),
        ],
      ),
    );
  }

  Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
    return ListTile(
      title: Text(title),
      trailing: Text(value == null ? '--:--' : _formatTime(value)),
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: value ?? const TimeOfDay(hour: 9, minute: 0));
        if (t != null) onPick(t);
      },
    );
  }

  Widget _ringtoneTile(String title, String? subtitle, ValueChanged<dynamic> onRingtoneSelected) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle ?? 'Not Selected', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.music_note),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RingtoneSelectionPage(selectSingle: false)),
        );
        if (result != null) onRingtoneSelected(result);
      },
    );
  }

  void _addBreakDialog() async {
    TimeOfDay? s;
    int d = 30;
    String? breakAudio;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Break'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                trailing: Text(s == null ? '--:--' : _formatTime(s!)),
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 13, minute: 0));
                  if (t != null) setDialogState(() => s = t);
                },
              ),
              DropdownButton<int>(
                value: d,
                items: [15, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e min'))).toList(),
                onChanged: (v) => setDialogState(() => d = v!),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.audiotrack),
                label: Text(breakAudio == null ? 'Select Audio' : _getFileName(breakAudio)),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RingtoneSelectionPage(selectSingle: true)),
                  );
                  if (result != null && result is String) {
                    setDialogState(() => breakAudio = result);
                  }
                },
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                if (s != null) {
                  setState(() => breaks.add(_BreakData(start: s!, duration: d, ringtone: breakAudio)));
                }
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndGenerate() async {
    if (startTime == null || endTime == null) return;

    final db = await AppDB.instance.database;
    await db.delete('periods', where: 'categoryId = ?', whereArgs: [widget.categoryId]);

    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    if (sundayEnabled) days.add('SUNDAY');

    for (final day in days) {
      int current = _toMinutes(startTime!);
      final end = _toMinutes(endTime!);
      int periodCount = 0;

      while (current < end) {
        // Check for specific break at this exact time
        final currentBreak = breaks.cast<_BreakData?>().firstWhere(
              (b) => _toMinutes(b!.start) == current,
          orElse: () => null,
        );

        if (currentBreak != null) {
          await db.insert('periods', PeriodModel(
            categoryId: widget.categoryId,
            day: day,
            title: 'Break',
            startTime: _formatTime(_fromMinutes(current)),
            endTime: _formatTime(_fromMinutes(current + currentBreak.duration)),
            isBreak: true,
            ringtone: currentBreak.ringtone, // Saves break-specific audio
          ).toMap());
          current += currentBreak.duration;
        } else {
          if (current + periodMinutes > end) break;

          // Assign sequential audio based on the period index
          String? ringtoneToSave;
          if (sequentialRingtones != null && sequentialRingtones!.isNotEmpty) {
            ringtoneToSave = sequentialRingtones![periodCount % sequentialRingtones!.length];
          }

          await db.insert('periods', PeriodModel(
            categoryId: widget.categoryId,
            day: day,
            title: 'Period ${periodCount + 1}',
            startTime: _formatTime(_fromMinutes(current)),
            endTime: _formatTime(_fromMinutes(current + periodMinutes)),
            isBreak: false,
            ringtone: ringtoneToSave,
          ).toMap());
          current += periodMinutes;
          periodCount++;
        }
      }
    }
    await db.update('categories', {'configured': 1}, where: 'id = ?', whereArgs: [widget.categoryId]);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: widget.categoryId)));
  }
}

class _BreakData {
  final TimeOfDay start;
  final int duration;
  final String? ringtone;
  _BreakData({required this.start, required this.duration, this.ringtone});
}