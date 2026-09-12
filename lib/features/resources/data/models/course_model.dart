// Matches the backend Course schema.
class CourseModel {
  final int id;
  final int departmentId;
  final int academicYear;
  final String name;
  final DateTime? createdAt;

  const CourseModel({
    required this.id,
    required this.departmentId,
    required this.academicYear,
    required this.name,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      departmentId: json['department_id'] as int,
      academicYear: json['academic_year'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
