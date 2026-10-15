import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:flutter/services.dart';
import 'package:syncrobell/pages/week/widgets/edit_todays_schedule.dart';
import 'package:syncrobell/pages/audio/audio_selection_page.dart';
import 'package:syncrobell/services/esp32_api_service.dart';
import '../../database/app_database.dart';

class TodaySchedulePage extends StatefulWidget {
  const TodaySchedulePage({super.key});

  @override
  State<TodaySchedulePage> createState() => _TodaySchedulePageState();
}

class _TodaySchedulePageState extends State<TodaySchedulePage> {
  late Future<List<Map<String, dynamic>>> _periodsFuture;

  @override
  void initState() {
    super.initState();
    _periodsFuture = _fetchTodayPeriods();
  }

  // UPDATED: This function now fetches periods only for the current day with a case-insensitive check.
  Future<List<Map<String, dynamic>>> _fetchTodayPeriods() async {
    final db = await AppDB.instance.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final String currentDay = DateFormat('EEEE').format(now);

    // 1. Get all active and synced categories (fallback to all categories if none marked synced)
    var categoriesRes = await db.query('categories', where: 'synced = 1');
    if (categoriesRes.isEmpty) {
      categoriesRes = await db.query('categories');
    }
    final List<int> activeCategoryIds = [];

    for (var cat in categoriesRes) {
      try {
        final start = DateTime.parse(cat['startDate'] as String);
        final end = DateTime.parse(cat['endDate'] as String);
        final startDate = DateTime(start.year, start.month, start.day);
        final endDate = DateTime(end.year, end.month, end.day);

        if (today.isAtSameMomentAs(startDate) ||
            today.isAtSameMomentAs(endDate) ||
            (today.isAfter(startDate) && today.isBefore(endDate))) {
          // Check skipped days / dates
          final skippedDaysStr = cat['skippedDays'] as String? ?? "";
          final skippedDays = skippedDaysStr.split(',').where((s) => s.isNotEmpty).map(int.parse).toList();
          if (skippedDays.contains(now.weekday % 7)) continue;

          final skippedDatesStr = cat['skippedDates'] as String? ?? "";
          final skippedDates = skippedDatesStr.split(',').where((s) => s.isNotEmpty).map(DateTime.parse).toList();
          if (skippedDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) continue;

          activeCategoryIds.add(cat['id'] as int);
        }
      } catch (e) {
        debugPrint("Error checking category validity: $e");
      }
    }

    if (activeCategoryIds.isEmpty) return [];

    final String placeholders = List.filled(activeCategoryIds.length, '?').join(',');
    final List<Map<String, dynamic>> rawResult = await db.rawQuery(
      'SELECT * FROM periods WHERE categoryId IN ($placeholders) AND UPPER(day) = UPPER(?)',
      [...activeCategoryIds, currentDay],
    );

    if (rawResult.isEmpty) return [];

    // Find logical start time from first non-break period or category config
    int toMinutes(String timeStr) {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    String logicalStart = "00:00";
    final categoryId = rawResult.first['categoryId'] as int;
    final catRes = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
    if (catRes.isNotEmpty && catRes.first['scheduleConfig'] != null) {
      try {
        final config = jsonDecode(catRes.first['scheduleConfig'] as String);
        logicalStart = config['startTime'] ?? "00:00";
      } catch (_) {}
    }

    final int startMinutes = toMinutes(logicalStart);

    final Set<String> seenKeys = {};
    final List<Map<String, dynamic>> uniqueResult = [];
    for (var p in rawResult) {
      final key = '${p['title']}_${p['startTime']}_${p['endTime']}_${p['isBreak']}';
      if (!seenKeys.contains(key)) {
        seenKeys.add(key);
        uniqueResult.add(Map<String, dynamic>.from(p));
      }
    }

    uniqueResult.sort((a, b) {
      int am = toMinutes(a['startTime']);
      int bm = toMinutes(b['startTime']);
      if (am < startMinutes) am += 1440;
      if (bm < startMinutes) bm += 1440;
      return am.compareTo(bm);
    });

    return uniqueResult;
  }

  // Function to navigate to the edit page
  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditTodaySchedulePage()),
    ).then((didUpdate) {
      if (didUpdate == true) {
        setState(() {
          _periodsFuture = _fetchTodayPeriods();
        });
      }
    });
  }

  Future<void> _editSinglePeriod(Map<String, dynamic> periodMap) async {
    String currentTitle = periodMap['title'];
    String currentStartTime = periodMap['startTime'];
    String currentEndTime = periodMap['endTime'];
    String? currentRingtone = periodMap['ringtone'];
    int categoryId = periodMap['categoryId'];
    int periodId = periodMap['id'];

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Quick Edit: $currentTitle", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Start Time", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(currentStartTime, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(currentStartTime.split(':')[0]),
                      minute: int.parse(currentStartTime.split(':')[1]),
                    ),
                  );
                  if (t != null) {
                    setDialogState(() => currentStartTime = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("End Time", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(currentEndTime, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(currentEndTime.split(':')[0]),
                      minute: int.parse(currentEndTime.split(':')[1]),
                    ),
                  );
                  if (t != null) {
                    setDialogState(() => currentEndTime = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                  }
                },
              ),
              const Divider(),
              InkWell(
                onTap: () async {
                  final audio = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RingtoneSelectionPage(selectSingle: true)),
                  );
                  if (audio != null && audio is String) {
                    setDialogState(() => currentRingtone = audio);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: Color(0xFF007AFF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ringtone", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(currentRingtone?.split('/').last ?? 'Default', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("SAVE & SYNC"),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await _saveAndSync(periodId, categoryId, currentStartTime, currentEndTime, currentRingtone, periodMap['day']);
    }
  }

  Future<void> _saveAndSync(int periodId, int categoryId, String start, String end, String? ringtone, String day) async {
    final db = await AppDB.instance.database;

    // 1. Update Database
    await db.update(
      'periods',
      {'startTime': start, 'endTime': end, 'ringtone': ringtone},
      where: 'id = ?',
      whereArgs: [periodId],
    );

    // Reset synced status for category
    await db.update(
      'categories',
      {'synced': 0},
      where: 'id = ?',
      whereArgs: [categoryId],
    );

    // 2. Fetch all periods for this day to send full P command
    final allDayPeriods = await db.query(
      'periods',
      where: 'categoryId = ? AND UPPER(day) = UPPER(?)',
      whereArgs: [categoryId, day],
      orderBy: 'startTime ASC',
    );

    // 3. Find Category Sequence
    final categories = await db.query('categories', orderBy: 'name');
    int sequence = 1;
    for (int i = 0; i < categories.length; i++) {
      if (categories[i]['id'] == categoryId) {
        sequence = i + 1;
        break;
      }
    }

    // 4. Send Command
    try {
      final dayCodeMap = {'sunday': 'U', 'monday': 'M', 'tuesday': 'T', 'wednesday': 'W', 'thursday': 'H', 'friday': 'F', 'saturday': 'S'};
      final dayCode = dayCodeMap[day.toLowerCase()] ?? 'M';
      
      String _getRingtoneName(String? path) {
        if (path == null || path.isEmpty) return "default.mp3";
        return path.split('/').last;
      }

      final pairs = allDayPeriods.map((p) => '${p['startTime']},${_getRingtoneName(p['ringtone'] as String?)}').join('!');
      final command = '\$P,$sequence,$dayCode,$pairs#';

      bool connected = await Esp32ApiService.checkConnection();
      if (connected) {
        await Esp32ApiService.sendRaw(command);
        // Mark as SYNCED in local database
        await db.update(
          'categories',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [categoryId],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync completed successfully!"), backgroundColor: Colors.green));
        }
      } else {
        throw Exception("Not connected to SyncroBell Wi-Fi");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Syncing: $e"), backgroundColor: Colors.red));
      }
    }

    // 5. Refresh UI
    setState(() {
      _periodsFuture = _fetchTodayPeriods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text(
          "Today's Schedule",
          style: TextStyle(
              color: Color(0xFF1A2552), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2552)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _periodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final periods = snapshot.data;

          if (periods == null || periods.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Schedule Found for Today",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: periods.length,
            itemBuilder: (context, index) {
              final period = periods[index];
              final title = period['title'] as String;
              final startTime = period['startTime'] as String;
              final endTime = period['endTime'] as String;
              final ringtone = period['ringtone'] as String? ?? 'Default';
              final ringtoneName = ringtone.split('/').last;
              final isBreak = period['isBreak'] == 1;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withAlpha((255 * 0.1).round()))),
                child: InkWell(
                  onTap: () => _editSinglePeriod(period),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isBreak ? Colors.brown : const Color(0xFF007AFF)).withAlpha((255 * 0.1).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isBreak ? Icons.coffee_rounded : Icons.school_rounded,
                            color: isBreak ? Colors.brown : const Color(0xFF007AFF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color(0xFF1A2552)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$startTime - $endTime",
                                    style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.music_note_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ringtoneName,
                                      style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7C7CC)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEditPage,
        tooltip: 'Edit Today\'s Schedule',
        child: const Icon(Icons.edit),
      ),
    );
  }
}
