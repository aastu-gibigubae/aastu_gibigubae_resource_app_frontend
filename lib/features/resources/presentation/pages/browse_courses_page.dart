import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync =
        ref.watch(coursesProvider(const CoursesParams()));

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

            // Courses List
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

                  if (courses.isEmpty) {
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
                                  ? 'No courses matching "$_localFilter"'
                                  : 'No courses available yet.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              ResourceUiConstants.freshmanCourses,
                              style: TextStyle(
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
                        const SizedBox(height: 16),
                        ...courses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CourseCard(
                              course: course,
                              onTap: () {
                                _searchFocusNode.unfocus();
                                context.push(
                                  RouteNames.courseDetail,
                                  extra: course.id,
                                );
                              },
                            ),
                          ),
                        ),
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
                            coursesProvider(const CoursesParams()),
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
