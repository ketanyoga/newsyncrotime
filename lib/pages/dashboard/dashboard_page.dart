import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/esp32_api_service.dart';
import '../../database/app_database.dart';
import '../announcement/announcement_page.dart';
import '../category/category_list_page.dart';
import '../category/create_category_page.dart';
import '../emergency/emergency_page.dart';
import '../today_schedule_page.dart';
import 'widgets/device_schedule_manager_sheet.dart';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  String time = "--:--";
  String date = "";
  String nextPeriodInfo = "Loading...";
  Map<String, dynamic>? nextPeriodData; 
  List<Map<String, dynamic>> todayPeriods = []; 
  List<Map<String, dynamic>> skippedPeriods = []; // Store multiple skipped periods
  bool _isEntireDaySkipped = false;
  bool get isSkipActive => _isEntireDaySkipped || skippedPeriods.isNotEmpty;
  Timer? timer;
  bool hasSchedule = false;
  int currentVolume = 70;
  String? orgName;
  bool _isDeviceConnected = false;

  StreamSubscription<bool>? _connectionSub;
  late final Future<Database> _dbFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dbFuture = AppDB.instance.database;
    _isDeviceConnected = Esp32ApiService.isConnected;
    _connectionSub = Esp32ApiService.connectionStateStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isDeviceConnected = connected;
        });
      }
    });
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectionAndInit();
    }
  }

  Future<void> _checkConnectionAndInit() async {
    final connected = await Esp32ApiService.checkConnection();
    if (mounted) {
      setState(() {
        _isDeviceConnected = connected;
      });
      _init();
    }
  }

  Future<void> _init() async {
    final db = await _dbFuture;
    final prefs = await SharedPreferences.getInstance();
    
    if (mounted) {
      setState(() {
        orgName = prefs.getString('org_name');
        _isDeviceConnected = Esp32ApiService.isConnected;
      });
    }

    final countResult =
    await db.rawQuery('SELECT COUNT(*) as c FROM categories');
    if (mounted) {
      setState(() {
        final count = countResult.first['c'] as int?;
        hasSchedule = (count ?? 0) > 0;
        if (!hasSchedule) {
          nextPeriodInfo = "No schedule created";
        }
      });
    }

    if (hasSchedule) {
      _loadNextPeriod();
      timer?.cancel();
      timer = Timer.periodic(const Duration(minutes: 1), (_) => _loadNextPeriod());
    } else {
      timer?.cancel();
      time = "--:--";
      nextPeriodInfo = "No schedule created";
    }
  }

  Future<List<int>> _getActiveCategoryIds(Database db) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final List<int> ids = [];
    final categoriesRes = await db.query('categories');
    for (var row in categoriesRes) {
      try {
        final start = DateTime.parse(row['startDate'] as String);
        final end = DateTime.parse(row['endDate'] as String);
        
        final startDate = DateTime(start.year, start.month, start.day);
        final endDate = DateTime(end.year, end.month, end.day);

        if (today.isAtSameMomentAs(startDate) || 
            today.isAtSameMomentAs(endDate) ||
            (today.isAfter(startDate) && today.isBefore(endDate))) {
          ids.add(row['id'] as int);
        }
      } catch (e) {
        debugPrint("Error parsing date for category: $e");
      }
    }
    return ids;
  }

  Future<void> _loadNextPeriod() async {
    final db = await _dbFuture;
    
    final activeIds = await _getActiveCategoryIds(db);
    if (activeIds.isEmpty) {
      if (mounted) {
        setState(() {
          time = "--:--";
          nextPeriodInfo = "No active category for today";
        });
      }
      return;
    }

    final List<Map<String, dynamic>> allValidPeriods = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final String currentDay = DateFormat('EEEE').format(now).toUpperCase();

    // 1. Collect all valid periods from ALL active categories
    for (int activeId in activeIds) {
      final catRes = await db.query('categories', where: 'id = ?', whereArgs: [activeId]);
      if (catRes.isEmpty) continue;

      // Check Exclusions for this specific category
      final skippedDaysStr = catRes.first['skippedDays'] as String? ?? "";
      final skippedDays = skippedDaysStr.split(',').where((s) => s.isNotEmpty).map(int.parse).toList();
      if (skippedDays.contains(now.weekday % 7)) continue;

      final skippedDatesStr = catRes.first['skippedDates'] as String? ?? "";
      final skippedDates = skippedDatesStr.split(',').where((s) => s.isNotEmpty).map(DateTime.parse).toList();
      if (skippedDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) continue;

      // Fetch periods
      final List<Map<String, dynamic>> rawResult = await db.rawQuery(
        'SELECT * FROM periods WHERE categoryId = ? AND UPPER(day) = ?',
        [activeId, currentDay],
      );
      
      // Inject logical start for this category into each period map for sorting
      String logicalStart = "00:00";
      if (catRes.first['scheduleConfig'] != null) {
        try {
          final config = jsonDecode(catRes.first['scheduleConfig'] as String);
          logicalStart = config['startTime'] ?? "00:00";
        } catch (_) {}
      }

      for (var p in rawResult) {
        final mutableP = Map<String, dynamic>.from(p);
        mutableP['@logicalStart'] = logicalStart;
        allValidPeriods.add(mutableP);
      }
    }

    if (allValidPeriods.isEmpty) {
      if (mounted) setState(() { time = "--:--"; nextPeriodInfo = "No periods scheduled for today"; });
      return;
    }

    int toMinutes(String timeStr) {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    // 2. Sort logically using each period's parent category logicalStart
    allValidPeriods.sort((a, b) {
      final int startA = toMinutes(a['@logicalStart']);
      final int startB = toMinutes(b['@logicalStart']);

      int am = toMinutes(a['startTime']);
      int bm = toMinutes(b['startTime']);

      if (am < startA) am += 1440;
      if (bm < startB) bm += 1440;

      return am.compareTo(bm);
    });

    // 3. Find the NEXT period based on current time
    final TimeOfDay currentTimeOfDay = TimeOfDay.now();
    final String currentTimeStr =
        '${currentTimeOfDay.hour.toString().padLeft(2, '0')}:${currentTimeOfDay.minute.toString().padLeft(2, '0')}';
    final int nowMinutes = toMinutes(currentTimeStr);
    
    Map<String, dynamic>? next;

    for (var p in allValidPeriods) {
      final int logicalStartM = toMinutes(p['@logicalStart']);
      int pStart = toMinutes(p['startTime']);
      
      // Handle midnight wrap in the comparison
      if (pStart < logicalStartM) pStart += 1440;
      
      if (pStart > nowMinutes) {
        next = p;
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      todayPeriods = allValidPeriods; // Save the full list
      if (next == null) {
        time = "--:--";
        nextPeriodInfo = "No more periods today";
        nextPeriodData = null;
      } else {
        time = next['startTime'] as String;
        nextPeriodInfo = "Next: ${next['title'] as String}";
        nextPeriodData = next;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionSub?.cancel();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, isSmallScreen ? 12 : 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _topBar(),
                        if (isSkipActive && skippedPeriods.isNotEmpty) _skipInfoCard(isSmallScreen),
                        const Spacer(flex: 1),
                        _timeHeroCard(isSmallScreen),
                        const Spacer(flex: 2),
                        _primaryActionCard(isSmallScreen),
                        const Spacer(flex: 2),
                        _sectionTitle("Quick Actions"),
                        const SizedBox(height: 12),
                        _quickActionsRow(isSmallScreen),
                        const Spacer(flex: 2),
                        _secondaryActionCard(isSmallScreen),
                        const Spacer(flex: 2),
                        _emergencyCard(isSmallScreen),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _skipInfoCard(bool isSmall) {
    if (skippedPeriods.isEmpty && !_isEntireDaySkipped) return const SizedBox.shrink();

    final bool isEntireDay = _isEntireDaySkipped ||
        (todayPeriods.isNotEmpty && skippedPeriods.length >= todayPeriods.length);

    if (isEntireDay) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withAlpha((255 * 0.2).round())),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_busy_rounded, color: Colors.orange, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SKIPPING ENTIRE DAY",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.orange, letterSpacing: 1)),
                  Text(
                    "All ${todayPeriods.length} bells for today are skipped",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _handleRedoEntireDay,
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text("UNDO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: skippedPeriods.map((period) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withAlpha((255 * 0.2).round())),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_paused_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SKIPPING BELL",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.orange, letterSpacing: 1)),
                  Text(
                    "${period['title']} at ${period['startTime']}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _handleRedoSpecificSkip(period),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text("UNDO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _getTodayHardwareDayCode() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.sunday: return "U";
      case DateTime.monday: return "M";
      case DateTime.tuesday: return "T";
      case DateTime.wednesday: return "W";
      case DateTime.thursday: return "H";
      case DateTime.friday: return "F";
      case DateTime.saturday: return "S";
      default: return "M";
    }
  }

  void _skipEntireDay() async {
    final messenger = ScaffoldMessenger.of(context);
    final dayCode = _getTodayHardwareDayCode();
    try {
      await Esp32ApiService.sendRaw("\$DEL,$dayCode#");
      
      if (mounted) {
        setState(() {
          _isEntireDaySkipped = true;
          skippedPeriods.clear();
          skippedPeriods.addAll(todayPeriods);
        });
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Entire day's schedule skipped on device!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Unable to skip entire day: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _skipSpecificDate() async {
    final messenger = ScaffoldMessenger.of(context);
    final db = await _dbFuture;
    final activeIds = await _getActiveCategoryIds(db);

    List<int> catSkippedDays = [0]; // Default Sunday
    List<DateTime> localDates = [];

    // Load active category skippedDays and skippedDates
    for (int catId in activeIds) {
      final catRes = await db.query('categories', where: 'id = ?', whereArgs: [catId]);
      if (catRes.isNotEmpty) {
        final cat = catRes.first;
        final daysStr = cat['skippedDays'] as String? ?? "0";
        catSkippedDays = daysStr
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList();

        final datesStr = cat['skippedDates'] as String? ?? "";
        final dates = datesStr
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(DateTime.parse)
            .toList();
        for (var d in dates) {
          if (!localDates.any((existing) => existing.year == d.year && existing.month == d.month && existing.day == d.day)) {
            localDates.add(d);
          }
        }
      }
    }

    // Save a copy of initial dates to detect newly added dates
    final List<DateTime> initialDates = List.from(localDates);

    if (!mounted) return;

    DateTime viewMonth = DateTime.now();

    final List<DateTime>? selectedDates = await showDialog<List<DateTime>>(
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("All Selected Dates"),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: localDates.isEmpty
                              ? const Text("No dates selected.")
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: localDates.length,
                                  itemBuilder: (ctx, index) {
                                    return ListTile(
                                      title: Text(DateFormat('EEEE, dd MMMM yyyy').format(localDates[index])),
                                      leading: const Icon(Icons.event, color: Colors.red),
                                    );
                                  },
                                ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE")),
                        ],
                      ),
                    );
                  },
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
                          onPressed: () => setDialogState(() => viewMonth = DateTime(viewMonth.year, viewMonth.month - 1)),
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
                          
                          int weekdayForSkip = date.weekday % 7; 
                          final bool isSkippedDay = catSkippedDays.contains(weekdayForSkip);
                          
                          final bool isManuallySelected = localDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);

                          final bool shouldShowRed = isSkippedDay || isManuallySelected;

                          return GestureDetector(
                            onTap: () {
                              if (isSkippedDay) {
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
                onPressed: () => Navigator.pop(context, null),
                child: const Text("CANCEL", style: TextStyle(color: Color(0xFF8E8E93))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, localDates),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SAVE & SEND TO DEVICE"),
              ),
            ],
          );
        },
      ),
    );

    if (selectedDates == null) return;

    try {
      // 1. Identify newly added dates that were not in initialDates
      final newlyAddedDates = selectedDates.where((d) =>
        !initialDates.any((existing) =>
          existing.year == d.year && existing.month == d.month && existing.day == d.day
        )
      ).toList();

      // 2. Save full updated dates to local SQLite database
      final datesIsoStr = selectedDates.map((d) => d.toIso8601String()).join(',');
      for (int catId in activeIds) {
        await db.update('categories', {'skippedDates': datesIsoStr}, where: 'id = ?', whereArgs: [catId]);
      }

      // 3. Send ONLY newly added dates to the ESP32 device memory
      if (newlyAddedDates.isNotEmpty) {
        for (final d in newlyAddedDates) {
          final formattedDate = DateFormat('dd/MM/yy').format(d);
          int slotIndex = selectedDates.indexWhere((existing) =>
            existing.year == d.year && existing.month == d.month && existing.day == d.day
          );
          if (slotIndex == -1) slotIndex = selectedDates.length - 1;
          final slotNum = (slotIndex + 1).clamp(1, 10).toString().padLeft(2, '0');

          await Esp32ApiService.sendRaw("\$H,$slotNum,$formattedDate#");
          
          // Wait for acknowledgment handshake from ESP32
          try {
            await Esp32ApiService.waitForAnyResponse(["OK: H", "OK", "ERROR"], timeout: const Duration(seconds: 3));
          } catch (_) {}

          await Future.delayed(const Duration(milliseconds: 150));
        }

        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text("Added ${newlyAddedDates.length} new holiday date(s) to device!"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          _init();
        }
      } else {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text("Holiday dates updated locally!"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          _init();
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Failed to send holiday dates: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSkipSelectionSheet() {
    int toMinutes(String timeStr) {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    
    final now = TimeOfDay.now();
    final nowM = now.hour * 60 + now.minute;
    
    final futurePeriods = todayPeriods.where((p) {
      int pStart = toMinutes(p['startTime']);
      bool alreadySkipped = skippedPeriods.any((s) => s['id'] == p['id'] && s['startTime'] == p['startTime']);
      if (alreadySkipped) return false;

      return pStart > nowM || (p['@logicalStart'] != null && pStart < toMinutes(p['@logicalStart']));
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Skip Schedule Options", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // --- QUICK SKIP CARDS ---
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Colors.orange.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _skipEntireDay();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.event_busy_rounded, color: Colors.orange, size: 28),
                              SizedBox(height: 8),
                              Text("Skip Entire Day", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("Cancel today's bells", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _skipSpecificDate();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Color(0xFF007AFF), size: 28),
                              SizedBox(height: 8),
                              Text("Skip Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 2),
                              Text("Calendar holiday", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text("Skip Specific Bell Time", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),

              if (futurePeriods.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("No more available periods to skip today.")))
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: futurePeriods.length,
                    itemBuilder: (context, i) {
                      final p = futurePeriods[i];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFF2F2F7), child: Icon(Icons.notifications_off_rounded, color: Colors.orange, size: 20)),
                        title: Text(p['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Rings at ${p['startTime']}"),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF007AFF)),
                        onTap: () {
                          Navigator.pop(context);
                          _applySkip(p);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _applySkip(Map<String, dynamic> period) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final time = period['startTime']; 
      await Esp32ApiService.sendRaw("\$SKIP,$time#");
      
      if (mounted) {
        setState(() {
          skippedPeriods.add(period);
        });
        messenger.showSnackBar(SnackBar(content: Text("Added skip for ${period['title']} at $time"), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Unable to skip bell: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _handleRedoSpecificSkip(Map<String, dynamic> period) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final time = period['startTime'];
      await Esp32ApiService.sendRaw("\$SKIPCANCEL,$time#");
      
      if (mounted) {
        setState(() {
          _isEntireDaySkipped = false;
          skippedPeriods.removeWhere((p) => p['id'] == period['id'] && p['startTime'] == period['startTime']);
        });
        messenger.showSnackBar(SnackBar(content: Text("Restored bell: ${period['title']} at $time"), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Unable to restore bell: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _handleRedoEntireDay() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      for (final period in todayPeriods) {
        final time = period['startTime'];
        await Esp32ApiService.sendRaw("\$SKIPCANCEL,$time#");
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      if (mounted) {
        setState(() {
          _isEntireDaySkipped = false;
          skippedPeriods.clear();
        });
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Restored today's entire schedule!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Unable to restore schedule: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRedoSkip() {
    if (_isEntireDaySkipped || (todayPeriods.isNotEmpty && skippedPeriods.length >= todayPeriods.length)) {
      _handleRedoEntireDay();
    } else if (skippedPeriods.isNotEmpty) {
      _handleRedoSpecificSkip(skippedPeriods.last);
    }
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (orgName != null && orgName!.isNotEmpty) ? orgName! : "SyncroBell",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isDeviceConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isDeviceConnected ? "Connected to SyncroBell" : "Not connected to device",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isDeviceConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: Colors.black.withAlpha((255 * 0.05).round()),
              child: IconButton(
                onPressed: () async {
                  final connected = await Esp32ApiService.checkConnection();
                  if (mounted) {
                    setState(() => _isDeviceConnected = connected);
                    DeviceScheduleManagerSheet.show(context);
                  }
                },
                icon: Icon(
                  _isDeviceConnected ? Icons.router_rounded : Icons.wifi_find_rounded,
                  color: _isDeviceConnected ? const Color(0xFF34C759) : Colors.red,
                  size: 22,
                ),
                splashRadius: 24,
                tooltip: _isDeviceConnected ? "Machine Schedules" : "Connect Device",
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: Colors.black.withAlpha((255 * 0.05).round()),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ).then((_) => _init());
                },
                icon: const Icon(Icons.settings_rounded, color: Color(0xFF007AFF), size: 22),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timeHeroCard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((255 * 0.03).round()), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          SizedBox(
            height: isSmall ? 80 : 120,
            child: Lottie.asset(
              'assets/lottie/clock.json',
              repeat: true,
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Text(
            time,
            style: TextStyle(
              fontSize: isSmall ? 48 : 64,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _primaryActionCard(bool isSmall) {
    return _iosNavCard(
      icon: Icons.calendar_today_rounded,
      title: hasSchedule ? "View Today’s Schedule" : "Create Schedule",
      isSmall: isSmall,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            hasSchedule ? const TodaySchedulePage() : const CreateCategoryPage(),
            settings: RouteSettings(name: hasSchedule ? 'TodaySchedulePage' : 'CreateCategoryPage'),
          ),
        ).then((_) => _init());
      },
    );
  }

  Widget _quickActionsRow(bool isSmall) {
    return Row(
      children: [
        _quickAction(
          "Skip",
          Icons.skip_next_rounded,
          isSkipActive ? _handleRedoSkip : _showSkipSelectionSheet,
          isSmall,
          color: isSkipActive ? Colors.orange : const Color(0xFF007AFF),
        ),
        const SizedBox(width: 10),
        _quickAction("Voice", Icons.campaign_rounded, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementPage()));
        }, isSmall),
        const SizedBox(width: 10),
        _quickAction("Vol", Icons.volume_up_rounded, _showVolumeDialog, isSmall),
        const SizedBox(width: 10),
        _quickAction("Ring", Icons.touch_app_rounded, _showManualRingDurationDialog, isSmall),
      ],
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap, bool isSmall, {Color color = const Color(0xFF007AFF)}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isSmall ? 14 : 18),
            child: Column(
              children: [
                Icon(icon, size: isSmall ? 22 : 26, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVolumeDialog() {
    int localVolume = currentVolume;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text("Device Volume", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded, size: 64, color: Color(0xFF007AFF)),
              const SizedBox(height: 20),
              Text("$localVolume%", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
              Slider(
                value: localVolume.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) => setDialogState(() => localVolume = value.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                setState(() => currentVolume = localVolume);
                Navigator.pop(context);
                try {
                  final espVol = ((currentVolume * 30) / 100).round().clamp(0, 30);
                  await Esp32ApiService.sendRaw("\$V,$espVol#");
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text("Unable to reach SyncroBell: $e"), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("APPLY"),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualRingDurationDialog() {
    int selectedDuration = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text("Manual Ring", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Set how long the bell should ring:"),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [0, 10, 20, 30].map((dur) {
                  return ChoiceChip(
                    label: Text(dur == 0 ? "Full" : "${dur}s"),
                    selected: selectedDuration == dur,
                    onSelected: (selected) {
                      if (selected) setDialogState(() => selectedDuration = dur);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                selectedDuration == 0 ? "Full Audio Duration" : "$selectedDuration Seconds",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF007AFF)),
              ),
              Slider(
                value: selectedDuration.toDouble(),
                min: 0,
                max: 120,
                divisions: 120,
                onChanged: (value) => setDialogState(() => selectedDuration = value.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await Esp32ApiService.sendRaw("\$D,$selectedDuration#");
                  await Future.delayed(const Duration(milliseconds: 100));
                  await Esp32ApiService.playFile("SchoolBell.mp3");
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text("Unable to reach SyncroBell: $e"), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("RING NOW"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryActionCard(bool isSmall) {
    return _iosNavCard(
      icon: Icons.settings_rounded,
      title: "Manage Schedules",
      isSmall: isSmall,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CategoryListPage(),
            settings: const RouteSettings(name: 'CategoryListPage'),
          ),
        ).then((_) => _init());
      },
    );
  }

  Widget _iosNavCard({
    required IconData icon,
    required String title,
    required bool isSmall,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Row(
            children: [
              Icon(icon, size: isSmall ? 22 : 26, color: const Color(0xFF007AFF)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 15 : 17,
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
      ),
    );
  }

  Widget _emergencyCard(bool isSmall) {
    return Material(
      color: const Color(0xFFFF3B30),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmergencyPage()),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 22),
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
      ),
    );
  }

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
