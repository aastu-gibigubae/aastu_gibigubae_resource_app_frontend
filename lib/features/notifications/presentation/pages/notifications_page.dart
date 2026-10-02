import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── COLLAPSIBLE HEADER ────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _NotificationsAppBarDelegate(
                topPadding: topPadding,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),

            // ── NOTIFICATIONS CONTENT ─────────────────────────────
            ...notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return [
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No notifications yet.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: () {
                                if (!notification.isRead) {
                                  ref
                                      .read(notificationsProvider.notifier)
                                      .markAsRead(int.parse(notification.id));
                                }
                              },
                              child: NotificationTile(
                                notification: notification,
                              ),
                            ),
                          );
                        },
                        childCount: notifications.length + 1,
                      ),
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
              error: (err, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            'Could not load notifications.\n${ErrorMapper.userMessage(err)}',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// COLLAPSIBLE APP BAR DELEGATE FOR NOTIFICATIONS
/// ===============================================================

class _NotificationsAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback onBack;

  _NotificationsAppBarDelegate({
    required this.topPadding,
    required this.onBack,
  });

  @override
  double get minExtent => topPadding + kToolbarHeight;

  @override
  double get maxExtent => topPadding + 130.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final delta = maxExtent - minExtent;
    final progress = (shrinkOffset / (delta <= 0 ? 1 : delta)).clamp(0.0, 1.0);

    final collapsedOpacity = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final expandedOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
    final cornerRadius = (1.0 - progress) * 32.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(cornerRadius),
        ),
        boxShadow: progress > 0.8
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── EXPANDED LARGE TITLE ───────────────────────────────
          if (expandedOpacity > 0.0)
            Positioned(
              top: topPadding + 52,
              left: 20,
              right: 20,
              child: Opacity(
                opacity: expandedOpacity,
                child: const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

          // ── PINNED TOP BAR (Back icon + Notifications text) ───
          Positioned(
            top: topPadding,
            left: 8,
            right: 16,
            height: kToolbarHeight,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onBack,
                ),
                const SizedBox(width: 4),
                if (collapsedOpacity > 0.0)
                  Opacity(
                    opacity: collapsedOpacity,
                    child: const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _NotificationsAppBarDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding;
  }
}
