import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:newsyncrotime/pages/week/widgets/edit_todays_schedule.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/app_database.dart';
import 'category/create_category_page.dart';

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

    // 1. Get the current day of the week as a full name (e.g., "Tuesday").
    final String currentDay = DateFormat('EEEE').format(DateTime.now());

    // 2. Modify the query to use UPPER() on both the column and the value for a case-insensitive comparison.
    // This ensures "Tuesday" matches "tuesday", "TUESDAY", etc.
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM periods WHERE UPPER(day) = UPPER(?) ORDER BY startTime ASC',
      [currentDay], // Pass the current day as an argument to prevent SQL injection.
    );

    return result;
  }

  // Function to navigate to the edit page
  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditTodaySchedulePage()),
    ).then((didUpdate) {
      // If the edit page returns true, refresh the schedule
      if (didUpdate == true) {
        setState(() {
          _periodsFuture = _fetchTodayPeriods();
        });
      }
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

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2552)),
                  ),
                  trailing: Text(
                    startTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
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
