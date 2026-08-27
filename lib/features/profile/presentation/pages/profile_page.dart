import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../auth/providers/auth_provider.dart';

/// ================================================================
/// PROFILE PAGE
///
/// Content only — the bottom nav bar is owned by MainShell.
/// ================================================================

// ── Design tokens ────────────────────────────────────────────────

const _kBg = Color(0xFFFDF6EE);
const _kCardBg = Colors.white;
const _kGold = Color(0xFF8B6914);
const _kGoldLight = Color(0xFFF5E6C8);
const _kTitle = Color(0xFF1A1A1A);
const _kText = Color(0xFF1A1A1A);
const _kSub = Color(0xFF888888);
const _kDivider = Color(0xFFEEEEEE);
const _kLogout = Color(0xFFD94040);
const _kToggleBg = Color(0xFFCCCCCC);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _businessMode = false;

  // ── Logout ──────────────────────────────────────────────────────

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: _kGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out',
                style: TextStyle(color: _kLogout)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go(RouteNames.login);
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);
    final userName = userAsync.valueOrNull?.name ?? 'Abebe Kebede';

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ─────────────────────────────────────────────
            const _TitleBar(),

            // ── Content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    _UserCard(userName: userName),
                    const SizedBox(height: 20),
                    _BusinessModeRow(
                      value: _businessMode,
                      onChanged: (v) =>
                          setState(() => _businessMode = v),
                    ),
                    const SizedBox(height: 20),
                    const _MenuCard(
                      items: [
                        _MenuItem(
                          icon: Icons.favorite_border_rounded,
                          label: 'Favorite',
                        ),
                        _MenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                        ),
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          label: 'About',
                        ),
                        _MenuItem(
                          icon: Icons.rate_review_outlined,
                          label: 'Reviews',
                        ),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Help',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _LogoutCard(onTap: _logout),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Title bar ─────────────────────────────────────────────────────

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: _kTitle,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final String userName;
  const _UserCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── Avatar with edit badge ───────────────────────────────
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFD0C4B0),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile_placeholder.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person,
                            size: 40, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: _kGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit,
                      color: Colors.white, size: 13),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // ── Name / role ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Member',
                  style: TextStyle(
                      fontSize: 13,
                      color: _kSub,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    // TODO: navigate to edit profile
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kGold,
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
}

// ── Business mode row ─────────────────────────────────────────────

class _BusinessModeRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BusinessModeRow({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work_outline_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Mode',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kText),
                ),
                SizedBox(height: 2),
                Text(
                  'Switch to business mode',
                  style: TextStyle(fontSize: 12, color: _kSub),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: _kGold,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: _kToggleBg,
              trackOutlineColor:
                  WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu card ─────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(
            children: [
              _MenuTile(item: items[i]),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: _kDivider,
                  indent: 64,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Menu tile ─────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kGoldLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: _kGold, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _kText,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _kSub, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Menu item data ────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});
}

// ── Logout card ───────────────────────────────────────────────────

class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: _kLogout, size: 22),
            SizedBox(width: 14),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
