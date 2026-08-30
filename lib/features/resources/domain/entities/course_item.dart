class CourseItem {
  final int id;
  final int streamId;
  final int departmentId;
  final String name;
  final int academicYear;
  final String semester;
  final int resourceCount;
  final String iconKey;

  const CourseItem({
    required this.id,
    required this.streamId,
    required this.departmentId,
    required this.name,
    required this.academicYear,
    required this.semester,
    required this.resourceCount,
    this.iconKey = 'book',
  });
}
