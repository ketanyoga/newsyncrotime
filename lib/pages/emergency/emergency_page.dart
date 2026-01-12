import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  static const String espIp = "192.168.4.1";

  bool _locked = true;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyStatus();
  }

  Future<void> _fetchEmergencyStatus() async {
    try {
      final res =
      await http.get(Uri.parse("http://$espIp/emergency/status"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _locked = data["locked"] ?? true;
        });
      }
    } catch (_) {
      _locked = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _triggerEmergency() async {
    if (_locked) return;

    setState(() => _sending = true);

    try {
      final res =
      await http.post(Uri.parse("http://$espIp/emergency/trigger"));

      if (res.statusCode == 200) {
        setState(() => _locked = true);
        _showMessage("🚨 Emergency Activated");
      } else {
        _showMessage("ESP32 error", error: true);
      }
    } catch (_) {
      _showMessage("Failed to connect to ESP32", error: true);
    } finally {
      setState(() => _sending = false);
    }
  }

  void _showMessage(String msg, {bool error = false}) {
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _locked || _sending ? null : _triggerEmergency,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: _locked ? Colors.grey : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 30,
                    )
                  ],
                ),
                child: Center(
                  child: _sending
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _locked ? "LOCKED" : "EMERGENCY",
                        style: const TextStyle(
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
            Text(
              _locked
                  ? "Emergency already triggered.\nAdmin reset required."
                  : "Press only once in case of emergency.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
