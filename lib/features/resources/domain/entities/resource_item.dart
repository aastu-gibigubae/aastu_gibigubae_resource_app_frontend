import 'resource_category_type.dart';

class ResourceItem {
  final int id;
  final int courseId;
  final String title;
  final String? description;
  final ResourceCategoryType category;
  final bool isFreeSample;
  final bool locked;
  final String? reasonCode;
  final String? message;
  final String? fileUrl;
  final int fileSizeBytes;
  final String? checksum;
  final String courseName;
  final String semester;
  final int academicYear;

  const ResourceItem({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.category,
    this.isFreeSample = false,
    this.locked = false,
    this.reasonCode,
    this.message,
    this.fileUrl,
    this.fileSizeBytes = 2516582,
    this.checksum,
    this.courseName = '',
    this.semester = 'Semester 1',
    this.academicYear = 1,
  });

  String get formattedSize {
    if (fileSizeBytes <= 0) return 'PDF';
    final mb = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
    return 'PDF ${mb}MB';
  }
}
