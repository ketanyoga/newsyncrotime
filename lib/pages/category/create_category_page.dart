import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/category_model.dart';
import 'category_list_page.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final nameCtrl = TextEditingController();
  DateTime? startDate, endDate;

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty || startDate == null || endDate == null) return;

    final db = await AppDB.instance.database;
    await db.insert(
      'categories',
      CategoryModel(
        name: nameCtrl.text,
        color: Colors.blue.value,
        startDate: startDate!.toIso8601String(),
        endDate: endDate!.toIso8601String(),
      ).toMap(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CategoryListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Text(startDate == null ? 'Select Start Date' : startDate.toString()),
              onPressed: () async {
                startDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );
                setState(() {});
              },
            ),
            ElevatedButton(
              child: Text(endDate == null ? 'Select End Date' : endDate.toString()),
              onPressed: () async {
                endDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );
                setState(() {});
              },
            ),
            const Spacer(),
            ElevatedButton(onPressed: _save, child: const Text('SAVE'))
          ],
        ),
      ),
    );
  }
}
