class CategoryModel {
  final int? id;
  final String name;
  final int color;
  final String startDate;
  final String endDate;
  final bool configured;

  CategoryModel({
    this.id,
    required this.name,
    required this.color,
    required this.startDate,
    required this.endDate,
    this.configured = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'startDate': startDate,
    'endDate': endDate,
    'configured': configured ? 1 : 0,
  };
}
