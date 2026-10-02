import 'package:flutter/material.dart';

class AuthColors {
  static const Color primary = Color(0xFF0B254E);
  static const Color field = Color(0xFFEBECEF);
  static const Color fieldBorder = Color(0xFFD1D5DB);
  static const Color hint = Color(0xFF8195B6);
  static const Color icon = Color(0xFF8195B6);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color text = Color(0xFF0F172A);
}

/// ===============================================================
/// SHARED AUTH BACKGROUND
/// ===============================================================

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            /// WHITE BACKGROUND
            const ColoredBox(
              color: Colors.white,
            ),

            /// BOTTOM RIGHT OUTLINE (matches Figma image copy 2 and 3)
            Positioned(
              right: -285,
              bottom: -215,
              child: IgnorePointer(
                child: Container(
                  width: 400,
                  height: 400,
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

            /// SCROLLABLE CONTENT (contains AuthTopCurve at top so text never scrolls over it)
            child,
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// TOP NAVY CURVE
/// ===============================================================

class AuthTopCurveClipper extends CustomClipper<Path> {
  final double topPadding;

  const AuthTopCurveClipper({this.topPadding = 0});

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, 240 + topPadding);

    path.cubicTo(
      size.width * 0.70,
      210 + topPadding,
      size.width * 0.45,
      165 + topPadding,
      size.width * 0.28,
      150 + topPadding,
    );

    path.cubicTo(
      size.width * 0.18,
      142 + topPadding,
      size.width * 0.08,
      146 + topPadding,
      0,
      250 + topPadding,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant AuthTopCurveClipper oldClipper) =>
      oldClipper.topPadding != topPadding;
}

class AuthTopCurve extends StatelessWidget {
  const AuthTopCurve({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = 255.0 + topPadding;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: ClipPath(
        clipper: AuthTopCurveClipper(topPadding: topPadding),
        child: const ColoredBox(
          color: AuthColors.primary,
        ),
      ),
    );
  }
}

/// ===============================================================
/// AUTH SCROLL VIEW
/// ===============================================================

class AuthScrollView extends StatelessWidget {
  final Widget child;

  const AuthScrollView({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthTopCurve(),
          child,
        ],
      ),
    );
  }
}

/// ===============================================================
/// AUTH TEXT FIELD
/// ===============================================================

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  final bool obscureText;
  final Widget? suffixIcon;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets scrollPadding;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
    this.scrollPadding = const EdgeInsets.only(bottom: 120),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AuthColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AuthColors.fieldBorder,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        scrollPadding: scrollPadding,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: AuthColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(
            color: AuthColors.hint,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: AuthColors.icon,
            size: 22,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 52,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// PASSWORD VISIBILITY BUTTON
/// ===============================================================

class AuthPasswordButton extends StatelessWidget {
  final bool obscure;
  final VoidCallback onPressed;

  const AuthPasswordButton({
    super.key,
    required this.obscure,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 46,
        minHeight: 52,
      ),
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AuthColors.icon,
        size: 22,
      ),
    );
  }
}

/// ===============================================================
/// REMEMBER ME (Matches Figma Toggle Switch)
/// ===============================================================

class AuthRememberMe extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AuthRememberMe({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Remember me',
            style: TextStyle(
              color: AuthColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 44,
            height: 24,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: value ? AuthColors.primary : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// AUTH BUTTON
/// ===============================================================

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 185,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AuthColors.primary,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}