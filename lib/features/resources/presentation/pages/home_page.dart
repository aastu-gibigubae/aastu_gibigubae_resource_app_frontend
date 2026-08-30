import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/popular_categories_grid.dart';
import '../widgets/recent_activity_tile.dart';
import '../widgets/stream_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting, status, search bar
            CurvedHeader(
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ResourceUiConstants.homeGreeting,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      const Text(
                        ResourceUiConstants.premiumAccess,
                        style: TextStyle(
                          color: ResourceUiConstants.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.hGapSm,
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ResourceUiConstants.accentGold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        ResourceUiConstants.activeStatus,
                        style: TextStyle(
                          color: ResourceUiConstants.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                  Row(
                    children: [
                      Expanded(
                        child: StreamCard(
                          title: 'Engineering',
                          icon: Icons.settings,
                          onTap: () => context.push(RouteNames.browse),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamCard(
                          title: 'Applied Science',
                          icon: Icons.science_outlined,
                          onTap: () => context.push(RouteNames.browse),
                        ),
                      ),
                    ],
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
                    onCategoryTap: (category) {
                      context.push(
                        RouteNames.courseCategoryResources,
                        extra: {
                          'courseId': 1,
                          'category': category,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            AppSpacing.gapLg,

            // Recent Activities
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
                        ResourceUiConstants.recentActivities,
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
                  const SizedBox(height: 10),
                  ...MockResourceDatasource.recentActivities.map(
                    (act) => RecentActivityTile(
                      activity: act,
                      onTap: () {
                        context.push(
                          RouteNames.resourceDetail,
                          extra: act.id,
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
}
