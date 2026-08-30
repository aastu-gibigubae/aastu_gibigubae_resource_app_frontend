import 'package:flutter/material.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../data/datasources/mock_notifications_datasource.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const notifications = MockNotificationsDatasource.notifications;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CurvedHeader(
            title: 'Notifications',
            subtitle: 'Updates & Announcements',
            subtitleColor: Color(0xFFF59E0B),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return NotificationTile(notification: notifications[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
