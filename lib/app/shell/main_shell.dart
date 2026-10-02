import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sync/sync_service.dart';
import '../../core/widgets/full_screen_loading_overlay.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/device/providers/device_status_provider.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';

/// ================================================================
/// MAIN SHELL
///
/// Persistent scaffold that wraps all bottom-nav tab screens.
/// [StatefulNavigationShell] from go_router keeps each branch's
/// page stack alive when you switch tabs.
///
/// Device gate: if the heartbeat returns device_mismatch or revoked,
/// a full-screen overlay blocks all content and forces the user to
/// either use their registered device or log out.
/// ================================================================

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  // ── Tab routes (must match branch order in router) ─────────────
  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, unselectedIcon: Icons.home_outlined, label: 'Home'),
    _TabItem(icon: Icons.search_rounded, unselectedIcon: Icons.search, label: 'Browse'),
    _TabItem(icon: Icons.check_circle_rounded, unselectedIcon: Icons.check_circle_outline, label: 'Status'),
    _TabItem(icon: Icons.person_rounded, unselectedIcon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncServiceProvider);
    final deviceAsync = ref.watch(deviceStatusProvider);

    final shell = Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        tabs: _tabs,
        onTap: _onTap,
      ),
    );

    // Check for blocking device states once the status has loaded.
    return deviceAsync.when(
      data: (deviceData) {
        final isBlocked = deviceData.status == DeviceStatusState.mismatch ||
            deviceData.status == DeviceStatusState.revoked;

        if (!isBlocked) return shell;

        // Full-screen blocking gate — overlaid on top of the shell so
        // the user cannot access any tab content.
        return Stack(
          children: [
            // Blur the shell underneath.
            IgnorePointer(child: Opacity(opacity: 0.15, child: shell)),
            _DeviceMismatchGate(
              deviceData: deviceData,
              onLogout: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
          ],
        );
      },
      // While loading or on error, show the shell normally —
      // do not block the user on transient network issues.
      loading: () => shell,
      error: (_, _) => shell,
    );
  }
}

// ── Device Mismatch Gate ──────────────────────────────────────────

class _DeviceMismatchGate extends StatefulWidget {
  final DeviceStatusData deviceData;
  final Future<void> Function() onLogout;

  const _DeviceMismatchGate({
    required this.deviceData,
    required this.onLogout,
  });

  @override
  State<_DeviceMismatchGate> createState() => _DeviceMismatchGateState();
}

class _DeviceMismatchGateState extends State<_DeviceMismatchGate> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await widget.onLogout();
    } catch (_) {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMismatch = widget.deviceData.status == DeviceStatusState.mismatch;

    return Stack(
      children: [
        Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
                  ),
                  child: Icon(
                    isMismatch
                        ? Icons.devices_other_rounded
                        : Icons.block_rounded,
                    size: 48,
                    color: const Color(0xFFDC2626),
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  isMismatch ? 'Wrong Device' : 'Access Revoked',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),

                const SizedBox(height: 12),

                // Body
                Text(
                  isMismatch
                      ? 'This account is registered on a different device.\n\n'
                          'Premium access is tied to a single device. Please '
                          'log in from your registered device, or contact support '
                          'to transfer your subscription.'
                      : widget.deviceData.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 36),

                // Log out button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Support hint
                const Text(
                  'Need help? Contact support@aastugibigubae.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    if (_isLoggingOut)
      const FullScreenLoadingOverlay(
        title: 'Logging out...',
        subtitle: 'Please wait a moment',
      ),
  ],
);
  }
}

// ── Bottom bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _BottomBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomInset > 0 ? bottomInset : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final active = i == currentIndex;
          final tab = tabs[i];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? tab.icon : tab.unselectedIcon,
                    size: 26,
                    color: active ? AppColors.primary : const Color(0xFF888888),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? AppColors.primary : const Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Active dot
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData unselectedIcon;
  final String label;
  const _TabItem({
    required this.icon,
    required this.unselectedIcon,
    required this.label,
  });
}
