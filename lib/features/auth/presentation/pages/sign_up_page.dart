import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _rememberMe = prefs.getBool(StorageKeys.rememberMe) ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Sign up ────────────────────────────────────────────────────

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      setState(() =>
          _errorMessage = 'Please fill in all required fields including phone.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (password.length < 8) {
      setState(() =>
          _errorMessage = 'Password must be at least 8 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref.read(authProvider.notifier).signup(
          name: name,
          email: email,
          password: password,
          phone: phone,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    } else {
      final prefs = ref.read(sharedPreferencesProvider);
      if (_rememberMe) {
        await prefs.setBool(StorageKeys.rememberMe, true);
        await prefs.setString(StorageKeys.savedEmail, email);
      } else {
        await prefs.setBool(StorageKeys.rememberMe, false);
        await prefs.remove(StorageKeys.savedEmail);
      }
      if (!mounted) return;
      context.go(RouteNames.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top space ────────────────────────────────────────
              const SizedBox(height: 285),

              // ── Title ────────────────────────────────────────────
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: AuthColors.primary,
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 4),

              // ── Subtitle ─────────────────────────────────────────
              const Text(
                'Please register to continue',
                style: TextStyle(
                  color: AuthColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // ── Error message ────────────────────────────────────
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_errorMessage!
                                .toLowerCase()
                                .contains('already exists')) ...[
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => context.go(RouteNames.login),
                                child: const Text(
                                  'Tap here to Log In instead →',
                                  style: TextStyle(
                                    color: Color(0xFFB45309),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Name ─────────────────────────────────────────────
              AuthTextField(
                controller: _nameController,
                hint: 'Name:',
                icon: Icons.person,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────────
              AuthTextField(
                controller: _emailController,
                hint: 'Email:',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // ── Password ─────────────────────────────────────────
              AuthTextField(
                controller: _passwordController,
                hint: 'Password:',
                icon: Icons.lock,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                suffixIcon: AuthPasswordButton(
                  obscure: _obscurePassword,
                  onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 16),

              // ── Phone ─────────────────────────────────────────────
              AuthTextField(
                controller: _phoneController,
                hint: 'Phone Number (e.g. +251912345678):',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 42),

              AuthRememberMe(
                value: _rememberMe,
                onChanged: (v) {
                  setState(() => _rememberMe = v);
                  final prefs = ref.read(sharedPreferencesProvider);
                  prefs.setBool(StorageKeys.rememberMe, v);
                  if (!v) {
                    prefs.remove(StorageKeys.savedEmail);
                  }
                },
              ),

              const SizedBox(height: 44),

              // ── Sign up button ────────────────────────────────────
              Center(
                child: SizedBox(
                  width: 376,
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text(
                              'Connecting to server (waking up)…',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      : AuthButton(
                          text: 'Sign Up',
                          onPressed: _signUp,
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Login link ───────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => context.go(RouteNames.login),
                  child: const Text(
                    'Already have an account? Log In',
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

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
