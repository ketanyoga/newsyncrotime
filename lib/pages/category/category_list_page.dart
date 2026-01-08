// import 'package:flutter/material.dart';
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import '../dashboard/dashboard_page.dart';
//
// class CategoryListPage extends StatefulWidget {
//   const CategoryListPage({super.key});
//
//   @override
//   State<CategoryListPage> createState() => _CategoryListPageState();
// }
//
// class _CategoryListPageState extends State<CategoryListPage> {
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
//   Future<void> _deleteCategory(int id) async {
//     final db = await AppDB.instance.database;
//     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//     _loadCategories();
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
//       ),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
//       ),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     if (categories.every((c) => c.configured == 1)) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Configure all categories first!')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: _checkAllConfigured,
//           )
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           return Card(
//             child: ListTile(
//               title: Text(cat.name),
//               subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
//               leading: CircleAvatar(backgroundColor: Color(cat.color)),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
//                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
//                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import '../dashboard/dashboard_page.dart';
// import 'dart:math'; // Import for random color generation
//
// class CategoryListPage extends StatefulWidget {
//   const CategoryListPage({super.key});
//
//   @override
//   State<CategoryListPage> createState() => _CategoryListPageState();
// }
//
// class _CategoryListPageState extends State<CategoryListPage> {
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
//   Future<void> _deleteCategory(int id) async {
//     final db = await AppDB.instance.database;
//     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//     _loadCategories();
//   }
//
//   // Future<void> _addCategory(String name) async {
//   //   final db = await AppDB.instance.database;
//   //   final newCategory = CategoryModel(
//   //     name: name,
//   //     color: (Random().nextDouble() * 0xFFFFFF).toInt(),
//   //     configured: 0,
//   //   );
//   //   await db.insert('categories', newCategory.toMap());
//   //   _loadCategories();
//   // }
//
//   Future<void> _addCategory(String name) async {
//     final db = await AppDB.instance.database;
//     final now = DateTime.now();final newCategory = CategoryModel(
//       name: name,
//       color: (Random().nextDouble() * 0xFFFFFF).toInt() | 0xFF000000, // Ensure full opacity
//       configured: false, // Use boolean false
//       startDate: now.toIso8601String(), // Convert DateTime to String
//       endDate: now.add(const Duration(days: 7)).toIso8601String(), // Convert DateTime to String
//     );
//     await db.insert('categories', newCategory.toMap());
//     _loadCategories();
//   }
//
//
//
//   void _showAddCategoryDialog() {
//     final TextEditingController nameController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add Category'),
//           content: TextField(
//             controller: nameController,
//             decoration: const InputDecoration(hintText: "Category Name"),
//           ),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: const Text('Add'),
//               onPressed: () {
//                 if (nameController.text.isNotEmpty) {
//                   _addCategory(nameController.text);
//                   Navigator.of(context).pop();
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
//       ),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
//       ),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     if (categories.every((c) => c.configured == 1)) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Configure all categories first!')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: _checkAllConfigured,
//           )
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           return Card(
//             child: ListTile(
//               title: Text(cat.name),
//               subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
//               leading: CircleAvatar(backgroundColor: Color(cat.color).withOpacity(1.0)),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
//                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
//                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddCategoryDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../models/category_model.dart';
import '../general/general_schedule_page.dart';
import '../week/week_schedule_page.dart';
import '../dashboard/dashboard_page.dart';
import 'create_category_page.dart'; // Import the new page

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
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteCategory(int id) async {
    final db = await AppDB.instance.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
    _loadCategories();
  }

  void _navigateAndRefresh() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
    ).then((_) {
      // When we return from CreateCategoryPage, reload the categories
      setState(() {
        loading = true;
      });
      _loadCategories();
    });
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
    final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
    if (allConfigured) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create and configure all categories first!')),
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
              subtitle: Text('Configured: ${cat.configured ? "Yes" : "No"}'),
              leading: CircleAvatar(backgroundColor: Color(cat.color).withOpacity(1.0)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh, // Changed to navigate
        child: const Icon(Icons.add),
      ),
    );
  }
}

