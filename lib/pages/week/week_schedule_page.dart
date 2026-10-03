import 'dart:convert';
import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/period_model.dart';
import 'edit_period_page.dart';
import 'widgets/day_switcher.dart';
import 'widgets/period_tile.dart';

class WeekSchedulePage extends StatefulWidget {
  final int categoryId;

  const WeekSchedulePage({super.key, required this.categoryId});

  @override
  State<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends State<WeekSchedulePage> {
  final List<String> days = [];
  int index = 0;
  final Map<String, List<PeriodModel>> data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    await AppDB.instance.cleanDuplicatePeriods();
    final db = await AppDB.instance.database;

    final cat = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [widget.categoryId],
    );

    final String skippedDaysStr = cat.first['skippedDays'] as String? ?? "0";
    final List<int> skippedDays = skippedDaysStr
        .split(',')
        .where((s) => s.isNotEmpty)
        .map(int.parse)
        .toList();

    // Determine the logical start time of the day to handle overnight sorting
    String logicalStart = "00:00";
    if (cat.first['scheduleConfig'] != null) {
      try {
        final config = jsonDecode(cat.first['scheduleConfig'] as String);
        logicalStart = config['startTime'] ?? "00:00";
      } catch (_) {}
    }

    final allDays = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    
    days.clear();
    for (int i = 0; i < 7; i++) {
      if (!skippedDays.contains(i)) {
        days.add(allDays[i]);
      }
    }

    int toMinutes(String timeStr) {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final int startMinutes = toMinutes(logicalStart);

    for (final d in days) {
      final rows = await db.rawQuery(
        'SELECT * FROM periods WHERE categoryId = ? AND UPPER(day) = UPPER(?)',
        [widget.categoryId, d],
      );
      
      final periods = rows.map((e) => PeriodModel.fromMap(e)).toList();
      
      // Deduplicate periods strictly by start time to prevent duplicate period tiles
      final Set<String> seenTimes = {};
      final List<PeriodModel> uniquePeriods = [];
      for (var p in periods) {
        final key = p.startTime.trim();
        if (!seenTimes.contains(key)) {
          seenTimes.add(key);
          uniquePeriods.add(p);
        }
      }

      // LOGICAL SORT:
      uniquePeriods.sort((a, b) {
        int am = toMinutes(a.startTime);
        int bm = toMinutes(b.startTime);
        
        if (am < startMinutes) am += 1440;
        if (bm < startMinutes) bm += 1440;
        
        return am.compareTo(bm);
      });

      data[d] = uniquePeriods;
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 16),
            if (!loading)
              DaySwitcher(
                days: days,
                currentIndex: index,
                onSelect: (val) => setState(() => index = val),
              ),
            const SizedBox(height: 24),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPeriodList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Return to general schedule page if possible, otherwise pop
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.chevron_left, color: Color(0xFF007AFF), size: 28),
                Text("Back", style: TextStyle(color: Color(0xFF007AFF), fontSize: 17)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Week Schedule",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodList() {
    if (days.isEmpty) {
      return const Center(child: Text("No active days selected."));
    }
    final day = days[index];
    final list = data[day]!;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 64, color: Color(0xFFC7C7CC)),
            const SizedBox(height: 16),
            Text(
              "No periods scheduled for $day",
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 17),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p = list[i];
        return PeriodTile(
          title: p.title,
          startTime: p.startTime,
          endTime: p.endTime,
          ringtone: p.ringtone,
          isBreak: p.isBreak,
          isLast: i == list.length - 1,
          onTap: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => EditPeriodPage(period: p),
              ),
            );
            if (changed == true) _load();
          },
        );
      },
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Returns to the Category List Page safely
          Navigator.of(context).popUntil((route) => route.settings.name == 'CategoryListPage' || route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: const Text(
          "SAVE & RETURN",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
