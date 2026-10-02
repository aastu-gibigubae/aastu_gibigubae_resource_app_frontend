import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? token;

  const ResetPasswordPage({
    super.key,
    this.token,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSuccessCard = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your new password.';
        _showSuccessCard = false;
      });
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters long.';
        _showSuccessCard = false;
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your new password.';
        _showSuccessCard = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match. Please try again.';
        _showSuccessCard = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showSuccessCard = false;
    });

    final error = await ref.read(authProvider.notifier).resetPassword(
          token: widget.token,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (error != null) {
        _errorMessage = error;
        _showSuccessCard = false;
      } else {
        _errorMessage = null;
        _showSuccessCard = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final scale = (width / 390).clamp(0.80, 1.15);
    final isSmall = height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(
            color: Colors.white,
          ),
          Positioned(
            right: -285 * scale,
            bottom: -215 * scale,
            child: IgnorePointer(
              child: Container(
                width: 400 * scale,
                height: 400 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AuthColors.outline,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(scale, isSmall),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                            horizontal: 30 * scale),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.token == null || widget.token!.isEmpty) ...[
                                SizedBox(height: (isSmall ? 8 : 12) * scale),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14 * scale,
                                    vertical: 12 * scale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange.shade800,
                                        size: 22 * scale,
                                      ),
                                      SizedBox(width: 10 * scale),
                                      Expanded(
                                        child: Text(
                                          'Please open the password reset link from your email. This page needs a valid token to complete the reset.',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 13 * scale,
                                            fontWeight: FontWeight.w500,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(height: (isSmall ? 16 : 24) * scale),
                              Text(
                                'New Password',
                                style: TextStyle(
                                  color: AuthColors.primary,
                                  fontSize: (isSmall ? 22 : 28) * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: (isSmall ? 14 : 20) * scale),
                              Center(
                                child: AuthTextField(
                                  controller: _newPasswordController,
                                  hint: 'Enter your new password:',
                                  icon: Icons.lock,
                                  obscureText: _obscureNewPassword,
                                  suffixIcon: AuthPasswordButton(
                                    obscure: _obscureNewPassword,
                                    onPressed: () => setState(() =>
                                        _obscureNewPassword =
                                            !_obscureNewPassword),
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              SizedBox(height: (isSmall ? 20 : 32) * scale),
                              Text(
                                'Confirm New Password',
                                style: TextStyle(
                                  color: AuthColors.primary,
                                  fontSize: (isSmall ? 22 : 28) * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: (isSmall ? 14 : 20) * scale),
                              Center(
                                child: AuthTextField(
                                  controller: _confirmPasswordController,
                                  hint: 'RE-enter your new password:',
                                  icon: Icons.lock,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: AuthPasswordButton(
                                    obscure: _obscureConfirmPassword,
                                    onPressed: () => setState(() =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword),
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                SizedBox(height: 16 * scale),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13 * scale,
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: (isSmall ? 20 : 28) * scale),
                              Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : _showSuccessCard
                                        ? _buildSuccessButton(scale, isSmall)
                                        : _buildResetButton(scale, isSmall),
                              ),
                              SizedBox(height: 20 * scale),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale, bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        8 * scale,
        (isSmall ? 8 : 16) * scale,
        16 * scale,
        (isSmall ? 22 : 36) * scale,
      ),
      decoration: BoxDecoration(
        color: AuthColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40 * scale),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.login);
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 32 * scale,
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Reset Your Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isSmall ? 26 : 34) * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(double scale, bool isSmall) {
    return SizedBox(
      width: double.infinity,
      height: (isSmall ? 48 : 56) * scale,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28 * scale),
          ),
        ),
        child: Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: (isSmall ? 20 : 26) * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessButton(double scale, bool isSmall) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: (isSmall ? 48 : 56) * scale,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28 * scale),
              ),
            ),
            child: Text(
              'Go to Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: (isSmall ? 20 : 26) * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Password reset successful!',
          style: TextStyle(
            color: Colors.green.shade700,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
