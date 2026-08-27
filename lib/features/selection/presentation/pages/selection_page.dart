import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/branding_widgets.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  int selectedYear = 3;

  String selectedField = 'Applied Science';

  final List<int> years = [1, 2, 3, 4, 5];

  final List<String> fields = [
    'Applied Science',
    'Engineering',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body: AppBackground(
        showTopRightOutline: false,

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 90,
              bottom: 130,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==================================================
                // SELECT YEAR
                // ==================================================

                const Text(
                  'Select your year',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Choose your current academic year',
                  style: TextStyle(
                    color: Color(0xFF657184),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // YEAR GRID
                // ==================================================

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: years.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.05,
                  ),

                  itemBuilder: (context, index) {
                    final year = years[index];

                    return _YearCard(
                      year: year,
                      selected: selectedYear == year,
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 25),

                // ==================================================
                // FIELD OF STUDY
                // ==================================================

                const Text(
                  'Select your field of study',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Choose your field of study',
                  style: TextStyle(
                    color: Color(0xFF657184),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // APPLIED SCIENCE
                // ==================================================

                _FieldCard(
                  title: 'Applied Science',
                  selected: selectedField == 'Applied Science',
                  onTap: () {
                    setState(() {
                      selectedField = 'Applied Science';
                    });
                  },
                ),

                const SizedBox(height: 26),

                // ==================================================
                // ENGINEERING
                // ==================================================

                _FieldCard(
                  title: 'Engineering',
                  selected: selectedField == 'Engineering',
                  onTap: () {
                    setState(() {
                      selectedField = 'Engineering';
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CONTINUE BUTTON
                // ==================================================

                Center(
                  child: SizedBox(
                    width: 155,
                    height: 64,

                    child: ElevatedButton(
                      onPressed: _continue,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 5),

                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // DIVIDER
                // ==================================================

                const Center(
                  child: AppDivider(
                    lineWidth: 40,
                    lineHeight: 5,
                    dotSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // CONTINUE
  // ==============================================================

  void _continue() {
    debugPrint('Selected year: $selectedYear');
    debugPrint('Selected field: $selectedField');

    // Navigate to Course Resources
    context.go(RouteNames.courseResources);
  }
}

// ==================================================================
// YEAR CARD
// ==================================================================

class _YearCard extends StatelessWidget {
  final int year;
  final bool selected;
  final VoidCallback onTap;

  const _YearCard({
    required this.year,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFFD8DEE8),
            width: 3,
          ),
        ),

        child: Stack(
          children: [

            // =====================================================
            // CONTENT
            // =====================================================

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.school,
                    color: selected
                        ? Colors.white
                        : AppColors.primary,
                    size: 18,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Year $year',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CHECK CIRCLE
            // =====================================================

            if (selected)
              Positioned(
                top: 3,
                right: 3,

                child: Container(
                  width: 23,
                  height: 23,

                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// FIELD CARD
// ==================================================================

class _FieldCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FieldCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,
        height: 50,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFFD8DEE8),
            width: 2,
          ),
        ),

        child: Row(
          children: [

            // =====================================================
            // TITLE
            // =====================================================

            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // =====================================================
            // CHECK
            // =====================================================

            Padding(
              padding: const EdgeInsets.only(right: 26),

              child: Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.white,

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFD8DEE8),
                    width: 3,
                  ),
                ),

                child: selected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 22,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}