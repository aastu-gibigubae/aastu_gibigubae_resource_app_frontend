import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/storage_keys.dart';
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
      final user = ref.read(authProvider).valueOrNull;
      final isPremium = user?.isPremium ?? false;
      if (mounted) {
        if (isPremium) {
          context.go(RouteNames.home);
        } else {
          final prefs = ref.read(sharedPreferencesProvider);
          final selectionCompleted =
              prefs.getBool(StorageKeys.selectionCompleted) ?? false;
          final exploreSeen = prefs.getBool(StorageKeys.exploreSeen) ?? false;
          final paymentSeen = prefs.getBool(StorageKeys.paymentSeen) ?? false;

          if (!selectionCompleted) {
            context.go(RouteNames.selection);
          } else if (!exploreSeen && !paymentSeen) {
            context.go(RouteNames.exploreResources);
          } else {
            context.go(RouteNames.home);
          }
        }
      }
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
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.error_outline,
                                color: Color(0xFFDC2626), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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

                  const SizedBox(height: 20),

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
