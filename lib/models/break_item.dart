class BreakItem {
  String startTime; // "HH:mm"
  int duration; // in minutes

  BreakItem({required this.startTime, required this.duration});

  factory BreakItem.fromMap(Map<String, dynamic> map) {
    return BreakItem(
      startTime: map['startTime'] as String,
      duration: map['duration'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'duration': duration,
    };
  }
}
