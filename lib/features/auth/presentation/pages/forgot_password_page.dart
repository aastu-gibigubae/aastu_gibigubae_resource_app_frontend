import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSuccessCard = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email.';
        _showSuccessCard = false;
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
        _showSuccessCard = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showSuccessCard = false;
    });

    final error = await ref.read(authProvider.notifier).forgotPassword(
          email: email,
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
                              SizedBox(height: (isSmall ? 16 : 24) * scale),
                              Text(
                                'Email',
                                style: TextStyle(
                                  color: AuthColors.primary,
                                  fontSize: (isSmall ? 22 : 28) * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: (isSmall ? 14 : 20) * scale),
                              Center(
                                child: AuthTextField(
                                  controller: _emailController,
                                  hint: 'Enter your email:',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
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
                                    : _buildSubmitButton(scale, isSmall),
                              ),
                              if (_showSuccessCard) ...[
                                SizedBox(height: 28 * scale),
                                _buildSuccessCard(scale, isSmall),
                              ],
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
                'Forgot Password',
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

  Widget _buildSubmitButton(double scale, bool isSmall) {
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
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontSize: (isSmall ? 22 : 28) * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard(double scale, bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        32 * scale,
        20 * scale,
        28 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88 * scale,
            height: 88 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFF3D6ACC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.email_outlined,
              color: Colors.white,
              size: 48 * scale,
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            'Check your email',
            style: TextStyle(
              color: AuthColors.primary,
              fontSize: (isSmall ? 24 : 32) * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: Text(
              'We sent a password reset link to ${_emailController.text.trim()}. Open the email and tap the link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AuthColors.hint,
                fontSize: (isSmall ? 15 : 19) * scale,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 28 * scale),
          SizedBox(
            width: double.infinity,
            height: (isSmall ? 44 : 52) * scale,
            child: ElevatedButton(
              onPressed: () => context.go(RouteNames.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D6ACC),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28 * scale),
                ),
              ),
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (isSmall ? 18 : 24) * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          SizedBox(
            width: double.infinity,
            height: (isSmall ? 44 : 52) * scale,
            child: TextButton(
              onPressed: _submit,
              style: TextButton.styleFrom(
                foregroundColor: AuthColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28 * scale),
                ),
              ),
              child: Text(
                'Resend email',
                style: TextStyle(
                  color: AuthColors.primary,
                  fontSize: (isSmall ? 16 : 20) * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
