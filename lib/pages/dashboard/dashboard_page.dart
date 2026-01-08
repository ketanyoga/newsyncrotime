import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/category_model.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<CategoryModel> categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await AppDB.instance.database;
    final res = await db.query('categories');
    categories = res.map((e) => CategoryModel.fromMap(e)).toList();
    setState(() => loading = false);
  }

  Future<void> _sendToESP32() async {
    final db = await AppDB.instance.database;
    final allPeriods = await db.query('periods');

    final payload = jsonEncode(allPeriods); // ready to send via TCP or HTTP
    print('Payload for ESP32: $payload');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule exported to ESP32 (check console)')),
    );
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
            Text('Total Categories: ${categories.length}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendToESP32,
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
