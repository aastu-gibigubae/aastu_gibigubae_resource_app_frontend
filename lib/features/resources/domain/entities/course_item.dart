class CourseItem {
  final int id;
  final int departmentId;
  final String name;
  final int academicYear;
  final String iconKey;

  const CourseItem({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.academicYear,
    this.iconKey = 'book',
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'] as int,
      departmentId: json['department_id'] as int,
      name: json['name'] as String,
      academicYear: json['academic_year'] as int,
    );
  }

  // Derived semester label based on academic year.
  String get semester => 'Year $academicYear';
}
