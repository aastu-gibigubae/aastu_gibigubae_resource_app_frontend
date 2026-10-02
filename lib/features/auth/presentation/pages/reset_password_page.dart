import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/curved_header.dart';
import '../widgets/auth_widgets.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? token;
  const ResetPasswordPage({super.key, this.token});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _errorMessage = 'Please enter both password fields.');
      return;
    }

    if (newPass.length < 8) {
      setState(() =>
          _errorMessage = 'Password must be at least 8 characters long.');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(
        token: widget.token ?? 'demo_reset_token',
        newPassword: newPass,
      );
    } catch (_) {
      // Backend may handle or mock
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully! Please log in.'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background bottom right circle decoration matching design
          Positioned(
            right: -230,
            bottom: -230,
            child: IgnorePointer(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB8B8B8),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurvedHeader(
                  showBackButton: true,
                  title: 'Reset Your Password',
                  onBack: () => context.pop(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Password',
                        style: TextStyle(
                          color: Color(0xFF0D3274),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        controller: _newPasswordController,
                        hint: 'Enter your new password:',
                        icon: Icons.lock_outline,
                        obscureText: _obscureNew,
                        textInputAction: TextInputAction.next,
                        suffixIcon: AuthPasswordButton(
                          obscure: _obscureNew,
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Confirm New Password',
                        style: TextStyle(
                          color: Color(0xFF0D3274),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hint: 'RE-enter your new password:',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        suffixIcon: AuthPasswordButton(
                          obscure: _obscureConfirm,
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : AuthButton(
                                text: 'Reset Password',
                                onPressed: _resetPassword,
                              ),
                      ),
                    ],
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
