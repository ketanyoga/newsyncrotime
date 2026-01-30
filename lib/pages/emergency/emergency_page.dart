import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Add this StatefulWidget class
class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});
  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  static const String espIp = "192.168.4.1"; // Make sure this IP is correct

  bool _sending = false;
  Timer? _longPressTimer;
  bool _isPressing = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> _triggerEmergency() async {
    // No longer checking for a locked state
    setState(() => _sending = true);

    try {
      // The HTTP post sends the "$E#" command as requested
      final res = await http.post(
        Uri.parse("http://$espIp/emergency/trigger"),
        body: "\$E#", // Sending the specified command
      );

      if (res.statusCode == 200) {
        _showMessage("🚨 Emergency Activated");
        // You might want to prevent further triggers after one successful send
        // For example: setState(() => _sending = true); // to lock the button
      } else {
        _showMessage("ESP32 error: Status code ${res.statusCode}", error: true);
      }
    } catch (e) {
      _showMessage("Failed to connect to ESP32: $e", error: true);
    } finally {
      // If you want the button to be reusable, set _sending to false
      // If not, you can leave it as true to "lock" it after sending.
      setState(() => _sending = false);
    }
  }

  void _startLongPressTimer() {
    // Do not start a new timer if a command is already being sent
    if (_sending) return;

    setState(() => _isPressing = true);

    // Timer waits for 3 seconds before executing the command
    _longPressTimer = Timer(const Duration(seconds: 3), () {
      _triggerEmergency();
      _cancelLongPressTimer(); // Stop the timer and reset pressing state
    });
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    setState(() => _isPressing = false);
  }

  void _showMessage(String msg, {bool error = false}) {
    // Ensure the widget is still in the tree before showing a SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => _startLongPressTimer(),
              onTapUp: (_) => _cancelLongPressTimer(),
              onTapCancel: _cancelLongPressTimer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  // The button is always red now
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isPressing
                          ? Colors.red.withOpacity(0.9)
                          : Colors.red.withOpacity(0.5),
                      blurRadius: _isPressing ? 50 : 30,
                    )
                  ],
                ),
                child: Center(
                  child: _sending
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications, // Bell Icon
                        color: Colors.white,
                        size: 60,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "EMERGENCY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Press and hold for 3 seconds in case of emergency.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
