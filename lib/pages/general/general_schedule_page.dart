import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/period_model.dart';
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

  final List<_BreakData> breaks = [];

  // ---------- HELPERS ----------
  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _fromMinutes(int m) =>
      TimeOfDay(hour: m ~/ 60, minute: m % 60);

  // ---------- UI ----------
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
              items: [30, 45, 60].map((e) {
                return DropdownMenuItem(value: e, child: Text('$e'));
              }).toList(),
              onChanged: (v) => setState(() => periodMinutes = v!),
            ),
          ),

          const Divider(),

          const Text('Breaks', style: TextStyle(fontWeight: FontWeight.bold)),

          ...breaks.map((b) => ListTile(
            title: Text('Break at ${_format(b.start)}'),
            subtitle: Text('${b.duration} min'),
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

  // ---------- TIME TILE ----------
  Widget _timeTile(String title, TimeOfDay? value, Function(TimeOfDay) onPick) {
    return ListTile(
      title: Text(title),
      trailing: Text(value == null ? '--:--' : _format(value)),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (t != null) onPick(t);
      },
    );
  }

  // ---------- ADD BREAK ----------
  void _addBreakDialog() async {
    TimeOfDay? s;
    int d = 30;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Break'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(s == null ? '--:--' : _format(s!)),
              onTap: () async {
                s = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 13, minute: 0),
                );
                setState(() {});
              },
            ),
            DropdownButton<int>(
              value: d,
              items: [15, 30, 45, 60].map((e) {
                return DropdownMenuItem(value: e, child: Text('$e min'));
              }).toList(),
              onChanged: (v) => d = v!,
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text('ADD'),
            onPressed: () {
              if (s != null) {
                breaks.add(_BreakData(start: s!, duration: d));
              }
              Navigator.pop(context);
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  // ---------- SAVE & GENERATE ----------
  Future<void> _saveAndGenerate() async {
    if (startTime == null || endTime == null) return;

    final db = await AppDB.instance.database;

    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    if (sundayEnabled) days.add('SUNDAY');

    for (final day in days) {
      int current = _toMinutes(startTime!);
      final end = _toMinutes(endTime!);

      final breakMap = {
        for (var b in breaks) _toMinutes(b.start): b.duration
      };

      int periodCount = 1;

      while (current + periodMinutes <= end) {
        if (breakMap.containsKey(current)) {
          await db.insert(
            'periods',
            PeriodModel(
              categoryId: widget.categoryId,
              day: day,
              title: 'Break',
              startTime: _format(_fromMinutes(current)),
              endTime: _format(_fromMinutes(current + breakMap[current]!)),
              isBreak: true,
            ).toMap(),
          );
          current += breakMap[current]!;
        } else {
          await db.insert(
            'periods',
            PeriodModel(
              categoryId: widget.categoryId,
              day: day,
              title: 'Period $periodCount',
              startTime: _format(_fromMinutes(current)),
              endTime: _format(_fromMinutes(current + periodMinutes)),
              isBreak: false,
            ).toMap(),
          );
          current += periodMinutes;
          periodCount++;
        }
      }
    }

    // Mark category as configured
    await db.update(
      'categories',
      {'configured': 1},
      where: 'id = ?',
      whereArgs: [widget.categoryId],
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WeekSchedulePage(categoryId: widget.categoryId),
        ),
      );
    }
  }
}

// ---------- BREAK DATA CLASS ----------
class _BreakData {
  final TimeOfDay start;
  final int duration;

  _BreakData({required this.start, required this.duration});
}
