import 'package:flutter/material.dart';

class DaySwitcher extends StatelessWidget {
  final String day;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const DaySwitcher({
    super.key,
    required this.day,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
        ),
        Text(
          day,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}
