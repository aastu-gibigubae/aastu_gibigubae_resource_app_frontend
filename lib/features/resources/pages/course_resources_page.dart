import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

class CourseResourcesPage extends StatelessWidget {
  const CourseResourcesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      extendBodyBehindAppBar: true,

      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // =====================================================
            // NAVY BACKGROUND
            // =====================================================

            const Positioned.fill(
              child: ColoredBox(
                color: AppColors.primary,
              ),
            ),

            // =====================================================
            // HEADER
            // =====================================================

            const Positioned(
              left: 30,
              right: 18,
              top: 20,
              child: _ResourceHeader(),
            ),

            // =====================================================
            // WHITE CONTENT PANEL
            // =====================================================

            Positioned(
              left: 0,
              right: 0,
              top: 182,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(48),
                    topRight: Radius.circular(48),
                  ),
                ),
                child: const _ResourceContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// HEADER
// =================================================================

class _ResourceHeader extends StatelessWidget {
  const _ResourceHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================================================
        // PREMIUM BUTTON
        // =========================================================

        Align(
          alignment: Alignment.topRight,

          // =======================================================
          // NAVIGATE TO PREMIUM
          // =======================================================

          child: GestureDetector(
            onTap: () {
              context.go(RouteNames.premium);
            },

            child: Container(
              height: 25,

              padding: const EdgeInsets.symmetric(
                horizontal: 11,
              ),

              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.secondary,
                  width: 2,
                ),

                borderRadius:
                    BorderRadius.circular(22),
              ),

              child: Row(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  // =================================================
                  // INFO ICON
                  // =================================================

                  Container(
                    width: 18,
                    height: 18,

                    decoration:
                        BoxDecoration(
                      shape: BoxShape.circle,

                      border: Border.all(
                        color:
                            AppColors.secondary,
                        width: 2,
                      ),
                    ),

                    child: const Center(
                      child: Text(
                        'i',

                        style: TextStyle(
                          color:
                              AppColors.secondary,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5, height:3),

                  // =================================================
                  // ABOUT PREMIUM
                  // =================================================

                  const Text(
                    'About Premium',

                    style: TextStyle(
                      color:
                          AppColors.secondary,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // =========================================================
        // TITLE
        // =========================================================

        const Text(
          'Explore Course Resources',

          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),

        const SizedBox(height: 8),

        // =========================================================
        // DESCRIPTION
        // =========================================================

        const Text(
          'Get access to past exams, lecture notes,\n'
          'modules and more.',

          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// WHITE CONTENT
// =================================================================

class _ResourceContent extends StatelessWidget {
  const _ResourceContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 30,
        right: 30,
        top: 38,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =======================================================
          // SECTION TITLE
          // =======================================================

          const Text(
            'Examples of resources you’ll get',

            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 30),

          // =======================================================
          // RESOURCE CONTAINER
          // =======================================================

          Expanded(
            child: Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 232, 238, 248),

                borderRadius:
                    BorderRadius.circular(40),

                border: Border.all(
                  color:
                      const Color(0xFFF0EDED),
                  width: 1.5,
                ),
              ),

              child: const Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 28,
                    child: _PdfResourceCard(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 50, width:30),
        ],
      ),
    );
  }
}

// =================================================================
// PDF RESOURCE CARD
// =================================================================

class _PdfResourceCard
    extends StatelessWidget {
  const _PdfResourceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 85,

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 204, 219, 252),

        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color: const Color(0xFFDADADA),
          width: 1,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.only(
          top: 4,
          left: 4,
          right: 4,
          bottom: 3,
        ),

        child: Column(
          children: [
            // =====================================================
            // PDF ICON
            // =====================================================

            SizedBox(
              width: 50,
              height: 42,

              child: CustomPaint(
                painter: _PdfIconPainter(),

                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 8,
                    ),

                    child: Text(
                      'PDF',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 3),

            // =====================================================
            // RESOURCE NAME
            // =====================================================

            const FittedBox(
              fit: BoxFit.scaleDown,

              child: Text(
                'Communicative English I',

                maxLines: 1,

                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// PDF ICON PAINTER
// =================================================================

class _PdfIconPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final path = Path();

    final double width = size.width;
    final double height = size.height;

    // ===========================================================
    // PDF BODY
    // ===========================================================

    path.moveTo(15, 0);

    path.lineTo(
      width - 25,
      0,
    );

    path.lineTo(
      width,
      25,
    );

    path.lineTo(
      width,
      height,
    );

    path.lineTo(
      15,
      height,
    );

    path.quadraticBezierTo(
      0,
      height,
      0,
      height - 15,
    );

    path.lineTo(
      0,
      15,
    );

    path.quadraticBezierTo(
      0,
      0,
      15,
      0,
    );

    path.close();

    final paint = Paint()
      ..color = const Color(0xFFFF4651)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      path,
      paint,
    );

    // ===========================================================
    // FOLDED CORNER
    // ===========================================================

    final foldPath = Path();

    foldPath.moveTo(
      width - 25,
      0,
    );

    foldPath.lineTo(
      width - 25,
      25,
    );

    foldPath.lineTo(
      width,
      25,
    );

    foldPath.close();

    final foldPaint = Paint()
      ..color = const Color(0xFFE83E49)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      foldPath,
      foldPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}