import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../../../core/widgets/search_pill_bar.dart';
import '../../domain/entities/resource_category_type.dart';
import '../../domain/entities/resource_item.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
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

  Future<void> _downloadResource(ResourceItem resource) async {
    if (resource.fileUrl == null || resource.fileUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download URL not available.')),
      );
      return;
    }

    final uri = Uri.parse(resource.fileUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open download link.')),
      );
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            CurvedHeader(
              showBackButton: true,
              onBack: () {
                _searchFocusNode.unfocus();
                context.pop();
              },
              title: courseName.valueOrNull ?? 'Course',
              subtitle: widget.category.label,
              subtitleColor: ResourceUiConstants.accentGold,
              bottomChild: SearchPillBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: resourcesAsync.when(
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
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No resources found for this category.',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ResourceItemCard(
                          resource: resource,
                          onTap: () {
                            _searchFocusNode.unfocus();
                            context.push(
                              RouteNames.resourceDetail,
                              extra: resource,
                            );
                          },
                          onDownload: resource.locked
                              ? null
                              : () => _downloadResource(resource),
                        ),
                      );
                    },
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
                          'Could not load resources.\n$err',
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
            ),
          ],
        ),
      ),
    );
  }
}
