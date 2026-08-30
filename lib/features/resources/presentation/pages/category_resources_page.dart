import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/resource_category_type.dart';
import '../../domain/entities/resource_item.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/resource_item_card.dart';

class CategoryResourcesPage extends StatefulWidget {
  final int courseId;
  final ResourceCategoryType category;

  const CategoryResourcesPage({
    super.key,
    required this.courseId,
    required this.category,
  });

  @override
  State<CategoryResourcesPage> createState() => _CategoryResourcesPageState();
}

class _CategoryResourcesPageState extends State<CategoryResourcesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final MockResourceDatasource _datasource = const MockResourceDatasource();
  late List<ResourceItem> _resources;

  @override
  void initState() {
    super.initState();
    _resources = _datasource.getCategoryResources(
      courseId: widget.courseId,
      category: widget.category,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      final all = _datasource.getCategoryResources(
        courseId: widget.courseId,
        category: widget.category,
      );
      if (query.trim().isEmpty) {
        _resources = all;
      } else {
        _resources = all
            .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = _datasource.getCourseById(widget.courseId);

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
              onBack: () {
                _searchFocusNode.unfocus();
                context.pop();
              },
              title: course.name,
              subtitle: widget.category.label,
              subtitleColor: ResourceUiConstants.accentGold,
              bottomChild: SearchPillBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
              ),
            ),

            // Resource List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: _resources.length,
                itemBuilder: (context, index) {
                  final resource = _resources[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ResourceItemCard(
                      resource: resource,
                      onTap: () {
                        _searchFocusNode.unfocus();
                        context.push(
                          RouteNames.resourceDetail,
                          extra: resource.id,
                        );
                      },
                      onDownload: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${resource.title}...'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
