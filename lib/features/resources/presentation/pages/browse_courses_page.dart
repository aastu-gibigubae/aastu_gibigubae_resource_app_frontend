import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/course_item.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/course_card.dart';

class BrowseCoursesPage extends StatefulWidget {
  const BrowseCoursesPage({super.key});

  @override
  State<BrowseCoursesPage> createState() => _BrowseCoursesPageState();
}

class _BrowseCoursesPageState extends State<BrowseCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<CourseItem> _courses = MockResourceDatasource.freshmanCourses;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _courses = MockResourceDatasource.freshmanCourses;
      } else {
        _courses = MockResourceDatasource.freshmanCourses
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
      _courses = MockResourceDatasource.freshmanCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    ..._courses.map(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
