class WeekScheduleModel {
  int? id;
  int categoryId;
  String day;
  String title;
  String startTime;
  String endTime;
  String? mp3Path;
  bool isBreak; // app logic

  WeekScheduleModel({
    this.id,
    required this.categoryId,
    required this.day,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.mp3Path,
    this.isBreak = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'day': day,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'mp3Path': mp3Path,
      'isBreak': isBreak ? 1 : 0, // ✅ bool -> int
    };
  }

  factory WeekScheduleModel.fromMap(Map<String, dynamic> map) {
    return WeekScheduleModel(
      id: map['id'],
      categoryId: map['categoryId'],
      day: map['day'],
      title: map['title'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      mp3Path: map['mp3Path'],
      isBreak: (map['isBreak'] as int) == 1, // ✅ int -> bool
    );
  }
}
