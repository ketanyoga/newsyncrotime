class PeriodModel {
  final int? id;
  final int categoryId;
  final String day;
  final String title;
  final String startTime;
  final String endTime;
  final bool isBreak;

  PeriodModel({
    this.id,
    required this.categoryId,
    required this.day,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'day': day,
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'isBreak': isBreak ? 1 : 0,
  };
}
