import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(Color) onColorChange;
  final Function(DateTime, DateTime) onDateChange;

  const CategoryCard({
    super.key,
    required this.controller,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.onColorChange,
    required this.onDateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Color:"),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: ()=>onColorChange(Colors.blue), // change color picker
                  child: CircleAvatar(backgroundColor: color),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
