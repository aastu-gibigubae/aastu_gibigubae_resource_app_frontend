// Matches the backend Department schema.
class DepartmentModel {
  final int id;
  final int streamId;
  final String name;
  final DateTime? createdAt;

  const DepartmentModel({
    required this.id,
    required this.streamId,
    required this.name,
    this.createdAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int,
      streamId: json['stream_id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
