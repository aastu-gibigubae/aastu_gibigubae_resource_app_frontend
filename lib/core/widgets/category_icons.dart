import 'package:flutter/material.dart';
import '../../features/resources/domain/entities/resource_category_type.dart';

class CategoryIconBadge extends StatelessWidget {
  final ResourceCategoryType category;
  final double size;

  const CategoryIconBadge({
    super.key,
    required this.category,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case ResourceCategoryType.handouts:
        return _buildHandoutsBadge(size);
      case ResourceCategoryType.ppts:
        return _buildPptsBadge(size);
      case ResourceCategoryType.midterms:
        return _buildMidtermsBadge(size);
      case ResourceCategoryType.assignments:
        return _buildAssignmentsBadge(size);
      case ResourceCategoryType.finals:
        return _buildFinalsBadge(size);
      case ResourceCategoryType.modules:
        return _buildModulesBadge(size);
    }
  }

  static Widget _buildContainer({
    required double size,
    required Color bgColor,
    required Widget child,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  static Widget _buildHandoutsBadge(double size) {
    return _buildContainer(
      size: size,
      bgColor: const Color(0xFFF3F7FF),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.folder, color: const Color(0xFFF59E0B), size: size * 0.65),
          Positioned(
            bottom: size * 0.12,
            right: size * 0.12,
            child: Container(
              padding: EdgeInsets.all(size * 0.04),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward,
                color: Colors.white,
                size: size * 0.28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPptsBadge(double size) {
    return _buildContainer(
      size: size,
      bgColor: const Color(0xFFF0F4FF),
      child: Container(
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.18),
          border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: size * 0.08, vertical: size * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMidtermsBadge(double size) {
    return _buildContainer(
      size: size,
      bgColor: const Color(0xFFF0FDF4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_month, color: const Color(0xFF3B82F6), size: size * 0.62),
          Positioned(
            bottom: size * 0.1,
            right: size * 0.1,
            child: Container(
              padding: EdgeInsets.all(size * 0.03),
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: Colors.white,
                size: size * 0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAssignmentsBadge(double size) {
    return _buildContainer(
      size: size,
      bgColor: const Color(0xFFFAF5FF),
      child: Icon(
        Icons.assignment_outlined,
        color: const Color(0xFF8B5CF6),
        size: size * 0.62,
      ),
    );
  }

  static Widget _buildFinalsBadge(double size) {
    return _buildContainer(
      size: size,
      bgColor: const Color(0xFFEFF6FF),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.school, color: const Color(0xFF1D4ED8), size: size * 0.62),
          Positioned(
            bottom: size * 0.1,
            right: size * 0.1,
            child: Icon(
              Icons.stars,
              color: const Color(0xFFF59E0B),
              size: size * 0.3,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildModulesBadge(double size) {
    return _buildContainer(
      size: size,
      bgColor: const Color(0xFFFFFBEB),
      child: Icon(
        Icons.menu_book,
        color: const Color(0xFF2563EB),
        size: size * 0.62,
      ),
    );
  }
}

class CourseIconBadge extends StatelessWidget {
  final String iconKey;
  final double size;

  const CourseIconBadge({
    super.key,
    required this.iconKey,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    Color bgGradientStart;
    Color bgGradientEnd;
    Widget innerIcon;

    switch (iconKey.toLowerCase()) {
      case 'english':
        bgGradientStart = const Color(0xFF60A5FA);
        bgGradientEnd = const Color(0xFF2563EB);
        innerIcon = const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28);
        break;
      case 'math':
        bgGradientStart = const Color(0xFF38BDF8);
        bgGradientEnd = const Color(0xFF0284C7);
        innerIcon = const Icon(Icons.calculate_outlined, color: Colors.white, size: 28);
        break;
      case 'physics':
        bgGradientStart = const Color(0xFF94A3B8);
        bgGradientEnd = const Color(0xFF475569);
        innerIcon = const Icon(Icons.biotech_outlined, color: Colors.white, size: 28);
        break;
      case 'logic':
        bgGradientStart = const Color(0xFFA78BFA);
        bgGradientEnd = const Color(0xFF7C3AED);
        innerIcon = const Icon(Icons.extension_outlined, color: Colors.white, size: 28);
        break;
      case 'psychology':
        bgGradientStart = const Color(0xFFF472B6);
        bgGradientEnd = const Color(0xFFDB2777);
        innerIcon = const Icon(Icons.psychology_outlined, color: Colors.white, size: 28);
        break;
      default:
        bgGradientStart = const Color(0xFF3B82F6);
        bgGradientEnd = const Color(0xFF1D4ED8);
        innerIcon = const Icon(Icons.school, color: Colors.white, size: 28);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgGradientStart, bgGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: bgGradientEnd.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: innerIcon),
    );
  }
}

class PdfIconBadge extends StatelessWidget {
  final double size;

  const PdfIconBadge({
    super.key,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size * 0.12,
            vertical: size * 0.08,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(size * 0.14),
          ),
          child: Text(
            'PDF',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
