import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// ================================================================
/// MAIN SHELL
///
/// Persistent scaffold that wraps all bottom-nav tab screens.
/// [StatefulNavigationShell] from go_router keeps each branch's
/// page stack alive when you switch tabs.
/// ================================================================

class MainShell extends StatelessWidget {
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
    _TabItem(icon: Icons.notifications_rounded, unselectedIcon: Icons.notifications_none_rounded, label: 'Notifications'),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        tabs: _tabs,
        onTap: _onTap,
      ),
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
