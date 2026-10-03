import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../../models/period_model.dart';
import '../audio/audio_selection_page.dart';
import '../week/week_schedule_page.dart';

class GeneralSchedulePage extends StatefulWidget {
  final int categoryId;
  const GeneralSchedulePage({super.key, required this.categoryId});

  @override
  State<GeneralSchedulePage> createState() => _GeneralSchedulePageState();
}

class _GeneralSchedulePageState extends State<GeneralSchedulePage> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int periodMinutes = 60;
  int ringtoneDuration = 60;
  List<int> skippedDays = [0]; // Default skip Sunday
  List<DateTime> skippedDates = [];

  List<String>? sequentialRingtones;

  final List<_BreakData> breaks = [];
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingCategory();
  }

  Future<void> _loadExistingCategory() async {
    try {
      debugPrint("--- Loading Category Data for ID: ${widget.categoryId} ---");
      final db = await AppDB.instance.database;
      final List<Map<String, dynamic>> res = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [widget.categoryId],
      );

      if (res.isNotEmpty) {
        final cat = res.first;
        debugPrint("Category found: ${cat['name']}");

        if (mounted) {
          setState(() {
            ringtoneDuration = cat['ringtoneDuration'] as int? ?? 60;
            skippedDays = (cat['skippedDays'] as String? ?? "0")
                .split(',')
                .where((s) => s.isNotEmpty)
                .map(int.parse)
                .toList();
            skippedDates = (cat['skippedDates'] as String? ?? "")
                .split(',')
                .where((s) => s.isNotEmpty)
                .map(DateTime.parse)
                .toList();
          });

          bool restoredFromJson = false;
          // Try to restore from scheduleConfig JSON first
          if (cat['scheduleConfig'] != null && (cat['scheduleConfig'] as String).isNotEmpty) {
            debugPrint("Restoring from scheduleConfig JSON...");
            try {
              final config = jsonDecode(cat['scheduleConfig'] as String) as Map<String, dynamic>;

              setState(() {
                if (config['startTime'] != null) startTime = _parseTime(config['startTime']);
                if (config['endTime'] != null) endTime = _parseTime(config['endTime']);
                periodMinutes = config['periodMinutes'] ?? 60;

                if (config['sequentialRingtones'] != null) {
                  sequentialRingtones = List<String>.from(config['sequentialRingtones']);
                }

                if (config['breaks'] != null) {
                  breaks.clear();
                  for (var b in (config['breaks'] as List)) {
                    breaks.add(_BreakData(
                      start: _parseTime(b['start']),
                      duration: b['duration'],
                      ringtone: b['ringtone'],
                    ));
                  }
                }
                restoredFromJson = true;
                _isInitialLoading = false;
              });
              debugPrint("Restoration from JSON complete.");
            } catch (e) {
              debugPrint("Error parsing scheduleConfig JSON: $e. Falling back...");
            }
          }

          if (!restoredFromJson) {
            // FALLBACK: Load from existing periods
            await _loadFromPeriodsFallback();
          }
        }
      } else {
        debugPrint("Category ID ${widget.categoryId} not found in database.");
        if (mounted) setState(() => _isInitialLoading = false);
      }
    } catch (e, stack) {
      debugPrint("CRITICAL ERROR during data restoration: $e");
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        setState(() => _isInitialLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadFromPeriodsFallback() async {
    final db = await AppDB.instance.database;
    final periods = await db.query(
      'periods',
      where: 'categoryId = ?',
      orderBy: 'startTime ASC',
    );

    if (periods.isNotEmpty) {
      debugPrint("Found ${periods.length} periods. Restoring settings from periods...");
      final sortedByTime = List<Map<String, dynamic>>.from(periods);
      sortedByTime.sort((a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));

      final first = sortedByTime.first;
      final sortedByEndTime = List<Map<String, dynamic>>.from(periods);
      sortedByEndTime.sort((a, b) => (b['endTime'] as String).compareTo(a['endTime'] as String));
      final last = sortedByEndTime.first;

      if (mounted) {
        setState(() {
          startTime = _parseTime(first['startTime'] as String);
          endTime = _parseTime(last['endTime'] as String);

          final firstNonBreak = periods.firstWhere((p) => p['isBreak'] == 0, orElse: () => periods.first);
          final startM = _toMinutes(_parseTime(firstNonBreak['startTime'] as String));
          final endM = _toMinutes(_parseTime(firstNonBreak['endTime'] as String));
          periodMinutes = endM - startM;

          final firstDayWithData = periods.first['day'] as String;
          final dayPeriods = periods.where((p) => p['day'] == firstDayWithData).toList();

          breaks.clear();
          final breakPeriods = dayPeriods.where((p) => p['isBreak'] == 1).toList();
          for (var b in breakPeriods) {
            final bs = _parseTime(b['startTime'] as String);
            final be = _parseTime(b['endTime'] as String);
            breaks.add(_BreakData(
              start: bs,
              duration: _toMinutes(be) - _toMinutes(bs),
              ringtone: b['ringtone'] as String?,
            ));
          }

          final nonBreakPeriods = dayPeriods.where((p) => p['isBreak'] == 0).toList();
          sequentialRingtones = nonBreakPeriods.map((p) => p['ringtone'] as String?).whereType<String>().toList();
          if (sequentialRingtones!.isEmpty) sequentialRingtones = null;
        });
      }
    }
    if (mounted) setState(() => _isInitialLoading = false);
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _fromMinutes(int m) => TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);

  String _getFileName(String? path) {
    if (path == null || path.isEmpty) return 'Not Selected';
    return path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                children: [
                  _buildCustomAppBar(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Schedule Settings"),
                  _buildTimingCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Exclusions"),
                  _buildExclusionsRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Configuration"),
                  _buildConfigRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Breaks"),
                  _buildBreaksCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildGenerateButton(),
    );
  }

  Widget _buildCustomAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
              "General Schedule",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTimingCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.play_circle_fill,
            iconColor: Colors.green,
            title: "Day Starts At",
            trailing: startTime == null ? "Select" : _formatTime(startTime!),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: startTime ?? const TimeOfDay(hour: 8, minute: 0));
              if (t != null) setState(() => startTime = t);
            },
          ),
          const Divider(indent: 60, height: 1),
          _buildListTile(
            icon: Icons.stop_circle_rounded,
            iconColor: Colors.red,
            title: "Day Ends At",
            trailing: endTime == null ? "Select" : _formatTime(endTime!),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: endTime ?? const TimeOfDay(hour: 16, minute: 0));
              if (t != null) setState(() => endTime = t);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExclusionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallActionCard(
            icon: Icons.calendar_view_week,
            label: "Skip Days",
            value: "${skippedDays.length} Days",
            onTap: _showSkipDaysDialog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallActionCard(
            icon: Icons.event_busy,
            label: "Skip Dates",
            value: "${skippedDates.length} Dates",
            onTap: _showSkipDatesDialog,
          ),
        ),
      ],
    );
  }

  void _showSkipDaysDialog() {
    final List<String> allDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Select Days to Skip"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (i) {
                return CheckboxListTile(
                  title: Text(allDays[i]),
                  value: skippedDays.contains(i),
                  onChanged: (v) {
                    setDialogState(() {
                      if (v == true) {
                        skippedDays.add(i);
                      } else {
                        skippedDays.remove(i);
                      }
                    });
                    setState(() {});
                  },
                );
              }),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("DONE")),
          ],
        ),
      ),
    );
  }

  void _showSkipDatesDialog() {
    List<DateTime> localDates = List.from(skippedDates);
    DateTime viewMonth = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final int daysInMonth = DateTime(viewMonth.year, viewMonth.month + 1, 0).day;
          final int firstDayOffset = DateTime(viewMonth.year, viewMonth.month, 1).weekday % 7;
          final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Holidays", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _showAllSelectedDates(localDates),
                  child: Text("View All (${localDates.length})", style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            content: SizedBox(
              width: 350,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month Navigator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setDialogState(() => viewMonth = DateTime(viewMonth.year, viewMonth.month - 1)),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('MMMM yyyy').format(viewMonth),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => setDialogState(() => viewMonth = DateTime(viewMonth.year, viewMonth.month + 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Weekday Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: weekdays
                            .map((d) => Expanded(
                                  child: Center(
                                      child: Text(d,
                                          style: TextStyle(
                                              color: (d == "S") ? Colors.redAccent : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Calendar Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 7,
                      children: [
                        ...List.generate(firstDayOffset, (_) => const SizedBox.shrink()),
                        ...List.generate(daysInMonth, (i) {
                          final day = i + 1;
                          final date = DateTime(viewMonth.year, viewMonth.month, day);
                          
                          // NEW: Check if this date falls on a skipped day of the week
                          // DateTime.weekday: 1=Mon...7=Sun. skippedDays: 0=Sun, 1=Mon...
                          int weekdayForSkip = date.weekday % 7; 
                          final bool isSkippedDay = skippedDays.contains(weekdayForSkip);
                          
                          // Check if this specific date is manually selected
                          final bool isManuallySelected = localDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);

                          final bool shouldShowRed = isSkippedDay || isManuallySelected;

                          return GestureDetector(
                            onTap: () {
                              if (isSkippedDay) {
                                // If the day is already skipped globally, no need to toggle the date
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("This day is already skipped in 'Skip Days' settings."), duration: Duration(seconds: 1)),
                                );
                                return;
                              }
                              
                              setDialogState(() {
                                if (isManuallySelected) {
                                  localDates.removeWhere(
                                      (d) => d.year == date.year && d.month == date.month && d.day == date.day);
                                } else {
                                  localDates.add(date);
                                  localDates.sort();
                                }
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: shouldShowRed ? Colors.red : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$day",
                                style: TextStyle(
                                  color: shouldShowRed ? Colors.white : Colors.black,
                                  fontWeight: shouldShowRed ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCEL", style: TextStyle(color: Color(0xFF8E8E93))),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    skippedDates = localDates;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SAVE"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAllSelectedDates(List<DateTime> dates) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("All Selected Dates"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(DateFormat('EEEE, dd MMMM yyyy').format(dates[index])),
                leading: const Icon(Icons.event),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  Widget _buildConfigRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallActionCard(
                icon: Icons.timer_outlined,
                label: "Duration",
                value: "${periodMinutes}m",
                onTap: _showDurationPicker,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallActionCard(
                icon: Icons.music_note_rounded,
                label: "Ringtones",
                value: sequentialRingtones == null || sequentialRingtones!.isEmpty 
                    ? "Default"
                    : "${sequentialRingtones!.length}",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RingtoneSelectionPage(selectSingle: false, initialSelection: sequentialRingtones)),
                  );
                  if (result != null) {
                    setState(() => sequentialRingtones = result as List<String>);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallActionCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final bool isPlaceholder = value == 'Select';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 26, color: const Color(0xFF007AFF)),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isPlaceholder ? const Color(0xFF007AFF) : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFFC7C7CC)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreaksCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (breaks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.coffee_outlined, color: Color(0xFFC7C7CC), size: 48),
                  SizedBox(height: 12),
                  Text("No breaks scheduled", style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
                ],
              ),
            )
          else
            ...breaks.asMap().entries.map((entry) {
              final idx = entry.key;
              final b = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFFF2F2F7), child: Icon(Icons.coffee, color: Colors.brown, size: 20)),
                    title: Text("Break at ${_formatTime(b.start)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("${b.duration} min • ${b.ringtone == null ? 'No Audio' : _getFileName(b.ringtone)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Color(0xFF007AFF), size: 22),
                          onPressed: () => _addBreakDialog(existingData: b, index: idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 22),
                          onPressed: () => setState(() => breaks.removeAt(idx)),
                        ),
                      ],
                    ),
                  ),
                  if (idx < breaks.length - 1) const Divider(indent: 60, height: 1),
                ],
              );
            }),
          const Divider(height: 1),
          InkWell(
            onTap: _addBreakDialog,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: Color(0xFF007AFF), size: 20),
                  SizedBox(width: 8),
                  Text("Add Break Time", style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailing,
    required VoidCallback onTap,
  }) {
    final bool isPlaceholder = trailing == 'Select';
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: TextStyle(
              color: isPlaceholder ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
              fontSize: 17,
              fontWeight: isPlaceholder ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC), size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFC7C7CC), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text("Period Duration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ...[30, 45, 50, 60, 90].map((mins) => ListTile(
                  title: Text("$mins minutes", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                  trailing: periodMinutes == mins ? const Icon(Icons.check_circle, color: Color(0xFF007AFF)) : null,
                  onTap: () {
                    setState(() => periodMinutes = mins);
                    Navigator.pop(context);
                  },
                )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: Color(0xFF007AFF)),
                  title: const Text("Custom Duration...", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF007AFF))),
                  onTap: () {
                    Navigator.pop(context);
                    _showCustomDurationDialog();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomDurationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Custom Duration", style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter period duration in minutes:"),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "e.g. 55",
                  border: OutlineInputBorder(),
                  suffixText: "min",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => periodMinutes = val);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final bool canGenerate = startTime != null && endTime != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: canGenerate ? _saveAndGenerate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFF2F2F7),
          disabledForegroundColor: const Color(0xFFC7C7CC),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: const Text(
          "GENERATE WEEK SCHEDULE",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _addBreakDialog({_BreakData? existingData, int? index}) async {
    TimeOfDay? s = existingData?.start;
    int d = existingData?.duration ?? 30;
    String? breakAudio = existingData?.ringtone;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(existingData == null ? 'Add Break Time' : 'Edit Break Time',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start Time', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(s == null ? 'Set Time' : _formatTime(s!),
                        style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold, fontSize: 16)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: s ?? const TimeOfDay(hour: 12, minute: 0));
                      if (t != null) setDialogState(() => s = t);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Duration', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: DropdownButton<int>(
                      value: [5, 10, 15, 20, 30, 45, 60].contains(d) ? d : null,
                      hint: Text('$d min'),
                      underline: const SizedBox(),
                      items: [
                        ...[5, 10, 15, 20, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e min'))),
                        const DropdownMenuItem(value: -1, child: Text('Custom...')),
                      ],
                      onChanged: (v) async {
                        if (v == -1) {
                          final custom = await _showCustomValueDialog("Break Duration", "minutes");
                          if (custom != null) setDialogState(() => d = custom);
                        } else if (v != null) {
                          setDialogState(() => d = v);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RingtoneSelectionPage(
                            selectSingle: true,
                            initialSelection: breakAudio,
                            showOnlyLunch: true, // NEW: Filter for lunch only
                          ),
                        ),
                      );
                      if (result != null && result is String) {
                        setDialogState(() => breakAudio = result);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: Color(0xFF007AFF), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              breakAudio == null ? 'Select Audio' : _getFileName(breakAudio),
                              style: TextStyle(
                                  color: breakAudio == null ? const Color(0xFF8E8E93) : Colors.black,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC), size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93)))),
            ElevatedButton(
              onPressed: s == null
                  ? null
                  : () {
                      final newData = _BreakData(start: s!, duration: d, ringtone: breakAudio);
                      if (existingData != null && index != null) {
                        setState(() => breaks[index] = newData);
                      } else {
                        setState(() => breaks.add(newData));
                      }
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(existingData == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _showCustomValueDialog(String title, String suffix) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("Custom $title", style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter $title in $suffix:"),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "e.g. 12",
                border: const OutlineInputBorder(),
                suffixText: suffix,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(context, val);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndGenerate() async {
    if (startTime == null || endTime == null) return;

    List<String> activeRingtones = [];
    final List<String> restrictedNames = ["assembly.mp3", "emergency.mp3", "lunch.mp3"];

    if (sequentialRingtones != null && sequentialRingtones!.isNotEmpty) {
      activeRingtones = sequentialRingtones!;
    } else {
      // Fallback: Load built-in assets
      try {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        activeRingtones = manifest.listAssets()
            .where((path) => path.startsWith('assets/audio/'))
            .where((path) {
              final name = path.split('/').last.toLowerCase();
              return !restrictedNames.contains(name);
            })
            .toList();
      } catch (e) {
        debugPrint("Error loading fallback assets: $e");
      }
      
      // Final safety fallback
      if (activeRingtones.isEmpty) {
        activeRingtones = ["SchoolBell.mp3"];
      }
    }

    final db = await AppDB.instance.database;
    await db.delete('periods', where: 'categoryId = ?', whereArgs: [widget.categoryId]);

    final allDays = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    final List<String> daysToGenerate = [];
    for (int i = 0; i < 7; i++) {
      if (!skippedDays.contains(i)) {
        daysToGenerate.add(allDays[i]);
      }
    }

    for (final day in daysToGenerate) {
      int current = _toMinutes(startTime!);
      int end = _toMinutes(endTime!);
      
      // Handle overnight schedules (e.g. 18:00 to 01:00)
      if (end <= current) {
        end += 1440; // Add 24 hours in minutes
      }

      int periodCount = 0;

      while (current < end) {
        final currentBreak = breaks.cast<_BreakData?>().firstWhere(
              (b) => _toMinutes(b!.start) == current,
          orElse: () => null,
        );

        if (currentBreak != null) {
          await db.insert('periods', PeriodModel(
            categoryId: widget.categoryId,
            day: day,
            title: 'Break',
            startTime: _formatTime(_fromMinutes(current)),
            endTime: _formatTime(_fromMinutes(current + currentBreak.duration)),
            isBreak: true,
            ringtone: currentBreak.ringtone,
          ).toMap());
          current += currentBreak.duration;
        } else {
          if (current + periodMinutes > end) break;

          String ringtoneToSave = activeRingtones[periodCount % activeRingtones.length];
          
          await db.insert('periods', PeriodModel(
            categoryId: widget.categoryId,
            day: day,
            title: 'Period ${periodCount + 1}',
            startTime: _formatTime(_fromMinutes(current)),
            endTime: _formatTime(_fromMinutes(current + periodMinutes)),
            isBreak: false,
            ringtone: ringtoneToSave,
          ).toMap());
          current += periodMinutes;
          periodCount++;
        }
      }

      // NEW: Add dedicated "End of day" slot at the very end
      await db.insert('periods', PeriodModel(
        categoryId: widget.categoryId,
        day: day,
        title: 'End of day',
        startTime: _formatTime(endTime!),
        endTime: _formatTime(endTime!),
        isBreak: false,
        ringtone: 'assets/audio/close day.mp3',
      ).toMap());
    }
    // Save exact configuration for future "Edit" pre-filling
    final configJson = jsonEncode({
      'startTime': _formatTime(startTime!),
      'endTime': _formatTime(endTime!),
      'periodMinutes': periodMinutes,
      'sequentialRingtones': sequentialRingtones,
      'breaks': breaks.map((b) => {
        'start': _formatTime(b.start),
        'duration': b.duration,
        'ringtone': b.ringtone,
      }).toList(),
    });

    await db.update('categories', {
      'configured': 1,
      'ringtoneDuration': ringtoneDuration,
      'skippedDays': skippedDays.join(','),
      'skippedDates': skippedDates.map((d) => d.toIso8601String()).join(','),
      'scheduleConfig': configJson,
    }, where: 'id = ?', whereArgs: [widget.categoryId]);
    
    if (mounted) {
      // Navigate to Week Schedule but allow standard "Back" to return here
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WeekSchedulePage(categoryId: widget.categoryId),
          settings: const RouteSettings(name: 'WeekSchedulePage'),
        ),
      );
    }
  }
}

class _BreakData {
  final TimeOfDay start;
  final int duration;
  final String? ringtone;
  _BreakData({required this.start, required this.duration, this.ringtone});
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If the user is deleting, just return the new value as is
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    var text = newValue.text;

    // Prevent typing more than 10 characters (DD/MM/YYYY)
    if (text.length > 10) {
      return oldValue;
    }

    // Automatically add '/' after 2nd and 5th character
    if (text.length == 2 || text.length == 5) {
      return TextEditingValue(
        text: '$text/',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    return newValue;
  }
}
