import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/period_model.dart';

class EditPeriodPage extends StatefulWidget {
  final PeriodModel period;

  const EditPeriodPage({super.key, required this.period});

  @override
  State<EditPeriodPage> createState() => _EditPeriodPageState();
}

class _EditPeriodPageState extends State<EditPeriodPage> {
  late TextEditingController titleCtrl;
  late TimeOfDay start;
  late TimeOfDay end;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.period.title);
    start = _parse(widget.period.startTime);
    end = _parse(widget.period.endTime);
  }

  TimeOfDay _parse(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Period')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              readOnly: widget.period.isBreak,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(_fmt(start)),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: start);
                if (t != null) setState(() => start = t);
              },
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: Text(_fmt(end)),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: end);
                if (t != null) setState(() => end = t);
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final db = await AppDB.instance.database;
                await db.update(
                  'periods',
                  {
                    'title': titleCtrl.text,
                    'startTime': _fmt(start),
                    'endTime': _fmt(end),
                  },
                  where: 'id = ?',
                  whereArgs: [widget.period.id],
                );
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
