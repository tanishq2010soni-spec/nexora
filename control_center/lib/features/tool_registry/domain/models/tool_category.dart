class ToolCategory {
  final String name;
  final int count;

  const ToolCategory({
    required this.name,
    this.count = 0,
  });

  factory ToolCategory.fromJson(Map<String, dynamic> json) => ToolCategory(
    name: json['name'] as String,
    count: json['count'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'count': count,
  };
}
