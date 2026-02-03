import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});
  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  static const String espIp = "192.168.4.1"; // Make sure this IP is correct

  bool _isSending = false;
  Timer? _longPressTimer;
  bool _isPressing = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }


  /// Generic function to send a command to the ESP32.
  Future<void> _sendCommand(String command, String successMessage) async {
    // Prevent sending a new command while one is already in progress.
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final res = await http.post(
        Uri.parse("http://$espIp/emergency/trigger"),
        body: command, // Send the specific command provided.
      ).timeout(const Duration(seconds: 5)); // Add a timeout for robustness.

      if (res.statusCode == 200) {
        _showMessage(successMessage);
      } else {
        _showMessage("ESP32 error: Status code ${res.statusCode}", error: true);
      }
    } catch (e) {
      _showMessage("Failed to connect to ESP32: $e", error: true);
    } finally {
      // Ensure the UI is updated only if the widget is still mounted.
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }


  /// Starts the timer for a long press to turn the siren ON.
  void _startLongPressTimer() {
    if (_isSending) return;

    setState(() => _isPressing = true);

    // After 3 seconds, send the 'ON' command.
    _longPressTimer = Timer(const Duration(seconds: 3), () {
      _sendCommand("\$E,on#", "🚨 Emergency Activated");
      _cancelLongPress(); // Reset the UI after the command is sent.
    });
  }


  /// Cancels the long press timer if the user releases their finger early.
  void _cancelLongPress() {
    _longPressTimer?.cancel();
    if (mounted) {
      setState(() => _isPressing = false);
    }
  }


  /// Handles a quick tap to turn the siren OFF.
  void _quickTap() {
    // A quick tap only happens if the long press timer is still active (i.e., not yet fired).
    // This prevents the 'off' command from firing right after the 'on' command.
    if (_longPressTimer?.isActive ?? false) {
      _cancelLongPress(); // Cancel the long press 'on' action.
      _sendCommand("\$E,off#", "✅ Emergency Deactivated");
    }
  }

  void _showMessage(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.green : Theme.of(context).colorScheme.primary,
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
            // --- MODIFIED GestureDetector ---
            GestureDetector(
              onTapDown: (_) => _startLongPressTimer(), // Start the timer on press down
              onTapUp: (_) => _quickTap(), // A quick release triggers the 'off' command
              onTapCancel: _cancelLongPress, // Also cancel if the gesture is interrupted
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
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
                  child: _isSending
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_active, // Bell Icon
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
            const SizedBox(height: 40),
            // --- MODIFIED Text ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "PRESS & HOLD for 3 seconds to ACTIVATE siren.\n\nQUICK TAP to DEACTIVATE.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
