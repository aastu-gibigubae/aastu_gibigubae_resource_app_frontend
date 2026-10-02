import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/resource_category_type.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/popular_categories_grid.dart';
import '../widgets/recent_activity_tile.dart';
import '../widgets/stream_card.dart';
import '../../providers/resource_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/session_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsync = ref.watch(streamsProvider);
    final user = ref.watch(authProvider).valueOrNull;
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final isPremium = user?.isPremium ?? isPremiumAsync.valueOrNull ?? false;

    final firstName = (user != null && user.name.trim().isNotEmpty)
        ? user.name.trim().split(' ').first
        : 'Student';
    final greeting = 'Hello, $firstName! 👋';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting, status, search bar
            CurvedHeader(
              trailing: GestureDetector(
                onTap: () => context.push(RouteNames.notifications),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  AppSpacing.gapXs,
                  GestureDetector(
                    onTap: isPremium
                        ? null
                        : () => context.push(RouteNames.premium),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isPremium
                              ? ResourceUiConstants.premiumAccess
                              : 'Free Plan',
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPremium
                                ? const Color(0xFF10B981)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPremium
                              ? 'Active'
                              : 'Upgrade ✨',
                          style: TextStyle(
                            color: isPremium
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFDE68A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration:
                                isPremium ? null : TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottomChild: SearchPillBar(
                readOnly: true,
                onTap: () => context.go(RouteNames.browse),
              ),
            ),

            const SizedBox(height: 20),

            // Browse by Stream
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ResourceUiConstants.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ResourceUiConstants.browseByStream,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  streamsAsync.when(
                    data: (streams) => Row(
                      children: streams.take(2).map((stream) {
                        final icon = stream.name.toLowerCase().contains('eng')
                            ? Icons.settings
                            : Icons.science_outlined;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: stream != streams.take(2).last ? 12 : 0,
                            ),
                            child: StreamCard(
                              title: stream.name,
                              icon: icon,
                              onTap: () {
                                ref
                                    .read(
                                        selectedStreamFilterProvider.notifier)
                                    .state = stream.id;
                                context.push(RouteNames.browse);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Row(
                      children: MockResourceDatasource.streams.take(2).map((stream) {
                        final icon = stream.name.toLowerCase().contains('eng')
                            ? Icons.settings
                            : Icons.science_outlined;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: stream != MockResourceDatasource.streams.take(2).last ? 12 : 0,
                            ),
                            child: StreamCard(
                              title: stream.name,
                              icon: icon,
                              onTap: () {
                                ref
                                    .read(selectedStreamFilterProvider.notifier)
                                    .state = stream.id;
                                context.push(RouteNames.browse);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.gapLg,

            // Popular Categories
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ResourceUiConstants.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ResourceUiConstants.popularCategories,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.browse),
                        child: const Text(
                          ResourceUiConstants.seeAll,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ResourceUiConstants.textLink,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PopularCategoriesGrid(
                    onCategoryTap: (category) =>
                        _showCoursePickerForCategory(context, ref, category),
                  ),
                ],
              ),
            ),

            AppSpacing.gapLg,

            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ResourceUiConstants.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...MockResourceDatasource.recentActivities.map(
                    (act) => RecentActivityTile(
                      activity: act,
                      onTap: () {
                        context.push(
                          RouteNames.courseCategoryResources,
                          extra: {
                            'courseId': act.id,
                            'category': ResourceCategoryType.handouts,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _showCoursePickerForCategory(
    BuildContext context,
    WidgetRef ref,
    ResourceCategoryType category,
  ) {
    final coursesAsync = ref.read(coursesProvider(const CoursesParams()));
    final courses = coursesAsync.valueOrNull?.courses ??
        MockResourceDatasource.freshmanCourses;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Course for ${category.label}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose which course resources to explore:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: courses.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      leading: CourseIconBadge(
                        iconKey: course.iconKey,
                        size: 40,
                      ),
                      title: Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      subtitle: Text(
                        '${course.academicYear}${course.academicYear == 1 ? 'st' : 'nd'} Year • ${course.semester}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(
                          RouteNames.courseCategoryResources,
                          extra: {
                            'courseId': course.id,
                            'category': category,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
