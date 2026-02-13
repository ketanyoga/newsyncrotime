// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import '../../database/app_database.dart';
// // // // // // // // import '../../models/category_model.dart';
// // // // // // // // import '../general/general_schedule_page.dart';
// // // // // // // // import '../week/week_schedule_page.dart';
// // // // // // // // import '../dashboard/dashboard_page.dart';
// // // // // // // //
// // // // // // // // class CategoryListPage extends StatefulWidget {
// // // // // // // //   const CategoryListPage({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // // // // //   List<CategoryModel> categories = [];
// // // // // // // //   bool loading = true;
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _loadCategories() async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     final res = await db.query('categories');
// // // // // // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // // // // //     setState(() => loading = false);
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _deleteCategory(int id) async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // // // // //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _checkAllConfigured() {
// // // // // // // //     if (categories.every((c) => c.configured == 1)) {
// // // // // // // //       Navigator.pushReplacement(
// // // // // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // // // // //     } else {
// // // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //         const SnackBar(content: Text('Configure all categories first!')),
// // // // // // // //       );
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('Categories'),
// // // // // // // //         actions: [
// // // // // // // //           IconButton(
// // // // // // // //             icon: const Icon(Icons.check),
// // // // // // // //             onPressed: _checkAllConfigured,
// // // // // // // //           )
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //       body: ListView.builder(
// // // // // // // //         itemCount: categories.length,
// // // // // // // //         itemBuilder: (_, index) {
// // // // // // // //           final cat = categories[index];
// // // // // // // //           return Card(
// // // // // // // //             child: ListTile(
// // // // // // // //               title: Text(cat.name),
// // // // // // // //               subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
// // // // // // // //               leading: CircleAvatar(backgroundColor: Color(cat.color)),
// // // // // // // //               trailing: Row(
// // // // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // // // //                 children: [
// // // // // // // //                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
// // // // // // // //                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
// // // // // // // //                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //           );
// // // // // // // //         },
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import '../../database/app_database.dart';
// // // // // // // // import '../../models/category_model.dart';
// // // // // // // // import '../general/general_schedule_page.dart';
// // // // // // // // import '../week/week_schedule_page.dart';
// // // // // // // // import '../dashboard/dashboard_page.dart';
// // // // // // // // import 'dart:math'; // Import for random color generation
// // // // // // // //
// // // // // // // // class CategoryListPage extends StatefulWidget {
// // // // // // // //   const CategoryListPage({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // // // // //   List<CategoryModel> categories = [];
// // // // // // // //   bool loading = true;
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _loadCategories() async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     final res = await db.query('categories');
// // // // // // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // // // // //     setState(() => loading = false);
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _deleteCategory(int id) async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // // // // //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // Future<void> _addCategory(String name) async {
// // // // // // // //   //   final db = await AppDB.instance.database;
// // // // // // // //   //   final newCategory = CategoryModel(
// // // // // // // //   //     name: name,
// // // // // // // //   //     color: (Random().nextDouble() * 0xFFFFFF).toInt(),
// // // // // // // //   //     configured: 0,
// // // // // // // //   //   );
// // // // // // // //   //   await db.insert('categories', newCategory.toMap());
// // // // // // // //   //   _loadCategories();
// // // // // // // //   // }
// // // // // // // //
// // // // // // // //   Future<void> _addCategory(String name) async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     final now = DateTime.now();final newCategory = CategoryModel(
// // // // // // // //       name: name,
// // // // // // // //       color: (Random().nextDouble() * 0xFFFFFF).toInt() | 0xFF000000, // Ensure full opacity
// // // // // // // //       configured: false, // Use boolean false
// // // // // // // //       startDate: now.toIso8601String(), // Convert DateTime to String
// // // // // // // //       endDate: now.add(const Duration(days: 7)).toIso8601String(), // Convert DateTime to String
// // // // // // // //     );
// // // // // // // //     await db.insert('categories', newCategory.toMap());
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // //   void _showAddCategoryDialog() {
// // // // // // // //     final TextEditingController nameController = TextEditingController();
// // // // // // // //     showDialog(
// // // // // // // //       context: context,
// // // // // // // //       builder: (context) {
// // // // // // // //         return AlertDialog(
// // // // // // // //           title: const Text('Add Category'),
// // // // // // // //           content: TextField(
// // // // // // // //             controller: nameController,
// // // // // // // //             decoration: const InputDecoration(hintText: "Category Name"),
// // // // // // // //           ),
// // // // // // // //           actions: [
// // // // // // // //             TextButton(
// // // // // // // //               child: const Text('Cancel'),
// // // // // // // //               onPressed: () => Navigator.of(context).pop(),
// // // // // // // //             ),
// // // // // // // //             TextButton(
// // // // // // // //               child: const Text('Add'),
// // // // // // // //               onPressed: () {
// // // // // // // //                 if (nameController.text.isNotEmpty) {
// // // // // // // //                   _addCategory(nameController.text);
// // // // // // // //                   Navigator.of(context).pop();
// // // // // // // //                 }
// // // // // // // //               },
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         );
// // // // // // // //       },
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _checkAllConfigured() {
// // // // // // // //     if (categories.every((c) => c.configured == 1)) {
// // // // // // // //       Navigator.pushReplacement(
// // // // // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // // // // //     } else {
// // // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //         const SnackBar(content: Text('Configure all categories first!')),
// // // // // // // //       );
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('Categories'),
// // // // // // // //         actions: [
// // // // // // // //           IconButton(
// // // // // // // //             icon: const Icon(Icons.check),
// // // // // // // //             onPressed: _checkAllConfigured,
// // // // // // // //           )
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //       body: ListView.builder(
// // // // // // // //         itemCount: categories.length,
// // // // // // // //         itemBuilder: (_, index) {
// // // // // // // //           final cat = categories[index];
// // // // // // // //           return Card(
// // // // // // // //             child: ListTile(
// // // // // // // //               title: Text(cat.name),
// // // // // // // //               subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
// // // // // // // //               leading: CircleAvatar(backgroundColor: Color(cat.color).withOpacity(1.0)),
// // // // // // // //               trailing: Row(
// // // // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // // // //                 children: [
// // // // // // // //                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
// // // // // // // //                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
// // // // // // // //                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //           );
// // // // // // // //         },
// // // // // // // //       ),
// // // // // // // //       floatingActionButton: FloatingActionButton(
// // // // // // // //         onPressed: _showAddCategoryDialog,
// // // // // // // //         child: const Icon(Icons.add),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // //
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import '../../database/app_database.dart';
// // // // // // // // import '../../models/category_model.dart';
// // // // // // // // import '../general/general_schedule_page.dart';
// // // // // // // // import '../week/week_schedule_page.dart';
// // // // // // // // import '../dashboard/dashboard_page.dart';
// // // // // // // // import 'create_category_page.dart'; // Import the new page
// // // // // // // //
// // // // // // // // class CategoryListPage extends StatefulWidget {
// // // // // // // //   const CategoryListPage({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // // // // //   List<CategoryModel> categories = [];
// // // // // // // //   bool loading = true;
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _loadCategories() async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     final res = await db.query('categories');
// // // // // // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // // // // //     if (mounted) {
// // // // // // // //       setState(() => loading = false);
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _deleteCategory(int id) async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // // // // //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _navigateAndRefresh() {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // // // // // //     ).then((_) {
// // // // // // // //       // When we return from CreateCategoryPage, reload the categories
// // // // // // // //       setState(() {
// // // // // // // //         loading = true;
// // // // // // // //       });
// // // // // // // //       _loadCategories();
// // // // // // // //     });
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _checkAllConfigured() {
// // // // // // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // // // // // //     if (allConfigured) {
// // // // // // // //       Navigator.pushReplacement(
// // // // // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // // // // //     } else {
// // // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //         const SnackBar(content: Text('Please create and configure all categories first!')),
// // // // // // // //       );
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('Categories'),
// // // // // // // //         actions: [
// // // // // // // //           IconButton(
// // // // // // // //             icon: const Icon(Icons.check),
// // // // // // // //             onPressed: _checkAllConfigured,
// // // // // // // //           )
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //       body: ListView.builder(
// // // // // // // //         itemCount: categories.length,
// // // // // // // //         itemBuilder: (_, index) {
// // // // // // // //           final cat = categories[index];
// // // // // // // //           return Card(
// // // // // // // //             child: ListTile(
// // // // // // // //               title: Text(cat.name),
// // // // // // // //               subtitle: Text('Configured: ${cat.configured ? "Yes" : "No"}'),
// // // // // // // //               leading: CircleAvatar(backgroundColor: Color(cat.color).withOpacity(1.0)),
// // // // // // // //               trailing: Row(
// // // // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // // // //                 children: [
// // // // // // // //                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
// // // // // // // //                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
// // // // // // // //                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //           );
// // // // // // // //         },
// // // // // // // //       ),
// // // // // // // //       floatingActionButton: FloatingActionButton(
// // // // // // // //         onPressed: _navigateAndRefresh, // Changed to navigate
// // // // // // // //         child: const Icon(Icons.add),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import '../../database/app_database.dart';
// // // // // // // // import '../../models/category_model.dart';
// // // // // // // // import '../general/general_schedule_page.dart';
// // // // // // // // import '../week/week_schedule_page.dart';
// // // // // // // // import '../dashboard/dashboard_page.dart';
// // // // // // // // import 'create_category_page.dart'; // Import the new page
// // // // // // // //
// // // // // // // // class CategoryListPage extends StatefulWidget {
// // // // // // // //   const CategoryListPage({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // // // // //   List<CategoryModel> categories = [];
// // // // // // // //   bool loading = true;
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _loadCategories();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _loadCategories() async {
// // // // // // // //     final db = await AppDB.instance.database;
// // // // // // // //     final res = await db.query('categories');
// // // // // // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // // // // //     if (mounted) {
// // // // // // // //       setState(() => loading = false);
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _deleteCategory(int id) async {
// // // // // // // //     // Show a confirmation dialog before deleting
// // // // // // // //     final bool? shouldDelete = await showDialog<bool>(
// // // // // // // //       context: context,
// // // // // // // //       builder: (context) => AlertDialog(
// // // // // // // //         title: const Text('Delete Category'),
// // // // // // // //         content: const Text('Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
// // // // // // // //         actions: [
// // // // // // // //           TextButton(
// // // // // // // //             onPressed: () => Navigator.of(context).pop(false),
// // // // // // // //             child: const Text('Cancel'),
// // // // // // // //           ),
// // // // // // // //           TextButton(
// // // // // // // //             onPressed: () => Navigator.of(context).pop(true),
// // // // // // // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // // // // // // //             child: const Text('Delete'),
// // // // // // // //           ),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //
// // // // // // // //     if (shouldDelete == true) {
// // // // // // // //       final db = await AppDB.instance.database;
// // // // // // // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // // // // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // // // // //       _loadCategories();
// // // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //         const SnackBar(content: Text('Category deleted successfully')),
// // // // // // // //       );
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _navigateAndRefresh() {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // // // // // //     ).then((_) {
// // // // // // // //       // When we return from CreateCategoryPage, reload the categories
// // // // // // // //       setState(() {
// // // // // // // //         loading = true;
// // // // // // // //       });
// // // // // // // //       _loadCategories();
// // // // // // // //     });
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // // // // //     Navigator.push(
// // // // // // // //       context,
// // // // // // // //       MaterialPageRoute(
// // // // // // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // // // // // //       ),
// // // // // // // //     ).then((_) => _loadCategories());
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _checkAllConfigured() {
// // // // // // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // // // // // //     if (allConfigured) {
// // // // // // // //       Navigator.pushReplacement(
// // // // // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // // // // //     } else {
// // // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //         const SnackBar(
// // // // // // // //           content: Text('Please create and configure all categories first!'),
// // // // // // // //           behavior: SnackBarBehavior.floating,
// // // // // // // //         ),
// // // // // // // //       );
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     if (loading) {
// // // // // // // //       return Scaffold(
// // // // // // // //         appBar: AppBar(title: const Text('Categories')),
// // // // // // // //         body: const Center(child: CircularProgressIndicator()),
// // // // // // // //       );
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('Categories'),
// // // // // // // //         actions: [
// // // // // // // //           IconButton(
// // // // // // // //             icon: const Icon(Icons.check_circle_outline),
// // // // // // // //             tooltip: 'Finish Configuration',
// // // // // // // //             onPressed: _checkAllConfigured,
// // // // // // // //           )
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //       body: categories.isEmpty
// // // // // // // //           ? Center(
// // // // // // // //         child: Column(
// // // // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // // // //           children: [
// // // // // // // //             Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // // // // // // //             const SizedBox(height: 16),
// // // // // // // //             const Text(
// // // // // // // //               'No Categories Found',
// // // // // // // //               style: TextStyle(fontSize: 18, color: Colors.grey),
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 8),
// // // // // // // //             const Text(
// // // // // // // //               'Tap the "+" button to add your first category.',
// // // // // // // //               style: TextStyle(color: Colors.grey),
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       )
// // // // // // // //           : ListView.builder(
// // // // // // // //         padding: const EdgeInsets.all(8.0), // Add padding around the list
// // // // // // // //         itemCount: categories.length,
// // // // // // // //         itemBuilder: (_, index) {
// // // // // // // //           final cat = categories[index];
// // // // // // // //           return Card(
// // // // // // // //             elevation: 4.0, // Add a shadow
// // // // // // // //             margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between cards
// // // // // // // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
// // // // // // // //             child: ListTile(
// // // // // // // //               contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // // // // // //               leading: CircleAvatar(
// // // // // // // //                 backgroundColor: Color(cat.color).withOpacity(1.0),
// // // // // // // //                 child: Text(
// // // // // // // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '',
// // // // // // // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // //               subtitle: Row(
// // // // // // // //                 children: [
// // // // // // // //                   Icon(
// // // // // // // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // // // // // // //                     color: cat.configured ? Colors.green : Colors.orange,
// // // // // // // //                     size: 16,
// // // // // // // //                   ),
// // // // // // // //                   const SizedBox(width: 4),
// // // // // // // //                   Text('Configured: ${cat.configured ? "Yes" : "No"}'),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //               trailing: PopupMenuButton<String>(
// // // // // // // //                 onSelected: (value) {
// // // // // // // //                   if (value == 'edit') {
// // // // // // // //                     _openGeneralSchedule(cat);
// // // // // // // //                   } else if (value == 'schedule') {
// // // // // // // //                     _openWeekSchedule(cat);
// // // // // // // //                   } else if (value == 'delete') {
// // // // // // // //                     _deleteCategory(cat.id!);
// // // // // // // //                   }
// // // // // // // //                 },
// // // // // // // //                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // // // // // // //                   const PopupMenuItem<String>(
// // // // // // // //                     value: 'edit',
// // // // // // // //                     child: ListTile(
// // // // // // // //                       leading: Icon(Icons.edit_calendar),
// // // // // // // //                       title: Text('Edit General'),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   const PopupMenuItem<String>(
// // // // // // // //                     value: 'schedule',
// // // // // // // //                     child: ListTile(
// // // // // // // //                       leading: Icon(Icons.schedule),
// // // // // // // //                       title: Text('Edit Weekly'),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   const PopupMenuDivider(),
// // // // // // // //                   const PopupMenuItem<String>(
// // // // // // // //                     value: 'delete',
// // // // // // // //                     child: ListTile(
// // // // // // // //                       leading: Icon(Icons.delete_forever, color: Colors.red),
// // // // // // // //                       title: Text('Delete', style: TextStyle(color: Colors.red)),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //           );
// // // // // // // //         },
// // // // // // // //       ),
// // // // // // // //       floatingActionButton: FloatingActionButton.extended(
// // // // // // // //         onPressed: _navigateAndRefresh,
// // // // // // // //         label: const Text('Add'),
// // // // // // // //         icon: const Icon(Icons.add),
// // // // // // // //         tooltip: 'Add a new category',
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import '../../database/app_database.dart';
// // // // // // // import '../../models/category_model.dart';
// // // // // // // import '../general/general_schedule_page.dart';
// // // // // // // import '../week/week_schedule_page.dart';
// // // // // // // import '../dashboard/dashboard_page.dart';
// // // // // // // import 'create_category_page.dart'; // Make sure this page exists for adding new categories
// // // // // // //
// // // // // // // class CategoryListPage extends StatefulWidget {
// // // // // // //   const CategoryListPage({super.key});
// // // // // // //
// // // // // // //   @override
// // // // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // // // }
// // // // // // //
// // // // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // // // //   List<CategoryModel> categories = [];
// // // // // // //   bool loading = true;
// // // // // // //
// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _loadCategories();
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _loadCategories() async {
// // // // // // //     final db = await AppDB.instance.database;
// // // // // // //     final res = await db.query('categories');
// // // // // // //     // Ensure you are using the correct type for 'configured'. Assuming it's a boolean (true/false).
// // // // // // //     // If your database stores it as 0 or 1, the CategoryModel.fromMap should handle the conversion.
// // // // // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // // // //     if (mounted) {
// // // // // // //       setState(() => loading = false);
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _deleteCategory(int id) async {
// // // // // // //     // Show a confirmation dialog before deleting to prevent accidental data loss
// // // // // // //     final bool? shouldDelete = await showDialog<bool>(
// // // // // // //       context: context,
// // // // // // //       builder: (context) => AlertDialog(
// // // // // // //         title: const Text('Delete Category'),
// // // // // // //         content: const Text('Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
// // // // // // //         actions: [
// // // // // // //           TextButton(
// // // // // // //             onPressed: () => Navigator.of(context).pop(false),
// // // // // // //             child: const Text('Cancel'),
// // // // // // //           ),
// // // // // // //           TextButton(
// // // // // // //             onPressed: () => Navigator.of(context).pop(true),
// // // // // // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // // // // // //             child: const Text('Delete'),
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //
// // // // // // //     if (shouldDelete == true) {
// // // // // // //       final db = await AppDB.instance.database;
// // // // // // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // // // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // // // //       // Show feedback and reload the list
// // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //         const SnackBar(content: Text('Category deleted successfully')),
// // // // // // //       );
// // // // // // //       _loadCategories(); // This reloads the state
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   void _navigateAndRefresh() {
// // // // // // //     Navigator.push(
// // // // // // //       context,
// // // // // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // // // // //     ).then((_) {
// // // // // // //       // When we return from the create page, reload the categories to show the new one.
// // // // // // //       setState(() => loading = true);
// // // // // // //       _loadCategories();
// // // // // // //     });
// // // // // // //   }
// // // // // // //
// // // // // // //   // Handles the main tap action on a category card
// // // // // // //   void _handleCategoryTap(CategoryModel cat) {
// // // // // // //     if (cat.configured) {
// // // // // // //       // If already configured, open the weekly schedule for editing.
// // // // // // //       _openWeekSchedule(cat);
// // // // // // //     } else {
// // // // // // //       // If not configured, open the general schedule for setup.
// // // // // // //       _openGeneralSchedule(cat);
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // // // //     Navigator.push(
// // // // // // //       context,
// // // // // // //       MaterialPageRoute(
// // // // // // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // // // // // //       ),
// // // // // // //     ).then((_) => _loadCategories());
// // // // // // //   }
// // // // // // //
// // // // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // // // //     Navigator.push(
// // // // // // //       context,
// // // // // // //       MaterialPageRoute(
// // // // // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // // // // //       ),
// // // // // // //     ).then((_) => _loadCategories());
// // // // // // //   }
// // // // // // //
// // // // // // //   void _checkAllConfigured() {
// // // // // // //     // Check if there are categories and if every single one is configured.
// // // // // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // // // // //     if (allConfigured) {
// // // // // // //       Navigator.pushReplacement(
// // // // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // // // //     } else {
// // // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //         const SnackBar(
// // // // // // //           content: Text('Please create and configure all categories first!'),
// // // // // // //           behavior: SnackBarBehavior.floating,
// // // // // // //         ),
// // // // // // //       );
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     if (loading) {
// // // // // // //       return Scaffold(
// // // // // // //         appBar: AppBar(title: const Text('Categories')),
// // // // // // //         body: const Center(child: CircularProgressIndicator()),
// // // // // // //       );
// // // // // // //     }
// // // // // // //
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(
// // // // // // //         title: const Text('Categories'),
// // // // // // //         actions: [
// // // // // // //           IconButton(
// // // // // // //             icon: const Icon(Icons.check_circle_outline),
// // // // // // //             tooltip: 'Finish Configuration',
// // // // // // //             onPressed: _checkAllConfigured,
// // // // // // //           )
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //       body: categories.isEmpty
// // // // // // //           ? Center(
// // // // // // //         child: Column(
// // // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //           children: [
// // // // // // //             Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // // // // // //             const SizedBox(height: 16),
// // // // // // //             const Text(
// // // // // // //               'No Categories Found',
// // // // // // //               style: TextStyle(fontSize: 18, color: Colors.grey),
// // // // // // //             ),
// // // // // // //             const SizedBox(height: 8),
// // // // // // //             Text(
// // // // // // //               'Tap the "+" button to add your first category.',
// // // // // // //               textAlign: TextAlign.center,
// // // // // // //               style: TextStyle(color: Colors.grey[600]),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       )
// // // // // // //           : ListView.builder(
// // // // // // //         padding: const EdgeInsets.all(8.0), // Add padding around the list
// // // // // // //         itemCount: categories.length,
// // // // // // //         itemBuilder: (_, index) {
// // // // // // //           final cat = categories[index];
// // // // // // //           return Card(
// // // // // // //             elevation: 4.0,
// // // // // // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // // // // // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // //             child: ListTile(
// // // // // // //               contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // // // // //               leading: CircleAvatar(
// // // // // // //                 backgroundColor: Color(cat.color).withOpacity(1.0),
// // // // // // //                 child: Text(
// // // // // // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // // // // // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // //               subtitle: Row(
// // // // // // //                 children: [
// // // // // // //                   Icon(
// // // // // // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // // // // // //                     color: cat.configured ? Colors.green : Colors.orange,
// // // // // // //                     size: 16,
// // // // // // //                   ),
// // // // // // //                   const SizedBox(width: 4),
// // // // // // //                   // Use a more descriptive subtitle
// // // // // // //                   Text(cat.configured ? "Ready to schedule" : "Setup required"),
// // // // // // //                 ],
// // // // // // //               ),
// // // // // // //               // Main tap action for the list tile
// // // // // // //               onTap: () => _handleCategoryTap(cat),
// // // // // // //               trailing: PopupMenuButton<String>(
// // // // // // //                 tooltip: "More Options",
// // // // // // //                 onSelected: (value) {
// // // // // // //                   if (value == 'edit_general') {
// // // // // // //                     _openGeneralSchedule(cat);
// // // // // // //                   } else if (value == 'delete') {
// // // // // // //                     _deleteCategory(cat.id!);
// // // // // // //                   }
// // // // // // //                 },
// // // // // // //                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // // // // // //                   const PopupMenuItem<String>(
// // // // // // //                     value: 'edit_general',
// // // // // // //                     child: ListTile(
// // // // // // //                       leading: Icon(Icons.edit_calendar_outlined),
// // // // // // //                       title: Text('Edit General'),
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                   const PopupMenuDivider(),
// // // // // // //                   const PopupMenuItem<String>(
// // // // // // //                     value: 'delete',
// // // // // // //                     child: ListTile(
// // // // // // //                       leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
// // // // // // //                       title: Text('Delete', style: TextStyle(color: Colors.red)),
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ],
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           );
// // // // // // //         },
// // // // // // //       ),
// // // // // // //       floatingActionButton: FloatingActionButton.extended(
// // // // // // //         onPressed: _navigateAndRefresh,
// // // // // // //         label: const Text('Add Category'),
// // // // // // //         icon: const Icon(Icons.add),
// // // // // // //         tooltip: 'Add a new category',
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:intl/intl.dart'; // Used for formatting dates
// // // // // // import '../../database/app_database.dart';
// // // // // // import '../../models/category_model.dart';
// // // // // // import '../../models/period_model.dart';
// // // // // // import '../general/general_schedule_page.dart';
// // // // // // import '../week/week_schedule_page.dart';
// // // // // // import '../dashboard/dashboard_page.dart';
// // // // // // import 'create_category_page.dart';
// // // // // //
// // // // // // class CategoryListPage extends StatefulWidget {
// // // // // //   const CategoryListPage({super.key});
// // // // // //
// // // // // //   @override
// // // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // // }
// // // // // //
// // // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // // //   List<CategoryModel> categories = [];
// // // // // //   bool loading = true;
// // // // // //
// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _loadCategories();
// // // // // //   }
// // // // // //
// // // // // //   Future<void> _loadCategories() async {
// // // // // //     setState(() => loading = true);
// // // // // //     final db = await AppDB.instance.database;
// // // // // //     final res = await db.query('categories', orderBy: 'name');
// // // // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // // //     if (mounted) {
// // // // // //       setState(() => loading = false);
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   Future<void> _deleteCategory(int id) async {
// // // // // //     final bool? shouldDelete = await showDialog<bool>(
// // // // // //       context: context,
// // // // // //       builder: (context) => AlertDialog(
// // // // // //         title: const Text('Delete Category'),
// // // // // //         content: const Text(
// // // // // //             'Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
// // // // // //         actions: [
// // // // // //           TextButton(
// // // // // //             onPressed: () => Navigator.of(context).pop(false),
// // // // // //             child: const Text('Cancel'),
// // // // // //           ),
// // // // // //           TextButton(
// // // // // //             onPressed: () => Navigator.of(context).pop(true),
// // // // // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // // // // //             child: const Text('Delete'),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //
// // // // // //     if (shouldDelete == true) {
// // // // // //       final db = await AppDB.instance.database;
// // // // // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // // //       if (mounted) {
// // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // //           const SnackBar(
// // // // // //               content: Text('Category deleted successfully'),
// // // // // //               backgroundColor: Colors.green),
// // // // // //         );
// // // // // //       }
// // // // // //       _loadCategories();
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   /// NEW METHOD: Generates and displays the commands for the ESP32.
// // // // // //   Future<void> _generateAndShowCommands(CategoryModel cat) async {
// // // // // //     if (!mounted) return;
// // // // // //
// // // // // //     // Show a loading indicator
// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       barrierDismissible: false,
// // // // // //       builder: (context) => const Center(child: CircularProgressIndicator()),
// // // // // //     );
// // // // // //
// // // // // //     final db = await AppDB.instance.database;
// // // // // //     final List<Map<String, dynamic>> periodMaps = await db.query(
// // // // // //       'periods',
// // // // // //       where: 'categoryId = ?',
// // // // // //       whereArgs: [cat.id],
// // // // // //       orderBy: 'startTime', // Order by time to ensure correct sequence
// // // // // //     );
// // // // // //     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // // // // //
// // // // // //     List<String> commands = [];
// // // // // //     final DateFormat formatter = DateFormat('dd/MM/yy');
// // // // // //
// // // // // //     // 1. Generate the main category command
// // // // // //     // **FIX**: Parse the date strings into DateTime objects before formatting.
// // // // // //     final DateTime startDate = DateTime.parse(cat.startDate);
// // // // // //     final DateTime endDate = DateTime.parse(cat.endDate);
// // // // // //     final String startDateFormatted = formatter.format(startDate);
// // // // // //     final String endDateFormatted = formatter.format(endDate);
// // // // // //     commands.add('\$${cat.name},$startDateFormatted,$endDateFormatted#');
// // // // // //
// // // // // //     // 2. Group periods by weekday
// // // // // //     final Map<String, List<PeriodModel>> periodsByDay = {};
// // // // // //     for (var p in periods) {
// // // // // //       // **FIX**: Provide a default value for 'day' if it's null.
// // // // // //       final day = p.day ?? 'Unknown';
// // // // // //       (periodsByDay[day] ??= []).add(p);
// // // // // //     }
// // // // // //
// // // // // //     // Helper to convert day name to a single character code
// // // // // //     String dayToCode(String day) {
// // // // // //       const map = {
// // // // // //         'MONDAY': 'M', 'TUESDAY': 'T', 'WEDNESDAY': 'W', 'THURSDAY': 'H',
// // // // // //         'FRIDAY': 'F', 'SATURDAY': 'S', 'SUNDAY': 'U',
// // // // // //       };
// // // // // //       return map[day] ?? '?';
// // // // // //     }
// // // // // //
// // // // // //     // Helper to extract track number from ringtone name
// // // // // //     int getTrackNumber(String? ringtone) {
// // // // // //       if (ringtone == null || ringtone.isEmpty) return 1; // Default track
// // // // // //       final match = RegExp(r'\d+').firstMatch(ringtone);
// // // // // //       if (match != null) {
// // // // // //         return int.tryParse(match.group(0)!) ?? 1;
// // // // // //       }
// // // // // //       return 1; // Default track if no number is found
// // // // // //     }
// // // // // //
// // // // // //     // 3. Generate schedule commands for each day
// // // // // //     for (var entry in periodsByDay.entries) {
// // // // // //       final dayCode = dayToCode(entry.key);
// // // // // //       final List<String> timeAndRingtonePairs = [];
// // // // // //
// // // // // //       for (var period in entry.value) {
// // // // // //         // **FIX**: Handle potential null for ringtone and provide a default.
// // // // // //         final track = getTrackNumber(period.ringtone);
// // // // // //         // **FIX**: Ensure startTime is not null before using it.
// // // // // //         final startTime = period.startTime ?? '00:00';
// // // // // //         timeAndRingtonePairs.add('$startTime,${track.toString().padLeft(2, '0')}');
// // // // // //       }
// // // // // //
// // // // // //       if (timeAndRingtonePairs.isNotEmpty) {
// // // // // //         final schedulePayload = timeAndRingtonePairs.join('!');
// // // // // //         final fullPayload = '$dayCode,$schedulePayload';
// // // // // //         final byteCount = fullPayload.length; // Calculate byte count of the payload
// // // // // //         commands.add('\$$byteCount,$fullPayload#');
// // // // // //       }
// // // // // //     }
// // // // // //
// // // // // //     if (!mounted) return;
// // // // // //     Navigator.of(context).pop(); // Dismiss loading indicator
// // // // // //
// // // // // //     // 4. Show the generated commands in a dialog
// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       builder: (context) => AlertDialog(
// // // // // //         title: Text('Generated Commands for "${cat.name}"'),
// // // // // //         content: SizedBox(
// // // // // //           width: double.maxFinite,
// // // // // //           child: SingleChildScrollView(
// // // // // //             child: Text(
// // // // // //               commands.join('\n'), // Join commands with a newline for readability
// // // // // //               style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //         actions: [
// // // // // //           TextButton(
// // // // // //             onPressed: () => Navigator.of(context).pop(),
// // // // // //             child: const Text('OK'),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   void _navigateAndRefresh() {
// // // // // //     Navigator.push(
// // // // // //       context,
// // // // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // // // //     ).then((_) {
// // // // // //       _loadCategories();
// // // // // //     });
// // // // // //   }
// // // // // //
// // // // // //   void _handleCategoryTap(CategoryModel cat) {
// // // // // //     if (cat.configured) {
// // // // // //       _openWeekSchedule(cat);
// // // // // //     } else {
// // // // // //       _openGeneralSchedule(cat);
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // // //     Navigator.push(
// // // // // //       context,
// // // // // //       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
// // // // // //     ).then((_) => _loadCategories());
// // // // // //   }
// // // // // //
// // // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // // //     Navigator.push(
// // // // // //       context,
// // // // // //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// // // // // //     ).then((_) => _loadCategories());
// // // // // //   }
// // // // // //
// // // // // //   void _checkAllConfigured() {
// // // // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // // // //     if (allConfigured) {
// // // // // //       Navigator.pushReplacement(
// // // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // // //     } else {
// // // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // // //         const SnackBar(
// // // // // //           content: Text('Please create and configure at least one category first!'),
// // // // // //           behavior: SnackBarBehavior.floating,
// // // // // //         ),
// // // // // //       );
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     if (loading) {
// // // // // //       return Scaffold(
// // // // // //         appBar: AppBar(title: const Text('Categories')),
// // // // // //         body: const Center(child: CircularProgressIndicator()),
// // // // // //       );
// // // // // //     }
// // // // // //
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text('Categories'),
// // // // // //         actions: [
// // // // // //           IconButton(
// // // // // //             icon: const Icon(Icons.check_circle_outline),
// // // // // //             tooltip: 'Finish Configuration',
// // // // // //             onPressed: _checkAllConfigured,
// // // // // //           )
// // // // // //         ],
// // // // // //       ),
// // // // // //       body: categories.isEmpty
// // // // // //           ? Center(
// // // // // //         child: Padding(
// // // // // //           padding: const EdgeInsets.all(24.0),
// // // // // //           child: Column(
// // // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // // //             children: [
// // // // // //               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // // // // //               const SizedBox(height: 16),
// // // // // //               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
// // // // // //               const SizedBox(height: 8),
// // // // // //               Text(
// // // // // //                 'Tap the "Add Category" button to create your first schedule category.',
// // // // // //                 textAlign: TextAlign.center,
// // // // // //                 style: TextStyle(color: Colors.grey[600]),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //       )
// // // // // //           : ListView.builder(
// // // // // //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Padding for FAB
// // // // // //         itemCount: categories.length,
// // // // // //         itemBuilder: (_, index) {
// // // // // //           final cat = categories[index];
// // // // // //           return Card(
// // // // // //             elevation: 4.0,
// // // // // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // // // // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // //             child: ListTile(
// // // // // //               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// // // // // //               leading: CircleAvatar(
// // // // // //                 backgroundColor: Color(cat.color).withOpacity(1.0),
// // // // // //                 child: Text(
// // // // // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // // // // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // // // //                 ),
// // // // // //               ),
// // // // // //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // //               subtitle: Row(
// // // // // //                 children: [
// // // // // //                   Icon(
// // // // // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // // // // //                     color: cat.configured ? Colors.green : Colors.orange,
// // // // // //                     size: 16,
// // // // // //                   ),
// // // // // //                   const SizedBox(width: 4),
// // // // // //                   Text(cat.configured ? "Ready to sync" : "Setup required"),
// // // // // //                 ],
// // // // // //               ),
// // // // // //               onTap: () => _handleCategoryTap(cat),
// // // // // //               trailing: Row(
// // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // //                 children: [
// // // // // //                   IconButton(
// // // // // //                     icon: const Icon(Icons.send_outlined),
// // // // // //                     tooltip: 'Generate Sync Commands',
// // // // // //                     onPressed: cat.configured ? () => _generateAndShowCommands(cat) : null,
// // // // // //                     color: Theme.of(context).primaryColor,
// // // // // //                   ),
// // // // // //                   PopupMenuButton<String>(
// // // // // //                     tooltip: "More Options",
// // // // // //                     onSelected: (value) {
// // // // // //                       if (value == 'edit_general') {
// // // // // //                         _openGeneralSchedule(cat);
// // // // // //                       } else if (value == 'delete') {
// // // // // //                         _deleteCategory(cat.id!);
// // // // // //                       }
// // // // // //                     },
// // // // // //                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // // // // //                       const PopupMenuItem<String>(
// // // // // //                         value: 'edit_general',
// // // // // //                         child: ListTile(
// // // // // //                           leading: Icon(Icons.edit_calendar_outlined),
// // // // // //                           title: Text('Edit General'),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       const PopupMenuDivider(),
// // // // // //                       const PopupMenuItem<String>(
// // // // // //                         value: 'delete',
// // // // // //                         child: ListTile(
// // // // // //                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
// // // // // //                           title: Text('Delete', style: TextStyle(color: Colors.red)),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             ),
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //       floatingActionButton: FloatingActionButton.extended(
// // // // // //         onPressed: _navigateAndRefresh,
// // // // // //         label: const Text('Add Category'),
// // // // // //         icon: const Icon(Icons.add),
// // // // // //         tooltip: 'Add a new category',
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:intl/intl.dart'; // Used for formatting dates
// // // // // // import 'package:path/path.dart' as p; // FIX: Unused import removed.
// // // // //
// // // // // import '../../database/app_database.dart';
// // // // // import '../../models/category_model.dart';
// // // // // import '../../models/period_model.dart';
// // // // // import '../dashboard/dashboard_page.dart';
// // // // // import '../general/general_schedule_page.dart';
// // // // // import '../week/week_schedule_page.dart';
// // // // // import 'create_category_page.dart';
// // // // //
// // // // // class CategoryListPage extends StatefulWidget {
// // // // //   const CategoryListPage({super.key});
// // // // //
// // // // //   @override
// // // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // // }
// // // // //
// // // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // // //   List<CategoryModel> categories = [];
// // // // //   bool loading = true;
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _loadCategories();
// // // // //   }
// // // // //
// // // // //   Future<void> _loadCategories() async {
// // // // //     setState(() => loading = true);
// // // // //     final db = await AppDB.instance.database;
// // // // //     // Sort by name to ensure the sequence number is consistent
// // // // //     final res = await db.query('categories', orderBy: 'name');
// // // // //     if (mounted) {
// // // // //       setState(() {
// // // // //         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // // //         loading = false;
// // // // //       });
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> _deleteCategory(int id) async {
// // // // //     final bool? shouldDelete = await showDialog<bool>(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: const Text('Delete Category'),
// // // // //         content: const Text(
// // // // //             'Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
// // // // //         actions: [
// // // // //           TextButton(
// // // // //             onPressed: () => Navigator.of(context).pop(false),
// // // // //             child: const Text('Cancel'),
// // // // //           ),
// // // // //           TextButton(
// // // // //             onPressed: () => Navigator.of(context).pop(true),
// // // // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // // // //             child: const Text('Delete'),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //
// // // // //     if (shouldDelete == true) {
// // // // //       final db = await AppDB.instance.database;
// // // // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // // //       if (mounted) {
// // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // //           const SnackBar(
// // // // //               content: Text('Category deleted successfully'),
// // // // //               backgroundColor: Colors.green),
// // // // //         );
// // // // //       }
// // // // //       _loadCategories(); // Refresh the list
// // // // //     }
// // // // //   }
// // // // //
// // // // //   /// METHOD WITH ALL CORRECTIONS APPLIED
// // // // //   Future<void> _generateAndShowCommands(
// // // // //       CategoryModel cat, int categorySequenceNumber) async {
// // // // //     if (!mounted) return;
// // // // //
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       barrierDismissible: false,
// // // // //       builder: (context) => const Center(child: CircularProgressIndicator()),
// // // // //     );
// // // // //
// // // // //     final db = await AppDB.instance.database;
// // // // //     final List<Map<String, dynamic>> periodMaps = await db.query(
// // // // //       'periods',
// // // // //       where: 'categoryId = ?',
// // // // //       whereArgs: [cat.id],
// // // // //       orderBy: 'startTime',
// // // // //     );
// // // // //     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // // // //
// // // // //     List<String> commands = [];
// // // // //     final DateFormat formatter = DateFormat('dd-MM-yy');
// // // // //
// // // // //     // 1. Category Command
// // // // //     final DateTime startDate = DateTime.parse(cat.startDate);
// // // // //     final DateTime endDate = DateTime.parse(cat.endDate);
// // // // //     final String startDateFormatted = formatter.format(startDate);
// // // // //     final String endDateFormatted = formatter.format(endDate);
// // // // //     commands.add(
// // // // //         '\$C,$categorySequenceNumber,${cat.name},$startDateFormatted,$endDateFormatted#');
// // // // //
// // // // //     // 2. Group periods by day
// // // // //     final Map<String, List<PeriodModel>> periodsByDay = {};
// // // // //     for (var p in periods) {
// // // // //       (periodsByDay[p.day] ??= []).add(p);
// // // // //     }
// // // // //
// // // // //     String dayToCode(String day) {
// // // // //       const map = {
// // // // //         'monday': 'M',
// // // // //         'tuesday': 'T',
// // // // //         'wednesday': 'W',
// // // // //         'thursday': 'H',
// // // // //         'friday': 'F',
// // // // //         'saturday': 'S',
// // // // //         'sunday': 'U',
// // // // //       };
// // // // //       return map[day.toLowerCase()] ?? '?';
// // // // //     }
// // // // //
// // // // //     // **DEFINITIVE FIX for ringtone name**
// // // // //     String getRingtoneName(String? ringtonePath) {
// // // // //       // 1. Handle null or empty case first.
// // // // //       if (ringtonePath == null || ringtonePath.isEmpty) {
// // // // //         return "default.mp3";
// // // // //       }
// // // // //
// // // // //       // 2. Isolate the filename from the path.
// // // // //       final filename = ringtonePath.split(r'\').last.split('/').last;
// // // // //
// // // // //       // 3. Correct the ".mp3.mp3" error if it exists.
// // // // //       if (filename.endsWith('.mp3.mp3')) {
// // // // //         return filename.substring(0, filename.length - 4);
// // // // //       }
// // // // //
// // // // //       // 4. Return the (now correct) filename.
// // // // //       return filename;
// // // // //     }
// // // // //
// // // // //     // 3. Generate Schedule Commands
// // // // //     for (var entry in periodsByDay.entries) {
// // // // //       final dayCode = dayToCode(entry.key);
// // // // //       if (dayCode == '?') continue;
// // // // //
// // // // //       final List<String> timeAndRingtonePairs = [];
// // // // //       for (var period in entry.value) {
// // // // //         // This call is now safe because getRingtoneName accepts String?
// // // // //         final ringtoneName = getRingtoneName(period.ringtone);
// // // // //         final startTime = period.startTime ?? '00:00';
// // // // //         timeAndRingtonePairs.add('$startTime,$ringtoneName');
// // // // //       }
// // // // //
// // // // //       if (timeAndRingtonePairs.isNotEmpty) {
// // // // //         final schedulePayload = timeAndRingtonePairs.join('!');
// // // // //         final fullPayload =
// // // // //             '$categorySequenceNumber,$dayCode,$schedulePayload';
// // // // //         final byteCount = fullPayload.length;
// // // // //         commands.add('\$S,$byteCount,$fullPayload#');
// // // // //       }
// // // // //     }
// // // // //
// // // // //     if (!mounted) return;
// // // // //     Navigator.of(context).pop(); // Dismiss loading dialog
// // // // //
// // // // //     // 4. Show generated commands
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: Text('Generated Commands for "${cat.name}"'),
// // // // //         content: SizedBox(
// // // // //           width: double.maxFinite,
// // // // //           child: SingleChildScrollView(
// // // // //             child: Text(
// // // // //               commands.join('\n'),
// // // // //               style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //         actions: [
// // // // //           TextButton(
// // // // //             onPressed: () => Navigator.of(context).pop(),
// // // // //             child: const Text('OK'),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   void _navigateAndRefresh() {
// // // // //     Navigator.push(
// // // // //       context,
// // // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // // //     ).then((_) {
// // // // //       // Refresh the list after returning from the create page
// // // // //       _loadCategories();
// // // // //     });
// // // // //   }
// // // // //
// // // // //   void _handleCategoryTap(CategoryModel cat) {
// // // // //     // If setup is complete, go to the detailed week schedule.
// // // // //     // Otherwise, go to the initial setup page.
// // // // //     if (cat.configured) {
// // // // //       _openWeekSchedule(cat);
// // // // //     } else {
// // // // //       _openGeneralSchedule(cat);
// // // // //     }
// // // // //   }
// // // // //
// // // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // // //     Navigator.push(
// // // // //       context,
// // // // //       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
// // // // //     ).then((_) => _loadCategories());
// // // // //   }
// // // // //
// // // // //   void _openWeekSchedule(CategoryModel cat) {
// // // // //     Navigator.push(
// // // // //       context,
// // // // //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// // // // //     ).then((_) => _loadCategories());
// // // // //   }
// // // // //
// // // // //   void _checkAllConfigured() {
// // // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // // //     if (allConfigured) {
// // // // //       Navigator.pushReplacement(
// // // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // // //     } else {
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         const SnackBar(
// // // // //           content: Text('Please create and configure at least one category first!'),
// // // // //           backgroundColor: Colors.orange,
// // // // //           behavior: SnackBarBehavior.floating,
// // // // //         ),
// // // // //       );
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: const Text('Categories'),
// // // // //         actions: [
// // // // //           IconButton(
// // // // //             icon: const Icon(Icons.check_circle_outline),
// // // // //             tooltip: 'Finish Configuration',
// // // // //             onPressed: _checkAllConfigured,
// // // // //           )
// // // // //         ],
// // // // //       ),
// // // // //       body: loading
// // // // //           ? const Center(child: CircularProgressIndicator())
// // // // //           : categories.isEmpty
// // // // //           ? Center(
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(24.0),
// // // // //           child: Column(
// // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // //             children: [
// // // // //               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // // // //               const SizedBox(height: 16),
// // // // //               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
// // // // //               const SizedBox(height: 8),
// // // // //               Text(
// // // // //                 'Tap the "Add Category" button to create your first schedule category.',
// // // // //                 textAlign: TextAlign.center,
// // // // //                 style: TextStyle(color: Colors.grey[600]),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       )
// // // // //           : ListView.builder(
// // // // //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Space for FAB
// // // // //         itemCount: categories.length,
// // // // //         itemBuilder: (_, index) {
// // // // //           final cat = categories[index];
// // // // //           // The sequential number is the list index + 1
// // // // //           final categorySequence = index + 1;
// // // // //           return Card(
// // // // //             elevation: 3.0,
// // // // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // // // //             shape: RoundedRectangleBorder(
// // // // //                 borderRadius: BorderRadius.circular(12)),
// // // // //             child: ListTile(
// // // // //               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// // // // //               leading: CircleAvatar(
// // // // //                 // FIX: Replaced deprecated 'withOpacity'
// // // // //                 backgroundColor: Color(cat.color),
// // // // //                 child: Text(
// // // // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // // // //                   style: const TextStyle(
// // // // //                       color: Colors.white,
// // // // //                       fontWeight: FontWeight.bold),
// // // // //                 ),
// // // // //               ),
// // // // //               title: Text(cat.name,
// // // // //                   style:
// // // // //                   const TextStyle(fontWeight: FontWeight.bold)),
// // // // //               subtitle: Row(
// // // // //                 children: [
// // // // //                   Icon(
// // // // //                     cat.configured
// // // // //                         ? Icons.check_circle
// // // // //                         : Icons.pending,
// // // // //                     color: cat.configured
// // // // //                         ? Colors.green
// // // // //                         : Colors.orange,
// // // // //                     size: 16,
// // // // //                   ),
// // // // //                   const SizedBox(width: 4),
// // // // //                   Text(cat.configured
// // // // //                       ? "Ready to sync"
// // // // //                       : "Setup required"),
// // // // //                 ],
// // // // //               ),
// // // // //               onTap: () => _handleCategoryTap(cat),
// // // // //               trailing: Row(
// // // // //                 mainAxisSize: MainAxisSize.min,
// // // // //                 children: [
// // // // //                   IconButton(
// // // // //                     icon: const Icon(Icons.send_outlined),
// // // // //                     tooltip: 'Generate Sync Commands',
// // // // //                     // Pass both the category and its sequence number
// // // // //                     onPressed: cat.configured
// // // // //                         ? () => _generateAndShowCommands(
// // // // //                         cat, categorySequence)
// // // // //                         : null,
// // // // //                     color: Theme.of(context).primaryColor,
// // // // //                   ),
// // // // //                   PopupMenuButton<String>(
// // // // //                     tooltip: "More Options",
// // // // //                     onSelected: (value) {
// // // // //                       if (value == 'edit_general') {
// // // // //                         _openGeneralSchedule(cat);
// // // // //                       } else if (value == 'delete') {
// // // // //                         _deleteCategory(cat.id!);
// // // // //                       }
// // // // //                     },
// // // // //                     itemBuilder: (BuildContext context) =>
// // // // //                     <PopupMenuEntry<String>>[
// // // // //                       const PopupMenuItem<String>(
// // // // //                         value: 'edit_general',
// // // // //                         child: ListTile(
// // // // //                           leading: Icon(Icons.edit_calendar_outlined),
// // // // //                           title: Text('Edit General'),
// // // // //                         ),
// // // // //                       ),
// // // // //                       const PopupMenuDivider(),
// // // // //                       const PopupMenuItem<String>(
// // // // //                         value: 'delete',
// // // // //                         child: ListTile(
// // // // //                           leading: Icon(Icons.delete_forever_outlined,
// // // // //                               color: Colors.red),
// // // // //                           title: Text('Delete',
// // // // //                               style: TextStyle(color: Colors.red)),
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //       floatingActionButton: FloatingActionButton.extended(
// // // // //         onPressed: _navigateAndRefresh,
// // // // //         label: const Text('Add Category'),
// // // // //         icon: const Icon(Icons.add),
// // // // //         tooltip: 'Add a new category',
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart'; // Used for formatting dates
// // // //
// // // // import '../../database/app_database.dart';
// // // // import '../../models/category_model.dart';
// // // // import '../../models/period_model.dart';
// // // // import '../dashboard/dashboard_page.dart';
// // // // import '../general/general_schedule_page.dart';
// // // // import '../week/week_schedule_page.dart';
// // // // import 'create_category_page.dart';
// // // //
// // // // class CategoryListPage extends StatefulWidget {
// // // //   const CategoryListPage({super.key});
// // // //
// // // //   @override
// // // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // // }
// // // //
// // // // class _CategoryListPageState extends State<CategoryListPage> {
// // // //   List<CategoryModel> categories = [];
// // // //   bool loading = true;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadCategories();
// // // //   }
// // // //
// // // //   Future<void> _loadCategories() async {
// // // //     setState(() => loading = true);
// // // //     final db = await AppDB.instance.database;
// // // //     // Sort by name to ensure the sequence number is consistent
// // // //     final res = await db.query('categories', orderBy: 'name');
// // // //     if (mounted) {
// // // //       setState(() {
// // // //         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // //         loading = false;
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _deleteCategory(int id) async {
// // // //     final bool? shouldDelete = await showDialog<bool>(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: const Text('Delete Category'),
// // // //         content: const Text(
// // // //           'Are you sure you want to delete this category and all its associated data? This action cannot be undone.',
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.of(context).pop(false),
// // // //             child: const Text('Cancel'),
// // // //           ),
// // // //           TextButton(
// // // //             onPressed: () => Navigator.of(context).pop(true),
// // // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // // //             child: const Text('Delete'),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //
// // // //     if (shouldDelete == true) {
// // // //       final db = await AppDB.instance.database;
// // // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(
// // // //             content: Text('Category deleted successfully'),
// // // //             backgroundColor: Colors.green,
// // // //           ),
// // // //         );
// // // //       }
// // // //       _loadCategories(); // Refresh the list
// // // //     }
// // // //   }
// // // //
// // // //   /// METHOD WITH ALL CORRECTIONS AND DEBUGGING APPLIED
// // // //   Future<void> _generateAndShowCommands(
// // // //     CategoryModel cat,
// // // //     int categorySequenceNumber,
// // // //   ) async {
// // // //     if (!mounted) return;
// // // //
// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (context) => const Center(child: CircularProgressIndicator()),
// // // //     );
// // // //
// // // //     final db = await AppDB.instance.database;
// // // //     final List<Map<String, dynamic>> periodMaps = await db.query(
// // // //       'periods',
// // // //       where: 'categoryId = ?',
// // // //       whereArgs: [cat.id],
// // // //       orderBy: 'startTime',
// // // //     );
// // // //     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // // //
// // // //     List<String> commands = [];
// // // //     final DateFormat formatter = DateFormat('dd-MM-yy');
// // // //
// // // //     // 1. Category Command
// // // //     final DateTime startDate = DateTime.parse(cat.startDate);
// // // //     final DateTime endDate = DateTime.parse(cat.endDate);
// // // //     final String startDateFormatted = formatter.format(startDate);
// // // //     final String endDateFormatted = formatter.format(endDate);
// // // //     commands.add(
// // // //       '\$C,$categorySequenceNumber,${cat.name},$startDateFormatted,$endDateFormatted#',
// // // //     );
// // // //
// // // //     // 2. Group periods by day
// // // //     final Map<String, List<PeriodModel>> periodsByDay = {};
// // // //     for (var p in periods) {
// // // //       (periodsByDay[p.day] ??= []).add(p);
// // // //     }
// // // //
// // // //     String dayToCode(String day) {
// // // //       const map = {
// // // //         'monday': 'M',
// // // //         'tuesday': 'T',
// // // //         'wednesday': 'W',
// // // //         'thursday': 'H',
// // // //         'friday': 'F',
// // // //         'saturday': 'S',
// // // //         'sunday': 'U',
// // // //       };
// // // //       return map[day.toLowerCase()] ?? '?';
// // // //     }
// // // //
// // // //     // **DEFINITIVE FIX with DEBUGGING**
// // // //     String getRingtoneName(String? ringtonePath) {
// // // //       // **DEBUG STEP**: Print the raw value from the database to the console.
// // // //       // This will immediately tell us if the value is null or an empty string.
// // // //
// // // //
// // // //       print("DEBUG: Received ringtone path from DB: '$ringtonePath'");
// // // //
// // // //       // 1. Handle null or empty case first.
// // // //       if (ringtonePath == null || ringtonePath.trim().isEmpty) {
// // // //         print("DEBUG: Path is null or empty, returning 'default.mp3'");
// // // //         return "default.mp3";
// // // //       }
// // // //
// // // //       // 2. Isolate the filename from the path. This handles both / and \ separators.
// // // //       final filename = ringtonePath.split(r'\').last.split('/').last;
// // // //
// // // //       // 3. Correct the ".mp3.mp3" error if it exists.
// // // //       if (filename.endsWith('.mp3.mp3')) {
// // // //         final correctedName = filename.substring(0, filename.length - 4);
// // // //         print("DEBUG: Corrected '.mp3' to '$correctedName'");
// // // //         return correctedName;
// // // //       }
// // // //
// // // //       // 4. Return the (now correct) filename.
// // // //       print("DEBUG: Returning filename as is: '$filename'");
// // // //       return filename;
// // // //     }
// // // //
// // // //     // 3. Generate Schedule Commands
// // // //     for (var entry in periodsByDay.entries) {
// // // //       final dayCode = dayToCode(entry.key);
// // // //       if (dayCode == '?') continue;
// // // //
// // // //       final List<String> timeAndRingtonePairs = [];
// // // //       for (var period in entry.value) {
// // // //         final ringtoneName = getRingtoneName(period.ringtone);
// // // //         final startTime = period.startTime ?? '00:00';
// // // //         timeAndRingtonePairs.add('$startTime,$ringtoneName');
// // // //       }
// // // //
// // // //       if (timeAndRingtonePairs.isNotEmpty) {
// // // //         final schedulePayload = timeAndRingtonePairs.join('!');
// // // //         final fullPayload = '$categorySequenceNumber,$dayCode,$schedulePayload';
// // // //         final byteCount = fullPayload.length;
// // // //         commands.add('\$S,$byteCount,$fullPayload#');
// // // //       }
// // // //     }
// // // //
// // // //     if (!mounted) return;
// // // //     Navigator.of(context).pop(); // Dismiss loading dialog
// // // //
// // // //     // 4. Show generated commands
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text('Generated Commands for "${cat.name}"'),
// // // //         content: SizedBox(
// // // //           width: double.maxFinite,
// // // //           child: SingleChildScrollView(
// // // //             child: Text(
// // // //               commands.join('\n'),
// // // //               style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.of(context).pop(),
// // // //             child: const Text('OK'),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   void _navigateAndRefresh() {
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // //     ).then((_) {
// // // //       _loadCategories();
// // // //     });
// // // //   }
// // // //
// // // //   void _handleCategoryTap(CategoryModel cat) {
// // // //     if (cat.configured) {
// // // //       _openWeekSchedule(cat);
// // // //     } else {
// // // //       _openGeneralSchedule(cat);
// // // //     }
// // // //   }
// // // //
// // // //   void _openGeneralSchedule(CategoryModel cat) {
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(
// // // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // // //       ),
// // // //     ).then((_) => _loadCategories());
// // // //   }
// // // //
// // // //   void _openWeekSchedule(CategoryModel cat) {
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// // // //     ).then((_) => _loadCategories());
// // // //   }
// // // //
// // // //   void _checkAllConfigured() {
// // // //     final allConfigured =
// // // //         categories.isNotEmpty && categories.every((c) => c.configured);
// // // //     if (allConfigured) {
// // // //       Navigator.pushReplacement(
// // // //         context,
// // // //         MaterialPageRoute(builder: (_) => const DashboardPage()),
// // // //       );
// // // //     } else {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(
// // // //           content: Text(
// // // //             'Please create and configure at least one category first!',
// // // //           ),
// // // //           backgroundColor: Colors.orange,
// // // //           behavior: SnackBarBehavior.floating,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('Categories'),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.check_circle_outline),
// // // //             tooltip: 'Finish Configuration',
// // // //             onPressed: _checkAllConfigured,
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       body: loading
// // // //           ? const Center(child: CircularProgressIndicator())
// // // //           : categories.isEmpty
// // // //           ? Center(
// // // //               child: Padding(
// // // //                 padding: const EdgeInsets.all(24.0),
// // // //                 child: Column(
// // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // //                   children: [
// // // //                     Icon(
// // // //                       Icons.category_outlined,
// // // //                       size: 80,
// // // //                       color: Colors.grey[400],
// // // //                     ),
// // // //                     const SizedBox(height: 16),
// // // //                     const Text(
// // // //                       'No Categories Found',
// // // //                       style: TextStyle(fontSize: 18, color: Colors.grey),
// // // //                     ),
// // // //                     const SizedBox(height: 8),
// // // //                     Text(
// // // //                       'Tap the "Add Category" button to create your first schedule category.',
// // // //                       textAlign: TextAlign.center,
// // // //                       style: TextStyle(color: Colors.grey[600]),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             )
// // // //           : ListView.builder(
// // // //               padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Space for FAB
// // // //               itemCount: categories.length,
// // // //               itemBuilder: (_, index) {
// // // //                 final cat = categories[index];
// // // //                 final categorySequence = index + 1;
// // // //                 return Card(
// // // //                   elevation: 3.0,
// // // //                   margin: const EdgeInsets.symmetric(vertical: 8.0),
// // // //                   shape: RoundedRectangleBorder(
// // // //                     borderRadius: BorderRadius.circular(12),
// // // //                   ),
// // // //                   child: ListTile(
// // // //                     contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// // // //                     leading: CircleAvatar(
// // // //                       backgroundColor: Color(cat.color),
// // // //                       child: Text(
// // // //                         cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // // //                         style: const TextStyle(
// // // //                           color: Colors.white,
// // // //                           fontWeight: FontWeight.bold,
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     title: Text(
// // // //                       cat.name,
// // // //                       style: const TextStyle(fontWeight: FontWeight.bold),
// // // //                     ),
// // // //                     subtitle: Row(
// // // //                       children: [
// // // //                         Icon(
// // // //                           cat.configured ? Icons.check_circle : Icons.pending,
// // // //                           color: cat.configured ? Colors.green : Colors.orange,
// // // //                           size: 16,
// // // //                         ),
// // // //                         const SizedBox(width: 4),
// // // //                         Text(
// // // //                           cat.configured ? "Ready to sync" : "Setup required",
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     onTap: () => _handleCategoryTap(cat),
// // // //                     trailing: Row(
// // // //                       mainAxisSize: MainAxisSize.min,
// // // //                       children: [
// // // //                         IconButton(
// // // //                           icon: const Icon(Icons.send_outlined),
// // // //                           tooltip: 'Generate Sync Commands',
// // // //                           onPressed: cat.configured
// // // //                               ? () => _generateAndShowCommands(
// // // //                                   cat,
// // // //                                   categorySequence,
// // // //                                 )
// // // //                               : null,
// // // //                           color: Theme.of(context).primaryColor,
// // // //                         ),
// // // //                         PopupMenuButton<String>(
// // // //                           tooltip: "More Options",
// // // //                           onSelected: (value) {
// // // //                             if (value == 'edit_general') {
// // // //                               _openGeneralSchedule(cat);
// // // //                             } else if (value == 'delete') {
// // // //                               _deleteCategory(cat.id!);
// // // //                             }
// // // //                           },
// // // //                           itemBuilder: (BuildContext context) =>
// // // //                               <PopupMenuEntry<String>>[
// // // //                                 const PopupMenuItem<String>(
// // // //                                   value: 'edit_general',
// // // //                                   child: ListTile(
// // // //                                     leading: Icon(Icons.edit_calendar_outlined),
// // // //                                     title: Text('Edit General'),
// // // //                                   ),
// // // //                                 ),
// // // //                                 const PopupMenuDivider(),
// // // //                                 const PopupMenuItem<String>(
// // // //                                   value: 'delete',
// // // //                                   child: ListTile(
// // // //                                     leading: Icon(
// // // //                                       Icons.delete_forever_outlined,
// // // //                                       color: Colors.red,
// // // //                                     ),
// // // //                                     title: Text(
// // // //                                       'Delete',
// // // //                                       style: TextStyle(color: Colors.red),
// // // //                                     ),
// // // //                                   ),
// // // //                                 ),
// // // //                               ],
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),
// // // //       floatingActionButton: FloatingActionButton.extended(
// // // //         onPressed: _navigateAndRefresh,
// // // //         label: const Text('Add Category'),
// // // //         icon: const Icon(Icons.add),
// // // //         tooltip: 'Add a new category',
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // //
// // //
// // //
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart'; // Used for formatting dates
// // //
// // // import '../../database/app_database.dart';
// // // import '../../models/category_model.dart';
// // // import '../../models/period_model.dart';
// // // import '../dashboard/dashboard_page.dart';
// // // import '../general/general_schedule_page.dart';
// // // import '../week/week_schedule_page.dart';
// // // import 'create_category_page.dart';
// // //
// // // class CategoryListPage extends StatefulWidget {
// // //   const CategoryListPage({super.key});
// // //
// // //   @override
// // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // }
// // //
// // // class _CategoryListPageState extends State<CategoryListPage> {
// // //   List<CategoryModel> categories = [];
// // //   bool loading = true;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCategories();
// // //   }
// // //
// // //   Future<void> _loadCategories() async {
// // //     setState(() => loading = true);
// // //     final db = await AppDB.instance.database;
// // //     // Sort by name to ensure the sequence number is consistent
// // //     final res = await db.query('categories', orderBy: 'name');
// // //     if (mounted) {
// // //       setState(() {
// // //         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // //         loading = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> _deleteCategory(int id) async {
// // //     final bool? shouldDelete = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('Delete Category'),
// // //         content: const Text(
// // //           'Are you sure you want to delete this category and all its associated data? This action cannot be undone.',
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(false),
// // //             child: const Text('Cancel'),
// // //           ),
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(true),
// // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // //             child: const Text('Delete'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //
// // //     if (shouldDelete == true) {
// // //       final db = await AppDB.instance.database;
// // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Category deleted successfully'),
// // //             backgroundColor: Colors.green,
// // //           ),
// // //         );
// // //       }
// // //       _loadCategories(); // Refresh the list
// // //     }
// // //   }
// // //
// // //   /// METHOD WITH ALL CORRECTIONS AND DEBUGGING APPLIED
// // //   Future<void> _generateAndShowCommands(
// // //       CategoryModel cat,
// // //       int categorySequenceNumber,
// // //       ) async {
// // //     if (!mounted) return;
// // //
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (context) => const Center(child: CircularProgressIndicator()),
// // //     );
// // //
// // //     final db = await AppDB.instance.database;
// // //     final List<Map<String, dynamic>> periodMaps = await db.query(
// // //       'periods',
// // //       where: 'categoryId = ?',
// // //       whereArgs: [cat.id],
// // //       orderBy: 'startTime',
// // //     );
// // //     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // //
// // //     List<String> commands = [];
// // //     final DateFormat formatter = DateFormat('dd-MM-yy');
// // //
// // //     // 1. Category Command
// // //     final DateTime startDate = DateTime.parse(cat.startDate);
// // //     final DateTime endDate = DateTime.parse(cat.endDate);
// // //     final String startDateFormatted = formatter.format(startDate);
// // //     final String endDateFormatted = formatter.format(endDate);
// // //     commands.add(
// // //       '\$C,$categorySequenceNumber,${cat.name},$startDateFormatted,$endDateFormatted#',
// // //     );
// // //
// // //     // 2. Group periods by day
// // //     final Map<String, List<PeriodModel>> periodsByDay = {};
// // //     for (var p in periods) {
// // //       (periodsByDay[p.day] ??= []).add(p);
// // //     }
// // //
// // //     String dayToCode(String day) {
// // //       const map = {
// // //         'monday': 'M',
// // //         'tuesday': 'T',
// // //         'wednesday': 'W',
// // //         'thursday': 'H',
// // //         'friday': 'F',
// // //         'saturday': 'S',
// // //         'sunday': 'U',
// // //       };
// // //       return map[day.toLowerCase()] ?? '?';
// // //     }
// // //
// // //     String getRingtoneName(String? ringtonePath) {
// // //       if (ringtonePath == null || ringtonePath.trim().isEmpty) {
// // //         return "default.mp3";
// // //       }
// // //       // Isolate the filename from the path. This handles both / and \ separators.
// // //       final filename = ringtonePath.split(r'\').last.split('/').last;
// // //
// // //       // Correct the ".mp3.mp3" error if it exists.
// // //       if (filename.endsWith('.mp3.mp3')) {
// // //         return filename.substring(0, filename.length - 4);
// // //       }
// // //
// // //       return filename;
// // //     }
// // //
// // //     // 3. Generate Schedule Commands
// // //     for (var entry in periodsByDay.entries) {
// // //       final dayCode = dayToCode(entry.key);
// // //       if (dayCode == '?') continue;
// // //
// // //       final List<String> timeAndRingtonePairs = [];
// // //       for (var period in entry.value) {
// // //         final ringtoneName = getRingtoneName(period.ringtone);
// // //         final startTime = period.startTime ?? '00:00';
// // //         timeAndRingtonePairs.add('$startTime,$ringtoneName');
// // //       }
// // //
// // //       if (timeAndRingtonePairs.isNotEmpty) {
// // //         final schedulePayload = timeAndRingtonePairs.join('!');
// // //         final fullPayload = '$categorySequenceNumber,$dayCode,$schedulePayload';
// // //         final byteCount = fullPayload.length;
// // //         commands.add('\$S,$byteCount,$fullPayload#');
// // //       }
// // //     }
// // //
// // //     if (!mounted) return;
// // //     Navigator.of(context).pop(); // Dismiss loading dialog
// // //
// // //     // 4. Show generated commands
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: Text('Generated Commands for "${cat.name}"'),
// // //         content: SizedBox(
// // //           width: double.maxFinite,
// // //           child: SingleChildScrollView(
// // //             child: Text(
// // //               commands.join('\n'),
// // //               style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
// // //             ),
// // //           ),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(),
// // //             child: const Text('OK'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _navigateAndRefresh() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // //     ).then((_) {
// // //       _loadCategories();
// // //     });
// // //   }
// // //
// // //   void _handleCategoryTap(CategoryModel cat) {
// // //     if (cat.configured) {
// // //       _openWeekSchedule(cat);
// // //     } else {
// // //       _openGeneralSchedule(cat);
// // //     }
// // //   }
// // //
// // //   void _openGeneralSchedule(CategoryModel cat) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
// // //       ),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _openWeekSchedule(CategoryModel cat) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _checkAllConfigured() {
// // //     final allConfigured =
// // //         categories.isNotEmpty && categories.every((c) => c.configured);
// // //     if (allConfigured) {
// // //       Navigator.pushReplacement(
// // //         context,
// // //         MaterialPageRoute(builder: (_) => const DashboardPage()),
// // //       );
// // //     } else {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text(
// // //             'Please create and configure at least one category first!',
// // //           ),
// // //           backgroundColor: Colors.orange,
// // //           behavior: SnackBarBehavior.floating,
// // //         ),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Categories'),
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(Icons.check_circle_outline),
// // //             tooltip: 'Finish Configuration',
// // //             onPressed: _checkAllConfigured,
// // //           ),
// // //         ],
// // //       ),
// // //       body: loading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : categories.isEmpty
// // //           ? Center(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(
// // //                 Icons.category_outlined,
// // //                 size: 80,
// // //                 color: Colors.grey[400],
// // //               ),
// // //               const SizedBox(height: 16),
// // //               const Text(
// // //                 'No Categories Found',
// // //                 style: TextStyle(fontSize: 18, color: Colors.grey),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               Text(
// // //                 'Tap the "Add Category" button to create your first schedule category.',
// // //                 textAlign: TextAlign.center,
// // //                 style: TextStyle(color: Colors.grey[600]),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       )
// // //           : ListView.builder(
// // //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Space for FAB
// // //         itemCount: categories.length,
// // //         itemBuilder: (_, index) {
// // //           final cat = categories[index];
// // //           final categorySequence = index + 1;
// // //           return Card(
// // //             elevation: 3.0,
// // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(12),
// // //             ),
// // //             child: ListTile(
// // //               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// // //               leading: CircleAvatar(
// // //                 backgroundColor: Color(cat.color),
// // //                 child: Text(
// // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ),
// // //               title: Text(
// // //                 cat.name,
// // //                 style: const TextStyle(fontWeight: FontWeight.bold),
// // //               ),
// // //               subtitle: Row(
// // //                 children: [
// // //                   Icon(
// // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // //                     color: cat.configured ? Colors.green : Colors.orange,
// // //                     size: 16,
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Text(
// // //                     cat.configured ? "Ready to sync" : "Setup required",
// // //                   ),
// // //                 ],
// // //               ),
// // //               onTap: () => _handleCategoryTap(cat),
// // //               trailing: Row(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   IconButton(
// // //                     icon: const Icon(Icons.send_outlined),
// // //                     tooltip: 'Generate Sync Commands',
// // //                     onPressed: cat.configured
// // //                         ? () => _generateAndShowCommands(
// // //                       cat,
// // //                       categorySequence,
// // //                     )
// // //                         : null,
// // //                     color: Theme.of(context).primaryColor,
// // //                   ),
// // //                   PopupMenuButton<String>(
// // //                     tooltip: "More Options",
// // //                     onSelected: (value) {
// // //                       if (value == 'edit_general') {
// // //                         _openGeneralSchedule(cat);
// // //                       } else if (value == 'delete') {
// // //                         _deleteCategory(cat.id!);
// // //                       }
// // //                     },
// // //                     itemBuilder: (BuildContext context) =>
// // //                     <PopupMenuEntry<String>>[
// // //                       const PopupMenuItem<String>(
// // //                         value: 'edit_general',
// // //                         child: ListTile(
// // //                           leading: Icon(Icons.edit_calendar_outlined),
// // //                           title: Text('Edit General'),
// // //                         ),
// // //                       ),
// // //                       const PopupMenuDivider(),
// // //                       const PopupMenuItem<String>(
// // //                         value: 'delete',
// // //                         child: ListTile(
// // //                           leading: Icon(
// // //                             Icons.delete_forever_outlined,
// // //                             color: Colors.red,
// // //                           ),
// // //                           title: Text(
// // //                             'Delete',
// // //                             style: TextStyle(color: Colors.red),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //       floatingActionButton: FloatingActionButton.extended(
// // //         onPressed: _navigateAndRefresh,
// // //         label: const Text('Add Category'),
// // //         icon: const Icon(Icons.add),
// // //         tooltip: 'Add a new category',
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:io'; // Required for raw TCP Socket communication
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:intl/intl.dart';
// // //
// // // import '../../database/app_database.dart';
// // // import '../../models/category_model.dart';
// // // import '../../models/period_model.dart';
// // // import '../dashboard/dashboard_page.dart';
// // // import '../general/general_schedule_page.dart';
// // // import '../week/week_schedule_page.dart';
// // // import 'create_category_page.dart';
// // //
// // // class CategoryListPage extends StatefulWidget {
// // //   const CategoryListPage({super.key});
// // //
// // //   @override
// // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // }
// // //
// // // class _CategoryListPageState extends State<CategoryListPage> {
// // //   List<CategoryModel> categories = [];
// // //   bool loading = true;
// // //   final Set<int> _audioUploadedCategories = {};
// // //   int? _activeUploadCategoryId;
// // //
// // //   // ESP32 Connection Details
// // //   static const String espIp = "192.168.4.1";
// // //   static const int espPort = 23;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCategories();
// // //   }
// // //
// // //   Future<void> _loadCategories() async {
// // //     setState(() => loading = true);
// // //     final db = await AppDB.instance.database;
// // //     final res = await db.query('categories', orderBy: 'name');
// // //     if (mounted) {
// // //       setState(() {
// // //         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // //         loading = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> _deleteCategory(int id) async {
// // //     final bool? shouldDelete = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('Delete Category'),
// // //         content: const Text(
// // //           'Are you sure you want to delete this category and all associated data?',
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(false),
// // //             child: const Text('Cancel'),
// // //           ),
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(true),
// // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // //             child: const Text('Delete'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //
// // //     if (shouldDelete == true) {
// // //       final db = await AppDB.instance.database;
// // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Category deleted successfully'),
// // //             backgroundColor: Colors.green,
// // //           ),
// // //         );
// // //       }
// // //       _loadCategories();
// // //     }
// // //   }
// // //
// // //   /// NEW: Standalone function to test the ESP32 connection.
// // //   Future<void> _checkEspConnection() async {
// // //     if (!mounted) return;
// // //
// // //     final messenger = ScaffoldMessenger.of(context);
// // //     messenger.hideCurrentSnackBar();
// // //     messenger.showSnackBar(
// // //       const SnackBar(content: Text('Checking ESP32 connection...')),
// // //     );
// // //
// // //     Socket? socket;
// // //     try {
// // //       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
// // //       messenger.hideCurrentSnackBar();
// // //       messenger.showSnackBar(
// // //         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
// // //       );
// // //     } catch (e) {
// // //       messenger.hideCurrentSnackBar();
// // //       messenger.showSnackBar(
// // //         SnackBar(
// // //           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
// // //           backgroundColor: Colors.red,
// // //           duration: const Duration(seconds: 7),
// // //         ),
// // //       );
// // //     } finally {
// // //       socket?.destroy();
// // //     }
// // //   }
// // //
// // //   String _getRingtoneName(String? ringtonePath) {
// // //     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
// // //       return "default.mp3";
// // //     }
// // //     final filename = ringtonePath.split(r'\').last.split('/').last;
// // //     if (filename.endsWith('.mp3.mp3')) {
// // //       return filename.substring(0, filename.length - 4);
// // //     }
// // //     return filename;
// // //   }
// // //
// // //   Future<void> _uploadAudioFiles(CategoryModel category) async {
// // //     if (!mounted) return;
// // //
// // //     setState(() {
// // //       _activeUploadCategoryId = category.id;
// // //     });
// // //
// // //     try {
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (context) => const AlertDialog(
// // //           title: Text('Preparing Audio Files...'),
// // //           content: Column(mainAxisSize: MainAxisSize.min, children: [
// // //             CircularProgressIndicator(),
// // //             SizedBox(height: 16),
// // //             Text("Please wait."),
// // //           ]),
// // //         ),
// // //       );
// // //
// // //       final db = await AppDB.instance.database;
// // //       final periodMaps = await db.query(
// // //         'periods',
// // //         where: 'categoryId = ?',
// // //         whereArgs: [category.id],
// // //       );
// // //       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // //       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
// // //
// // //       if (!mounted) return;
// // //       Navigator.of(context).pop();
// // //
// // //       if (uniqueRingtonePaths.isEmpty) {
// // //         _audioUploadedCategories.add(category.id!);
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('No audio files to upload for this category.')),
// // //         );
// // //         return;
// // //       }
// // //
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (context) => AlertDialog(
// // //           title: const Text('Uploading Audio Files'),
// // //           content: Column(mainAxisSize: MainAxisSize.min, children: [
// // //             const CircularProgressIndicator(),
// // //             const SizedBox(height: 16),
// // //             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
// // //           ]),
// // //         ),
// // //       );
// // //
// // //       for (final path in uniqueRingtonePaths) {
// // //         final fileName = _getRingtoneName(path);
// // //         final ByteData data = await rootBundle.load(path);
// // //         final List<int> bytes = data.buffer.asUint8List();
// // //
// // //         Socket? socket;
// // //         try {
// // //           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
// // //           final fileHeader = 'SENDFILE|$fileName|${bytes.length}\n';
// // //           socket.write(fileHeader);
// // //           socket.add(bytes);
// // //           await socket.flush();
// // //           await socket.close();
// // //         } catch (e) {
// // //           throw Exception("Failed to upload '$fileName': $e");
// // //         } finally {
// // //           socket?.destroy();
// // //         }
// // //       }
// // //
// // //       if (!mounted) return;
// // //       Navigator.of(context).pop();
// // //
// // //       setState(() {
// // //         _audioUploadedCategories.add(category.id!);
// // //       });
// // //
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
// // //       );
// // //     } catch (e) {
// // //       if (mounted) {
// // //         if (Navigator.canPop(context)) Navigator.of(context).pop();
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() {
// // //           _activeUploadCategoryId = null;
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   /// UPDATED: Now uses raw TCP sockets, removing the last dependency on the service file.
// // //   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
// // //     // if (!_audioUploadedCategories.contains(cat.id)) {
// // //     //   ScaffoldMessenger.of(context).showSnackBar(
// // //     //     const SnackBar(
// // //     //       content: Text('Please upload the audio files before sending commands.'),
// // //     //       backgroundColor: Colors.orange,
// // //     //     ),
// // //     //   );
// // //     //   return;
// // //     // }
// // //
// // //     if (!mounted) return;
// // //
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (context) => const Center(child: CircularProgressIndicator()),
// // //     );
// // //
// // //     try {
// // //       final db = await AppDB.instance.database;
// // //       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
// // //       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // //
// // //       List<String> commands = [];
// // //       final DateFormat formatter = DateFormat('dd/MM/yy');
// // //       final DateTime startDate = DateTime.parse(cat.startDate);
// // //       final DateTime endDate = DateTime.parse(cat.endDate);
// // //       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
// // //
// // //       final Map<String, List<PeriodModel>> periodsByDay = {};
// // //       for (var p in periods) {
// // //         (periodsByDay[p.day] ??= []).add(p);
// // //       }
// // //
// // //       String dayToCode(String day) => day.toLowerCase().substring(0, 1).toUpperCase();
// // //
// // //       for (var entry in periodsByDay.entries) {
// // //         final dayCode = dayToCode(entry.key);
// // //         final timeAndRingtonePairs = entry.value.map((p) {
// // //           final ringtoneName = _getRingtoneName(p.ringtone);
// // //           return '${p.startTime},$ringtoneName';
// // //         }).join('!');
// // //         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
// // //         commands.add('\$S,${fullPayload.length},$fullPayload#');
// // //       }
// // //
// // //       Socket? socket;
// // //       try {
// // //         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
// // //         for (final command in commands) {
// // //           socket.writeln(command);
// // //           await Future.delayed(const Duration(milliseconds: 50));
// // //         }
// // //         await socket.flush();
// // //       } catch (e) {
// // //         throw Exception("Failed to send commands via TCP: $e");
// // //       } finally {
// // //         socket?.destroy();
// // //       }
// // //
// // //       if (mounted) {
// // //         Navigator.of(context).pop();
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         Navigator.of(context).pop();
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
// // //         );
// // //       }
// // //     }
// // //   }
// // //
// // //   void _navigateAndRefresh() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _handleCategoryTap(CategoryModel cat) {
// // //     if (cat.configured) {
// // //       _openWeekSchedule(cat);
// // //     } else {
// // //       _openGeneralSchedule(cat);
// // //     }
// // //   }
// // //
// // //   void _openGeneralSchedule(CategoryModel cat) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _openWeekSchedule(CategoryModel cat) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _checkAllConfigured() {
// // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // //     if (allConfigured) {
// // //       Navigator.pushReplacement(
// // //         context,
// // //         MaterialPageRoute(builder: (_) => const DashboardPage()),
// // //       );
// // //     } else {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text('Please create and configure at least one category first!'),
// // //           backgroundColor: Colors.orange,
// // //         ),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Categories'),
// // //         actions: [
// // //           // NEW DIAGNOSTIC BUTTON
// // //           IconButton(
// // //             icon: const Icon(Icons.wifi_tethering),
// // //             tooltip: 'Check ESP32 Connection',
// // //             onPressed: _checkEspConnection,
// // //           ),
// // //           IconButton(
// // //             icon: const Icon(Icons.check_circle_outline),
// // //             tooltip: 'Finish Configuration',
// // //             onPressed: _checkAllConfigured,
// // //           ),
// // //         ],
// // //       ),
// // //       body: loading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : categories.isEmpty
// // //           ? Center(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // //               const SizedBox(height: 16),
// // //               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
// // //             ],
// // //           ),
// // //         ),
// // //       )
// // //           : ListView.builder(
// // //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
// // //         itemCount: categories.length,
// // //         itemBuilder: (_, index) {
// // //           final cat = categories[index];
// // //           final categorySequence = index + 1;
// // //           final isUploading = _activeUploadCategoryId == cat.id;
// // //           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
// // //
// // //           return Card(
// // //             elevation: 3.0,
// // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //             child: ListTile(
// // //               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// // //               leading: CircleAvatar(
// // //                 backgroundColor: Color(cat.color),
// // //                 child: Text(
// // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                 ),
// // //               ),
// // //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// // //               subtitle: Row(
// // //                 children: [
// // //                   Icon(
// // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // //                     color: cat.configured ? Colors.green : Colors.orange,
// // //                     size: 16,
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Text(cat.configured ? "Ready to sync" : "Setup required"),
// // //                 ],
// // //               ),
// // //               onTap: () => _handleCategoryTap(cat),
// // //               trailing: Row(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   if (isUploading)
// // //                     const Padding(
// // //                       padding: EdgeInsets.all(12.0),
// // //                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
// // //                     )
// // //                   else
// // //                     IconButton(
// // //                       icon: Icon(
// // //                         Icons.music_note_outlined,
// // //                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
// // //                       ),
// // //                       tooltip: 'Upload Audio Files to ESP32',
// // //                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
// // //                     ),
// // //                   IconButton(
// // //                     icon: const Icon(Icons.send_outlined),
// // //                     tooltip: 'Send Commands to ESP32',
// // //                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
// // //                     color: Theme.of(context).colorScheme.primary,
// // //                   ),
// // //                   PopupMenuButton<String>(
// // //                     tooltip: "More Options",
// // //                     onSelected: (value) {
// // //                       if (value == 'edit_general') {
// // //                         _openGeneralSchedule(cat);
// // //                       } else if (value == 'delete') {
// // //                         _deleteCategory(cat.id!);
// // //                       }
// // //                     },
// // //                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // //                       const PopupMenuItem<String>(
// // //                         value: 'edit_general',
// // //                         child: ListTile(
// // //                           leading: Icon(Icons.edit_calendar_outlined),
// // //                           title: Text('Edit General'),
// // //                         ),
// // //                       ),
// // //                       const PopupMenuDivider(),
// // //                       const PopupMenuItem<String>(
// // //                         value: 'delete',
// // //                         child: ListTile(
// // //                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
// // //                           title: Text('Delete', style: TextStyle(color: Colors.red)),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //       floatingActionButton: FloatingActionButton.extended(
// // //         onPressed: _navigateAndRefresh,
// // //         label: const Text('Add Category'),
// // //         icon: const Icon(Icons.add),
// // //         tooltip: 'Add a new category',
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:io'; // Required for raw TCP Socket communication
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:intl/intl.dart';
// // //
// // // import '../../database/app_database.dart';
// // // import '../../models/category_model.dart';
// // // import '../../models/period_model.dart';
// // // import '../dashboard/dashboard_page.dart';
// // // import '../general/general_schedule_page.dart';
// // // import '../week/week_schedule_page.dart';
// // // import 'create_category_page.dart';
// // //
// // // class CategoryListPage extends StatefulWidget {
// // //   const CategoryListPage({super.key});
// // //
// // //   @override
// // //   State<CategoryListPage> createState() => _CategoryListPageState();
// // // }
// // //
// // // class _CategoryListPageState extends State<CategoryListPage> {
// // //   List<CategoryModel> categories = [];
// // //   bool loading = true;
// // //   final Set<int> _audioUploadedCategories = {};
// // //   int? _activeUploadCategoryId;
// // //
// // //   // ESP32 Connection Details
// // //   static const String espIp = "192.168.4.1";
// // //   static const int espPort = 23;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCategories();
// // //   }
// // //
// // //   Future<void> _loadCategories() async {
// // //     setState(() => loading = true);
// // //     final db = await AppDB.instance.database;
// // //     final res = await db.query('categories', orderBy: 'name');
// // //     if (mounted) {
// // //       setState(() {
// // //         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // //         loading = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> _deleteCategory(int id) async {
// // //     final bool? shouldDelete = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('Delete Category'),
// // //         content: const Text(
// // //           'Are you sure you want to delete this category and all associated data?',
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(false),
// // //             child: const Text('Cancel'),
// // //           ),
// // //           TextButton(
// // //             onPressed: () => Navigator.of(context).pop(true),
// // //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// // //             child: const Text('Delete'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //
// // //     if (shouldDelete == true) {
// // //       final db = await AppDB.instance.database;
// // //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Category deleted successfully'),
// // //             backgroundColor: Colors.green,
// // //           ),
// // //         );
// // //       }
// // //       _loadCategories();
// // //     }
// // //   }
// // //
// // //   /// NEW: Standalone function to test the ESP32 connection.
// // //   Future<void> _checkEspConnection() async {
// // //     if (!mounted) return;
// // //
// // //     final messenger = ScaffoldMessenger.of(context);
// // //     messenger.hideCurrentSnackBar();
// // //     messenger.showSnackBar(
// // //       const SnackBar(content: Text('Checking ESP32 connection...')),
// // //     );
// // //
// // //     Socket? socket;
// // //     try {
// // //       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
// // //       messenger.hideCurrentSnackBar();
// // //       messenger.showSnackBar(
// // //         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
// // //       );
// // //     } catch (e) {
// // //       messenger.hideCurrentSnackBar();
// // //       messenger.showSnackBar(
// // //         SnackBar(
// // //           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
// // //           backgroundColor: Colors.red,
// // //           duration: const Duration(seconds: 7),
// // //         ),
// // //       );
// // //     } finally {
// // //       socket?.destroy();
// // //     }
// // //   }
// // //
// // //   String _getRingtoneName(String? ringtonePath) {
// // //     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
// // //       return "default.mp3";
// // //     }
// // //     final filename = ringtonePath.split(r'\').last.split('/').last;
// // //     if (filename.endsWith('.mp3.mp3')) {
// // //       return filename.substring(0, filename.length - 4);
// // //     }
// // //     return filename;
// // //   }
// // //
// // //   Future<void> _uploadAudioFiles(CategoryModel category) async {
// // //     if (!mounted) return;
// // //
// // //     setState(() {
// // //       _activeUploadCategoryId = category.id;
// // //     });
// // //
// // //     try {
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (context) => const AlertDialog(
// // //           title: Text('Preparing Audio Files...'),
// // //           content: Column(mainAxisSize: MainAxisSize.min, children: [
// // //             CircularProgressIndicator(),
// // //             SizedBox(height: 16),
// // //             Text("Please wait."),
// // //           ]),
// // //         ),
// // //       );
// // //
// // //       final db = await AppDB.instance.database;
// // //       final periodMaps = await db.query(
// // //         'periods',
// // //         where: 'categoryId = ?',
// // //         whereArgs: [category.id],
// // //       );
// // //       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // //       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
// // //
// // //       if (!mounted) return;
// // //       Navigator.of(context).pop();
// // //
// // //       if (uniqueRingtonePaths.isEmpty) {
// // //         _audioUploadedCategories.add(category.id!);
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('No audio files to upload for this category.')),
// // //         );
// // //         return;
// // //       }
// // //
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (context) => AlertDialog(
// // //           title: const Text('Uploading Audio Files'),
// // //           content: Column(mainAxisSize: MainAxisSize.min, children: [
// // //             const CircularProgressIndicator(),
// // //             const SizedBox(height: 16),
// // //             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
// // //           ]),
// // //         ),
// // //       );
// // //
// // //       for (final path in uniqueRingtonePaths) {
// // //         final fileName = _getRingtoneName(path);
// // //         final ByteData data = await rootBundle.load(path);
// // //         final List<int> bytes = data.buffer.asUint8List();
// // //
// // //         Socket? socket;
// // //         try {
// // //           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
// // //           final fileHeader = 'SENDFILE|$fileName|${bytes.length}\n';
// // //           socket.write(fileHeader);
// // //           socket.add(bytes);
// // //           await socket.flush();
// // //           await socket.close();
// // //         } catch (e) {
// // //           throw Exception("Failed to upload '$fileName': $e");
// // //         } finally {
// // //           socket?.destroy();
// // //         }
// // //       }
// // //
// // //       if (!mounted) return;
// // //       Navigator.of(context).pop();
// // //
// // //       setState(() {
// // //         _audioUploadedCategories.add(category.id!);
// // //       });
// // //
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
// // //       );
// // //     } catch (e) {
// // //       if (mounted) {
// // //         if (Navigator.canPop(context)) Navigator.of(context).pop();
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() {
// // //           _activeUploadCategoryId = null;
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   /// UPDATED: Now shows commands in a dialog before sending.
// // //   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
// // //     if (!mounted) return;
// // //
// // //     final messenger = ScaffoldMessenger.of(context);
// // //
// // //     try {
// // //       // Part 1: Generate Commands
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (context) => const Center(child: CircularProgressIndicator()),
// // //       );
// // //
// // //       final db = await AppDB.instance.database;
// // //       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
// // //       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// // //
// // //       List<String> commands = [];
// // //       final DateFormat formatter = DateFormat('dd/MM/yy');
// // //       final DateTime startDate = DateTime.parse(cat.startDate);
// // //       final DateTime endDate = DateTime.parse(cat.endDate);
// // //       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
// // //
// // //       final Map<String, List<PeriodModel>> periodsByDay = {};
// // //       for (var p in periods) {
// // //         (periodsByDay[p.day] ??= []).add(p);
// // //       }
// // //
// // //       String dayToCode(String day) => day.toLowerCase().substring(0, 1).toUpperCase();
// // //
// // //       for (var entry in periodsByDay.entries) {
// // //         final dayCode = dayToCode(entry.key);
// // //         final timeAndRingtonePairs = entry.value.map((p) {
// // //           final ringtoneName = _getRingtoneName(p.ringtone);
// // //           return '${p.startTime},$ringtoneName';
// // //         }).join('!');
// // //         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
// // //         commands.add('\$S,${fullPayload.length},$fullPayload#');
// // //       }
// // //
// // //       if (!mounted) return;
// // //       Navigator.of(context).pop(); // Pop the temporary loading indicator
// // //
// // //       // Part 2: Show confirmation dialog
// // //       final bool? shouldSend = await showDialog<bool>(
// // //         context: context,
// // //         builder: (context) => AlertDialog(
// // //           title: Text('Generated Commands for "${cat.name}"'),
// // //           content: SizedBox(
// // //             width: double.maxFinite,
// // //             child: SingleChildScrollView(
// // //               child: Text(
// // //                 commands.join('\n'),
// // //                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
// // //               ),
// // //             ),
// // //           ),
// // //           actions: [
// // //             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
// // //             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
// // //           ],
// // //         ),
// // //       );
// // //
// // //       if (shouldSend != true) return; // User cancelled
// // //
// // //       // Part 3: Send commands with progress indicator
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (context) => const AlertDialog(
// // //           title: Text('Sending Commands...'),
// // //           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
// // //         ),
// // //       );
// // //
// // //       Socket? socket;
// // //       try {
// // //         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
// // //         for (final command in commands) {
// // //           socket.writeln(command);
// // //           await Future.delayed(const Duration(milliseconds: 50));
// // //         }
// // //         await socket.flush();
// // //       } catch (e) {
// // //         throw Exception("Failed to send commands via TCP: $e");
// // //       } finally {
// // //         socket?.destroy();
// // //       }
// // //
// // //       if (mounted) {
// // //         Navigator.of(context).pop(); // Pop progress indicator
// // //         messenger.showSnackBar(
// // //           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         if (Navigator.canPop(context)) {
// // //           Navigator.of(context).pop(); // Pop any open dialog
// // //         }
// // //         messenger.showSnackBar(
// // //           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
// // //         );
// // //       }
// // //     }
// // //   }
// // //
// // //   void _navigateAndRefresh() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _handleCategoryTap(CategoryModel cat) {
// // //     if (cat.configured) {
// // //       _openWeekSchedule(cat);
// // //     } else {
// // //       _openGeneralSchedule(cat);
// // //     }
// // //   }
// // //
// // //   void _openGeneralSchedule(CategoryModel cat) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _openWeekSchedule(CategoryModel cat) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _checkAllConfigured() {
// // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // //     if (allConfigured) {
// // //       Navigator.pushReplacement(
// // //         context,
// // //         MaterialPageRoute(builder: (_) => const DashboardPage()),
// // //       );
// // //     } else {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text('Please create and configure at least one category first!'),
// // //           backgroundColor: Colors.orange,
// // //         ),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Categories'),
// // //         actions: [
// // //           // NEW DIAGNOSTIC BUTTON
// // //           IconButton(
// // //             icon: const Icon(Icons.wifi_tethering),
// // //             tooltip: 'Check ESP32 Connection',
// // //             onPressed: _checkEspConnection,
// // //           ),
// // //           IconButton(
// // //             icon: const Icon(Icons.check_circle_outline),
// // //             tooltip: 'Finish Configuration',
// // //             onPressed: _checkAllConfigured,
// // //           ),
// // //         ],
// // //       ),
// // //       body: loading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : categories.isEmpty
// // //           ? Center(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // //               const SizedBox(height: 16),
// // //               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
// // //             ],
// // //           ),
// // //         ),
// // //       )
// // //           : ListView.builder(
// // //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
// // //         itemCount: categories.length,
// // //         itemBuilder: (_, index) {
// // //           final cat = categories[index];
// // //           final categorySequence = index + 1;
// // //           final isUploading = _activeUploadCategoryId == cat.id;
// // //           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
// // //
// // //           return Card(
// // //             elevation: 3.0,
// // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //             child: ListTile(
// // //               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// // //               leading: CircleAvatar(
// // //                 backgroundColor: Color(cat.color),
// // //                 child: Text(
// // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                 ),
// // //               ),
// // //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// // //               subtitle: Row(
// // //                 children: [
// // //                   Icon(
// // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // //                     color: cat.configured ? Colors.green : Colors.orange,
// // //                     size: 16,
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Text(cat.configured ? "Ready to sync" : "Setup required"),
// // //                 ],
// // //               ),
// // //               onTap: () => _handleCategoryTap(cat),
// // //               trailing: Row(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   if (isUploading)
// // //                     const Padding(
// // //                       padding: EdgeInsets.all(12.0),
// // //                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
// // //                     )
// // //                   else
// // //                     IconButton(
// // //                       icon: Icon(
// // //                         Icons.music_note_outlined,
// // //                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
// // //                       ),
// // //                       tooltip: 'Upload Audio Files to ESP32',
// // //                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
// // //                     ),
// // //                   IconButton(
// // //                     icon: const Icon(Icons.send_outlined),
// // //                     tooltip: 'Send Commands to ESP32',
// // //                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
// // //                     color: Theme.of(context).colorScheme.primary,
// // //                   ),
// // //                   PopupMenuButton<String>(
// // //                     tooltip: "More Options",
// // //                     onSelected: (value) {
// // //                       if (value == 'edit_general') {
// // //                         _openGeneralSchedule(cat);
// // //                       } else if (value == 'delete') {
// // //                         _deleteCategory(cat.id!);
// // //                       }
// // //                     },
// // //                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // //                       const PopupMenuItem<String>(
// // //                         value: 'edit_general',
// // //                         child: ListTile(
// // //                           leading: Icon(Icons.edit_calendar_outlined),
// // //                           title: Text('Edit General'),
// // //                         ),
// // //                       ),
// // //                       const PopupMenuDivider(),
// // //                       const PopupMenuItem<String>(
// // //                         value: 'delete',
// // //                         child: ListTile(
// // //                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
// // //                           title: Text('Delete', style: TextStyle(color: Colors.red)),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //       floatingActionButton: FloatingActionButton.extended(
// // //         onPressed: _navigateAndRefresh,
// // //         label: const Text('Add Category'),
// // //         icon: const Icon(Icons.add),
// // //         tooltip: 'Add a new category',
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Category deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   /// NEW: Standalone function to test the ESP32 connection.
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(
//       const SnackBar(content: Text('Checking ESP32 connection...')),
//     );
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 7),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
//       return "default.mp3";
//     }
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//     if (filename.endsWith('.mp3.mp3')) {
//       return filename.substring(0, filename.length - 4);
//     }
//     return filename;
//   }
//
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() {
//       _activeUploadCategoryId = category.id;
//     });
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Preparing Audio Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Please wait."),
//           ]),
//         ),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       if (uniqueRingtonePaths.isEmpty) {
//         _audioUploadedCategories.add(category.id!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No audio files to upload for this category.')),
//         );
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Audio Files'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
//           ]),
//         ),
//       );
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//         final ByteData data = await rootBundle.load(path);
//         final List<int> bytes = data.buffer.asUint8List();
//
//         Socket? socket;
//         try {
//           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
//           final fileHeader = 'SENDFILE|$fileName|${bytes.length}\n';
//           socket.write(fileHeader);
//           socket.add(bytes);
//           await socket.flush();
//           await socket.close();
//         } catch (e) {
//           throw Exception("Failed to upload '$fileName': $e");
//         } finally {
//           socket?.destroy();
//         }
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       setState(() {
//         _audioUploadedCategories.add(category.id!);
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _activeUploadCategoryId = null;
//         });
//       }
//     }
//   }
//
//   /// UPDATED: Implements the requested day-to-code mapping.
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       // Part 1: Generate Commands
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       final DateTime startDate = DateTime.parse(cat.startDate);
//       final DateTime endDate = DateTime.parse(cat.endDate);
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) {
//         (periodsByDay[p.day] ??= []).add(p);
//       }
//
//       // Correct Day-to-Code Mapping
//       String dayToCode(String day) {
//         const map = {
//           'sunday': 'U',
//           'monday': 'M',
//           'tuesday': 'T',
//           'wednesday': 'W',
//           'thursday': 'H',
//           'friday': 'F',
//           'saturday': 'S',
//         };
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue; // Skip days not in the map
//
//         final timeAndRingtonePairs = entry.value.map((p) {
//           final ringtoneName = _getRingtoneName(p.ringtone);
//           return '${p.startTime},$ringtoneName';
//         }).join('!');
//         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${fullPayload.length},$fullPayload#');
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop(); // Pop the temporary loading indicator
//
//       // Part 2: Show confirmation dialog
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Text(
//                 commands.join('\n'),
//                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return; // User cancelled
//
//       // Part 3: Send commands with progress indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Sending Commands...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
//         ),
//       );
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands via TCP: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Pop progress indicator
//         messenger.showSnackBar(
//           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) {
//           Navigator.of(context).pop(); // Pop any open dialog
//         }
//         messenger.showSnackBar(
//           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           // NEW DIAGNOSTIC BUTTON
//           IconButton(
//             icon: const Icon(Icons.wifi_tethering),
//             tooltip: 'Check ESP32 Connection',
//             onPressed: _checkEspConnection,
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured ? Icons.check_circle : Icons.pending,
//                     color: cat.configured ? Colors.green : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured ? "Ready to sync" : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
//                     )
//                   else
//                     IconButton(
//                       icon: Icon(
//                         Icons.music_note_outlined,
//                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
//                       ),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') {
//                         _openGeneralSchedule(cat);
//                       } else if (value == 'delete') {
//                         _deleteCategory(cat.id!);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(
//                           leading: Icon(Icons.edit_calendar_outlined),
//                           title: Text('Edit General'),
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
//                           title: Text('Delete', style: TextStyle(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
//       ),
//     );
//   }
// }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Category deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   /// NEW: Standalone function to test the ESP32 connection.
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(
//       const SnackBar(content: Text('Checking ESP32 connection...')),
//     );
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 7),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
//       return "default.mp3";
//     }
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//     if (filename.endsWith('.mp3.mp3')) {
//       return filename.substring(0, filename.length - 4);
//     }
//     return filename;
//   }
//
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() {
//       _activeUploadCategoryId = category.id;
//     });
//
//     Socket? socket;
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Preparing Audio Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Please wait."),
//           ]),
//         ),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       // Handle default ringtone if any period uses it
//       if (periods.any((p) => p.ringtone == null || p.ringtone?.trim().isEmpty == true)) {
//         uniqueRingtonePaths.add('assets/default.mp3'); // Adjust this path to your actual default asset path
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       if (uniqueRingtonePaths.isEmpty) {
//         _audioUploadedCategories.add(category.id!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No audio files to upload for this category.')),
//         );
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Audio Files'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
//           ]),
//         ),
//       );
//
//       // Connect once for all files
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 30));
//
//       // Optional: Listen for responses
//       StringBuffer responseBuffer = StringBuffer();
//       socket.listen(
//             (List<int> data) {
//           responseBuffer.write(utf8.decode(data));
//           // You can check for specific responses if needed, e.g., if (responseBuffer.toString().contains('OK')) { ... }
//         },
//         onError: (error) {
//           print('Socket error: $error');
//         },
//         onDone: () {
//           print('Socket closed. Response: ${responseBuffer.toString()}');
//         },
//       );
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//
//         // Load bytes: try asset first, then file system
//         List<int> bytes;
//         try {
//           final ByteData data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (e) {
//           final File audioFile = File(path);
//           if (!await audioFile.exists()) {
//             throw Exception('Audio file not found at $path');
//           }
//           bytes = await audioFile.readAsBytes();
//         }
//
//         final fileHeader = 'SENDFILE|$fileName|${bytes.length}\n';
//         socket.write(fileHeader);
//         await socket.flush();
//
//         // Send in chunks to avoid buffer issues
//         const int chunkSize = 1024;
//         for (int i = 0; i < bytes.length; i += chunkSize) {
//           int end = i + chunkSize;
//           if (end > bytes.length) end = bytes.length;
//           socket.add(bytes.sublist(i, end));
//           await socket.flush();
//           await Future.delayed(const Duration(milliseconds: 50)); // Small delay between chunks
//         }
//
//         // Delay to allow ESP32 to write to SD card
//         await Future.delayed(const Duration(seconds: 2));
//
//         // Optional: Check response if needed
//         // For now, assume success if no error thrown
//       }
//
//       await socket.flush();
//       await socket.close();
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       setState(() {
//         _audioUploadedCategories.add(category.id!);
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       socket?.destroy();
//       if (mounted) {
//         setState(() {
//           _activeUploadCategoryId = null;
//         });
//       }
//     }
//   }
//
//   /// UPDATED: Implements the requested day-to-code mapping.
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       // Part 1: Generate Commands
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       final DateTime startDate = DateTime.parse(cat.startDate);
//       final DateTime endDate = DateTime.parse(cat.endDate);
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) {
//         (periodsByDay[p.day] ??= []).add(p);
//       }
//
//       // Correct Day-to-Code Mapping
//       String dayToCode(String day) {
//         const map = {
//           'sunday': 'U',
//           'monday': 'M',
//           'tuesday': 'T',
//           'wednesday': 'W',
//           'thursday': 'H',
//           'friday': 'F',
//           'saturday': 'S',
//         };
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue; // Skip days not in the map
//
//         final timeAndRingtonePairs = entry.value.map((p) {
//           final ringtoneName = _getRingtoneName(p.ringtone);
//           return '${p.startTime},$ringtoneName';
//         }).join('!');
//         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${fullPayload.length},$fullPayload#');
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop(); // Pop the temporary loading indicator
//
//       // Part 2: Show confirmation dialog
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Text(
//                 commands.join('\n'),
//                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return; // User cancelled
//
//       // Part 3: Send commands with progress indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Sending Commands...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
//         ),
//       );
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands via TCP: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Pop progress indicator
//         messenger.showSnackBar(
//           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) {
//           Navigator.of(context).pop(); // Pop any open dialog
//         }
//         messenger.showSnackBar(
//           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           // NEW DIAGNOSTIC BUTTON
//           IconButton(
//             icon: const Icon(Icons.wifi_tethering),
//             tooltip: 'Check ESP32 Connection',
//             onPressed: _checkEspConnection,
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured ? Icons.check_circle : Icons.pending,
//                     color: cat.configured ? Colors.green : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured ? "Ready to sync" : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
//                     )
//                   else
//                     IconButton(
//                       icon: Icon(
//                         Icons.music_note_outlined,
//                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
//                       ),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') {
//                         _openGeneralSchedule(cat);
//                       } else if (value == 'delete') {
//                         _deleteCategory(cat.id!);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(
//                           leading: Icon(Icons.edit_calendar_outlined),
//                           title: Text('Edit General'),
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
//                           title: Text('Delete', style: TextStyle(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
//       ),
//     );
//   }
// }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Required for raw TCP Socket communication
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../models/category_model.dart';
import '../../models/period_model.dart';
import '../general/general_schedule_page.dart';
import '../week/week_schedule_page.dart';
import 'create_category_page.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<CategoryModel> categories = [];
  bool loading = true;
  final Set<int> _audioUploadedCategories = {};
  int? _activeUploadCategoryId;

  // ESP32 Connection Details
  static const String espIp = "192.168.4.1";
  static const int espPort = 23;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => loading = true);
    final db = await AppDB.instance.database;
    final res = await db.query('categories', orderBy: 'name');
    if (mounted) {
      setState(() {
        categories = res.map((e) => CategoryModel.fromMap(e)).toList();
        loading = false;
      });
    }
  }

  Future<void> _deleteCategory(int id) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category and all associated data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final db = await AppDB.instance.database;
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
      await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadCategories();
    }
  }

  /// NEW: Standalone function to test the ESP32 connection.
  Future<void> _checkEspConnection() async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Checking ESP32 connection...')),
    );

    Socket? socket;
    try {
      socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 7),
        ),
      );
    } finally {
      socket?.destroy();
    }
  }

  String _getRingtoneName(String? ringtonePath) {
    if (ringtonePath == null || ringtonePath.trim().isEmpty) {
      return "default.mp3";
    }
    final filename = ringtonePath.split(r'\').last.split('/').last;
    if (filename.endsWith('.mp3.mp3')) {
      return filename.substring(0, filename.length - 4);
    }
    return filename;
  }

  Future<void> _uploadAudioFiles(CategoryModel category) async {
    if (!mounted) return;

    setState(() {
      _activeUploadCategoryId = category.id;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Preparing Audio Files...'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Please wait."),
          ]),
        ),
      );

      final db = await AppDB.instance.database;
      final periodMaps = await db.query(
        'periods',
        where: 'categoryId = ?',
        whereArgs: [category.id],
      );
      final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
      final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();

      // Handle default ringtone if any period uses it
      if (periods.any((p) => p.ringtone == null || p.ringtone?.trim().isEmpty == true)) {
        uniqueRingtonePaths.add('assets/default.mp3'); // Adjust this path to your actual default asset path
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      if (uniqueRingtonePaths.isEmpty) {
        _audioUploadedCategories.add(category.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio files to upload for this category.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Uploading Audio Files'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
          ]),
        ),
      );

      for (final path in uniqueRingtonePaths) {
        final fileName = _getRingtoneName(path);

        // Load bytes: try asset first, then file system
        List<int> bytes;
        try {
          final ByteData data = await rootBundle.load(path);
          bytes = data.buffer.asUint8List();
        } catch (e) {
          final File audioFile = File(path);
          if (!await audioFile.exists()) {
            throw Exception('Audio file not found at $path');
          }
          bytes = await audioFile.readAsBytes();
        }

        final fileSize = bytes.length;

        Socket? socket;
        StreamSubscription<List<int>>? listener;
        try {
          socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 30));

          Completer<String> headerCompleter = Completer<String>();
          Completer<String> successCompleter = Completer<String>();
          StringBuffer responseBuffer = StringBuffer();

          listener = socket.listen(
                (List<int> data) {
              final String decoded = utf8.decode(data);
              responseBuffer.write(decoded);
              final String response = responseBuffer.toString();

              if (!headerCompleter.isCompleted && response.contains('READY, SEND')) {
                headerCompleter.complete(response.trim());
                responseBuffer.clear(); // Clear for next response
              } else if (!successCompleter.isCompleted && response.contains('SUCCESS:')) {
                successCompleter.complete(response.trim());
              }
            },
            onError: (error) {
              if (!headerCompleter.isCompleted) headerCompleter.completeError(error);
              if (!successCompleter.isCompleted) successCompleter.completeError(error);
            },
            onDone: () {
              if (!headerCompleter.isCompleted) headerCompleter.completeError(Exception('Socket closed unexpectedly'));
              if (!successCompleter.isCompleted) successCompleter.completeError(Exception('Socket closed unexpectedly'));
            },
          );

          // Send file command
          final command = '\$FILE,$fileName,$fileSize#';
          socket.write(command);
          await socket.flush();

          // Wait for header response
          final String headerResponse = await headerCompleter.future.timeout(const Duration(seconds: 10));
          final expectedHeader = 'OK: /$fileName READY, SEND $fileSize BYTES';
          if (!headerResponse.contains(expectedHeader)) {
            throw Exception('Unexpected header response: $headerResponse');
          }

          // Send binary data in chunks
          const int chunkSize = 512;
          for (int i = 0; i < bytes.length; i += chunkSize) {
            int end = i + chunkSize;
            if (end > bytes.length) end = bytes.length;
            socket.add(bytes.sublist(i, end));
            await socket.flush();
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // Wait for success response
          final String successResponse = await successCompleter.future.timeout(const Duration(seconds: 30));
          final expectedSuccess = 'SUCCESS: $fileSize bytes saved as /$fileName';
          if (!successResponse.contains(expectedSuccess)) {
            throw Exception('Unexpected success response: $successResponse');
          }

          await listener.cancel();
          await socket.close();
        } catch (e) {
          throw Exception("Failed to upload '$fileName': $e");
        } finally {
          listener?.cancel();
          socket?.destroy();
        }

        // Delay between files
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      setState(() {
        _audioUploadedCategories.add(category.id!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _activeUploadCategoryId = null;
        });
      }
    }
  }

  /// UPDATED: Implements the requested day-to-code mapping.
  Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      // Part 1: Generate Commands
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final db = await AppDB.instance.database;
      final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
      final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();

      List<String> commands = [];
      final DateFormat formatter = DateFormat('dd/MM/yy');
      final DateTime startDate = DateTime.parse(cat.startDate);
      final DateTime endDate = DateTime.parse(cat.endDate);
      commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');

      final Map<String, List<PeriodModel>> periodsByDay = {};
      for (var p in periods) {
        (periodsByDay[p.day] ??= []).add(p);
      }

      // Correct Day-to-Code Mapping
      String dayToCode(String day) {
        const map = {
          'sunday': 'U',
          'monday': 'M',
          'tuesday': 'T',
          'wednesday': 'W',
          'thursday': 'H',
          'friday': 'F',
          'saturday': 'S',
        };
        return map[day.toLowerCase()] ?? '?';
      }

      for (var entry in periodsByDay.entries) {
        final dayCode = dayToCode(entry.key);
        if (dayCode == '?') continue; // Skip days not in the map

        final timeAndRingtonePairs = entry.value.map((p) {
          final ringtoneName = _getRingtoneName(p.ringtone);
          return '${p.startTime},$ringtoneName';
        }).join('!');
        final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
        commands.add('\$S,$fullPayload#');
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Pop the temporary loading indicator

      // Part 2: Show confirmation dialog
      final bool? shouldSend = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Generated Commands for "${cat.name}"'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                commands.join('\n'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
          ],
        ),
      );

      if (shouldSend != true) return; // User cancelled

      // Part 3: Send commands with progress indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Sending Commands...'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
        ),
      );

      Socket? socket;
      try {
        socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
        for (final command in commands) {
          socket.writeln(command);
          await Future.delayed(const Duration(milliseconds: 50));
        }
        await socket.flush();
      } catch (e) {
        throw Exception("Failed to send commands via TCP: $e");
      } finally {
        socket?.destroy();
      }

      if (mounted) {
        Navigator.of(context).pop(); // Pop progress indicator
        messenger.showSnackBar(
          const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Pop any open dialog
        }
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _navigateAndRefresh() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
    ).then((_) => _loadCategories());
  }

  void _handleCategoryTap(CategoryModel cat) {
    if (cat.configured) {
      _openWeekSchedule(cat);
    } else {
      _openGeneralSchedule(cat);
    }
  }

  void _openGeneralSchedule(CategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
    ).then((_) => _loadCategories());
  }

  void _openWeekSchedule(CategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
    ).then((_) => _loadCategories());
  }

  // void _checkAllConfigured() {
  //   final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
  //   if (allConfigured) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const DashboardPage()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please create and configure at least one category first!'),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          // NEW DIAGNOSTIC BUTTON
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            tooltip: 'Check ESP32 Connection',
            onPressed: _checkEspConnection,
          ),
          // IconButton(
          //   icon: const Icon(Icons.check_circle_outline),
          //   tooltip: 'Finish Configuration',
          //   onPressed: _checkAllConfigured,
          // ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          final categorySequence = index + 1;
          final isUploading = _activeUploadCategoryId == cat.id;
          final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);

          return Card(
            elevation: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
              leading: CircleAvatar(
                backgroundColor: Color(cat.color),
                child: Text(
                  cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  Icon(
                    cat.configured ? Icons.check_circle : Icons.pending,
                    color: cat.configured ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(cat.configured ? "Ready to sync" : "Setup required"),
                ],
              ),
              onTap: () => _handleCategoryTap(cat),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUploading)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.music_note_outlined,
                        color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Upload Audio Files to ESP32',
                      onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
                    ),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    tooltip: 'Send Commands to ESP32',
                    onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  PopupMenuButton<String>(
                    tooltip: "More Options",
                    onSelected: (value) {
                      if (value == 'edit_general') {
                        _openGeneralSchedule(cat);
                      } else if (value == 'delete') {
                        _deleteCategory(cat.id!);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit_general',
                        child: ListTile(
                          leading: Icon(Icons.edit_calendar_outlined),
                          title: Text('Edit General'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndRefresh,
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
        tooltip: 'Add a new category',
      ),
    );
  }
}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
//
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
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     setState(() {
//       categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//       loading = false;
//     });
//   }
//
//   String _getFileName(String path) {
//     if (path.isEmpty) return 'default.mp3';
//     return path.split('/').last.split('\\').last;
//   }
//
//   /// ✅ FIXED: Binary-safe TCP upload
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     final db = await AppDB.instance.database;
//     final periodMaps = await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [category.id],
//     );
//
//     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//     final paths = periods.map((e) => e.ringtone).whereType<String>().toSet();
//
//     if (paths.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No audio files to upload')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const AlertDialog(
//         title: Text('Uploading Audio'),
//         content: CircularProgressIndicator(),
//       ),
//     );
//
//     try {
//       for (final path in paths) {
//         final fileName = _getFileName(path);
//
//         List<int> bytes;
//         try {
//           final data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (_) {
//           bytes = await File(path).readAsBytes();
//         }
//
//         final socket = await Socket.connect(
//           espIp,
//           espPort,
//           timeout: const Duration(seconds: 10),
//         );
//
//         // 1️⃣ Send FILE header
//         socket.add(utf8.encode('\$FILE,$fileName,${bytes.length}#'));
//         await socket.flush();
//
//         // 2️⃣ Wait for READY
//         final ready = await utf8.decoder
//             .bind(socket)
//             .firstWhere((msg) => msg.contains('READY, SEND'));
//
//
//         if (!ready.contains('READY')) {
//           socket.destroy();
//           throw Exception('ESP32 did not accept file');
//         }
//
//         // 3️⃣ Send raw binary (NO DELAYS)
//         socket.add(bytes);
//         await socket.flush();
//
//         // 4️⃣ Wait for SUCCESS
//         final success = await utf8.decoder
//             .bind(socket)
//             .firstWhere((msg) => msg.contains('SUCCESS'));
//
//
//         if (!success.contains('SUCCESS')) {
//           socket.destroy();
//           throw Exception('Upload failed');
//         }
//
//         socket.destroy();
//       }
//
//       if (mounted) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Audio uploaded successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     }
//   }
//
//   /// unchanged command sender (works fine)
//   Future<void> _sendCommands(CategoryModel cat, int seq) async {
//     final db = await AppDB.instance.database;
//     final periods = (await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [cat.id],
//       orderBy: 'startTime',
//     ))
//         .map((e) => PeriodModel.fromMap(e))
//         .toList();
//
//     final formatter = DateFormat('dd/MM/yy');
//     final start = DateTime.parse(cat.startDate);
//     final end = DateTime.parse(cat.endDate);
//
//     List<String> cmds = [
//       '\$C,$seq,${cat.name},${formatter.format(start)},${formatter.format(end)}#'
//     ];
//
//     const map = {
//       'sunday': 'U',
//       'monday': 'M',
//       'tuesday': 'T',
//       'wednesday': 'W',
//       'thursday': 'H',
//       'friday': 'F',
//       'saturday': 'S',
//     };
//
//     final byDay = <String, List<PeriodModel>>{};
//     for (var p in periods) {
//       byDay.putIfAbsent(p.day, () => []).add(p);
//     }
//
//     for (var e in byDay.entries) {
//       final d = map[e.key.toLowerCase()];
//       if (d == null) continue;
//
//       final payload = e.value
//           .map((p) => '${p.startTime},${_getFileName(p.ringtone ?? '')}')
//           .join('!');
//
//       cmds.add('\$S,${('$seq,$d,$payload').length},$seq,$d,$payload#');
//     }
//
//     final socket = await Socket.connect(espIp, espPort);
//     for (final c in cmds) {
//       socket.writeln(c);
//       await Future.delayed(const Duration(milliseconds: 30));
//     }
//     socket.destroy();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Commands sent'), backgroundColor: Colors.green),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Categories')),
//       body: ListView.builder(
//         itemCount: categories.length,
//         itemBuilder: (_, i) {
//           final c = categories[i];
//           return ListTile(
//             title: Text(c.name),
//             leading: CircleAvatar(backgroundColor: Color(c.color)),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.music_note),
//                   onPressed: () => _uploadAudioFiles(c),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () => _sendCommands(c, i + 1),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// import '../../database/app_database.dart';
// import '../../database/dashboard_page.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (!mounted) return;
//     setState(() {
//       categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//       loading = false;
//     });
//   }
//
//   String _getFileName(String? path) {
//     if (path == null || path.trim().isEmpty) return 'default.mp3';
//     return path.split('/').last.split('\\').last;
//   }
//
//   /// ✅ FINAL: Binary-safe TCP upload (ESP32 compatible)
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() => _activeUploadCategoryId = category.id);
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const AlertDialog(
//         title: Text('Uploading Audio Files'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Please wait...')
//           ],
//         ),
//       ),
//     );
//
//     try {
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//
//       final periods = periodMaps.map((e) => PeriodModel.fromMap(e)).toList();
//       final paths = periods.map((e) => e.ringtone).whereType<String>().toSet();
//
//       if (periods.any((p) => p.ringtone == null || p.ringtone!.isEmpty)) {
//         paths.add('assets/default.mp3');
//       }
//
//       for (final path in paths) {
//         final fileName = _getFileName(path);
//
//         List<int> bytes;
//         try {
//           final data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (_) {
//           bytes = await File(path).readAsBytes();
//         }
//
//         final socket = await Socket.connect(
//           espIp,
//           espPort,
//           timeout: const Duration(seconds: 10),
//         );
//
//         // 1️⃣ Send FILE header
//         socket.add(utf8.encode('\$FILE,$fileName,${bytes.length}#'));
//         await socket.flush();
//
//         // 2️⃣ Wait for READY
//         final ready = await utf8.decoder
//             .bind(socket)
//             .firstWhere((msg) => msg.contains('READY, SEND'));
//
//         if (!ready.contains('READY')) {
//           socket.destroy();
//           throw Exception('ESP32 not ready');
//         }
//
//         // 3️⃣ Send raw binary (NO DELAYS)
//         socket.add(bytes);
//         await socket.flush();
//
//         // 4️⃣ Wait for SUCCESS
//         final success = await utf8.decoder
//             .bind(socket)
//             .firstWhere((msg) => msg.contains('SUCCESS'));
//
//         if (!success.contains('SUCCESS')) {
//           socket.destroy();
//           throw Exception('Upload failed');
//         }
//
//         socket.destroy();
//         await Future.delayed(const Duration(milliseconds: 300));
//       }
//
//       if (mounted) Navigator.pop(context);
//       setState(() => _audioUploadedCategories.add(category.id!));
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Audio files uploaded successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _activeUploadCategoryId = null);
//       }
//     }
//   }
//
//   /// ✅ Command sender (unchanged, stable)
//   Future<void> _sendCommands(CategoryModel cat, int seq) async {
//     final db = await AppDB.instance.database;
//     final periods = (await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [cat.id],
//       orderBy: 'startTime',
//     ))
//         .map((e) => PeriodModel.fromMap(e))
//         .toList();
//
//     final formatter = DateFormat('dd/MM/yy');
//     final start = DateTime.parse(cat.startDate);
//     final end = DateTime.parse(cat.endDate);
//
//     List<String> cmds = [
//       '\$C,$seq,${cat.name},${formatter.format(start)},${formatter.format(end)}#'
//     ];
//
//     const map = {
//       'sunday': 'U',
//       'monday': 'M',
//       'tuesday': 'T',
//       'wednesday': 'W',
//       'thursday': 'H',
//       'friday': 'F',
//       'saturday': 'S',
//     };
//
//     final byDay = <String, List<PeriodModel>>{};
//     for (var p in periods) {
//       byDay.putIfAbsent(p.day, () => []).add(p);
//     }
//
//     for (var e in byDay.entries) {
//       final d = map[e.key.toLowerCase()];
//       if (d == null) continue;
//
//       final payload = e.value
//           .map((p) => '${p.startTime},${_getFileName(p.ringtone)}')
//           .join('!');
//
//       cmds.add('\$S,${('$seq,$d,$payload').length},$seq,$d,$payload#');
//     }
//
//     final socket = await Socket.connect(espIp, espPort);
//     for (final c in cmds) {
//       socket.writeln(c);
//       await Future.delayed(const Duration(milliseconds: 40));
//     }
//     socket.destroy();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Commands sent'), backgroundColor: Colors.green),
//     );
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//       );
//     }
//   }
//
//   void _checkAllConfigured() {
//     final ok = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (ok) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please configure at least one category'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, i) {
//           final c = categories[i];
//           final uploading = _activeUploadCategoryId == c.id;
//
//           return Card(
//             child: ListTile(
//               leading: CircleAvatar(backgroundColor: Color(c.color)),
//               title: Text(c.name),
//               subtitle: Text(c.configured ? 'Ready' : 'Setup required'),
//               onTap: () => _handleCategoryTap(c),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   uploading
//                       ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(),
//                   )
//                       : IconButton(
//                     icon: Icon(
//                       Icons.music_note,
//                       color: _audioUploadedCategories.contains(c.id)
//                           ? Colors.green
//                           : null,
//                     ),
//                     onPressed: c.configured
//                         ? () => _uploadAudioFiles(c)
//                         : null,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: c.configured ? () => _sendCommands(c, i + 1) : null,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         icon: const Icon(Icons.add),
//         label: const Text('Add Category'),
//       ),
//     );
//   }
// }
















































//
// import 'dart:async';import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Category deleted successfully'), backgroundColor: Colors.green),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   /// Standalone function to test the ESP32 connection.
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(const SnackBar(content: Text('Checking ESP32 connection...')));
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi and have tapped "Stay Connected". Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 8),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) return "default.mp3";
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//     if (filename.endsWith('.mp3.mp3')) return filename.substring(0, filename.length - 4);
//     return filename;
//   }
//
//   /// Simplified file upload method (sends in one block).
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() => _activeUploadCategoryId = category.id);
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [category.id]);
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       if (uniqueRingtonePaths.isEmpty) {
//         messenger.showSnackBar(const SnackBar(content: Text('No new audio files to upload for this category.')));
//         setState(() => _audioUploadedCategories.add(category.id!));
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Sending ${uniqueRingtonePaths.length} file(s). Please wait."),
//           ]),
//         ),
//       );
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//         final ByteData data = await rootBundle.load(path);
//         final List<int> bytes = data.buffer.asUint8List();
//
//         Socket? socket;
//         try {
//           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
//           final fileHeader = 'SENDFILE|$fileName|${bytes.length}\n';
//           socket.write(fileHeader);
//           socket.add(bytes);
//           await socket.flush();
//           await socket.close();
//         } catch (e) {
//           socket?.destroy();
//           throw Exception("Failed to upload '$fileName': $e");
//         }
//       }
//
//       if (mounted) Navigator.of(context).pop();
//
//       setState(() => _audioUploadedCategories.add(category.id!));
//       messenger.showSnackBar(const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green));
//
//     } catch (e) {
//       if (mounted) Navigator.of(context).pop();
//       messenger.showSnackBar(
//         SnackBar(content: Text('UPLOAD ERROR: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 8)),
//       );
//     } finally {
//       if (mounted) setState(() => _activeUploadCategoryId = null);
//     }
//   }
//
//   /// Shows commands in a dialog before sending.
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     if (!_audioUploadedCategories.contains(cat.id)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please upload the audio files before sending commands.'), backgroundColor: Colors.orange),
//       );
//       return;
//     }
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(DateTime.parse(cat.startDate))},${formatter.format(DateTime.parse(cat.endDate))}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) { (periodsByDay[p.day] ??= []).add(p); }
//
//       String dayToCode(String day) {
//         const map = {'sunday': 'U', 'monday': 'M', 'tuesday': 'T', 'wednesday': 'W', 'thursday': 'H', 'friday': 'F', 'saturday': 'S'};
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue;
//         final timeAndRingtonePairs = entry.value.map((p) => '${p.startTime},${_getRingtoneName(p.ringtone)}').join('!');
//         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${fullPayload.length},$fullPayload#');
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Text(commands.join('\n'), style: const TextStyle(fontFamily: 'monospace')))),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return;
//
//       showDialog(context: context, barrierDismissible: false, builder: (context) => const AlertDialog(title: Text('Sending...'), content: Center(child: CircularProgressIndicator())));
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) Navigator.of(context).pop();
//       messenger.showSnackBar(const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green));
//
//     } catch (e) {
//       if (mounted) Navigator.of(context).pop();
//       messenger.showSnackBar(SnackBar(content: Text('COMMAND ERROR: $e'), backgroundColor: Colors.red));
//     }
//   }
//
//   void _navigateAndRefresh() => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCategoryPage())).then((_) => _loadCategories());
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) => Navigator.push(context, MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!))).then((_) => _loadCategories());
//
//   void _openWeekSchedule(CategoryModel cat) => Navigator.push(context, MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!))).then((_) => _loadCategories());
//
//   void _checkAllConfigured() {
//     if (categories.isNotEmpty && categories.every((c) => c.configured)) {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create and configure at least one category first!'), backgroundColor: Colors.orange));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(icon: const Icon(Icons.wifi_tethering), tooltip: 'Check ESP32 Connection', onPressed: _checkEspConnection),
//           IconButton(icon: const Icon(Icons.check_circle_outline), tooltip: 'Finish Configuration', onPressed: _checkAllConfigured),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? const Center(child: Text('No Categories Found. Add one to start.'))
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(backgroundColor: Color(cat.color), child: Text(cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(children: [
//                 Icon(cat.configured ? Icons.check_circle : Icons.pending, color: cat.configured ? Colors.green : Colors.orange, size: 16),
//                 const SizedBox(width: 4),
//                 Text(cat.configured ? "Ready to sync" : "Setup required"),
//               ]),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()))
//                   else
//                     IconButton(
//                       icon: Icon(Icons.music_note_outlined, color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') _openGeneralSchedule(cat);
//                       if (value == 'delete') _deleteCategory(cat.id!);
//                     },
//                     // THIS IS THE CORRECTED PART
//                     itemBuilder: (context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(leading: Icon(Icons.edit_calendar_outlined), title: Text('Edit General')),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(leading: Icon(Icons.delete_forever_outlined, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red))),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//       ),
//     );
//   }
// }









// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Category deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   /// NEW: Standalone function to test the ESP32 connection.
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(
//       const SnackBar(content: Text('Checking ESP32 connection...')),
//     );
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 7),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
//       return "default.mp3";
//     }
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//     if (filename.endsWith('.mp3.mp3')) {
//       return filename.substring(0, filename.length - 4);
//     }
//     return filename;
//   }
//
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() {
//       _activeUploadCategoryId = category.id;
//     });
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Preparing Audio Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Please wait."),
//           ]),
//         ),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       if (uniqueRingtonePaths.isEmpty) {
//         _audioUploadedCategories.add(category.id!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No audio files to upload for this category.')),
//         );
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Audio Files'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
//           ]),
//         ),
//       );
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//         final ByteData data = await rootBundle.load(path);
//         final List<int> bytes = data.buffer.asUint8List();
//
//         Socket? socket;
//         try {
//           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
//           final fileHeader = 'SENDFILE|$fileName|${bytes.length}\n';
//           socket.write(fileHeader);
//           socket.add(bytes);
//           await socket.flush();
//           await socket.close();
//         } catch (e) {
//           throw Exception("Failed to upload '$fileName': $e");
//         } finally {
//           socket?.destroy();
//         }
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       setState(() {
//         _audioUploadedCategories.add(category.id!);
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _activeUploadCategoryId = null;
//         });
//       }
//     }
//   }
//
//   /// UPDATED: Implements the requested day-to-code mapping.
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       // Part 1: Generate Commands
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       final DateTime startDate = DateTime.parse(cat.startDate);
//       final DateTime endDate = DateTime.parse(cat.endDate);
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) {
//         (periodsByDay[p.day] ??= []).add(p);
//       }
//
//       // Correct Day-to-Code Mapping
//       String dayToCode(String day) {
//         const map = {
//           'sunday': 'U',
//           'monday': 'M',
//           'tuesday': 'T',
//           'wednesday': 'W',
//           'thursday': 'H',
//           'friday': 'F',
//           'saturday': 'S',
//         };
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue; // Skip days not in the map
//
//         final timeAndRingtonePairs = entry.value.map((p) {
//           final ringtoneName = _getRingtoneName(p.ringtone);
//           return '${p.startTime},$ringtoneName';
//         }).join('!');
//         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${fullPayload.length},$fullPayload#');
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop(); // Pop the temporary loading indicator
//
//       // Part 2: Show confirmation dialog
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Text(
//                 commands.join('\n'),
//                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return; // User cancelled
//
//       // Part 3: Send commands with progress indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Sending Commands...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
//         ),
//       );
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands via TCP: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Pop progress indicator
//         messenger.showSnackBar(
//           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) {
//           Navigator.of(context).pop(); // Pop any open dialog
//         }
//         messenger.showSnackBar(
//           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           // NEW DIAGNOSTIC BUTTON
//           IconButton(
//             icon: const Icon(Icons.wifi_tethering),
//             tooltip: 'Check ESP32 Connection',
//             onPressed: _checkEspConnection,
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured ? Icons.check_circle : Icons.pending,
//                     color: cat.configured ? Colors.green : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured ? "Ready to sync" : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
//                     )
//                   else
//                     IconButton(
//                       icon: Icon(
//                         Icons.music_note_outlined,
//                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
//                       ),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') {
//                         _openGeneralSchedule(cat);
//                       } else if (value == 'delete') {
//                         _deleteCategory(cat.id!);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(
//                           leading: Icon(Icons.edit_calendar_outlined),
//                           title: Text('Edit General'),
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
//                           title: Text('Delete', style: TextStyle(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
//       ),
//     );
//   }
// }

















// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// // Make sure these import paths are correct for your project structure
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Category deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(
//       const SnackBar(content: Text('Checking ESP32 connection...')),
//     );
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 7),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
//       return "default.mp3";
//     }
//     // Handles both Windows and Unix-style separators
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//
//     // Fix for potential double extensions like 'audio.mp3.mp3'
//     if (filename.endsWith('.mp3.mp3')) {
//       return filename.substring(0, filename.length - 4);
//     }
//     return filename;
//   }
//
//   /// MERGED & FIXED: Implements binary-safe TCP upload with clear protocol steps
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() {
//       _activeUploadCategoryId = category.id;
//     });
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Preparing Audio Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Please wait."),
//           ]),
//         ),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       // Handle default ringtone if any period uses it
//       if (periods.any((p) => p.ringtone == null || p.ringtone!.trim().isEmpty)) {
//         uniqueRingtonePaths.add('assets/default.mp3'); // Assumed path for the default asset
//       }
//
//       if (mounted) Navigator.of(context).pop(); // Pop "Preparing" dialog
//
//       if (uniqueRingtonePaths.isEmpty) {
//         setState(() {
//           _audioUploadedCategories.add(category.id!);
//         });
//         messenger.showSnackBar(
//           const SnackBar(content: Text('No unique audio files to upload for this category.')),
//         );
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Audio Files'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
//           ]),
//         ),
//       );
//
//       // SOLVED: Create a StreamTransformer that correctly handles Uint8List from the socket.
//       final utf8Transformer = StreamTransformer<Uint8List, String>.fromBind(utf8.decoder.bind);
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//
//         // Load bytes: try from assets first, then from the local file system
//         List<int> bytes;
//         try {
//           final ByteData data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (_) {
//           try {
//             final file = File(path);
//             if (!await file.exists()){
//               throw Exception("File not found at path: $path");
//             }
//             bytes = await file.readAsBytes();
//           } catch(e) {
//             throw Exception("Failed to load '$fileName': $e");
//           }
//         }
//
//         Socket? socket;
//         try {
//           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 10));
//
//           // 1. Send FILE header
//           final fileHeader = '\$FILE,$fileName,${bytes.length}#';
//           socket.add(utf8.encode(fileHeader));
//           await socket.flush();
//
//           // 2. Wait for READY confirmation from ESP32
//           // CORRECTED: Use the transformer here
//           final readyResponse = await socket.transform(utf8Transformer).firstWhere(
//                 (msg) => msg.contains('READY, SEND'),
//             orElse: () => throw Exception('ESP32 did not send READY signal'),
//           ).timeout(const Duration(seconds: 10), onTimeout: () => throw Exception('Timeout waiting for READY signal'));
//
//           if (!readyResponse.contains('READY, SEND')) {
//             throw Exception('ESP32 did not accept file. Response: $readyResponse');
//           }
//
//           // 3. Send raw binary data
//           socket.add(bytes);
//           await socket.flush();
//
//           // 4. Wait for SUCCESS confirmation from ESP32
//           // CORRECTED: Use the transformer here as well
//           final successResponse = await socket.transform(utf8Transformer).firstWhere(
//                 (msg) => msg.contains('SUCCESS'),
//             orElse: () => throw Exception('Upload failed: No SUCCESS signal received'),
//           ).timeout(const Duration(seconds: 30), onTimeout: () => throw Exception('Timeout waiting for SUCCESS signal'));
//
//           if (!successResponse.contains('SUCCESS')) {
//             throw Exception('Upload failed. Response: $successResponse');
//           }
//
//         } catch (e) {
//           throw Exception("Failed to upload '$fileName': $e");
//         } finally {
//           socket?.destroy();
//           await Future.delayed(const Duration(milliseconds: 500)); // Brief delay between files
//         }
//       }
//
//       if (mounted) Navigator.of(context).pop(); // Pop "Uploading" dialog
//
//       setState(() {
//         _audioUploadedCategories.add(category.id!);
//       });
//
//       messenger.showSnackBar(
//         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         messenger.showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _activeUploadCategoryId = null;
//         });
//       }
//     }
//   }
//
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       final DateTime startDate = DateTime.parse(cat.startDate);
//       final DateTime endDate = DateTime.parse(cat.endDate);
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) {
//         (periodsByDay[p.day] ??= []).add(p);
//       }
//
//       String dayToCode(String day) {
//         const map = {
//           'sunday': 'U', 'monday': 'M', 'tuesday': 'T', 'wednesday': 'W',
//           'thursday': 'H', 'friday': 'F', 'saturday': 'S',
//         };
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue;
//
//         final timeAndRingtonePairs = entry.value.map((p) {
//           final ringtoneName = _getRingtoneName(p.ringtone);
//           return '${p.startTime},$ringtoneName';
//         }).join('!');
//
//         final payload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${payload.length},$payload#');
//       }
//
//       if (mounted) Navigator.of(context).pop();
//
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Text(
//                 commands.join('\n'),
//                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return;
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Sending Commands...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
//         ),
//       );
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands via TCP: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop();
//         messenger.showSnackBar(
//           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         messenger.showSnackBar(
//           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.wifi_tethering),
//             tooltip: 'Check ESP32 Connection',
//             onPressed: _checkEspConnection,
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured ? Icons.check_circle : Icons.pending,
//                     color: cat.configured ? Colors.green : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured ? "Ready to sync" : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
//                     )
//                   else
//                     IconButton(
//                       icon: Icon(
//                         Icons.music_note_outlined,
//                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
//                       ),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') {
//                         _openGeneralSchedule(cat);
//                       } else if (value == 'delete') {
//                         _deleteCategory(cat.id!);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(
//                           leading: Icon(Icons.edit_calendar_outlined),
//                           title: Text('Edit General'),
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
//                           title: Text('Delete', style: TextStyle(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
//       ),
//     );
//   }
// }




























// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     setState(() {
//       categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//       loading = false;
//     });
//   }
//
//   String _getFileName(String path) {
//     if (path.isEmpty) return 'default.mp3';
//     return path.split('/').last.split('\\').last;
//   }
//
//   /// ✅ FIXED: Binary-safe TCP upload
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     final db = await AppDB.instance.database;
//     final periodMaps = await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [category.id],
//     );
//
//     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//     final paths = periods.map((e) => e.ringtone).whereType<String>().toSet();
//
//     if (paths.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No audio files to upload')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const AlertDialog(
//         title: Text('Uploading Audio'),
//         content: CircularProgressIndicator(),
//       ),
//     );
//
//     try {
//       for (final path in paths) {
//         final fileName = _getFileName(path);
//
//         List<int> bytes;
//         try {
//           final data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (_) {
//           bytes = await File(path).readAsBytes();
//         }
//
//         final socket = await Socket.connect(
//           espIp,
//           espPort,
//           timeout: const Duration(seconds: 10),
//         );
//
//         // 1️⃣ Send FILE header
//         socket.add(utf8.encode('\$FILE,$fileName,${bytes.length}#'));
//         await socket.flush();
//
//         // 2️⃣ Wait for READY
//         final ready = await utf8.decoder
//             .bind(socket)
//             .firstWhere((msg) => msg.contains('READY, SEND'));
//
//
//         if (!ready.contains('READY')) {
//           socket.destroy();
//           throw Exception('ESP32 did not accept file');
//         }
//
//         // 3️⃣ Send raw binary (NO DELAYS)
//         socket.add(bytes);
//         await socket.flush();
//
//         // 4️⃣ Wait for SUCCESS
//         final success = await utf8.decoder
//             .bind(socket)
//             .firstWhere((msg) => msg.contains('SUCCESS'));
//
//
//         if (!success.contains('SUCCESS')) {
//           socket.destroy();
//           throw Exception('Upload failed');
//         }
//
//         socket.destroy();
//       }
//
//       if (mounted) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Audio uploaded successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     }
//   }
//
//   /// unchanged command sender (works fine)
//   Future<void> _sendCommands(CategoryModel cat, int seq) async {
//     final db = await AppDB.instance.database;
//     final periods = (await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [cat.id],
//       orderBy: 'startTime',
//     ))
//         .map((e) => PeriodModel.fromMap(e))
//         .toList();
//
//     final formatter = DateFormat('dd/MM/yy');
//     final start = DateTime.parse(cat.startDate);
//     final end = DateTime.parse(cat.endDate);
//
//     List<String> cmds = [
//       '\$C,$seq,${cat.name},${formatter.format(start)},${formatter.format(end)}#'
//     ];
//
//     const map = {
//       'sunday': 'U',
//       'monday': 'M',
//       'tuesday': 'T',
//       'wednesday': 'W',
//       'thursday': 'H',
//       'friday': 'F',
//       'saturday': 'S',
//     };
//
//     final byDay = <String, List<PeriodModel>>{};
//     for (var p in periods) {
//       byDay.putIfAbsent(p.day, () => []).add(p);
//     }
//
//     for (var e in byDay.entries) {
//       final d = map[e.key.toLowerCase()];
//       if (d == null) continue;
//
//       final payload = e.value
//           .map((p) => '${p.startTime},${_getFileName(p.ringtone ?? '')}')
//           .join('!');
//
//       cmds.add('\$S,${('$seq,$d,$payload').length},$seq,$d,$payload#');
//     }
//
//     final socket = await Socket.connect(espIp, espPort);
//     for (final c in cmds) {
//       socket.writeln(c);
//       await Future.delayed(const Duration(milliseconds: 30));
//     }
//     socket.destroy();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Commands sent'), backgroundColor: Colors.green),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Categories')),
//       body: ListView.builder(
//         itemCount: categories.length,
//         itemBuilder: (_, i) {
//           final c = categories[i];
//           return ListTile(
//             title: Text(c.name),
//             leading: CircleAvatar(backgroundColor: Color(c.color)),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.music_note),
//                   onPressed: () => _uploadAudioFiles(c),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () => _sendCommands(c, i + 1),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



















// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Category deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   /// NEW: Standalone function to test the ESP32 connection.
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(
//       const SnackBar(content: Text('Checking ESP32 connection...')),
//     );
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 7),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
//       return "default.mp3";
//     }
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//     if (filename.endsWith('.mp3.mp3')) {
//       return filename.substring(0, filename.length - 4);
//     }
//     return filename;
//   }
//
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() {
//       _activeUploadCategoryId = category.id;
//     });
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Preparing Audio Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Please wait."),
//           ]),
//         ),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       // Handle default ringtone if any period uses it
//       if (periods.any((p) => p.ringtone == null || p.ringtone?.trim().isEmpty == true)) {
//         uniqueRingtonePaths.add('assets/default.mp3'); // Adjust this path to your actual default asset path
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       if (uniqueRingtonePaths.isEmpty) {
//         _audioUploadedCategories.add(category.id!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No audio files to upload for this category.')),
//         );
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Audio Files'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
//           ]),
//         ),
//       );
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//
//         // Load bytes: try asset first, then file system
//         List<int> bytes;
//         try {
//           final ByteData data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (e) {
//           final File audioFile = File(path);
//           if (!await audioFile.exists()) {
//             throw Exception('Audio file not found at $path');
//           }
//           bytes = await audioFile.readAsBytes();
//         }
//
//         final fileSize = bytes.length;
//
//         Socket? socket;
//         StreamSubscription<List<int>>? listener;
//         try {
//           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 30));
//
//           Completer<String> headerCompleter = Completer<String>();
//           Completer<String> successCompleter = Completer<String>();
//           StringBuffer responseBuffer = StringBuffer();
//
//           listener = socket.listen(
//                 (List<int> data) {
//               final String decoded = utf8.decode(data);
//               responseBuffer.write(decoded);
//               final String response = responseBuffer.toString();
//
//               if (!headerCompleter.isCompleted && response.contains('READY, SEND')) {
//                 headerCompleter.complete(response.trim());
//                 responseBuffer.clear(); // Clear for next response
//               } else if (!successCompleter.isCompleted && response.contains('SUCCESS:')) {
//                 successCompleter.complete(response.trim());
//               }
//             },
//             onError: (error) {
//               if (!headerCompleter.isCompleted) headerCompleter.completeError(error);
//               if (!successCompleter.isCompleted) successCompleter.completeError(error);
//             },
//             onDone: () {
//               if (!headerCompleter.isCompleted) headerCompleter.completeError(Exception('Socket closed unexpectedly'));
//               if (!successCompleter.isCompleted) successCompleter.completeError(Exception('Socket closed unexpectedly'));
//             },
//           );
//
//           // Send file command
//           final command = '\$FILE,$fileName,$fileSize#';
//           socket.write(command);
//           await socket.flush();
//
//           // Wait for header response
//           final String headerResponse = await headerCompleter.future.timeout(const Duration(seconds: 10));
//           final expectedHeader = 'OK: /$fileName READY, SEND $fileSize BYTES';
//           if (!headerResponse.contains(expectedHeader)) {
//             throw Exception('Unexpected header response: $headerResponse');
//           }
//
//           // Send binary data in chunks
//           const int chunkSize = 512;
//           for (int i = 0; i < bytes.length; i += chunkSize) {
//             int end = i + chunkSize;
//             if (end > bytes.length) end = bytes.length;
//             socket.add(bytes.sublist(i, end));
//             await socket.flush();
//             await Future.delayed(const Duration(milliseconds: 100));
//           }
//
//           // Wait for success response
//           final String successResponse = await successCompleter.future.timeout(const Duration(seconds: 30));
//           final expectedSuccess = 'SUCCESS: $fileSize bytes saved as /$fileName';
//           if (!successResponse.contains(expectedSuccess)) {
//             throw Exception('Unexpected success response: $successResponse');
//           }
//
//           await listener.cancel();
//           await socket.close();
//         } catch (e) {
//           throw Exception("Failed to upload '$fileName': $e");
//         } finally {
//           listener?.cancel();
//           socket?.destroy();
//         }
//
//         // Delay between files
//         await Future.delayed(const Duration(seconds: 2));
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       setState(() {
//         _audioUploadedCategories.add(category.id!);
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _activeUploadCategoryId = null;
//         });
//       }
//     }
//   }
//
//   /// UPDATED: Implements the requested day-to-code mapping.
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       // Part 1: Generate Commands
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       final DateTime startDate = DateTime.parse(cat.startDate);
//       final DateTime endDate = DateTime.parse(cat.endDate);
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) {
//         (periodsByDay[p.day] ??= []).add(p);
//       }
//
//       // Correct Day-to-Code Mapping
//       String dayToCode(String day) {
//         const map = {
//           'sunday': 'U',
//           'monday': 'M',
//           'tuesday': 'T',
//           'wednesday': 'W',
//           'thursday': 'H',
//           'friday': 'F',
//           'saturday': 'S',
//         };
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue; // Skip days not in the map
//
//         final timeAndRingtonePairs = entry.value.map((p) {
//           final ringtoneName = _getRingtoneName(p.ringtone);
//           return '${p.startTime},$ringtoneName';
//         }).join('!');
//         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${fullPayload.length},$fullPayload#');
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop(); // Pop the temporary loading indicator
//
//       // Part 2: Show confirmation dialog
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Text(
//                 commands.join('\n'),
//                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return; // User cancelled
//
//       // Part 3: Send commands with progress indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Sending Commands...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
//         ),
//       );
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands via TCP: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Pop progress indicator
//         messenger.showSnackBar(
//           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) {
//           Navigator.of(context).pop(); // Pop any open dialog
//         }
//         messenger.showSnackBar(
//           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           // NEW DIAGNOSTIC BUTTON
//           IconButton(
//             icon: const Icon(Icons.wifi_tethering),
//             tooltip: 'Check ESP32 Connection',
//             onPressed: _checkEspConnection,
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured ? Icons.check_circle : Icons.pending,
//                     color: cat.configured ? Colors.green : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured ? "Ready to sync" : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
//                     )
//                   else
//                     IconButton(
//                       icon: Icon(
//                         Icons.music_note_outlined,
//                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
//                       ),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') {
//                         _openGeneralSchedule(cat);
//                       } else if (value == 'delete') {
//                         _deleteCategory(cat.id!);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(
//                           leading: Icon(Icons.edit_calendar_outlined),
//                           title: Text('Edit General'),
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
//                           title: Text('Delete', style: TextStyle(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
//       ),
//     );
//   }
// }










// import 'dart:async';
// import 'dart:convert';
// import 'dart:io'; // Required for raw TCP Socket communication
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:newsyncrotime/database/dashboard_page.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   // ESP32 Connection Details
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (mounted) {
//       setState(() {
//         categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//         loading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text(
//           'Are you sure you want to delete this category and all associated data?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldDelete == true) {
//       final db = await AppDB.instance.database;
//       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Category deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//       _loadCategories();
//     }
//   }
//
//   /// NEW: Standalone function to test the ESP32 connection.
//   Future<void> _checkEspConnection() async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.hideCurrentSnackBar();
//     messenger.showSnackBar(
//       const SnackBar(content: Text('Checking ESP32 connection...')),
//     );
//
//     Socket? socket;
//     try {
//       socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         const SnackBar(content: Text('ESP32 Connection Successful!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       messenger.hideCurrentSnackBar();
//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Connection Failed. Ensure you are on the ESP32 Wi-Fi network. Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 7),
//         ),
//       );
//     } finally {
//       socket?.destroy();
//     }
//   }
//
//   String _getRingtoneName(String? ringtonePath) {
//     if (ringtonePath == null || ringtonePath.trim().isEmpty) {
//       return "default.mp3";
//     }
//     final filename = ringtonePath.split(r'\').last.split('/').last;
//     if (filename.endsWith('.mp3.mp3')) {
//       return filename.substring(0, filename.length - 4);
//     }
//     return filename;
//   }
//
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//
//     setState(() {
//       _activeUploadCategoryId = category.id;
//     });
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Preparing Audio Files...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Please wait."),
//           ]),
//         ),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//       final uniqueRingtonePaths = periods.map((p) => p.ringtone).whereType<String>().toSet();
//
//       // Handle default ringtone if any period uses it
//       if (periods.any((p) => p.ringtone == null || p.ringtone?.trim().isEmpty == true)) {
//         uniqueRingtonePaths.add('assets/default.mp3'); // Adjust this path to your actual default asset path
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       if (uniqueRingtonePaths.isEmpty) {
//         _audioUploadedCategories.add(category.id!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No audio files to upload for this category.')),
//         );
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Uploading Audio Files'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text("Uploading ${uniqueRingtonePaths.length} file(s)..."),
//           ]),
//         ),
//       );
//
//       for (final path in uniqueRingtonePaths) {
//         final fileName = _getRingtoneName(path);
//
//         // Load bytes: try asset first, then file system
//         List<int> bytes;
//         try {
//           final ByteData data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (e) {
//           final File audioFile = File(path);
//           if (!await audioFile.exists()) {
//             throw Exception('Audio file not found at $path');
//           }
//           bytes = await audioFile.readAsBytes();
//         }
//
//         final fileSize = bytes.length;
//
//         Socket? socket;
//         StreamSubscription<List<int>>? listener;
//         try {
//           socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 30));
//
//           Completer<String> headerCompleter = Completer<String>();
//           Completer<String> successCompleter = Completer<String>();
//           StringBuffer responseBuffer = StringBuffer();
//
//           listener = socket.listen(
//                 (List<int> data) {
//               final String decoded = utf8.decode(data);
//               responseBuffer.write(decoded);
//               final String response = responseBuffer.toString();
//
//               if (!headerCompleter.isCompleted && response.contains('READY, SEND')) {
//                 headerCompleter.complete(response.trim());
//                 responseBuffer.clear(); // Clear for next response
//               } else if (!successCompleter.isCompleted && response.contains('SUCCESS:')) {
//                 successCompleter.complete(response.trim());
//               }
//             },
//             onError: (error) {
//               if (!headerCompleter.isCompleted) headerCompleter.completeError(error);
//               if (!successCompleter.isCompleted) successCompleter.completeError(error);
//             },
//             onDone: () {
//               if (!headerCompleter.isCompleted) headerCompleter.completeError(Exception('Socket closed unexpectedly'));
//               if (!successCompleter.isCompleted) successCompleter.completeError(Exception('Socket closed unexpectedly'));
//             },
//           );
//
//           // Send file command
//           final command = '\$FILE,$fileName,$fileSize#';
//           socket.write(command);
//           await socket.flush();
//
//           // Wait for header response
//           final String headerResponse = await headerCompleter.future.timeout(const Duration(seconds: 10));
//           final expectedHeader = 'OK: /$fileName READY, SEND $fileSize BYTES';
//           if (!headerResponse.contains(expectedHeader)) {
//             throw Exception('Unexpected header response: $headerResponse');
//           }
//
//           // Send binary data in chunks
//           const int chunkSize = 512;
//           for (int i = 0; i < bytes.length; i += chunkSize) {
//             int end = i + chunkSize;
//             if (end > bytes.length) end = bytes.length;
//             socket.add(bytes.sublist(i, end));
//             await socket.flush();
//             await Future.delayed(const Duration(milliseconds: 100));
//           }
//
//           // Wait for success response
//           final String successResponse = await successCompleter.future.timeout(const Duration(seconds: 30));
//           final expectedSuccess = 'SUCCESS: $fileSize bytes saved as /$fileName';
//           if (!successResponse.contains(expectedSuccess)) {
//             throw Exception('Unexpected success response: $successResponse');
//           }
//
//           await listener.cancel();
//           await socket.close();
//         } catch (e) {
//           throw Exception("Failed to upload '$fileName': $e");
//         } finally {
//           listener?.cancel();
//           socket?.destroy();
//         }
//
//         // Delay between files
//         await Future.delayed(const Duration(seconds: 2));
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop();
//
//       setState(() {
//         _audioUploadedCategories.add(category.id!);
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio files uploaded successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _activeUploadCategoryId = null;
//         });
//       }
//     }
//   }
//
//   /// UPDATED: Implements the requested day-to-code mapping.
//   Future<void> _sendCommands(CategoryModel cat, int categorySequence) async {
//     if (!mounted) return;
//
//     final messenger = ScaffoldMessenger.of(context);
//
//     try {
//       // Part 1: Generate Commands
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query('periods', where: 'categoryId = ?', whereArgs: [cat.id], orderBy: 'startTime');
//       final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//       List<String> commands = [];
//       final DateFormat formatter = DateFormat('dd/MM/yy');
//       final DateTime startDate = DateTime.parse(cat.startDate);
//       final DateTime endDate = DateTime.parse(cat.endDate);
//       commands.add('\$C,$categorySequence,${cat.name},${formatter.format(startDate)},${formatter.format(endDate)}#');
//
//       final Map<String, List<PeriodModel>> periodsByDay = {};
//       for (var p in periods) {
//         (periodsByDay[p.day] ??= []).add(p);
//       }
//
//       // Correct Day-to-Code Mapping
//       String dayToCode(String day) {
//         const map = {
//           'sunday': 'U',
//           'monday': 'M',
//           'tuesday': 'T',
//           'wednesday': 'W',
//           'thursday': 'H',
//           'friday': 'F',
//           'saturday': 'S',
//         };
//         return map[day.toLowerCase()] ?? '?';
//       }
//
//       for (var entry in periodsByDay.entries) {
//         final dayCode = dayToCode(entry.key);
//         if (dayCode == '?') continue; // Skip days not in the map
//
//         final timeAndRingtonePairs = entry.value.map((p) {
//           final ringtoneName = _getRingtoneName(p.ringtone);
//           return '${p.startTime},$ringtoneName';
//         }).join('!');
//         final fullPayload = '$categorySequence,$dayCode,$timeAndRingtonePairs';
//         commands.add('\$S,${fullPayload.length},$fullPayload#');
//       }
//
//       if (!mounted) return;
//       Navigator.of(context).pop(); // Pop the temporary loading indicator
//
//       // Part 2: Show confirmation dialog
//       final bool? shouldSend = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Generated Commands for "${cat.name}"'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Text(
//                 commands.join('\n'),
//                 style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//             TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Send')),
//           ],
//         ),
//       );
//
//       if (shouldSend != true) return; // User cancelled
//
//       // Part 3: Send commands with progress indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           title: Text('Sending Commands...'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Please wait.")]),
//         ),
//       );
//
//       Socket? socket;
//       try {
//         socket = await Socket.connect(espIp, espPort, timeout: const Duration(seconds: 5));
//         for (final command in commands) {
//           socket.writeln(command);
//           await Future.delayed(const Duration(milliseconds: 50));
//         }
//         await socket.flush();
//       } catch (e) {
//         throw Exception("Failed to send commands via TCP: $e");
//       } finally {
//         socket?.destroy();
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Pop progress indicator
//         messenger.showSnackBar(
//           const SnackBar(content: Text('Commands sent successfully!'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (Navigator.canPop(context)) {
//           Navigator.of(context).pop(); // Pop any open dialog
//         }
//         messenger.showSnackBar(
//           SnackBar(content: Text('Failed to send commands: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     if (cat.configured) {
//       _openWeekSchedule(cat);
//     } else {
//       _openGeneralSchedule(cat);
//     }
//   }
//
//   void _openGeneralSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _openWeekSchedule(CategoryModel cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
//     ).then((_) => _loadCategories());
//   }
//
//   void _checkAllConfigured() {
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           // NEW DIAGNOSTIC BUTTON
//           IconButton(
//             icon: const Icon(Icons.wifi_tethering),
//             tooltip: 'Check ESP32 Connection',
//             onPressed: _checkEspConnection,
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : categories.isEmpty
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final categorySequence = index + 1;
//           final isUploading = _activeUploadCategoryId == cat.id;
//           final hasUploadedAudio = _audioUploadedCategories.contains(cat.id);
//
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured ? Icons.check_circle : Icons.pending,
//                     color: cat.configured ? Colors.green : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured ? "Ready to sync" : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
//                     )
//                   else
//                     IconButton(
//                       icon: Icon(
//                         Icons.music_note_outlined,
//                         color: hasUploadedAudio ? Colors.green : Theme.of(context).colorScheme.primary,
//                       ),
//                       tooltip: 'Upload Audio Files to ESP32',
//                       onPressed: cat.configured ? () => _uploadAudioFiles(cat) : null,
//                     ),
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Send Commands to ESP32',
//                     onPressed: cat.configured ? () => _sendCommands(cat, categorySequence) : null,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   PopupMenuButton<String>(
//                     tooltip: "More Options",
//                     onSelected: (value) {
//                       if (value == 'edit_general') {
//                         _openGeneralSchedule(cat);
//                       } else if (value == 'delete') {
//                         _deleteCategory(cat.id!);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       const PopupMenuItem<String>(
//                         value: 'edit_general',
//                         child: ListTile(
//                           leading: Icon(Icons.edit_calendar_outlined),
//                           title: Text('Edit General'),
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       const PopupMenuItem<String>(
//                         value: 'delete',
//                         child: ListTile(
//                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
//                           title: Text('Delete', style: TextStyle(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add Category'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
//       ),
//     );
//   }
// }







// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../../models/period_model.dart';
// import '../dashboard/dashboard_page.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import 'create_category_page.dart';
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
//   final Set<int> _audioUploadedCategories = {};
//   int? _activeUploadCategoryId;
//
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     final res = await db.query('categories', orderBy: 'name');
//     if (!mounted) return;
//     setState(() {
//       categories = res.map((e) => CategoryModel.fromMap(e)).toList();
//       loading = false;
//     });
//   }
//
//   String _getRingtoneName(String? path) {
//     if (path == null || path.trim().isEmpty) return 'default.mp3';
//     return path.split('/').last.split('\\').last;
//   }
//
//   /// ✅ FINAL, FIXED, BINARY-SAFE AUDIO UPLOAD
//   Future<void> _uploadAudioFiles(CategoryModel category) async {
//     if (!mounted) return;
//     setState(() => _activeUploadCategoryId = category.id);
//
//     try {
//       final db = await AppDB.instance.database;
//       final periodMaps = await db.query(
//         'periods',
//         where: 'categoryId = ?',
//         whereArgs: [category.id],
//       );
//
//       final periods = periodMaps.map((e) => PeriodModel.fromMap(e)).toList();
//       final paths = periods.map((e) => e.ringtone).whereType<String>().toSet();
//
//       if (paths.isEmpty) {
//         _audioUploadedCategories.add(category.id!);
//         return;
//       }
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const AlertDialog(
//           title: Text('Uploading Audio Files'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 12),
//               Text('Please wait…'),
//             ],
//           ),
//         ),
//       );
//
//       for (final path in paths) {
//         final fileName = _getRingtoneName(path);
//
//         List<int> bytes;
//         try {
//           final data = await rootBundle.load(path);
//           bytes = data.buffer.asUint8List();
//         } catch (_) {
//           bytes = await File(path).readAsBytes();
//         }
//
//         final socket = await Socket.connect(
//           espIp,
//           espPort,
//           timeout: const Duration(seconds: 15),
//         );
//
//         final ready = Completer<void>();
//         final success = Completer<void>();
//         final buffer = StringBuffer();
//
//         late StreamSubscription sub;
//         sub = socket.listen(
//               (Uint8List data) {
//             final text = utf8.decode(data, allowMalformed: true);
//             buffer.write(text);
//             final msg = buffer.toString();
//
//             if (!ready.isCompleted && msg.contains('READY')) {
//               ready.complete();
//               buffer.clear();
//             }
//
//             if (!success.isCompleted && msg.contains('SUCCESS')) {
//               success.complete();
//             }
//           },
//           onError: (e) {
//             if (!ready.isCompleted) ready.completeError(e);
//             if (!success.isCompleted) success.completeError(e);
//           },
//         );
//
//         // 1️⃣ Send header
//         socket.add(utf8.encode('\$FILE,$fileName,${bytes.length}#'));
//         await socket.flush();
//
//         // 2️⃣ Wait READY
//         await ready.future.timeout(const Duration(seconds: 10));
//
//         // 3️⃣ Send raw binary
//         socket.add(bytes);
//         await socket.flush();
//
//         // 4️⃣ Wait SUCCESS
//         await success.future.timeout(const Duration(seconds: 20));
//
//         await sub.cancel();
//         socket.destroy();
//         await Future.delayed(const Duration(seconds: 1));
//       }
//
//       if (mounted) Navigator.pop(context);
//       setState(() => _audioUploadedCategories.add(category.id!));
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Audio uploaded successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => _activeUploadCategoryId = null);
//     }
//   }
//
//   /// ✅ COMMAND SENDER (UNCHANGED & WORKING)
//   Future<void> _sendCommands(CategoryModel cat, int seq) async {
//     final db = await AppDB.instance.database;
//     final periods = (await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [cat.id],
//       orderBy: 'startTime',
//     ))
//         .map((e) => PeriodModel.fromMap(e))
//         .toList();
//
//     final formatter = DateFormat('dd/MM/yy');
//     final start = DateTime.parse(cat.startDate);
//     final end = DateTime.parse(cat.endDate);
//
//     List<String> cmds = [
//       '\$C,$seq,${cat.name},${formatter.format(start)},${formatter.format(end)}#'
//     ];
//
//     const map = {
//       'sunday': 'U',
//       'monday': 'M',
//       'tuesday': 'T',
//       'wednesday': 'W',
//       'thursday': 'H',
//       'friday': 'F',
//       'saturday': 'S',
//     };
//
//     final byDay = <String, List<PeriodModel>>{};
//     for (var p in periods) {
//       byDay.putIfAbsent(p.day, () => []).add(p);
//     }
//
//     for (var e in byDay.entries) {
//       final d = map[e.key.toLowerCase()];
//       if (d == null) continue;
//
//       final payload = e.value
//           .map((p) => '${p.startTime},${_getRingtoneName(p.ringtone)}')
//           .join('!');
//
//       cmds.add('\$S,${('$seq,$d,$payload').length},$seq,$d,$payload#');
//     }
//
//     final socket = await Socket.connect(espIp, espPort);
//     for (final c in cmds) {
//       socket.writeln(c);
//       await Future.delayed(const Duration(milliseconds: 30));
//     }
//     socket.destroy();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Commands sent'), backgroundColor: Colors.green),
//     );
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
//     ).then((_) => _loadCategories());
//   }
//
//   void _handleTap(CategoryModel c) {
//     if (c.configured) {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: c.id!)))
//           .then((_) => _loadCategories());
//     } else {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: c.id!)))
//           .then((_) => _loadCategories());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Categories')),
//       body: ListView.builder(
//         itemCount: categories.length,
//         itemBuilder: (_, i) {
//           final c = categories[i];
//           final uploading = _activeUploadCategoryId == c.id;
//           final uploaded = _audioUploadedCategories.contains(c.id);
//
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               leading: CircleAvatar(backgroundColor: Color(c.color)),
//               title: Text(c.name),
//               subtitle: Text(c.configured ? 'Ready' : 'Setup required'),
//               onTap: () => _handleTap(c),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   uploading
//                       ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(),
//                   )
//                       : IconButton(
//                     icon: Icon(
//                       Icons.music_note,
//                       color: uploaded ? Colors.green : null,
//                     ),
//                     onPressed:
//                     c.configured ? () => _uploadAudioFiles(c) : null,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: c.configured
//                         ? () => _sendCommands(c, i + 1)
//                         : null,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         icon: const Icon(Icons.add),
//         label: const Text('Add Category'),
//       ),
//     );
//   }
// }
