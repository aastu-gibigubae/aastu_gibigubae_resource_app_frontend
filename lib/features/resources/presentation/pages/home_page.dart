import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/popular_categories_grid.dart';
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
                            color: isPremium
                                ? ResourceUiConstants.accentGold
                                : Colors.white.withAlpha(220),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPremium
                                ? ResourceUiConstants.accentGold
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPremium
                              ? ResourceUiConstants.activeStatus
                              : 'Upgrade ✨',
                          style: TextStyle(
                            color: isPremium
                                ? ResourceUiConstants.accentGold
                                : const Color(0xFFFDE68A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                              onTap: () => context.push(RouteNames.browse),
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
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Could not load streams: $err',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
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

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
