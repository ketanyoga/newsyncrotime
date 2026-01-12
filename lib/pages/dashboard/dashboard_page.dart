// import 'package:flutter/material.dart';
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import 'dart:convert';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   List<CategoryModel> categories = [];
//   bool loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories');
//     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//     setState(() => loading = false);
//   }
//
//   Future<void> _sendToESP32() async {
//     final db = await AppDB.instance.database;
//     final allPeriods = await db.query('periods');
//
//     final payload = jsonEncode(allPeriods); // ready to send via TCP or HTTP
//     print('Payload for ESP32: $payload');
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Schedule exported to ESP32 (check console)')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Dashboard')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text('Total Categories: ${categories.length}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _sendToESP32,
//               child: const Text('Export Schedule to ESP32'),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: categories.map((c) {
//                   return ListTile(
//                     title: Text(c.name),
//                     leading: CircleAvatar(backgroundColor: Color(c.color)),
//                     subtitle: Text('Configured: ${c.configured == 1 ? "Yes" : "No"}'),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
























import 'package:flutter/material.dart';import '../../database/app_database.dart';
import '../../models/category_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<CategoryModel> categories = [];
  bool loading = true;

  // --- New State Variables ---
  bool _isConnected = false;
  String _nextPeriodTime = "N/A";
  Timer? _connectionTimer;
  final String _esp32Ip = "192.168.4.1"; // Default IP for ESP32 AP mode

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // Start checking for connection status periodically
    _connectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  /// Pings the ESP32 to check for a connection.
  Future<void> _checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('http://$_esp32Ip/status'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok' && mounted) {
          setState(() {
            _isConnected = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    final db = await AppDB.instance.database;
    final res = await db.query('categories');
    // The caret was here, assuming CategoryModel.fromMap is correct.
    categories = res.map((e) => CategoryModel.fromMap(e)).toList();
    setState(() => loading = false);
  }

  Future<void> _sendToESP32() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to ESP32!'), backgroundColor: Colors.red),
      );
      return;
    }

    final db = await AppDB.instance.database;
    final allPeriods = await db.query('periods');
    final payload = jsonEncode(allPeriods);

    try {
      final response = await http.post(
        Uri.parse('http://$_esp32Ip/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule sent successfully!'), backgroundColor: Colors.green),
        );
        // Here, you would parse the response or update the UI accordingly
        // For example, find the next period time from `allPeriods` and set it.
        // This is a simplified placeholder:
        setState(() {
          _nextPeriodTime = "18:00"; // Update with actual next period time
        });

      } else {
        throw Exception('Failed to send schedule');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- New UI Widgets ---
            ListTile(
              leading: Icon(
                Icons.wifi,
                color: _isConnected ? Colors.green : Colors.red,
              ),
              title: Text(_isConnected ? 'Connected to ESP32' : 'Disconnected'),
              subtitle: Text('Next scheduled event: $_nextPeriodTime'),
            ),
            const SizedBox(height: 16),
            // --- End of New UI Widgets ---

            Text('Total Categories: ${categories.length}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendToESP32,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.blue : Colors.grey,
              ),
              child: const Text('Export Schedule to ESP32'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: categories.map((c) {
                  return ListTile(
                    title: Text(c.name),
                    leading: CircleAvatar(backgroundColor: Color(c.color)),
                    subtitle: Text('Configured: ${c.configured == 1 ? "Yes" : "No"}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
