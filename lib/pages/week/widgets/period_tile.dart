import 'package:flutter/material.dart';

class PeriodTile extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String? ringtone;
  final bool isBreak;
  final bool isLast;
  final VoidCallback onTap;

  const PeriodTile({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.ringtone,
    required this.isBreak,
    this.isLast = false,
    required this.onTap,
  });

  String _getFileName(String? path) {
    if (path == null || path.isEmpty) return 'Default';
    return path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endTime,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),

          // Timeline Column
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isBreak ? Colors.brown : const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE5E5EA),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E5EA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isBreak
                                  ? Colors.brown
                                  : (title.toLowerCase() == 'end of day'
                                      ? Colors.redAccent
                                      : const Color(0xFF007AFF)))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isBreak
                              ? Icons.coffee_rounded
                              : (title.toLowerCase() == 'end of day'
                                  ? Icons.exit_to_app_rounded
                                  : Icons.school_rounded),
                          color: isBreak
                              ? Colors.brown
                              : (title.toLowerCase() == 'end of day'
                                  ? Colors.redAccent
                                  : const Color(0xFF007AFF)),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.music_note_rounded, size: 14, color: Color(0xFF8E8E93)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _getFileName(ringtone),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8E8E93),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_rounded, color: Color(0xFFC7C7CC), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
