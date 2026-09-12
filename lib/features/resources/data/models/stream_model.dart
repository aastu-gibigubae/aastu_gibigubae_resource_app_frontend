// Matches the backend Stream schema.
class StreamModel {
  final int id;
  final String name;
  final DateTime? createdAt;

  const StreamModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
