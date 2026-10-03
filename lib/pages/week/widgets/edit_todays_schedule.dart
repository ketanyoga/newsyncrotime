// lib/pages/week/widgets/edit_todays_schedule.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncrobell/pages/audio/audio_selection_page.dart';

import '../../../database/app_database.dart';// A simple model class to hold period data and controllers
class EditablePeriod {
  final int id;
  final int categoryId;
  final String day;
  final TextEditingController titleController;
  final TextEditingController timeController;
  String? ringtonePath;

  EditablePeriod({
    required this.id,
    required this.categoryId,
    required this.day,
    required String title,
    required String startTime,
    this.ringtonePath,
  })  : titleController = TextEditingController(text: title),
        timeController = TextEditingController(text: startTime);

  // Dispose controllers to free up resources
  void dispose() {
    titleController.dispose();
    timeController.dispose();
  }
}

class EditTodaySchedulePage extends StatefulWidget {
  const EditTodaySchedulePage({super.key});

  @override
  State<EditTodaySchedulePage> createState() => _EditTodaySchedulePageState();
}

class _EditTodaySchedulePageState extends State<EditTodaySchedulePage> {
  late Future<List<EditablePeriod>> _periodsFuture;
  final List<EditablePeriod> _periods = [];

  @override
  void initState() {
    super.initState();
    _periodsFuture = _fetchAndPreparePeriods();
  }

  // UPDATED: Fetch periods for the current day only, similar to TodaySchedulePage
  Future<List<EditablePeriod>> _fetchAndPreparePeriods() async {
    final db = await AppDB.instance.database;
    // Get the current day of the week (e.g., "Tuesday")
    final String currentDay = DateFormat('EEEE').format(DateTime.now());

    // Query for periods matching the current day, case-insensitive
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM periods WHERE UPPER(day) = UPPER(?) ORDER BY startTime ASC',
      [currentDay],
    );

    // Clear previous list and dispose old controllers
    for (var p in _periods) {
      p.dispose();
    }
    _periods.clear();

    // Create EditablePeriod objects from the query result
    for (var map in result) {
      _periods.add(EditablePeriod(
        id: map['id'],
        categoryId: map['categoryId'],
        day: map['day'],
        title: map['title'],
        startTime: map['startTime'],
        ringtonePath: map['ringtone'],
      ));
    }
    return _periods;
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed
    for (var period in _periods) {
      period.dispose();
    }
    super.dispose();
  }

  // Save changes to the database
  Future<void> _saveSchedule() async {
    final bool? saveForAll = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Schedule"),
        content: const Text("Would you like to save these changes for only today or for the entire category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ONLY TODAY"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ENTIRE CATEGORY"),
          ),
        ],
      ),
    );

    if (saveForAll == null) return;

    final db = await AppDB.instance.database;
    final batch = db.batch();

    if (saveForAll) {
      // Save for entire category: Update based on title and categoryId
      for (final period in _periods) {
        batch.update(
          'periods',
          {
            'startTime': period.timeController.text,
            'ringtone': period.ringtonePath,
          },
          where: 'categoryId = ? AND title = ?',
          whereArgs: [period.categoryId, period.titleController.text],
        );
      }
      // Reset sync status for the category
      if (_periods.isNotEmpty) {
        await db.update('categories', {'synced': 0}, where: 'id = ?', whereArgs: [_periods.first.categoryId]);
      }
    } else {
      // Save for only today: Update by id
      for (final period in _periods) {
        batch.update(
          'periods',
          {
            'title': period.titleController.text,
            'startTime': period.timeController.text,
            'ringtone': period.ringtonePath,
          },
          where: 'id = ?',
          whereArgs: [period.id],
        );
      }
      // Reset sync status for the category
      if (_periods.isNotEmpty) {
        await db.update('categories', {'synced': 0}, where: 'id = ?', whereArgs: [_periods.first.categoryId]);
      }
    }

    await batch.commit(noResult: true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveForAll ? "Category schedule updated!" : "Today's schedule updated!")),
      );
      Navigator.pop(context, true);
    }
  }

  // NEW: Function to show a time picker and update the controller
  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Format the picked time and set it to the controller
      // The 'HH:mm' format ensures it is stored in 24-hour format
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Today's Schedule"),
      ),
      body: FutureBuilder<List<EditablePeriod>>(
        future: _periodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No schedule to edit for today."));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: period.titleController,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    decoration: const InputDecoration(
                                      labelText: 'Period Title',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(period.timeController),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Colors.blueGrey),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Start Time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            Text(period.timeController.text, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const RingtoneSelectionPage(selectSingle: true)),
                                      );
                                      if (result != null && result is String) {
                                        setState(() {
                                          period.ringtonePath = result;
                                        });
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.music_note, color: Colors.blueGrey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Ringtone", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                              Text(
                                                period.ringtonePath?.split('/').last ?? 'Default',
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text("Save Today's Schedule"),
          onPressed: _saveSchedule,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
