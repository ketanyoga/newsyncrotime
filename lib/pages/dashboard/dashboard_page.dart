import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // Import path package
import 'dart:async';
import '../../services/esp32_api_service.dart';
import '../../database/app_database.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // State variables to manage UI and data
  String espResponse = "Press a button to get data.";
  String connectionStatus = "Disconnected";
  Color statusColor = Colors.red;
  bool isLoading = false;
  bool isSyncing = false;
  bool hasSchedule = false;

  // ** FIX 1: Add a StreamSubscription to listen for responses **
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();

    // ** FIX 2: Start listening to the response stream from the service **
    // This is the correct way to get data back from the service
    _socketSubscription = Esp32ApiService.listen().listen((data) {
      if (mounted) {
        // Update the UI with the most recent response from the ESP32
        setState(() => espResponse = data);
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          espResponse = "Stream Error: $error";
          statusColor = Colors.red;
          connectionStatus = "Error";
        });
      }
    });
  }

  // Check connection once at the start
  Future<void> _checkInitialStatus() async {
    setState(() => isLoading = true);
    final connected = await Esp32ApiService.checkConnection();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (connected) {
          connectionStatus = "Connected";
          statusColor = Colors.green;
          espResponse = "ESP32 Connected. Ready for commands.";
        } else {
          connectionStatus = "Disconnected";
          statusColor = Colors.red;
          espResponse = "Connection Failed. Connect to 'SchoolBell_AP' WiFi.";
        }
      });
    }
  }


  Future<void> _syncFullSchedule() async {
    final connected = await Esp32ApiService.checkConnection();
    if (!connected) {
      _showSnack("Not connected to ESP32. Check WiFi.", Colors.red);
      return;
    }

    setState(() {
      isSyncing = true;
      espResponse = "Preparing to send schedule...";
    });

    final db = await AppDB.instance.database;

    try {
      // Optional: stop any sound first
      await Esp32ApiService.sendRaw("\$STOP#");
      await Future.delayed(const Duration(milliseconds: 400));

      // You can send this once at beginning if your firmware supports clearing old slots
      // await Esp32ApiService.sendRaw("\$CLEAR#");   // ← only if your ESP firmware has this command

      // Decide which mode to use (you can later make this selectable in UI)
      const String currentMode = "SUMMER";   // ← CHANGE HERE when needed: SUMMER, WINTER, EXAM, ...

      // Get all periods (you can add WHERE categoryId = ? later)
      final List<Map<String, dynamic>> periods = await db.query(
        'periods',
        orderBy: 'day, startTime',
      );

      if (periods.isEmpty) {
        _showSnack("No periods found in database", Colors.orange);
        setState(() => espResponse = "Nothing to send.");
        return;
      }

      int sentCount = 0;

      for (final period in periods) {
        final dayFull = period['day'] as String?;
        final startTime = (period['startTime'] as String?)?.trim() ?? '';
        final isBreak = period['isBreak'] as int? ?? 0;
        final ringtoneRaw = period['ringtone'] as String? ?? '';

        if (dayFull == null || startTime.isEmpty) continue;

        // Convert day name → single letter code
        final dayCode = _dayToCode(dayFull);
        if (dayCode.isEmpty) continue;

        // Extract slot number from title (assuming "Period 1", "Period 2" ...)
        final slotMatch = RegExp(r'Period\s*(\d+)').firstMatch(period['title'] as String? ?? '');
        final slotNum = slotMatch != null ? int.tryParse(slotMatch.group(1)!) : null;

        if (slotNum == null || slotNum < 1 || slotNum > 9) {
          debugPrint("Skipping invalid slot: ${period['title']}");
          continue;
        }

        // Format time → must be HH:MM (pad if needed)
        String timeFormatted = startTime;
        if (timeFormatted.length == 4 && !timeFormatted.contains(':')) {
          timeFormatted = '${timeFormatted.substring(0,2)}:${timeFormatted.substring(2)}';
        }
        if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(timeFormatted)) {
          debugPrint("Invalid time format: $timeFormatted");
          continue;
        }

        // Track number logic
        int track = 1; // default
        if (ringtoneRaw.isNotEmpty) {
          final numMatch = RegExp(r'\d+').firstMatch(ringtoneRaw);
          if (numMatch != null) {
            track = int.tryParse(numMatch.group(0)!) ?? 1;
          }
        }
        // If isBreak == 1 you might want different track (e.g. short bell)
        if (isBreak == 1) {
          track = 3; // ← example: use track 3 for breaks – CHANGE AS NEEDED
        }

        // Build real command
        final command = "\$$currentMode,$dayCode$slotNum,$timeFormatted,$track#";

        await Esp32ApiService.sendRaw(command);
        sentCount++;

        // Small delay – many ESP32 command parsers are slow / buffer-limited
        await Future.delayed(const Duration(milliseconds: 150));

        // Optional: update UI every 5 commands
        if (sentCount % 5 == 0) {
          if (mounted) {
            setState(() {
              espResponse = "Sent $sentCount / ${periods.length} commands...";
            });
          }
        }
      }

      // Optional: activate mode (if not already done via $MD command)
      // await Esp32ApiService.sendRaw("\$MM,1#"); // 1 = Summer – only if needed

      if (mounted) {
        setState(() {
          espResponse = "Sync completed → sent $sentCount slot commands ($currentMode mode)";
        });
        _showSnack("Successfully sent $sentCount periods", Colors.green);
      }
    } catch (e, stack) {
      debugPrint("Sync error: $e\n$stack");
      if (mounted) {
        setState(() => espResponse = "Sync failed: $e");
        _showSnack("Error during sync: $e", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => isSyncing = false);
      }
    }
  }

// Helper: day name → code
  String _dayToCode(String day) {
    final map = {
      'Sunday': 'U',
      'Monday': 'M',
      'Tuesday': 'T',
      'Wednesday': 'W',
      'Thursday': 'H',
      'Friday': 'F',
      'Saturday': 'S',
    };
    return map[day.trim()] ?? '';
  }

  // ** FIX 3: `_getStatus` now just sends the command. The stream listener handles the response. **
  /// Gets the full status from the ESP32
  Future<void> _getStatus() async {
    setState(() {
      isLoading = true;
      espResponse = "Sending \$STATUS# command..."; // Give immediate feedback
    });
    // getStatus now just sends the command, it doesn't return a value.
    await Esp32ApiService.getStatus();
    if (!mounted) return;
    // We can set loading to false after a short delay to allow the response to arrive.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  /// Sends the current time to the ESP32
  Future<void> _sendTime() async {
    setState(() {
      isLoading = true;
      espResponse = "Sending time command..."; // Give immediate feedback
    });

    final now = DateTime.now();
    // Format: $R,DD-MM-YY,HH:MM:SS#
    final dateStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${(now.year % 100).toString().padLeft(2, '0')}";
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    final command = "\$R,$dateStr,$timeStr#";

    // sendRaw is `void`, so we just call it.
    await Esp32ApiService.sendRaw(command);
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ** FIX 5: Cancel the subscription in dispose to prevent memory leaks **
  @override
  void dispose() {
    _socketSubscription?.cancel();
    Esp32ApiService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The UI code is correct and reads from the state variables that are now properly updated.
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESP32 Sync Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(connectionStatus, style: TextStyle(color: statusColor)),
                const SizedBox(width: 8),
                Icon(Icons.wifi, color: statusColor),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Response Display Area
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  espResponse,
                  style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Sync Button
            ElevatedButton.icon(
              onPressed: isLoading || isSyncing ? null : _syncFullSchedule,
              icon: isSyncing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync),
              label: Text(isSyncing ? "Syncing..." : "Full Sync to ESP32"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),

            // Diagnostic Buttons
            ElevatedButton.icon(
              onPressed: isLoading || isSyncing ? null : _getStatus,
              icon: const Icon(Icons.info_outline),
              label: const Text("Get Status"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: isLoading || isSyncing ? null : _sendTime,
              icon: const Icon(Icons.today),
              label: const Text("Send Time to ESP32"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),

            if (isLoading && !isSyncing) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
