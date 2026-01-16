import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../services/esp32_api_service.dart';
import '../database/app_database.dart';
import '../pages/category/category_list_page.dart';
import '../pages/category/create_category_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool espConnected = false;
  // This 'time' variable will now be the main display time.
  // We'll update it to show the next period's time.
  String time = "--:--";
  String date = ""; // We can still keep the date from the ESP32
  String nextPeriodInfo = "Loading..."; // For the small text below the time
  Timer? timer;
  bool hasSchedule = false;

  late final Future<Database> _dbFuture;

  @override
  void initState() {
    super.initState();
    _dbFuture = AppDB.instance.database;
    _init();
  }

  Future<void> _init() async {
    final db = await _dbFuture;

    final countResult = await db.rawQuery('SELECT COUNT(*) as c FROM categories');
    if (mounted) {
      setState(() {
        final count = countResult.first['c'] as int?;
        hasSchedule = (count ?? 0) > 0;
      });
    }

    _checkEsp();
    // We still load the date and check connection periodically
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEsp();
      _loadDateFromEsp(); // Changed to only load date, as time is handled by schedule
      _loadNextPeriod();
    });
  }

  Future<void> _checkEsp() async {
    final connected = await Esp32ApiService.checkConnection();
    if (mounted) {
      setState(() => espConnected = connected);
    }
  }

  // Renamed from _loadTime to avoid confusion. We only need the date.
  Future<void> _loadDateFromEsp() async {
    final data = await Esp32ApiService.getTime();
    if (data != null && mounted) {
      setState(() {
        date = data['date'];
      });
    }
  }

  // MODIFIED SECTION
  Future<void> _loadNextPeriod() async {
    final db = await _dbFuture;
    final now = TimeOfDay.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
      [currentTime],
    );

    if (mounted) {
      setState(() {
        if (result.isEmpty) {
          // If no more periods, revert to showing ESP time or a message
          time = "--:--";
          nextPeriodInfo = "No more periods today";
        } else {
          final periodTitle = result.first['title'];
          final periodTime = result.first['startTime'];

          // *** THIS IS THE KEY CHANGE ***
          // 1. Set the main time display to the next period's start time.
          time = periodTime;

          // 2. Set the descriptive text for the banner below.
          nextPeriodInfo = "Next: $periodTitle";
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // --- UI WIDGETS SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 20),
              // This card now correctly shows the next period's time in the large display.
              _timeCard(),
              const SizedBox(height: 20),
              _scheduleButton(),
              const SizedBox(height: 20),
              _actionButtons(),
              const Spacer(),
              _bottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Dashboard",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: espConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.wifi, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text("WiFi", style: TextStyle(color: Colors.white)),
            ],
          ),
        )
      ],
    );
  }

  // The 'time' variable used here is now updated by _loadNextPeriod()
  Widget _timeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(date, style: const TextStyle(color: Colors.white70)),
          Text(time, // This now shows the next period's time
              style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(nextPeriodInfo, // This shows "Next: Period Name"
                style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _scheduleButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
              hasSchedule ? const CategoryListPage() : const CreateCategoryPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(hasSchedule ? "View Schedules" : "Create Schedule"),
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallButton("Skip Bell", () {
          Esp32ApiService.sendCommand({"action": "skip_next_bell"});
        }),
        _smallButton("Announcement", () {
          Navigator.pushNamed(context, "/announcement");
        }),
        _smallButton("Manual Ring", () {
          Esp32ApiService.sendCommand(
              {"action": "manual_ring", "sound": "default"});
        }),
      ],
    );
  }

  Widget _smallButton(String text, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: onTap,
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(icon: const Icon(Icons.home), onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // today's schedule page
            }),
        IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CategoryListPage()));
            }),
      ],
    );
  }
}
