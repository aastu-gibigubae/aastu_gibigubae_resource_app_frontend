import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });

  // Creates a NotificationItem from the backend Notification schema.
  // The backend provides type/message/read_status/created_at; we derive
  // title, icon, and color from the notification type.
  factory NotificationItem.fromBackend({
    required int id,
    required String type,
    required String message,
    required bool readStatus,
    DateTime? createdAt,
  }) {
    final (title, icon, color) = _typeToUi(type);
    return NotificationItem(
      id: id.toString(),
      title: title,
      message: message,
      timestamp: _formatTimestamp(createdAt),
      icon: icon,
      iconColor: color,
      isRead: readStatus,
    );
  }

  static (String, IconData, Color) _typeToUi(String type) {
    switch (type) {
      case 'premium_approved':
        return (
          'Premium Approved',
          Icons.verified_rounded,
          const Color(0xFF10B981),
        );
      case 'issue_report_addressed':
        return (
          'Report Addressed',
          Icons.check_circle_rounded,
          const Color(0xFF3B82F6),
        );
      case 'subscription_expiring':
        return (
          'Subscription Expiring',
          Icons.warning_amber_rounded,
          const Color(0xFFF59E0B),
        );
      default:
        return (
          'Notification',
          Icons.notifications_rounded,
          const Color(0xFF6B7280),
        );
    }
  }

  static String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
