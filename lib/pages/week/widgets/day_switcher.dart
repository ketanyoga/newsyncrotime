import 'package:flutter/material.dart';

class DaySwitcher extends StatelessWidget {
  final List<String> days;
  final int currentIndex;
  final Function(int) onSelect;

  const DaySwitcher({
    super.key,
    required this.days,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final bool active = currentIndex == index;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF007AFF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF8E8E93),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
