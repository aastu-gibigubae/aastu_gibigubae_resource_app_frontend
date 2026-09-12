// Matches the backend Notification schema.
class NotificationModel {
  final int id;
  final String type;
  final String message;
  final bool readStatus;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.readStatus,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      readStatus: json['read_status'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
