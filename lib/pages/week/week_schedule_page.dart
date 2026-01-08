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
    final db = await AppDB.instance.database;

    final cat = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [widget.categoryId],
    );

    final sunday = cat.first['configured'] == 1;

    days.clear();
    days.addAll(
        ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY']);
    if (sunday) days.add('SUNDAY');

    for (final d in days) {
      final rows = await db.query(
        'periods',
        where: 'categoryId = ? AND day = ?',
        whereArgs: [widget.categoryId, d],
        orderBy: 'startTime',
      );
      data[d] = rows.map((e) => PeriodModel.fromMap(e)).toList();
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final day = days[index];
    final list = data[day]!;

    final isLastDay = index == days.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: DaySwitcher(
          day: day,
          onPrev: index > 0 ? () => setState(() => index--) : null,
          onNext: index < days.length - 1 ? () => setState(() => index++) : null,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i];
                return PeriodTile(
                  title: p.title,
                  time: '${p.startTime} - ${p.endTime}',
                  isBreak: p.isBreak,
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
            ),
          ),
          if (isLastDay)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('SAVE WEEK SCHEDULE'),
              ),
            )
        ],
      ),
    );
  }
}
