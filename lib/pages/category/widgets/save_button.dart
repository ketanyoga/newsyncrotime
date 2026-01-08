import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const SaveButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onTap, child: const Text("SAVE"));
  }
}
