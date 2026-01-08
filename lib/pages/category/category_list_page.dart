import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/category_model.dart';
import '../general/general_schedule_page.dart';
import '../week/week_schedule_page.dart';
import '../dashboard/dashboard_page.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
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

  Future<void> _deleteCategory(int id) async {
    final db = await AppDB.instance.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
    _loadCategories();
  }

  void _openGeneralSchedule(CategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
      ),
    ).then((_) => _loadCategories());
  }

  void _openWeekSchedule(CategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeekSchedulePage(categoryId: cat.id!),
      ),
    ).then((_) => _loadCategories());
  }

  void _checkAllConfigured() {
    if (categories.every((c) => c.configured == 1)) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configure all categories first!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _checkAllConfigured,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          return Card(
            child: ListTile(
              title: Text(cat.name),
              subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
              leading: CircleAvatar(backgroundColor: Color(cat.color)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
