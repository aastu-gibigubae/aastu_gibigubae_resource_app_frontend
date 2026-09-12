import '../../domain/entities/resource_category_type.dart';

// Matches the backend StudentResourceView schema.
// Access state is decided server-side: locked resources have reason_code/message,
// unlocked resources have file_url/file_size_bytes/checksum.
class StudentResourceModel {
  final int id;
  final String title;
  final String? description;
  final String category;
  final bool isFreeSample;
  final bool locked;
  final String? reasonCode;
  final String? message;
  final String? fileUrl;
  final int? fileSizeBytes;
  final String? checksum;

  const StudentResourceModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.isFreeSample,
    required this.locked,
    this.reasonCode,
    this.message,
    this.fileUrl,
    this.fileSizeBytes,
    this.checksum,
  });

  factory StudentResourceModel.fromJson(Map<String, dynamic> json) {
    return StudentResourceModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      isFreeSample: json['is_free_sample'] as bool? ?? false,
      locked: json['locked'] as bool? ?? true,
      reasonCode: json['reason_code'] as String?,
      message: json['message'] as String?,
      fileUrl: json['file_url'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      checksum: json['checksum'] as String?,
    );
  }

  ResourceCategoryType get categoryType =>
      ResourceCategoryType.fromString(category);
}
