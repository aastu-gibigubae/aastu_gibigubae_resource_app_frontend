class CourseItem {
  final int id;
  final int departmentId;
  final String name;
  final int academicYear;
  final String iconKey;
  final int resourceCount;
  final String? semesterLabel;

  const CourseItem({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.academicYear,
    this.iconKey = 'book',
    this.resourceCount = 16,
    this.semesterLabel,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'] as int,
      departmentId: json['department_id'] as int,
      name: json['name'] as String,
      academicYear: json['academic_year'] as int,
      iconKey: json['icon_key'] as String? ?? 'book',
      resourceCount: json['resource_count'] as int? ?? 16,
      semesterLabel: json['semester_label'] as String?,
    );
  }

  // Derived semester label: For freshman, defaults to 'Semester 1' matching Figma
  String get semester => semesterLabel ?? 'Semester 1';
}
