import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ================================================================
/// MAIN SHELL
///
/// Persistent scaffold that wraps all bottom-nav tab screens.
/// [StatefulNavigationShell] from go_router keeps each branch's
/// page stack alive when you switch tabs.
/// ================================================================

const _kBg = Color(0xFFFDF6EE);
const _kActive = Color(0xFF1A1A1A);
const _kInactive = Color(0xFF888888);
const _kDivider = Color(0xFFEEEEEE);

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  // ── Tab routes (must match branch order in router) ─────────────
  static const _tabs = [
    _TabItem(icon: Icons.explore_outlined,              label: 'Explore'),
    _TabItem(icon: Icons.map_outlined,                  label: 'Map'),
    _TabItem(icon: Icons.confirmation_number_outlined,  label: 'Coupons'),
    _TabItem(icon: Icons.person_rounded,                label: 'Profile'),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Return to the branch's initial location when re-tapping
      // the active tab (mirrors standard app behaviour).
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kDivider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final active = i == currentIndex;
          final tab = tabs[i];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 26,
                    color: active ? _kActive : _kInactive,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? _kActive : _kInactive,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Active dot
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? _kActive : Colors.transparent,
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
  final String label;
  const _TabItem({required this.icon, required this.label});
}
