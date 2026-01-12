import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/esp32_api_service.dart';
import '../../services/database_service.dart';
import '../pages/category/category_list_page.dart';
import '../pages/category/create_category_page.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool espConnected = false;
  String time = "--:--";
  String date = "";
  String nextPeriod = "Loading...";
  Timer? timer;
  bool hasSchedule = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    hasSchedule = await DatabaseService.hasSchedule();
    _checkEsp();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEsp();
      _loadTime();
      _loadNextPeriod();
    });
  }

  Future<void> _checkEsp() async {
    final connected = await Esp32ApiService.checkConnection();
    setState(() => espConnected = connected);
  }

  Future<void> _loadTime() async {
    final data = await Esp32ApiService.getTime();
    if (data != null) {
      setState(() {
        time = data['time'];
        date = data['date'];
      });
    }
  }

  Future<void> _loadNextPeriod() async {
    final schedule = await DatabaseService.getTodaySchedule();
    setState(() {
      nextPeriod = schedule == null ? "No more periods" : "Next Period Soon";
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

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
          Text(time,
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
            child: Text("Next Period: $nextPeriod",
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
      child: Text(hasSchedule ? "Temp Schedule" : "Create Schedule"),
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
