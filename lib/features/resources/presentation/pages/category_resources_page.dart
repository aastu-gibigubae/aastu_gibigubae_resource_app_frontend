import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../domain/entities/resource_category_type.dart';
import '../../domain/entities/resource_item.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/download_success_dialog.dart';
import '../widgets/resource_item_card.dart';

class CategoryResourcesPage extends ConsumerStatefulWidget {
  final int courseId;
  final ResourceCategoryType category;

  const CategoryResourcesPage({
    super.key,
    required this.courseId,
    required this.category,
  });

  @override
  ConsumerState<CategoryResourcesPage> createState() =>
      _CategoryResourcesPageState();
}

class _CategoryResourcesPageState
    extends ConsumerState<CategoryResourcesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _localFilter = '';

  /// Tracks which resource IDs are currently downloading.
  final Set<int> _downloadingIds = {};

  /// Tracks per-resource download progress (0..1).
  final Map<int, double> _downloadProgressMap = {};

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _localFilter = query.trim().toLowerCase();
    });
  }

  void _onBack() {
    _searchFocusNode.unfocus();
    context.pop();
  }

  Future<void> _downloadResource(ResourceItem resource) async {
    if (resource.fileUrl == null || resource.fileUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download URL not available.')),
      );
      return;
    }

    // Prevent double-tap
    if (_downloadingIds.contains(resource.id)) return;

    setState(() {
      _downloadingIds.add(resource.id);
      _downloadProgressMap[resource.id] = 0;
    });

    try {
      final downloadService = ref.read(resourceDownloadServiceProvider);
      await downloadService.downloadResource(
        resource,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgressMap[resource.id] = received / total;
            });
          }
        },
      );
      ref.invalidate(isResourceDownloadedProvider(resource.id));
      ref.invalidate(downloadedResourceIdsProvider);
      if (mounted) {
        await showDownloadSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMapper.userMessage(
                e,
                defaultMessage: 'Download failed. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingIds.remove(resource.id);
          _downloadProgressMap.remove(resource.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = CourseResourcesParams(
      courseId: widget.courseId,
      category: widget.category,
    );
    final resourcesAsync = ref.watch(courseResourcesProvider(params));

    final coursesAsync =
        ref.watch(coursesProvider(const CoursesParams()));
    final courseName = coursesAsync.whenData((result) {
      final match = result.courses.where((c) => c.id == widget.courseId);
      return match.isNotEmpty ? match.first.name : 'Course';
    });

    final topPadding = MediaQuery.of(context).padding.top;
    final resolvedCourseTitle = courseName.valueOrNull ?? 'Course';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── COLLAPSIBLE HEADER ────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryResourcesAppBarDelegate(
                topPadding: topPadding,
                courseTitle: resolvedCourseTitle,
                categoryLabel: widget.category.label,
                onBack: _onBack,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onSearchChanged: _onSearchChanged,
              ),
            ),

            // ── RESOURCES LIST ────────────────────────────────────
            ...resourcesAsync.when(
              data: (result) {
                List<ResourceItem> resources = result.resources;
                if (_localFilter.isNotEmpty) {
                  resources = resources
                      .where((r) => r.title
                          .toLowerCase()
                          .contains(_localFilter))
                      .toList();
                }

                if (resources.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _localFilter.isNotEmpty
                                ? 'No resources matching "$_localFilter"'
                                : 'No resources found for this category.',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                return [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final resource = resources[index];
                          final isDownloaded = ref
                                  .watch(isResourceDownloadedProvider(
                                      resource.id))
                                  .valueOrNull ??
                              false;
                          final isDownloading =
                              _downloadingIds.contains(resource.id);
                          final progress =
                              _downloadProgressMap[resource.id] ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ResourceItemCard(
                              resource: resource,
                              isDownloaded: isDownloaded,
                              isDownloading: isDownloading,
                              downloadProgress: progress,
                              onTap: () {
                                _searchFocusNode.unfocus();
                                context.push(
                                  RouteNames.resourceDetail,
                                  extra: resource,
                                );
                              },
                              onDownload: resource.locked || isDownloaded
                                  ? null
                                  : () => _downloadResource(resource),
                            ),
                          );
                        },
                        childCount: resources.length,
                      ),
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
              error: (err, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            'Could not load resources.\n${ErrorMapper.userMessage(err)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(
                                courseResourcesProvider(params)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// COLLAPSIBLE APP BAR DELEGATE FOR CATEGORY RESOURCES SCREEN
/// ===============================================================

class _CategoryResourcesAppBarDelegate
    extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String courseTitle;
  final String categoryLabel;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;

  _CategoryResourcesAppBarDelegate({
    required this.topPadding,
    required this.courseTitle,
    required this.categoryLabel,
    required this.onBack,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
  });

  @override
  double get minExtent => topPadding + kToolbarHeight;

  @override
  double get maxExtent => topPadding + 148.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final delta = maxExtent - minExtent;
    final progress = (shrinkOffset / (delta <= 0 ? 1 : delta)).clamp(0.0, 1.0);

    // Fade out search bar & subtitle quickly so they vanish before collapsing
    final expandedOpacity = (1.0 - progress * 1.8).clamp(0.0, 1.0);

    // Curved bottom corner radius flattens as it collapses
    final cornerRadius = (1.0 - progress) * 32.0;

    return Container(
      clipBehavior: Clip.hardEdge,
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
        clipBehavior: Clip.hardEdge,
        children: [
          // ── EXPANDABLE SUBTITLE & SEARCH BAR ──────────────────
          if (expandedOpacity > 0.0)
            Positioned(
              top: topPadding + 44,
              left: 16,
              right: 16,
              child: Opacity(
                opacity: expandedOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text(
                        categoryLabel,
                        style: const TextStyle(
                          color: ResourceUiConstants.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SearchPillBar(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onChanged: onSearchChanged,
                    ),
                  ],
                ),
              ),
            ),

          // ── PINNED TOP ROW: Back button & Course title on SAME line ──
          Positioned(
            top: topPadding,
            left: 4,
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
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    courseTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  bool shouldRebuild(
      covariant _CategoryResourcesAppBarDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.courseTitle != courseTitle ||
        oldDelegate.categoryLabel != categoryLabel ||
        oldDelegate.searchController != searchController;
  }
}
