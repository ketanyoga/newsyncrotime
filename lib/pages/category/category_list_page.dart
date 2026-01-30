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

// import 'package:flutter/material.dart';
// import '../../database/app_database.dart';
// import '../../models/category_model.dart';
// import '../general/general_schedule_page.dart';
// import '../week/week_schedule_page.dart';
// import '../dashboard/dashboard_page.dart';
// import 'create_category_page.dart'; // Import the new page
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
//     if (mounted) {
//       setState(() => loading = false);
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     final db = await AppDB.instance.database;
//     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//     await db.delete('periods', where: 'categoryId = ?', whereArgs: [id]);
//     _loadCategories();
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) {
//       // When we return from CreateCategoryPage, reload the categories
//       setState(() {
//         loading = true;
//       });
//       _loadCategories();
//     });
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
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please create and configure all categories first!')),
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
//               subtitle: Text('Configured: ${cat.configured ? "Yes" : "No"}'),
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
//         onPressed: _navigateAndRefresh, // Changed to navigate
//         child: const Icon(Icons.add),
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
// import 'create_category_page.dart'; // Import the new page
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
//     if (mounted) {
//       setState(() => loading = false);
//     }
//   }
//
//   Future<void> _deleteCategory(int id) async {
//     // Show a confirmation dialog before deleting
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Category'),
//         content: const Text('Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
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
//       _loadCategories();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Category deleted successfully')),
//       );
//     }
//   }
//
//   void _navigateAndRefresh() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
//     ).then((_) {
//       // When we return from CreateCategoryPage, reload the categories
//       setState(() {
//         loading = true;
//       });
//       _loadCategories();
//     });
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
//     final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
//     if (allConfigured) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please create and configure all categories first!'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Categories')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
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
//       body: categories.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'No Categories Found',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Tap the "+" button to add your first category.',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.all(8.0), // Add padding around the list
//         itemCount: categories.length,
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           return Card(
//             elevation: 4.0, // Add a shadow
//             margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between cards
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               leading: CircleAvatar(
//                 backgroundColor: Color(cat.color).withOpacity(1.0),
//                 child: Text(
//                   cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '',
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
//                   Text('Configured: ${cat.configured ? "Yes" : "No"}'),
//                 ],
//               ),
//               trailing: PopupMenuButton<String>(
//                 onSelected: (value) {
//                   if (value == 'edit') {
//                     _openGeneralSchedule(cat);
//                   } else if (value == 'schedule') {
//                     _openWeekSchedule(cat);
//                   } else if (value == 'delete') {
//                     _deleteCategory(cat.id!);
//                   }
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                   const PopupMenuItem<String>(
//                     value: 'edit',
//                     child: ListTile(
//                       leading: Icon(Icons.edit_calendar),
//                       title: Text('Edit General'),
//                     ),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'schedule',
//                     child: ListTile(
//                       leading: Icon(Icons.schedule),
//                       title: Text('Edit Weekly'),
//                     ),
//                   ),
//                   const PopupMenuDivider(),
//                   const PopupMenuItem<String>(
//                     value: 'delete',
//                     child: ListTile(
//                       leading: Icon(Icons.delete_forever, color: Colors.red),
//                       title: Text('Delete', style: TextStyle(color: Colors.red)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateAndRefresh,
//         label: const Text('Add'),
//         icon: const Icon(Icons.add),
//         tooltip: 'Add a new category',
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
import 'create_category_page.dart'; // Make sure this page exists for adding new categories

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
    // Ensure you are using the correct type for 'configured'. Assuming it's a boolean (true/false).
    // If your database stores it as 0 or 1, the CategoryModel.fromMap should handle the conversion.
    categories = res.map((e) => CategoryModel.fromMap(e)).toList();
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteCategory(int id) async {
    // Show a confirmation dialog before deleting to prevent accidental data loss
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category and all its associated data? This action cannot be undone.'),
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
      // Show feedback and reload the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
      _loadCategories(); // This reloads the state
    }
  }

  void _navigateAndRefresh() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCategoryPage()),
    ).then((_) {
      // When we return from the create page, reload the categories to show the new one.
      setState(() => loading = true);
      _loadCategories();
    });
  }

  // Handles the main tap action on a category card
  void _handleCategoryTap(CategoryModel cat) {
    if (cat.configured) {
      // If already configured, open the weekly schedule for editing.
      _openWeekSchedule(cat);
    } else {
      // If not configured, open the general schedule for setup.
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
      MaterialPageRoute(
        builder: (_) => WeekSchedulePage(categoryId: cat.id!),
      ),
    ).then((_) => _loadCategories());
  }

  void _checkAllConfigured() {
    // Check if there are categories and if every single one is configured.
    final allConfigured = categories.isNotEmpty && categories.every((c) => c.configured);
    if (allConfigured) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create and configure all categories first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Finish Configuration',
            onPressed: _checkAllConfigured,
          )
        ],
      ),
      body: categories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Categories Found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the "+" button to add your first category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0), // Add padding around the list
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: CircleAvatar(
                backgroundColor: Color(cat.color).withOpacity(1.0),
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
                  // Use a more descriptive subtitle
                  Text(cat.configured ? "Ready to schedule" : "Setup required"),
                ],
              ),
              // Main tap action for the list tile
              onTap: () => _handleCategoryTap(cat),
              trailing: PopupMenuButton<String>(
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
