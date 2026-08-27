import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Login ──────────────────────────────────────────────────────

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    } else {
      context.go(RouteNames.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 280),

                  // ── Title ────────────────────────────────────────
                  const Text(
                    'Log In',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      height: 0.95,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Subtitle ─────────────────────────────────────
                  const Text(
                    'Please log in to continue',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Error message ────────────────────────────────
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Email ────────────────────────────────────────
                  Center(
                    child: AuthTextField(
                      controller: _emailController,
                      hint: 'Email:',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Password ─────────────────────────────────────
                  Center(
                    child: AuthTextField(
                      controller: _passwordController,
                      hint: 'Password:',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: AuthPasswordButton(
                        obscure: _obscurePassword,
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  // ── Forgot password ──────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: implement forgot password
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Color(0xFFD99B14),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD99B14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Remember me ──────────────────────────────────
                  AuthRememberMe(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v),
                  ),

                  const SizedBox(height: 44),

                  // ── Login button ─────────────────────────────────
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : AuthButton(
                            text: 'Log In',
                            onPressed: _login,
                          ),
                  ),

                  const SizedBox(height: 20),

                  // ── Sign up link ─────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(RouteNames.signup),
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Color(0xFFD99B14),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFD99B14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
