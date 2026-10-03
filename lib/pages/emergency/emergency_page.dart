import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/esp32_api_service.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});
  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool _isSending = false;
  Timer? _longPressTimer;
  bool _isPressing = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }


  /// Sends a command to the ESP32 via TCP Socket.
  Future<void> _sendCommand(String command, String successMessage) async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      // The service handles connection and command termination
      await Esp32ApiService.sendRaw(command);
      _showMessage(successMessage);
    } catch (e) {
      _showMessage("SyncroBell device not reachable. Please check your connection.", error: true);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }


  /// Starts the timer for a long press to turn the siren ON.
  void _startLongPressTimer() {
    if (_isSending) return;

    setState(() => _isPressing = true);

    // After 3 seconds, send the 'ON' command ($E#)
    _longPressTimer = Timer(const Duration(seconds: 3), () {
      _sendCommand("\$E#", "🚨 Emergency Activated");
      _cancelLongPress(); 
    });
  }

  /// Cancels the long press timer if the user releases their finger early.
  void _cancelLongPress() {
    _longPressTimer?.cancel();
    if (mounted) {
      setState(() => _isPressing = false);
    }
  }

  /// Handles a quick tap to turn the siren OFF ($E,OFF#).
  void _quickTap() {
    if (_longPressTimer?.isActive ?? false) {
      _cancelLongPress();
      _sendCommand("\$E,OFF#", "✅ Emergency Deactivated");
    }
  }

  void _showMessage(String msg, {bool error = false}) {
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
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => _startLongPressTimer(), 
              onTapUp: (_) => _quickTap(), 
              onTapCancel: _cancelLongPress, 
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
                          ? const Color.fromRGBO(255, 0, 0, 0.9)
                          : const Color.fromRGBO(255, 0, 0, 0.5),
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
                        Icons.notifications_active, 
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
