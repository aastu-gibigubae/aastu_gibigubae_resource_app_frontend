import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../data/models/search_result_model.dart';
import '../../domain/entities/stream_item.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/course_card.dart';

class BrowseCoursesPage extends ConsumerStatefulWidget {
  const BrowseCoursesPage({super.key});

  @override
  ConsumerState<BrowseCoursesPage> createState() => _BrowseCoursesPageState();
}

class _BrowseCoursesPageState extends ConsumerState<BrowseCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _localFilter = '';

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
    ref.read(searchQueryProvider.notifier).state = query.trim();
  }

  void _onBack() {
    _searchFocusNode.unfocus();
    context.go(RouteNames.home);
  }

  void _onSeeAll() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _localFilter = '';
    });
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedStreamFilterProvider.notifier).state = null;
    ref.read(selectedYearFilterProvider.notifier).state = 1;
  }

  Widget _buildFilterChips({
    required List<StreamItem> streams,
    required int? selectedStream,
    required int selectedYear,
  }) {
    const years = [1, 2, 3, 4, 5];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Academic Year Filter ──────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final y in years) ...[
                  ChoiceChip(
                    label: Text(y == 1 ? 'Year 1 (Freshman)' : 'Year $y'),
                    selected: selectedYear == y,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedYearFilterProvider.notifier).state = y;
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selectedYear == y ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Stream / Field of Study Filter ────────────────────
          if (streams.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Streams'),
                    selected: selectedStream == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedStreamFilterProvider.notifier).state = null;
                      }
                    },
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      color: selectedStream == null ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...streams.map((stream) {
                    final isSelected = selectedStream == stream.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(stream.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(selectedStreamFilterProvider.notifier).state =
                              selected ? stream.id : null;
                        },
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(SearchResultModel result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: result.isCourse
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            result.isCourse
                ? Icons.menu_book_rounded
                : Icons.description_outlined,
            color: result.isCourse ? AppColors.primary : const Color(0xFFD97706),
            size: 22,
          ),
        ),
        title: Text(
          result.displayName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text(
          result.isCourse ? 'Course' : 'Resource Document',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Color(0xFF9CA3AF),
        ),
        onTap: () {
          _searchFocusNode.unfocus();
          if (result.isCourse) {
            context.push(RouteNames.courseDetail, extra: result.id);
          } else {
            context.push(RouteNames.resourceDetail, extra: result.id);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStream = ref.watch(selectedStreamFilterProvider);
    final selectedYear = ref.watch(selectedYearFilterProvider) ?? 1;
    final streams = ref.watch(streamsProvider).valueOrNull ?? [];
    final topPadding = MediaQuery.of(context).padding.top;

    final coursesParams = CoursesParams(
      streamId: selectedStream,
      year: selectedYear,
    );
    final coursesAsync = ref.watch(coursesProvider(coursesParams));
    final searchResultsAsync = _localFilter.isNotEmpty
        ? ref.watch(searchResultsProvider)
        : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── COLLAPSIBLE HEADER (Collapses to small app bar with back icon & Browse text) ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _BrowseAppBarDelegate(
                topPadding: topPadding,
                onBack: _onBack,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onSearchChanged: _onSearchChanged,
              ),
            ),

            // ── FILTER CHIPS (Year & Stream) ────────────────────
            SliverToBoxAdapter(
              child: _buildFilterChips(
                streams: streams,
                selectedStream: selectedStream,
                selectedYear: selectedYear,
              ),
            ),

            // ── COURSES AND RESULTS LIST ────────────────────────
            ...coursesAsync.when(
              data: (result) {
                var courses = result.courses;
                if (_localFilter.isNotEmpty) {
                  courses = courses
                      .where((c) =>
                          c.name.toLowerCase().contains(_localFilter))
                      .toList();
                }

                final searchResults = searchResultsAsync?.valueOrNull ?? [];
                final resourceResults =
                    searchResults.where((r) => r.isResource).toList();

                final hasFilters = selectedStream != null ||
                    selectedYear != 1 ||
                    _localFilter.isNotEmpty;

                if (courses.isEmpty && resourceResults.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _localFilter.isNotEmpty
                                    ? 'No results matching "$_localFilter"'
                                    : 'No courses found for selected filters.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (hasFilters) ...[
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                  onPressed: _onSeeAll,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Clear Filters'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                String sectionTitle;
                if (selectedYear == 1) {
                  sectionTitle = selectedStream != null
                      ? '${streams.where((s) => s.id == selectedStream).firstOrNull?.name ?? "Freshman"} Freshman Courses'
                      : ResourceUiConstants.freshmanCourses;
                } else {
                  final streamName = streams
                      .where((s) => s.id == selectedStream)
                      .firstOrNull
                      ?.name;
                  sectionTitle = streamName != null
                      ? 'Year $selectedYear $streamName Courses'
                      : 'Year $selectedYear Courses';
                }

                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sectionTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: _onSeeAll,
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

                          // Matching courses (top card highlighted matching Figma image copy 13.png)
                          ...courses.asMap().entries.map((entry) {
                            final index = entry.key;
                            final course = entry.value;
                            final isHighlighted = index == 0 &&
                                _localFilter.isEmpty &&
                                selectedStream == null &&
                                selectedYear == 1;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CourseCard(
                                course: course,
                                isHighlighted: isHighlighted,
                                onTap: () {
                                  _searchFocusNode.unfocus();
                                  context.push(
                                    RouteNames.courseDetail,
                                    extra: course,
                                  );
                                },
                              ),
                            );
                          }),

                          // If searching, also display any matching resources from global search
                          if (resourceResults.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Matching Resources',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...resourceResults.map(_buildSearchResultTile),
                          ],

                          const SizedBox(height: 32),
                        ],
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
                            'Could not load courses.\n${ErrorMapper.userMessage(err)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(
                              coursesProvider(coursesParams),
                            ),
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
/// COLLAPSIBLE APP BAR DELEGATE FOR BROWSE SCREEN
/// ===============================================================

class _BrowseAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;

  _BrowseAppBarDelegate({
    required this.topPadding,
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
                    const Padding(
                      padding: EdgeInsets.only(left: 36),
                      child: Text(
                        'Find your course resources',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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

          // ── PINNED TOP ROW: Back button & Browse title on SAME line ──
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
                const Text(
                  'Browse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
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
  bool shouldRebuild(covariant _BrowseAppBarDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.searchController != searchController;
  }
}

