import 'package:flutter/material.dart';

class AuthColors {
  static const Color primary = Color(0xFF0B2D6B);
  static const Color field = Color(0xFFECECEC);
  static const Color fieldBorder = Color(0xFFC7C7C7);
  static const Color hint = Color(0xFF8195B6);
  static const Color icon = Color(0xFFA9B8CF);
  static const Color outline = Color(0xFFB7B7B7);
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
    return Scaffold(
      backgroundColor: Colors.white,

      // Background NEVER moves when keyboard opens.
      resizeToAvoidBottomInset: false,

      body: Stack(
        fit: StackFit.expand,
        children: [

          /// WHITE BACKGROUND
          const ColoredBox(
            color: Colors.white,
          ),

          /// NAVY TOP CURVE
          const Positioned.fill(
            child: ClipPath(
              clipper: AuthTopCurveClipper(),
              child: ColoredBox(
                color: AuthColors.primary,
              ),
            ),
          ),

          /// BOTTOM RIGHT OUTLINE
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

          /// CONTENT
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// TOP NAVY CURVE
/// ===============================================================

class AuthTopCurveClipper extends CustomClipper<Path> {
  const AuthTopCurveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);

    path.lineTo(size.width, 0);

    path.lineTo(
      size.width,
      285,
    );

    path.cubicTo(
      size.width * 0.70,
      255,
      size.width * 0.45,
      205,
      size.width * 0.28,
      190,
    );

    path.cubicTo(
      size.width * 0.18,
      181,
      size.width * 0.08,
      185,
      0,
      295,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) {
    return false;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.only(
            bottom: 40,
          ),

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
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

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,

      decoration: BoxDecoration(
        color: AuthColors.field,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AuthColors.fieldBorder,
          width: 2,
        ),
      ),

      child: TextField(
        controller: controller,

        obscureText: obscureText,

        keyboardType: keyboardType,

        textInputAction: textInputAction,

        textAlignVertical: TextAlignVertical.center,

        style: const TextStyle(
          color: AuthColors.hint,
          fontSize: 10,
          fontWeight: FontWeight.w100,
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
            size: 20,
          ),

          prefixIconConstraints:
              const BoxConstraints(
            minWidth: 42,
            minHeight: 60,
          ),

          suffixIcon: suffixIcon,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 8,
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
        minWidth: 45,
        minHeight: 50,
      ),

      icon: Icon(
        obscure
            ? Icons.visibility_off
            : Icons.visibility,
        color: const Color(0xFFA8A8A8),
        size: 20,
      ),
    );
  }
}

/// ===============================================================
/// REMEMBER ME
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
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        const Text(
          'Remember me',
          style: TextStyle(
            color: AuthColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        GestureDetector(
          onTap: () {
            onChanged(!value);
          },

          child: Container(
            width: 38,
            height: 22,

            padding:
                const EdgeInsets.all(3),

            decoration: BoxDecoration(
              color: value
                  ? AuthColors.primary
                  : const Color(0xFFD0D0D0),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: AnimatedAlign(
              duration:
                  const Duration(
                milliseconds: 180,
              ),

              alignment: value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,

              child: Container(
                width: 21,
                height: 21,

                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// AUTH BUTTON
/// ===============================================================

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 34,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor:
              AuthColors.primary,

          foregroundColor: Colors.white,

          elevation: 0,

          padding: EdgeInsets.zero,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        child: Text(
          text,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}