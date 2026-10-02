import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/curved_header.dart';
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
    ref.read(selectedYearFilterProvider.notifier).state = null;
    ref.read(selectedDepartmentFilterProvider.notifier).state = null;
  }

  Widget _buildFilterChips(
    List<StreamItem> streams,
    int? selectedStream,
    int? selectedYear,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Streams'),
            selected: selectedStream == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(selectedStreamFilterProvider.notifier).state = null;
                ref.read(selectedDepartmentFilterProvider.notifier).state = null;
              }
            },
            selectedColor: AppColors.primary,
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
                  // Reset department when stream changes
                  ref.read(selectedDepartmentFilterProvider.notifier).state =
                      null;
                },
                selectedColor: AppColors.primary,
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
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 22,
            color: const Color(0xFFE5E7EB),
          ),
          const SizedBox(width: 10),
          ...[1, 2].map((year) {
            final isSelected = selectedYear == year;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(year == 1 ? 'Freshman (Yr 1)' : 'Year $year'),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(selectedYearFilterProvider.notifier).state =
                      selected ? year : null;
                  // Reset department when year changes
                  ref.read(selectedDepartmentFilterProvider.notifier).state =
                      null;
                },
                selectedColor: const Color(0xFFD97706),
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
    );
  }

  Widget _buildDepartmentChips(
    List<({int id, String name})> departments,
    int? selectedDepartment,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.school_outlined,
                size: 16, color: Color(0xFF6B7280)),
          ),
          ChoiceChip(
            label: const Text('All Departments'),
            selected: selectedDepartment == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(selectedDepartmentFilterProvider.notifier).state =
                    null;
              }
            },
            selectedColor: const Color(0xFF7C3AED),
            labelStyle: TextStyle(
              color: selectedDepartment == null
                  ? Colors.white
                  : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            backgroundColor: const Color(0xFFF3F4F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          ...departments.map((dept) {
            final isSelected = selectedDepartment == dept.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(dept.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(selectedDepartmentFilterProvider.notifier)
                      .state = selected ? dept.id : null;
                },
                selectedColor: const Color(0xFF7C3AED),
                labelStyle: TextStyle(
                  color:
                      isSelected ? Colors.white : const Color(0xFF374151),
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
    final selectedYear = ref.watch(selectedYearFilterProvider);
    final selectedDepartment = ref.watch(selectedDepartmentFilterProvider);
    final streams = ref.watch(streamsProvider).valueOrNull ?? [];

    // Fetch departments when a stream is selected and year >= 2
    final showDepartments =
        selectedStream != null && (selectedYear ?? 1) >= 2;
    final departmentsAsync = showDepartments
        ? ref.watch(departmentsProvider(selectedStream))
        : null;
    final departments = departmentsAsync?.valueOrNull ?? [];

    final coursesParams = CoursesParams(
      streamId: selectedStream,
      departmentId: selectedDepartment,
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
        body: Column(
          children: [
            // Header
            CurvedHeader(
              showBackButton: true,
              onBack: _onBack,
              title: ResourceUiConstants.browseTitle,
              subtitle: ResourceUiConstants.browseSubtitle,
              subtitleColor: ResourceUiConstants.accentGold,
              bottomChild: SearchPillBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
              ),
            ),

            // Stream and Year Filter Chips
            _buildFilterChips(streams, selectedStream, selectedYear),

            // Department filter (visible when year >= 2 and stream is selected)
            if (showDepartments && departments.isNotEmpty)
              _buildDepartmentChips(departments, selectedDepartment),

            // Courses and Results List
            Expanded(
              child: coursesAsync.when(
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
                      selectedYear != null ||
                      _localFilter.isNotEmpty;

                  if (courses.isEmpty && resourceResults.isEmpty) {
                    return Center(
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
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedStream != null
                                  ? streams
                                          .where((s) => s.id == selectedStream)
                                          .firstOrNull
                                          ?.name ??
                                      ResourceUiConstants.freshmanCourses
                                  : ResourceUiConstants.freshmanCourses,
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

                        // Matching courses
                        ...courses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CourseCard(
                              course: course,
                              onTap: () {
                                _searchFocusNode.unfocus();
                                context.push(
                                  RouteNames.courseDetail,
                                  extra: course,
                                );
                              },
                            ),
                          ),
                        ),

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
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load courses.\n$err',
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
            ),
          ],
        ),
      ),
    );
  }
}
