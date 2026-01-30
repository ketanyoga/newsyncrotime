// lib/pages/week/widgets/edit_todays_schedule.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../../database/app_database.dart';// A simple model class to hold period data and controllers
class EditablePeriod {
  final int id;
  final TextEditingController titleController;
  final TextEditingController timeController;

  EditablePeriod({
    required this.id,
    required String title,
    required String startTime,
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
        title: map['title'],
        startTime: map['startTime'],
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
    final db = await AppDB.instance.database;
    final batch = db.batch();

    for (final period in _periods) {
      batch.update(
        'periods',
        {
          'title': period.titleController.text,
          'startTime': period.timeController.text,
        },
        where: 'id = ?',
        whereArgs: [period.id],
      );
    }

    await batch.commit(noResult: true);

    // TODO: Implement the logic to send data to the ESP32 here
    // For example: await sendScheduleToESP32();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule updated successfully!")),
      );
      // Pop the page and return true to indicate an update occurred
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
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Add padding at bottom
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: period.titleController,
                              decoration: const InputDecoration(
                                labelText: 'Period Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // UPDATED: TextFormField for time with a time picker
                            TextFormField(
                              controller: period.timeController,
                              readOnly: true, // Makes the field not editable by keyboard
                              decoration: const InputDecoration(
                                labelText: 'Start Time (HH:mm)',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                              onTap: () => _selectTime(period.timeController), // Show time picker on tap
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
