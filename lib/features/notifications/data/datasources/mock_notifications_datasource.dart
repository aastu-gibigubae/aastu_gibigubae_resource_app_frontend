import 'package:flutter/material.dart';
import '../../domain/entities/notification_item.dart';

class MockNotificationsDatasource {
  const MockNotificationsDatasource();

  static const List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Premium Approved',
      message:
          'Your payment has been verified and premium access is activated for 12 months.',
      timestamp: '2 hours ago',
      icon: Icons.verified_rounded,
      iconColor: Color(0xFF10B981),
    ),
    NotificationItem(
      id: '2',
      title: 'New Midterm Exams Added',
      message: 'Midterm 2023 solved exam uploaded for Communicative English I.',
      timestamp: '1 day ago',
      icon: Icons.auto_stories_rounded,
      iconColor: Color(0xFF3B82F6),
    ),
    NotificationItem(
      id: '3',
      title: 'Welcome to Resource Hub',
      message:
          'Explore your freshman courses and download lecture handouts offline.',
      timestamp: '3 days ago',
      icon: Icons.celebration_rounded,
      iconColor: Color(0xFFF59E0B),
    ),
  ];
}
