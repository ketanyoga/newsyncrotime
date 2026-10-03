class CategoryModel {
  final int? id;
  final String name;
  final int color;
  final String startDate;
  final String endDate;
  final bool configured;
  final int ringtoneDuration; // in seconds
  final bool synced;
  final List<int> skippedDays; // 0=Sunday, 1=Monday...
  final List<DateTime> skippedDates;
  final String? scheduleConfig; // JSON string for form state persistence

  CategoryModel({
    this.id,
    required this.name,
    required this.color,
    required this.startDate,
    required this.endDate,
    this.configured = false,
    this.ringtoneDuration = 60,
    this.synced = false,
    this.skippedDays = const [],
    this.skippedDates = const [],
    this.scheduleConfig,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      configured: map['configured'] == 1,
      ringtoneDuration: map['ringtoneDuration'] ?? 60,
      synced: map['synced'] == 1,
      skippedDays: (map['skippedDays'] as String? ?? "")
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toList(),
      skippedDates: (map['skippedDates'] as String? ?? "")
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(DateTime.parse)
          .toList(),
      scheduleConfig: map['scheduleConfig'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'startDate': startDate,
    'endDate': endDate,
    'configured': configured ? 1 : 0,
    'ringtoneDuration': ringtoneDuration,
    'synced': synced ? 1 : 0,
    'skippedDays': skippedDays.join(','),
    'skippedDates': skippedDates.map((d) => d.toIso8601String()).join(','),
    'scheduleConfig': scheduleConfig,
  };
}
