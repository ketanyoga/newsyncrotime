import 'package:flutter/material.dart';

class PeriodTile extends StatelessWidget {
  final String title;
  final String time;
  final bool isBreak;
  final VoidCallback onTap;

  const PeriodTile({
    super.key,
    required this.title,
    required this.time,
    required this.isBreak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isBreak ? Colors.grey[200] : Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle: Text(time),
        trailing: const Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }
}
