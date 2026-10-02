import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/full_screen_loading_overlay.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _userDept = 'Not selected';
  String _userYear = 'Not selected';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  Future<void> _loadSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedYear = prefs.getInt('selected_academic_year');
      final savedField = prefs.getString('selected_field');
      if (mounted) {
        setState(() {
          if (savedYear != null) {
            _userYear = 'Year $savedYear';
          }
          if (savedField != null && savedField.isNotEmpty) {
            _userDept = savedField;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoggingOut = true);
      try {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          context.go(RouteNames.login);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoggingOut = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ErrorMapper.userMessage(
                  e,
                  defaultMessage: 'Logout failed. Please try again.',
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    final userName = (user?.name != null && user!.name.isNotEmpty)
        ? user.name
        : 'Abebe Kebede';
    final userEmail = (user?.email != null && user!.email.isNotEmpty)
        ? user.email
        : 'abebekebede@gmail.com';
    final userPhone = (user?.phone != null && user!.phone!.isNotEmpty)
        ? user.phone!
        : '0912345678';
    final userDept = _userDept;
    final userYear = _userYear;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Navy Curved Header matching image copy 20.png
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      12,
                      MediaQuery.of(context).padding.top + 12,
                      24,
                      54,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RouteNames.home);
                            }
                          },
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

              // Overlapping Avatar and Card Structure
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // User Card with integrated top Avatar
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // White Card
                          Container(
                            width: double.infinity,
                            margin: const Offset(0, 48).dx == 0
                                ? const EdgeInsets.only(top: 48)
                                : EdgeInsets.zero,
                            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(6),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Full Name
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Email
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Detail row 1: Phone
                                _buildProfileDetailRow(
                                  icon: Icons.phone_outlined,
                                  value: userPhone,
                                ),

                                const SizedBox(height: 18),

                                // Detail row 2: Department
                                _buildProfileDetailRow(
                                  icon: Icons.school_outlined,
                                  value: userDept,
                                ),

                                const SizedBox(height: 18),

                                // Detail row 3: Year
                                _buildProfileDetailRow(
                                  icon: Icons.calendar_today_outlined,
                                  value: userYear,
                                ),
                              ],
                            ),
                          ),

                          // Top Centered Circular Avatar
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Red Outlined Log Out Button matching image copy 20.png
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isLoggingOut ? null : _logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFDC2626),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      if (_isLoggingOut)
        const FullScreenLoadingOverlay(
          title: 'Logging out...',
          subtitle: 'Please wait a moment',
        ),
    ],
  ),
);
}

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF0F172A),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
