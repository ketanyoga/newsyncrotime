// class PeriodModel {
//   final int? id;
//   final int categoryId;
//   final String day;
//   final String title;
//   final String startTime;
//   final String endTime;
//   final bool isBreak;
//   final String? ringtone;
//
//   PeriodModel({
//     this.id,
//     required this.categoryId,
//     required this.day,
//     required this.title,
//     required this.startTime,
//     required this.endTime,
//     required this.isBreak,
//     this.ringtone,
//   });
//   factory PeriodModel.fromMap(Map<String, dynamic> map) {
//     return PeriodModel(
//       id: map['id'],
//       categoryId: map['categoryId'],
//       day: map['day'],
//       title: map['title'],
//       startTime: map['startTime'],
//       endTime: map['endTime'],
//       isBreak: map['isBreak'] == 1, // Converts integer from DB to boolean
//     );
//   }
//
//
//   Map<String, dynamic> toMap() => {
//     'id': id,
//     'categoryId': categoryId,
//     'day': day,
//     'title': title,
//     'startTime': startTime,
//     'endTime': endTime,
//     'isBreak': isBreak ? 1 : 0,
//     'ringtone': ringtone,
//   };
// }





class PeriodModel {
  final int? id;
  final int categoryId;
  final String day;  final String title;
  final String startTime;
  final String endTime;
  final bool isBreak;
  final String? ringtone;

  PeriodModel({
    this.id,
    required this.categoryId,
    required this.day,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    this.ringtone,
  });

  factory PeriodModel.fromMap(Map<String, dynamic> map) {
    return PeriodModel(
      id: map['id'],
      categoryId: map['categoryId'],
      day: map['day'],
      title: map['title'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      isBreak: map['isBreak'] == 1, // Converts integer from DB to boolean
      ringtone: map['ringtone'], // This line was missing
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'day': day,
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'isBreak': isBreak ? 1 : 0,
    'ringtone': ringtone,
  };
}