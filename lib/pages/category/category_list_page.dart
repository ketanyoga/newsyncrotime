// // // // import 'package:flutter/material.dart';
// // // // import '../../database/app_database.dart';
// // // // import '../../models/category_model.dart';
// // // // import '../general/general_schedule_page.dart';
// // // // import '../week/week_schedule_page.dart';
// // // // import '../dashboard/dashboard_page.dart';
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
// // // //     final db = await AppDB.instance.database;
// // // //     final res = await db.query('categories');
// // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // //     setState(() => loading = false);
// // // //   }
// // // //
// // // //   Future<void> _deleteCategory(int id) async {
// // // //     final db = await AppDB.instance.database;
// // // //     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // //     _loadCategories();
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
// // // //       MaterialPageRoute(
// // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // //       ),
// // // //     ).then((_) => _loadCategories());
// // // //   }
// // // //
// // // //   void _checkAllConfigured() {
// // // //     if (categories.every((c) => c.configured == 1)) {
// // // //       Navigator.pushReplacement(
// // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // //     } else {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Configure all categories first!')),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('Categories'),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.check),
// // // //             onPressed: _checkAllConfigured,
// // // //           )
// // // //         ],
// // // //       ),
// // // //       body: ListView.builder(
// // // //         itemCount: categories.length,
// // // //         itemBuilder: (_, index) {
// // // //           final cat = categories[index];
// // // //           return Card(
// // // //             child: ListTile(
// // // //               title: Text(cat.name),
// // // //               subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
// // // //               leading: CircleAvatar(backgroundColor: Color(cat.color)),
// // // //               trailing: Row(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
// // // //                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
// // // //                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // import 'package:flutter/material.dart';
// // // // import '../../database/app_database.dart';
// // // // import '../../models/category_model.dart';
// // // // import '../general/general_schedule_page.dart';
// // // // import '../week/week_schedule_page.dart';
// // // // import '../dashboard/dashboard_page.dart';
// // // // import 'dart:math'; // Import for random color generation
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
// // // //     final db = await AppDB.instance.database;
// // // //     final res = await db.query('categories');
// // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // //     setState(() => loading = false);
// // // //   }
// // // //
// // // //   Future<void> _deleteCategory(int id) async {
// // // //     final db = await AppDB.instance.database;
// // // //     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // //     _loadCategories();
// // // //   }
// // // //
// // // //   // Future<void> _addCategory(String name) async {
// // // //   //   final db = await AppDB.instance.database;
// // // //   //   final newCategory = CategoryModel(
// // // //   //     name: name,
// // // //   //     color: (Random().nextDouble() * 0xFFFFFF).toInt(),
// // // //   //     configured: 0,
// // // //   //   );
// // // //   //   await db.insert('categories', newCategory.toMap());
// // // //   //   _loadCategories();
// // // //   // }
// // // //
// // // //   Future<void> _addCategory(String name) async {
// // // //     final db = await AppDB.instance.database;
// // // //     final now = DateTime.now();final newCategory = CategoryModel(
// // // //       name: name,
// // // //       color: (Random().nextDouble() * 0xFFFFFF).toInt() | 0xFF000000, // Ensure full opacity
// // // //       configured: false, // Use boolean false
// // // //       startDate: now.toIso8601String(), // Convert DateTime to String
// // // //       endDate: now.add(const Duration(days: 7)).toIso8601String(), // Convert DateTime to String
// // // //     );
// // // //     await db.insert('categories', newCategory.toMap());
// // // //     _loadCategories();
// // // //   }
// // // //
// // // //
// // // //
// // // //   void _showAddCategoryDialog() {
// // // //     final TextEditingController nameController = TextEditingController();
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) {
// // // //         return AlertDialog(
// // // //           title: const Text('Add Category'),
// // // //           content: TextField(
// // // //             controller: nameController,
// // // //             decoration: const InputDecoration(hintText: "Category Name"),
// // // //           ),
// // // //           actions: [
// // // //             TextButton(
// // // //               child: const Text('Cancel'),
// // // //               onPressed: () => Navigator.of(context).pop(),
// // // //             ),
// // // //             TextButton(
// // // //               child: const Text('Add'),
// // // //               onPressed: () {
// // // //                 if (nameController.text.isNotEmpty) {
// // // //                   _addCategory(nameController.text);
// // // //                   Navigator.of(context).pop();
// // // //                 }
// // // //               },
// // // //             ),
// // // //           ],
// // // //         );
// // // //       },
// // // //     );
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
// // // //       MaterialPageRoute(
// // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // //       ),
// // // //     ).then((_) => _loadCategories());
// // // //   }
// // // //
// // // //   void _checkAllConfigured() {
// // // //     if (categories.every((c) => c.configured == 1)) {
// // // //       Navigator.pushReplacement(
// // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // //     } else {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Configure all categories first!')),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('Categories'),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.check),
// // // //             onPressed: _checkAllConfigured,
// // // //           )
// // // //         ],
// // // //       ),
// // // //       body: ListView.builder(
// // // //         itemCount: categories.length,
// // // //         itemBuilder: (_, index) {
// // // //           final cat = categories[index];
// // // //           return Card(
// // // //             child: ListTile(
// // // //               title: Text(cat.name),
// // // //               subtitle: Text('Configured: ${cat.configured == 1 ? "Yes" : "No"}'),
// // // //               leading: CircleAvatar(backgroundColor: Color(cat.color).withOpacity(1.0)),
// // // //               trailing: Row(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
// // // //                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
// // // //                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //       floatingActionButton: FloatingActionButton(
// // // //         onPressed: _showAddCategoryDialog,
// // // //         child: const Icon(Icons.add),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // // // import 'package:flutter/material.dart';
// // // // import '../../database/app_database.dart';
// // // // import '../../models/category_model.dart';
// // // // import '../general/general_schedule_page.dart';
// // // // import '../week/week_schedule_page.dart';
// // // // import '../dashboard/dashboard_page.dart';
// // // // import 'create_category_page.dart'; // Import the new page
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
// // // //     final db = await AppDB.instance.database;
// // // //     final res = await db.query('categories');
// // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // //     if (mounted) {
// // // //       setState(() => loading = false);
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _deleteCategory(int id) async {
// // // //     final db = await AppDB.instance.database;
// // // //     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// // // //     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// // // //     _loadCategories();
// // // //   }
// // // //
// // // //   void _navigateAndRefresh() {
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // //     ).then((_) {
// // // //       // When we return from CreateCategoryPage, reload the categories
// // // //       setState(() {
// // // //         loading = true;
// // // //       });
// // // //       _loadCategories();
// // // //     });
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
// // // //       MaterialPageRoute(
// // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // //       ),
// // // //     ).then((_) => _loadCategories());
// // // //   }
// // // //
// // // //   void _checkAllConfigured() {
// // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // //     if (allConfigured) {
// // // //       Navigator.pushReplacement(
// // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // //     } else {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Please create and configure all categories first!')),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('Categories'),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.check),
// // // //             onPressed: _checkAllConfigured,
// // // //           )
// // // //         ],
// // // //       ),
// // // //       body: ListView.builder(
// // // //         itemCount: categories.length,
// // // //         itemBuilder: (_, index) {
// // // //           final cat = categories[index];
// // // //           return Card(
// // // //             child: ListTile(
// // // //               title: Text(cat.name),
// // // //               subtitle: Text('Configured: ${cat.configured ? "Yes" : "No"}'),
// // // //               leading: CircleAvatar(backgroundColor: Color(cat.color).withOpacity(1.0)),
// // // //               trailing: Row(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   IconButton(icon: const Icon(Icons.schedule), onPressed: () => _openWeekSchedule(cat)),
// // // //                   IconButton(icon: const Icon(Icons.edit), onPressed: () => _openGeneralSchedule(cat)),
// // // //                   IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(cat.id!)),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //       floatingActionButton: FloatingActionButton(
// // // //         onPressed: _navigateAndRefresh, // Changed to navigate
// // // //         child: const Icon(Icons.add),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // //
// // // // import 'package:flutter/material.dart';
// // // // import '../../database/app_database.dart';
// // // // import '../../models/category_model.dart';
// // // // import '../general/general_schedule_page.dart';
// // // // import '../week/week_schedule_page.dart';
// // // // import '../dashboard/dashboard_page.dart';
// // // // import 'create_category_page.dart'; // Import the new page
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
// // // //     final db = await AppDB.instance.database;
// // // //     final res = await db.query('categories');
// // // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // // //     if (mounted) {
// // // //       setState(() => loading = false);
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _deleteCategory(int id) async {
// // // //     // Show a confirmation dialog before deleting
// // // //     final bool? shouldDelete = await showDialog<bool>(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: const Text('Delete Category'),
// // // //         content: const Text('Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
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
// // // //       _loadCategories();
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Category deleted successfully')),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   void _navigateAndRefresh() {
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // // //     ).then((_) {
// // // //       // When we return from CreateCategoryPage, reload the categories
// // // //       setState(() {
// // // //         loading = true;
// // // //       });
// // // //       _loadCategories();
// // // //     });
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
// // // //       MaterialPageRoute(
// // // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // // //       ),
// // // //     ).then((_) => _loadCategories());
// // // //   }
// // // //
// // // //   void _checkAllConfigured() {
// // // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // // //     if (allConfigured) {
// // // //       Navigator.pushReplacement(
// // // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // // //     } else {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(
// // // //           content: Text('Please create and configure all categories first!'),
// // // //           behavior: SnackBarBehavior.floating,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (loading) {
// // // //       return Scaffold(
// // // //         appBar: AppBar(title: const Text('Categories')),
// // // //         body: const Center(child: CircularProgressIndicator()),
// // // //       );
// // // //     }
// // // //
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('Categories'),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.check_circle_outline),
// // // //             tooltip: 'Finish Configuration',
// // // //             onPressed: _checkAllConfigured,
// // // //           )
// // // //         ],
// // // //       ),
// // // //       body: categories.isEmpty
// // // //           ? Center(
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // // //             const SizedBox(height: 16),
// // // //             const Text(
// // // //               'No Categories Found',
// // // //               style: TextStyle(fontSize: 18, color: Colors.grey),
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             const Text(
// // // //               'Tap the "+" button to add your first category.',
// // // //               style: TextStyle(color: Colors.grey),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       )
// // // //           : ListView.builder(
// // // //         padding: const EdgeInsets.all(8.0), // Add padding around the list
// // // //         itemCount: categories.length,
// // // //         itemBuilder: (_, index) {
// // // //           final cat = categories[index];
// // // //           return Card(
// // // //             elevation: 4.0, // Add a shadow
// // // //             margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between cards
// // // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
// // // //             child: ListTile(
// // // //               contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // //               leading: CircleAvatar(
// // // //                 backgroundColor: Color(cat.color).withOpacity(1.0),
// // // //                 child: Text(
// // // //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '',
// // // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //                 ),
// // // //               ),
// // // //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //               subtitle: Row(
// // // //                 children: [
// // // //                   Icon(
// // // //                     cat.configured ? Icons.check_circle : Icons.pending,
// // // //                     color: cat.configured ? Colors.green : Colors.orange,
// // // //                     size: 16,
// // // //                   ),
// // // //                   const SizedBox(width: 4),
// // // //                   Text('Configured: ${cat.configured ? "Yes" : "No"}'),
// // // //                 ],
// // // //               ),
// // // //               trailing: PopupMenuButton<String>(
// // // //                 onSelected: (value) {
// // // //                   if (value == 'edit') {
// // // //                     _openGeneralSchedule(cat);
// // // //                   } else if (value == 'schedule') {
// // // //                     _openWeekSchedule(cat);
// // // //                   } else if (value == 'delete') {
// // // //                     _deleteCategory(cat.id!);
// // // //                   }
// // // //                 },
// // // //                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // // //                   const PopupMenuItem<String>(
// // // //                     value: 'edit',
// // // //                     child: ListTile(
// // // //                       leading: Icon(Icons.edit_calendar),
// // // //                       title: Text('Edit General'),
// // // //                     ),
// // // //                   ),
// // // //                   const PopupMenuItem<String>(
// // // //                     value: 'schedule',
// // // //                     child: ListTile(
// // // //                       leading: Icon(Icons.schedule),
// // // //                       title: Text('Edit Weekly'),
// // // //                     ),
// // // //                   ),
// // // //                   const PopupMenuDivider(),
// // // //                   const PopupMenuItem<String>(
// // // //                     value: 'delete',
// // // //                     child: ListTile(
// // // //                       leading: Icon(Icons.delete_forever, color: Colors.red),
// // // //                       title: Text('Delete', style: TextStyle(color: Colors.red)),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //       floatingActionButton: FloatingActionButton.extended(
// // // //         onPressed: _navigateAndRefresh,
// // // //         label: const Text('Add'),
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
// // //
// // //
// // //
// // //
// // //
// // // import 'package:flutter/material.dart';
// // // import '../../database/app_database.dart';
// // // import '../../models/category_model.dart';
// // // import '../general/general_schedule_page.dart';
// // // import '../week/week_schedule_page.dart';
// // // import '../dashboard/dashboard_page.dart';
// // // import 'create_category_page.dart'; // Make sure this page exists for adding new categories
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
// // //     final db = await AppDB.instance.database;
// // //     final res = await db.query('categories');
// // //     // Ensure you are using the correct type for 'configured'. Assuming it's a boolean (true/false).
// // //     // If your database stores it as 0 or 1, the CategoryModel.fromMap should handle the conversion.
// // //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// // //     if (mounted) {
// // //       setState(() => loading = false);
// // //     }
// // //   }
// // //
// // //   Future<void> _deleteCategory(int id) async {
// // //     // Show a confirmation dialog before deleting to prevent accidental data loss
// // //     final bool? shouldDelete = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('Delete Category'),
// // //         content: const Text('Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
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
// // //       // Show feedback and reload the list
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Category deleted successfully')),
// // //       );
// // //       _loadCategories(); // This reloads the state
// // //     }
// // //   }
// // //
// // //   void _navigateAndRefresh() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// // //     ).then((_) {
// // //       // When we return from the create page, reload the categories to show the new one.
// // //       setState(() => loading = true);
// // //       _loadCategories();
// // //     });
// // //   }
// // //
// // //   // Handles the main tap action on a category card
// // //   void _handleCategoryTap(CategoryModel cat) {
// // //     if (cat.configured) {
// // //       // If already configured, open the weekly schedule for editing.
// // //       _openWeekSchedule(cat);
// // //     } else {
// // //       // If not configured, open the general schedule for setup.
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
// // //       MaterialPageRoute(
// // //         builder: (_) => WeekSchedulePage(categoryId: cat.id!),
// // //       ),
// // //     ).then((_) => _loadCategories());
// // //   }
// // //
// // //   void _checkAllConfigured() {
// // //     // Check if there are categories and if every single one is configured.
// // //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// // //     if (allConfigured) {
// // //       Navigator.pushReplacement(
// // //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// // //     } else {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text('Please create and configure all categories first!'),
// // //           behavior: SnackBarBehavior.floating,
// // //         ),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (loading) {
// // //       return Scaffold(
// // //         appBar: AppBar(title: const Text('Categories')),
// // //         body: const Center(child: CircularProgressIndicator()),
// // //       );
// // //     }
// // //
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Categories'),
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(Icons.check_circle_outline),
// // //             tooltip: 'Finish Configuration',
// // //             onPressed: _checkAllConfigured,
// // //           )
// // //         ],
// // //       ),
// // //       body: categories.isEmpty
// // //           ? Center(
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// // //             const SizedBox(height: 16),
// // //             const Text(
// // //               'No Categories Found',
// // //               style: TextStyle(fontSize: 18, color: Colors.grey),
// // //             ),
// // //             const SizedBox(height: 8),
// // //             Text(
// // //               'Tap the "+" button to add your first category.',
// // //               textAlign: TextAlign.center,
// // //               style: TextStyle(color: Colors.grey[600]),
// // //             ),
// // //           ],
// // //         ),
// // //       )
// // //           : ListView.builder(
// // //         padding: const EdgeInsets.all(8.0), // Add padding around the list
// // //         itemCount: categories.length,
// // //         itemBuilder: (_, index) {
// // //           final cat = categories[index];
// // //           return Card(
// // //             elevation: 4.0,
// // //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //             child: ListTile(
// // //               contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // //               leading: CircleAvatar(
// // //                 backgroundColor: Color(cat.color).withOpacity(1.0),
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
// // //                   // Use a more descriptive subtitle
// // //                   Text(cat.configured ? "Ready to schedule" : "Setup required"),
// // //                 ],
// // //               ),
// // //               // Main tap action for the list tile
// // //               onTap: () => _handleCategoryTap(cat),
// // //               trailing: PopupMenuButton<String>(
// // //                 tooltip: "More Options",
// // //                 onSelected: (value) {
// // //                   if (value == 'edit_general') {
// // //                     _openGeneralSchedule(cat);
// // //                   } else if (value == 'delete') {
// // //                     _deleteCategory(cat.id!);
// // //                   }
// // //                 },
// // //                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// // //                   const PopupMenuItem<String>(
// // //                     value: 'edit_general',
// // //                     child: ListTile(
// // //                       leading: Icon(Icons.edit_calendar_outlined),
// // //                       title: Text('Edit General'),
// // //                     ),
// // //                   ),
// // //                   const PopupMenuDivider(),
// // //                   const PopupMenuItem<String>(
// // //                     value: 'delete',
// // //                     child: ListTile(
// // //                       leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
// // //                       title: Text('Delete', style: TextStyle(color: Colors.red)),
// // //                     ),
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
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart'; // Used for formatting dates
// // import '../../database/app_database.dart';
// // import '../../models/category_model.dart';
// // import '../../models/period_model.dart';
// // import '../general/general_schedule_page.dart';
// // import '../week/week_schedule_page.dart';
// // import '../dashboard/dashboard_page.dart';
// // import 'create_category_page.dart';
// //
// // class CategoryListPage extends StatefulWidget {
// //   const CategoryListPage({super.key});
// //
// //   @override
// //   State<CategoryListPage> createState() => _CategoryListPageState();
// // }
// //
// // class _CategoryListPageState extends State<CategoryListPage> {
// //   List<CategoryModel> categories = [];
// //   bool loading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCategories();
// //   }
// //
// //   Future<void> _loadCategories() async {
// //     setState(() => loading = true);
// //     final db = await AppDB.instance.database;
// //     final res = await db.query('categories', orderBy: 'name');
// //     categories = res.map((e) => CategoryModel.fromMap(e)).toList();
// //     if (mounted) {
// //       setState(() => loading = false);
// //     }
// //   }
// //
// //   Future<void> _deleteCategory(int id) async {
// //     final bool? shouldDelete = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Delete Category'),
// //         content: const Text(
// //             'Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(false),
// //             child: const Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(true),
// //             style: TextButton.styleFrom(foregroundColor: Colors.red),
// //             child: const Text('Delete'),
// //           ),
// //         ],
// //       ),
// //     );
// //
// //     if (shouldDelete == true) {
// //       final db = await AppDB.instance.database;
// //       await db.delete('categories', where: 'id = ?', whereArgs: [id]);
// //       await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //               content: Text('Category deleted successfully'),
// //               backgroundColor: Colors.green),
// //         );
// //       }
// //       _loadCategories();
// //     }
// //   }
// //
// //   /// NEW METHOD: Generates and displays the commands for the ESP32.
// //   Future<void> _generateAndShowCommands(CategoryModel cat) async {
// //     if (!mounted) return;
// //
// //     // Show a loading indicator
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => const Center(child: CircularProgressIndicator()),
// //     );
// //
// //     final db = await AppDB.instance.database;
// //     final List<Map<String, dynamic>> periodMaps = await db.query(
// //       'periods',
// //       where: 'categoryId = ?',
// //       whereArgs: [cat.id],
// //       orderBy: 'startTime', // Order by time to ensure correct sequence
// //     );
// //     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
// //
// //     List<String> commands = [];
// //     final DateFormat formatter = DateFormat('dd/MM/yy');
// //
// //     // 1. Generate the main category command
// //     // **FIX**: Parse the date strings into DateTime objects before formatting.
// //     final DateTime startDate = DateTime.parse(cat.startDate);
// //     final DateTime endDate = DateTime.parse(cat.endDate);
// //     final String startDateFormatted = formatter.format(startDate);
// //     final String endDateFormatted = formatter.format(endDate);
// //     commands.add('\$${cat.name},$startDateFormatted,$endDateFormatted#');
// //
// //     // 2. Group periods by weekday
// //     final Map<String, List<PeriodModel>> periodsByDay = {};
// //     for (var p in periods) {
// //       // **FIX**: Provide a default value for 'day' if it's null.
// //       final day = p.day ?? 'Unknown';
// //       (periodsByDay[day] ??= []).add(p);
// //     }
// //
// //     // Helper to convert day name to a single character code
// //     String dayToCode(String day) {
// //       const map = {
// //         'MONDAY': 'M', 'TUESDAY': 'T', 'WEDNESDAY': 'W', 'THURSDAY': 'H',
// //         'FRIDAY': 'F', 'SATURDAY': 'S', 'SUNDAY': 'U',
// //       };
// //       return map[day] ?? '?';
// //     }
// //
// //     // Helper to extract track number from ringtone name
// //     int getTrackNumber(String? ringtone) {
// //       if (ringtone == null || ringtone.isEmpty) return 1; // Default track
// //       final match = RegExp(r'\d+').firstMatch(ringtone);
// //       if (match != null) {
// //         return int.tryParse(match.group(0)!) ?? 1;
// //       }
// //       return 1; // Default track if no number is found
// //     }
// //
// //     // 3. Generate schedule commands for each day
// //     for (var entry in periodsByDay.entries) {
// //       final dayCode = dayToCode(entry.key);
// //       final List<String> timeAndRingtonePairs = [];
// //
// //       for (var period in entry.value) {
// //         // **FIX**: Handle potential null for ringtone and provide a default.
// //         final track = getTrackNumber(period.ringtone);
// //         // **FIX**: Ensure startTime is not null before using it.
// //         final startTime = period.startTime ?? '00:00';
// //         timeAndRingtonePairs.add('$startTime,${track.toString().padLeft(2, '0')}');
// //       }
// //
// //       if (timeAndRingtonePairs.isNotEmpty) {
// //         final schedulePayload = timeAndRingtonePairs.join('!');
// //         final fullPayload = '$dayCode,$schedulePayload';
// //         final byteCount = fullPayload.length; // Calculate byte count of the payload
// //         commands.add('\$$byteCount,$fullPayload#');
// //       }
// //     }
// //
// //     if (!mounted) return;
// //     Navigator.of(context).pop(); // Dismiss loading indicator
// //
// //     // 4. Show the generated commands in a dialog
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Generated Commands for "${cat.name}"'),
// //         content: SizedBox(
// //           width: double.maxFinite,
// //           child: SingleChildScrollView(
// //             child: Text(
// //               commands.join('\n'), // Join commands with a newline for readability
// //               style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
// //             ),
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(),
// //             child: const Text('OK'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _navigateAndRefresh() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
// //     ).then((_) {
// //       _loadCategories();
// //     });
// //   }
// //
// //   void _handleCategoryTap(CategoryModel cat) {
// //     if (cat.configured) {
// //       _openWeekSchedule(cat);
// //     } else {
// //       _openGeneralSchedule(cat);
// //     }
// //   }
// //
// //   void _openGeneralSchedule(CategoryModel cat) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (_) => GeneralSchedulePage(categoryId: cat.id!)),
// //     ).then((_) => _loadCategories());
// //   }
// //
// //   void _openWeekSchedule(CategoryModel cat) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
// //     ).then((_) => _loadCategories());
// //   }
// //
// //   void _checkAllConfigured() {
// //     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
// //     if (allConfigured) {
// //       Navigator.pushReplacement(
// //           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please create and configure at least one category first!'),
// //           behavior: SnackBarBehavior.floating,
// //         ),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (loading) {
// //       return Scaffold(
// //         appBar: AppBar(title: const Text('Categories')),
// //         body: const Center(child: CircularProgressIndicator()),
// //       );
// //     }
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Categories'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.check_circle_outline),
// //             tooltip: 'Finish Configuration',
// //             onPressed: _checkAllConfigured,
// //           )
// //         ],
// //       ),
// //       body: categories.isEmpty
// //           ? Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
// //               const SizedBox(height: 16),
// //               const Text('No Categories Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
// //               const SizedBox(height: 8),
// //               Text(
// //                 'Tap the "Add Category" button to create your first schedule category.',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(color: Colors.grey[600]),
// //               ),
// //             ],
// //           ),
// //         ),
// //       )
// //           : ListView.builder(
// //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Padding for FAB
// //         itemCount: categories.length,
// //         itemBuilder: (_, index) {
// //           final cat = categories[index];
// //           return Card(
// //             elevation: 4.0,
// //             margin: const EdgeInsets.symmetric(vertical: 8.0),
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //             child: ListTile(
// //               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
// //               leading: CircleAvatar(
// //                 backgroundColor: Color(cat.color).withOpacity(1.0),
// //                 child: Text(
// //                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
// //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
// //               subtitle: Row(
// //                 children: [
// //                   Icon(
// //                     cat.configured ? Icons.check_circle : Icons.pending,
// //                     color: cat.configured ? Colors.green : Colors.orange,
// //                     size: 16,
// //                   ),
// //                   const SizedBox(width: 4),
// //                   Text(cat.configured ? "Ready to sync" : "Setup required"),
// //                 ],
// //               ),
// //               onTap: () => _handleCategoryTap(cat),
// //               trailing: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   IconButton(
// //                     icon: const Icon(Icons.send_outlined),
// //                     tooltip: 'Generate Sync Commands',
// //                     onPressed: cat.configured ? () => _generateAndShowCommands(cat) : null,
// //                     color: Theme.of(context).primaryColor,
// //                   ),
// //                   PopupMenuButton<String>(
// //                     tooltip: "More Options",
// //                     onSelected: (value) {
// //                       if (value == 'edit_general') {
// //                         _openGeneralSchedule(cat);
// //                       } else if (value == 'delete') {
// //                         _deleteCategory(cat.id!);
// //                       }
// //                     },
// //                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
// //                       const PopupMenuItem<String>(
// //                         value: 'edit_general',
// //                         child: ListTile(
// //                           leading: Icon(Icons.edit_calendar_outlined),
// //                           title: Text('Edit General'),
// //                         ),
// //                       ),
// //                       const PopupMenuDivider(),
// //                       const PopupMenuItem<String>(
// //                         value: 'delete',
// //                         child: ListTile(
// //                           leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
// //                           title: Text('Delete', style: TextStyle(color: Colors.red)),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //       floatingActionButton: FloatingActionButton.extended(
// //         onPressed: _navigateAndRefresh,
// //         label: const Text('Add Category'),
// //         icon: const Icon(Icons.add),
// //         tooltip: 'Add a new category',
// //       ),
// //     );
// //   }
// // }
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
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Used for formatting dates
// // import 'package:path/path.dart' as p; // FIX: Unused import removed.
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
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() => loading = true);
//     final db = await AppDB.instance.database;
//     // Sort by name to ensure the sequence number is consistent
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
//             'Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
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
//               content: Text('Category deleted successfully'),
//               backgroundColor: Colors.green),
//         );
//       }
//       _loadCategories(); // Refresh the list
//     }
//   }
//
//   /// METHOD WITH ALL CORRECTIONS APPLIED
//   Future<void> _generateAndShowCommands(
//       CategoryModel cat, int categorySequenceNumber) async {
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );
//
//     final db = await AppDB.instance.database;
//     final List<Map<String, dynamic>> periodMaps = await db.query(
//       'periods',
//       where: 'categoryId = ?',
//       whereArgs: [cat.id],
//       orderBy: 'startTime',
//     );
//     final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();
//
//     List<String> commands = [];
//     final DateFormat formatter = DateFormat('dd-MM-yy');
//
//     // 1. Category Command
//     final DateTime startDate = DateTime.parse(cat.startDate);
//     final DateTime endDate = DateTime.parse(cat.endDate);
//     final String startDateFormatted = formatter.format(startDate);
//     final String endDateFormatted = formatter.format(endDate);
//     commands.add(
//         '\$C,$categorySequenceNumber,${cat.name},$startDateFormatted,$endDateFormatted#');
//
//     // 2. Group periods by day
//     final Map<String, List<PeriodModel>> periodsByDay = {};
//     for (var p in periods) {
//       (periodsByDay[p.day] ??= []).add(p);
//     }
//
//     String dayToCode(String day) {
//       const map = {
//         'monday': 'M',
//         'tuesday': 'T',
//         'wednesday': 'W',
//         'thursday': 'H',
//         'friday': 'F',
//         'saturday': 'S',
//         'sunday': 'U',
//       };
//       return map[day.toLowerCase()] ?? '?';
//     }
//
//     // **DEFINITIVE FIX for ringtone name**
//     String getRingtoneName(String? ringtonePath) {
//       // 1. Handle null or empty case first.
//       if (ringtonePath == null || ringtonePath.isEmpty) {
//         return "default.mp3";
//       }
//
//       // 2. Isolate the filename from the path.
//       final filename = ringtonePath.split(r'\').last.split('/').last;
//
//       // 3. Correct the ".mp3.mp3" error if it exists.
//       if (filename.endsWith('.mp3.mp3')) {
//         return filename.substring(0, filename.length - 4);
//       }
//
//       // 4. Return the (now correct) filename.
//       return filename;
//     }
//
//     // 3. Generate Schedule Commands
//     for (var entry in periodsByDay.entries) {
//       final dayCode = dayToCode(entry.key);
//       if (dayCode == '?') continue;
//
//       final List<String> timeAndRingtonePairs = [];
//       for (var period in entry.value) {
//         // This call is now safe because getRingtoneName accepts String?
//         final ringtoneName = getRingtoneName(period.ringtone);
//         final startTime = period.startTime ?? '00:00';
//         timeAndRingtonePairs.add('$startTime,$ringtoneName');
//       }
//
//       if (timeAndRingtonePairs.isNotEmpty) {
//         final schedulePayload = timeAndRingtonePairs.join('!');
//         final fullPayload =
//             '$categorySequenceNumber,$dayCode,$schedulePayload';
//         final byteCount = fullPayload.length;
//         commands.add('\$S,$byteCount,$fullPayload#');
//       }
//     }
//
//     if (!mounted) return;
//     Navigator.of(context).pop(); // Dismiss loading dialog
//
//     // 4. Show generated commands
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Generated Commands for "${cat.name}"'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: SingleChildScrollView(
//             child: Text(
//               commands.join('\n'),
//               style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) {
//       // Refresh the list after returning from the create page
//       _loadCategories();
//     });
//   }
//
//   void _handleCategoryTap(CategoryModel cat) {
//     // If setup is complete, go to the detailed week schedule.
//     // Otherwise, go to the initial setup page.
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
//           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure at least one category first!'),
//           backgroundColor: Colors.orange,
//           behavior: SnackBarBehavior.floating,
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
//             icon: const Icon(Icons.check_circle_outline),
//             tooltip: 'Finish Configuration',
//             onPressed: _checkAllConfigured,
//           )
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
//               const SizedBox(height: 8),
//               Text(
//                 'Tap the "Add Category" button to create your first schedule category.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             ],
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Space for FAB
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           // The sequential number is the list index + 1
//           final categorySequence = index + 1;
//           return Card(
//             elevation: 3.0,
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//               leading: CircleAvatar(
//                 // FIX: Replaced deprecated 'withOpacity'
//                 backgroundColor: Color(cat.color),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(cat.name,
//                   style:
//                   const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Row(
//                 children: [
//                   Icon(
//                     cat.configured
//                         ? Icons.check_circle
//                         : Icons.pending,
//                     color: cat.configured
//                         ? Colors.green
//                         : Colors.orange,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(cat.configured
//                       ? "Ready to sync"
//                       : "Setup required"),
//                 ],
//               ),
//               onTap: () => _handleCategoryTap(cat),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.send_outlined),
//                     tooltip: 'Generate Sync Commands',
//                     // Pass both the category and its sequence number
//                     onPressed: cat.configured
//                         ? () => _generateAndShowCommands(
//                         cat, categorySequence)
//                         : null,
//                     color: Theme.of(context).primaryColor,
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
//                     itemBuilder: (BuildContext context) =>
//                     <PopupMenuEntry<String>>[
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
//                           leading: Icon(Icons.delete_forever_outlined,
//                               color: Colors.red),
//                           title: Text('Delete',
//                               style: TextStyle(color: Colors.red)),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Used for formatting dates

import '../../database/app_database.dart';
import '../../models/category_model.dart';
import '../../models/period_model.dart';
import '../dashboard/dashboard_page.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => loading = true);
    final db = await AppDB.instance.database;
    // Sort by name to ensure the sequence number is consistent
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
          'Are you sure you want to delete this category and all its associated data? This action cannot be undone.',
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
      _loadCategories(); // Refresh the list
    }
  }

  /// METHOD WITH ALL CORRECTIONS AND DEBUGGING APPLIED
  Future<void> _generateAndShowCommands(
    CategoryModel cat,
    int categorySequenceNumber,
  ) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final db = await AppDB.instance.database;
    final List<Map<String, dynamic>> periodMaps = await db.query(
      'periods',
      where: 'categoryId = ?',
      whereArgs: [cat.id],
      orderBy: 'startTime',
    );
    final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();

    List<String> commands = [];
    final DateFormat formatter = DateFormat('dd-MM-yy');

    // 1. Category Command
    final DateTime startDate = DateTime.parse(cat.startDate);
    final DateTime endDate = DateTime.parse(cat.endDate);
    final String startDateFormatted = formatter.format(startDate);
    final String endDateFormatted = formatter.format(endDate);
    commands.add(
      '\$C,$categorySequenceNumber,${cat.name},$startDateFormatted,$endDateFormatted#',
    );

    // 2. Group periods by day
    final Map<String, List<PeriodModel>> periodsByDay = {};
    for (var p in periods) {
      (periodsByDay[p.day] ??= []).add(p);
    }

    String dayToCode(String day) {
      const map = {
        'monday': 'M',
        'tuesday': 'T',
        'wednesday': 'W',
        'thursday': 'H',
        'friday': 'F',
        'saturday': 'S',
        'sunday': 'U',
      };
      return map[day.toLowerCase()] ?? '?';
    }

    // **DEFINITIVE FIX with DEBUGGING**
    String getRingtoneName(String? ringtonePath) {
      // **DEBUG STEP**: Print the raw value from the database to the console.
      // This will immediately tell us if the value is null or an empty string.


      print("DEBUG: Received ringtone path from DB: '$ringtonePath'");

      // 1. Handle null or empty case first.
      if (ringtonePath == null || ringtonePath.trim().isEmpty) {
        print("DEBUG: Path is null or empty, returning 'default.mp3'");
        return "default.mp3";
      }

      // 2. Isolate the filename from the path. This handles both / and \ separators.
      final filename = ringtonePath.split(r'\').last.split('/').last;

      // 3. Correct the ".mp3.mp3" error if it exists.
      if (filename.endsWith('.mp3.mp3')) {
        final correctedName = filename.substring(0, filename.length - 4);
        print("DEBUG: Corrected '.mp3.mp3' to '$correctedName'");
        return correctedName;
      }

      // 4. Return the (now correct) filename.
      print("DEBUG: Returning filename as is: '$filename'");
      return filename;
    }

    // 3. Generate Schedule Commands
    for (var entry in periodsByDay.entries) {
      final dayCode = dayToCode(entry.key);
      if (dayCode == '?') continue;

      final List<String> timeAndRingtonePairs = [];
      for (var period in entry.value) {
        final ringtoneName = getRingtoneName(period.ringtone);
        final startTime = period.startTime ?? '00:00';
        timeAndRingtonePairs.add('$startTime,$ringtoneName');
      }

      if (timeAndRingtonePairs.isNotEmpty) {
        final schedulePayload = timeAndRingtonePairs.join('!');
        final fullPayload = '$categorySequenceNumber,$dayCode,$schedulePayload';
        final byteCount = fullPayload.length;
        commands.add('\$S,$byteCount,$fullPayload#');
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // Dismiss loading dialog

    // 4. Show generated commands
    showDialog(
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateAndRefresh() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
    ).then((_) {
      _loadCategories();
    });
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
      MaterialPageRoute(
        builder: (_) => GeneralSchedulePage(categoryId: cat.id!),
      ),
    ).then((_) => _loadCategories());
  }

  void _openWeekSchedule(CategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeekSchedulePage(categoryId: cat.id!)),
    ).then((_) => _loadCategories());
  }

  void _checkAllConfigured() {
    final allConfigured =
        categories.isNotEmpty && categories.every((c) => c.configured);
    if (allConfigured) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please create and configure at least one category first!',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Finish Configuration',
            onPressed: _checkAllConfigured,
          ),
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
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Categories Found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the "Add Category" button to create your first schedule category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Space for FAB
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                final categorySequence = index + 1;
                return Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    leading: CircleAvatar(
                      backgroundColor: Color(cat.color),
                      child: Text(
                        cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          cat.configured ? Icons.check_circle : Icons.pending,
                          color: cat.configured ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat.configured ? "Ready to sync" : "Setup required",
                        ),
                      ],
                    ),
                    onTap: () => _handleCategoryTap(cat),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.send_outlined),
                          tooltip: 'Generate Sync Commands',
                          onPressed: cat.configured
                              ? () => _generateAndShowCommands(
                                  cat,
                                  categorySequence,
                                )
                              : null,
                          color: Theme.of(context).primaryColor,
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
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
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
                                    leading: Icon(
                                      Icons.delete_forever_outlined,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
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
