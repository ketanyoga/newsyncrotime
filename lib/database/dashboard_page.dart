





import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/esp32_api_service.dart';
import '../database/app_database.dart';
import '../pages/announcement/announcement_page.dart';
import '../pages/category/category_list_page.dart';
import '../pages/category/create_category_page.dart';
import '../pages/emergency/emergency_page.dart';
import '../pages/today_schedule_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String time = "--:--";
  String date = "";
  String nextPeriodInfo = "Loading...";
  Timer? timer;
  bool hasSchedule = false;

  late final Future<Database> _dbFuture;

  // ───────────────────── LOGIC (MODIFIED) ─────────────────────

  @override
  void initState() {
    super.initState();
    _dbFuture = AppDB.instance.database;
    _init();
  }

  Future<void> _init() async {
    final db = await _dbFuture;

    final countResult =
    await db.rawQuery('SELECT COUNT(*) as c FROM categories');
    if (mounted) {
      setState(() {
        final count = countResult.first['c'] as int?;
        hasSchedule = (count ?? 0) > 0;
      });
    }

    // _checkEsp();
    // // Modified Timer: Removed the call to _loadDateFromEsp
    // timer = Timer.periodic(const Duration(seconds: 3), (_) {
    //   _checkEsp();
    //   _loadNextPeriod();
    // });
  }

  // Future<void> _checkEsp() async {
  //   final connected = await Esp32ApiService.checkConnection();
  //   if (mounted) setState(() => espConnected = connected);
  // }

  // REMOVED: The _loadDateFromEsp function has been deleted as it sent the status.
  // Future<void> _loadDateFromEsp() async {
  //   if (!espConnected) return;
  //   Esp32ApiService.getStatus();
  // }

  Future<void> _loadNextPeriod() async {
    final db = await _dbFuture;
    final now = TimeOfDay.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final result = await db.rawQuery(
      'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
      [currentTime],
    );

    if (!mounted) return;

    setState(() {
      if (result.isEmpty) {
        time = "--:--";
        nextPeriodInfo = "No more periods today";
      } else {
        time = result.first['startTime'] as String;
        nextPeriodInfo = "Next: ${result.first['title'] as String}";
      }
    });

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ───────────────────── UI (UNCHANGED) ─────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS grouped background
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _topBar(),
            const SizedBox(height: 28),
            _timeHeroCard(),
            const SizedBox(height: 28),
            _primaryActionCard(),
            const SizedBox(height: 32),
            _sectionTitle("Quick Actions"),
            const SizedBox(height: 16),
            _quickActionsRow(),
            const SizedBox(height: 32),
            _secondaryActionCard(),
            const SizedBox(height: 24),
            _emergencyCard(),
          ],
        ),
      ),
    );
  }

  // ───────────────────── TOP BAR ─────────────────────

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),

      ],
    );
  }

  // ───────────────────── TIME HERO ─────────────────────

  Widget _timeHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Lottie.asset(
              'assets/lottie/clock.json',
              repeat: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nextPeriodInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E6E73),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── PRIMARY ACTION ─────────────────────

  Widget _primaryActionCard() {
    return _iosNavCard(
      icon: Icons.calendar_today_rounded,
      title: hasSchedule ? "View Today’s Schedule" : "Create Schedule",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            hasSchedule ? const TodaySchedulePage() : const CreateCategoryPage(),
          ),
        );
      },
    );
  }

  // ───────────────────── QUICK ACTIONS ─────────────────────

  Widget _quickActionsRow() {
    return Row(
      children: [
        _quickAction(
          "Skip Bell",
          Icons.skip_next_rounded,
              () => Esp32ApiService.sendRaw("\$S#"),
        ),
        const SizedBox(width: 12),
        _quickAction(
          "Announce",
          Icons.campaign_rounded,
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnnouncementPage()),
            );
          },
        ),
        const SizedBox(width: 12),
        _quickAction(
          "Manual Ring",
          Icons.touch_app_rounded,
              () => Esp32ApiService.sendRaw("\$T,mr.mp3#"),
        ),
      ],
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: const Color(0xFF007AFF)),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────── SECONDARY ─────────────────────

  Widget _secondaryActionCard() {
    return _iosNavCard(
      icon: Icons.settings_rounded,
      title: "Manage Schedules",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryListPage()),
        );
      },
    );
  }

  Widget _iosNavCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: const Color(0xFF007AFF)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: Color(0xFFAEAEB2),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── EMERGENCY ─────────────────────

  Widget _emergencyCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30), // iOS system red
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: Text(
            "EMERGENCY",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── HELPERS ─────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Colors.black,
      ),
    );
  }
}
