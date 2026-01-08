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

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      configured: map['configured'] == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'startDate': startDate,
    'endDate': endDate,
    'configured': configured ? 1 : 0,
  };
}
