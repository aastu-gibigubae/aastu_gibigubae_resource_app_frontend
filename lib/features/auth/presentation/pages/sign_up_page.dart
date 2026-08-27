import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
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

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() =>
          _errorMessage = 'Please fill in all required fields.');
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
          phone: phone.isEmpty ? null : phone,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    } else {
      context.go(RouteNames.home);
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
                hint: 'Phone Number:',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 42),

              // ── Remember me ──────────────────────────────────────
              AuthRememberMe(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v),
              ),

              const SizedBox(height: 44),

              // ── Sign up button ────────────────────────────────────
              Center(
                child: SizedBox(
                  width: 376,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
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
