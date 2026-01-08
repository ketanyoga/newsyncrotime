import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Add this dependency
import '../../database/app_database.dart';
import '../../models/category_model.dart';
import 'category_list_page.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  Color _selectedColor = Colors.blue;
  List<int> _usedColors = [];

  @override
  void initState() {
    super.initState();
    _fetchUsedColors();
  }

  Future<void> _fetchUsedColors() async {
    final db = await AppDB.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('categories', columns: ['color']);
    setState(() {
      _usedColors = maps.map((map) => map['color'] as int).toList();
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final db = await AppDB.instance.database;
      await db.insert(
        'categories',
        CategoryModel(
          name: nameCtrl.text,
          color: _selectedColor.value,
          startDate: _startDate!.toIso8601String(),
          endDate: _endDate!.toIso8601String(),
        ).toMap(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CategoryListPage()),
              (route) => false,
        );
      }
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            availableColors: Colors.primaries
                .where((color) => !_usedColors.contains(color.value))
                .toList(),
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.color_lens),
                          ),
                          title: const Text('Category Color'),
                          trailing: CircleAvatar(backgroundColor: _selectedColor),
                          onTap: _showColorPicker,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate == null
                              ? 'Select Start Date'
                              : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              initialDate: _startDate ?? DateTime.now(),
                            );
                            if (date != null) setState(() => _startDate = date);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_month),
                          label: Text(_endDate == null
                              ? 'Select End Date'
                              : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}'),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: _startDate ?? DateTime(2020),
                              lastDate: DateTime(2030),
                              initialDate: _endDate ?? _startDate ?? DateTime.now(),
                            );
                            if (date != null) setState(() => _endDate = date);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE CATEGORY'),
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
