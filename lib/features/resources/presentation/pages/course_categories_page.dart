import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/course_item.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/category_row_card.dart';
import '../widgets/course_stats_banner.dart';

class CourseCategoriesPage extends ConsumerWidget {
  final int courseId;
  final CourseItem? initialCourse;

  const CourseCategoriesPage({
    super.key,
    required this.courseId,
    this.initialCourse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialCourse != null) {
      return _buildContent(context, initialCourse!);
    }

    final coursesAsync =
        ref.watch(coursesProvider(const CoursesParams()));

    return coursesAsync.when(
      data: (result) {
        final course = result.courses.firstWhere(
          (c) => c.id == courseId,
          orElse: () =>
              const MockResourceDatasource().getCourseById(courseId),
        );
        return _buildContent(context, course);
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) {
        final course =
            const MockResourceDatasource().getCourseById(courseId);
        return _buildContent(context, course);
      },
    );
  }

  Widget _buildContent(BuildContext context, CourseItem course) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── COLLAPSIBLE HEADER ────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _CourseAppBarDelegate(
              topPadding: topPadding,
              course: course,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),

          // ── COURSE STATS & CATEGORIES LIST ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Course Stats Banner (orphaned widget embedded)
                  CourseStatsBanner(course: course),

                  AppSpacing.gapLg,

                  // Resource Categories List
                  const Text(
                    ResourceUiConstants.resourceCategories,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...ResourceUiConstants.categoryPairs.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CategoryRowCard(
                        category: cat.$1,
                        title: cat.$2,
                        onTap: () {
                          context.push(
                            RouteNames.courseCategoryResources,
                            extra: {
                              'courseId': course.id,
                              'category': cat.$1,
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// COLLAPSIBLE APP BAR DELEGATE FOR COURSE / SUBJECT PAGE
/// ===============================================================

class _CourseAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final CourseItem course;
  final VoidCallback onBack;

  _CourseAppBarDelegate({
    required this.topPadding,
    required this.course,
    required this.onBack,
  });

  @override
  double get minExtent => topPadding + kToolbarHeight;

  @override
  double get maxExtent => topPadding + 145.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final delta = maxExtent - minExtent;
    final progress = (shrinkOffset / (delta <= 0 ? 1 : delta)).clamp(0.0, 1.0);

    final collapsedOpacity = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final expandedOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
    final cornerRadius = (1.0 - progress) * 32.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(cornerRadius),
        ),
        boxShadow: progress > 0.8
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── EXPANDED VIEW (Course icon badge, name, semester) ────
          if (expandedOpacity > 0.0)
            Positioned(
              top: topPadding + 48,
              left: 20,
              right: 20,
              child: Opacity(
                opacity: expandedOpacity,
                child: Row(
                  children: [
                    CourseIconBadge(iconKey: course.iconKey, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.semester,
                            style: const TextStyle(
                              color: ResourceUiConstants.accentGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── PINNED TOP APPBAR (Back icon + Course Name) ─────────
          Positioned(
            top: topPadding,
            left: 8,
            right: 16,
            height: kToolbarHeight,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onBack,
                ),
                const SizedBox(width: 4),
                if (collapsedOpacity > 0.0)
                  Expanded(
                    child: Opacity(
                      opacity: collapsedOpacity,
                      child: Text(
                        course.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CourseAppBarDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.course != course;
  }
}
