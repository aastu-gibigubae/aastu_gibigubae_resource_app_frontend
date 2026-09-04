import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

// ================================================================
// COURSE RESOURCES PAGE
// ================================================================

class CourseResourcesPage extends StatelessWidget {
  const CourseResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Premium button
                  Align(
                    alignment: Alignment.topRight,
                    child: _AboutPremiumButton(
                      onTap: () => context.go(RouteNames.premium),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Explore Course Resources',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Get access to past exams, lecture notes,\nmodules and more.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── White panel ───────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: const _WhitePanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ABOUT PREMIUM BUTTON
// ================================================================

class _AboutPremiumButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AboutPremiumButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'About Premium',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// WHITE PANEL
// ================================================================

class _WhitePanel extends StatelessWidget {
  const _WhitePanel();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sneak peek section ────────────────────────────────
          const Text(
            "Here's a sneak peek of what you'll get",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // ── Category icons row ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _CategoryCard(
                emoji: '📋',
                label: 'Final Exams',
              ),
              _CategoryCard(
                emoji: '📚',
                label: 'Modules',
              ),
              _CategoryCard(
                emoji: '📁',
                label: 'Handouts',
              ),
              _CategoryCard(
                emoji: '📊',
                label: 'Midterms',
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          const SizedBox(height: 20),

          // ── Sample resources ──────────────────────────────────
          const Text(
            'Sample Resources',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          // ── Resource list ─────────────────────────────────────
          const _ResourceRow(
            type: _FileType.pdf,
            title: 'Communicative English I',
            subtitle: 'Midterm',
            year: '2023 AC',
          ),
          const SizedBox(height: 10),
          const _ResourceRow(
            type: _FileType.pdf,
            title: 'Mathematics',
            subtitle: 'Final Exam',
            year: '2024 AC',
          ),
          const SizedBox(height: 10),
          const _ResourceRow(
            type: _FileType.ppt,
            title: 'Anthropology',
            subtitle: 'Lecture Notes',
          ),
          const SizedBox(height: 10),
          const _ResourceRow(
            type: _FileType.docx,
            title: 'History',
            subtitle: 'Lecture Notes',
          ),

          const SizedBox(height: 28),

          // ── Get Premium link ──────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.go(RouteNames.premium),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Premium',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CATEGORY CARD
// ================================================================

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;

  const _CategoryCard({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// RESOURCE ROW
// ================================================================

enum _FileType { pdf, ppt, docx }

class _ResourceRow extends StatelessWidget {
  final _FileType type;
  final String title;
  final String subtitle;
  final String? year;

  const _ResourceRow({
    required this.type,
    required this.title,
    required this.subtitle,
    this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // ── File icon ─────────────────────────────────────────
          _FileIcon(type: type),

          const SizedBox(width: 14),

          // ── Title + subtitle ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7B8EB8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (year != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    year!,
                    style: const TextStyle(
                      color: Color(0xFF9BA8C8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Type badge ────────────────────────────────────────
          _TypeBadge(type: type),
        ],
      ),
    );
  }
}

// ================================================================
// FILE ICON
// ================================================================

class _FileIcon extends StatelessWidget {
  final _FileType type;

  const _FileIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _FileType.pdf:
        return _buildIcon(
          bgColor: const Color(0xFFFFE5E5),
          child: const _PdfLabel(label: 'PDF', color: Color(0xFFE53935)),
        );
      case _FileType.ppt:
        return _buildIcon(
          bgColor: const Color(0xFFFFE5E5),
          child: const _PdfLabel(label: 'PPT', color: Color(0xFFE53935)),
        );
      case _FileType.docx:
        return _buildIcon(
          bgColor: const Color(0xFFE3F0FF),
          child: const _DocxIcon(),
        );
    }
  }

  Widget _buildIcon({required Color bgColor, required Widget child}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }
}

class _PdfLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _PdfLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DocxIcon extends StatelessWidget {
  const _DocxIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'W',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ================================================================
// TYPE BADGE
// ================================================================

class _TypeBadge extends StatelessWidget {
  final _FileType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      _FileType.pdf => 'PDF',
      _FileType.ppt => 'PPT',
      _FileType.docx => 'Docx',
    };

    final color = switch (type) {
      _FileType.pdf => const Color(0xFFE53935),
      _FileType.ppt => const Color(0xFFE53935),
      _FileType.docx => const Color(0xFF1565C0),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
