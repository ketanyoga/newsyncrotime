import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/period_model.dart';
import '../audio/audio_selection_page.dart';

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
  String? ringtonePath;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.period.title);
    start = _parse(widget.period.startTime);
    end = _parse(widget.period.endTime);
    ringtonePath = widget.period.ringtone;
  }

  TimeOfDay _parse(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _getFileName(String? path) {
    if (path == null || path.isEmpty) return 'Default';
    return path.split('/').last;
  }

  Future<void> _save() async {
    final bool? saveForAll = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Save Period", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apply these changes to only this day or the entire category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ONLY THIS DAY"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("ENTIRE CATEGORY"),
          ),
        ],
      ),
    );

    if (saveForAll == null) return;

    final db = await AppDB.instance.database;

    if (saveForAll) {
      await db.update(
        'periods',
        {
          'startTime': _fmt(start),
          'endTime': _fmt(end),
          'ringtone': ringtonePath,
        },
        where: 'categoryId = ? AND title = ?',
        whereArgs: [widget.period.categoryId, titleCtrl.text],
      );
      // Reset sync status for the category
      await db.update('categories', {'synced': 0}, where: 'id = ?', whereArgs: [widget.period.categoryId]);
    } else {
      await db.update(
        'periods',
        {
          'title': titleCtrl.text,
          'startTime': _fmt(start),
          'endTime': _fmt(end),
          'ringtone': ringtonePath,
        },
        where: 'id = ?',
        whereArgs: [widget.period.id],
      );
      // Reset sync status for the category
      await db.update('categories', {'synced': 0}, where: 'id = ?', whereArgs: [widget.period.categoryId]);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveForAll ? "Category updated!" : "Period saved!")),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildEditCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.chevron_left, color: Color(0xFF007AFF), size: 28),
                Text("Back", style: TextStyle(color: Color(0xFF007AFF), fontSize: 17)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Edit Period",
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

  Widget _buildEditCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("INFORMATION", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
            const SizedBox(height: 12),
            TextFormField(
              controller: titleCtrl,
              readOnly: widget.period.isBreak,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.label_important_rounded, color: Color(0xFF007AFF)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            const Text("TIMING", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
            const SizedBox(height: 12),
            _buildActionRow(
              icon: Icons.access_time_filled_rounded,
              color: Colors.green,
              label: "Start Time",
              value: _fmt(start),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: start);
                if (t != null) setState(() => start = t);
              },
            ),
            const Divider(height: 32),
            _buildActionRow(
              icon: Icons.timer_off_rounded,
              color: Colors.red,
              label: "End Time",
              value: _fmt(end),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: end);
                if (t != null) setState(() => end = t);
              },
            ),
            const SizedBox(height: 24),
            const Text("AUDIO", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
            const SizedBox(height: 12),
            _buildActionRow(
              icon: Icons.music_note_rounded,
              color: Colors.pink,
              label: "Ringtone",
              value: _getFileName(ringtonePath),
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const RingtoneSelectionPage(selectSingle: true)),
                );
                if (result != null) {
                  setState(() => ringtonePath = result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC)),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: const Text("SAVE CHANGES", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
