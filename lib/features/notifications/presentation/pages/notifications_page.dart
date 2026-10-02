import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CurvedHeader(
            showBackButton: true,
            title: 'Notifications',
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No notifications yet.',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(notificationsProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    itemCount: notifications.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 20),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.mail_outline_rounded,
                                color: Color(0xFF9CA3AF),
                                size: 34,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "That's everything — no email or push, just this list",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final notification = notifications[index];
                      return GestureDetector(
                        onTap: () {
                          if (!notification.isRead) {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(
                                    int.parse(notification.id));
                          }
                        },
                        child: NotificationTile(
                            notification: notification),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load notifications.\n$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(notificationsProvider.notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
