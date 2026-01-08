import '../models/period_model.dart';

class BreakItem {
  final DateTime startTime;
  final Duration duration;

  BreakItem({
    required this.startTime,
    required this.duration,
  });
}

class ScheduleGenerator {
  static List<PeriodModel> generate({
    required int categoryId,
    required String day,
    required DateTime start,
    required DateTime end,
    required Duration periodDuration,
    required List<BreakItem> breaks,
  }) {
    List<PeriodModel> list = [];
    DateTime current = start;
    int count = 1;

    while (current.isBefore(end)) {
      // 🔹 Check if break starts now
      final breakNow = breaks.where(
            (b) =>
        b.startTime.hour == current.hour &&
            b.startTime.minute == current.minute,
      );

      if (breakNow.isNotEmpty) {
        final b = breakNow.first;

        list.add(
          PeriodModel(
            categoryId: categoryId,
            day: day,
            title: 'Break',
            startTime: _fmt(current),
            endTime: _fmt(current.add(b.duration)),
            isBreak: true,
          ),
        );

        current = current.add(b.duration);
        continue;
      }

      // 🔹 Normal period
      final next = current.add(periodDuration);
      if (next.isAfter(end)) break;

      list.add(
        PeriodModel(
          categoryId: categoryId,
          day: day,
          title: 'Period $count',
          startTime: _fmt(current),
          endTime: _fmt(next),
          isBreak: false,
        ),
      );

      count++;
      current = next;
    }

    return list;
  }

  static String _fmt(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
