import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../auth/providers/session_provider.dart';
import '../../resources/data/models/pagination_model.dart';
import '../data/datasources/mock_resource_datasource.dart';
import '../data/datasources/resource_download_service.dart';
import '../data/datasources/resource_remote_datasource.dart';
import '../data/models/search_result_model.dart';
import '../domain/entities/course_item.dart';
import '../domain/entities/resource_category_type.dart';
import '../domain/entities/resource_item.dart';
import '../domain/entities/stream_item.dart';

// Datasource provider
final resourceRemoteDatasourceProvider =
    Provider<ResourceRemoteDatasource>((ref) {
  return ResourceRemoteDatasource(ref.watch(dioProvider));
});

// In-app sandbox download service provider
final resourceDownloadServiceProvider =
    Provider<ResourceDownloadService>((ref) {
  return ResourceDownloadService(ref.watch(dioProvider));
});

// Reactively checks if a resource is saved in the app's internal sandbox
final isResourceDownloadedProvider =
    FutureProvider.family<bool, int>((ref, resourceId) async {
  final service = ref.watch(resourceDownloadServiceProvider);
  return service.isResourceDownloaded(resourceId);
});

// Returns list of all downloaded resource IDs
final downloadedResourceIdsProvider =
    FutureProvider<List<int>>((ref) async {
  final service = ref.watch(resourceDownloadServiceProvider);
  return service.getDownloadedResourceIds();
});

// Streams provider
// Streams are a tiny, bounded list (2 items). Mock fallback is acceptable
// here since these rarely change and the backend may be cold-starting.
final streamsProvider =
    AutoDisposeFutureProvider<List<StreamItem>>((ref) async {
  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    final models = await ds.getStreams();
    if (models.isNotEmpty) {
      return models
          .map((m) => StreamItem(id: m.id, name: m.name))
          .toList();
    }
  } catch (e) {
    debugPrint('[streamsProvider] Remote fetch failed ($e), using fallback.');
  }
  return MockResourceDatasource.streams;
});

// Departments provider — fetches departments for a given stream.
// Only relevant for Year 2+ where courses are department-specific.
final departmentsProvider =
    AutoDisposeFutureProvider.family<List<({int id, String name})>, int>(
        (ref, streamId) async {
  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    final models = await ds.getDepartments(streamId: streamId);
    return models.map((m) => (id: m.id, name: m.name)).toList();
  } catch (e) {
    debugPrint(
        '[departmentsProvider] Remote fetch failed ($e), returning empty.');
    return [];
  }
});

// Stream selection filter provider for Browse Courses
final selectedStreamFilterProvider = StateProvider<int?>((ref) => null);
final selectedYearFilterProvider = StateProvider<int?>((ref) => 1);
final selectedDepartmentFilterProvider = StateProvider<int?>((ref) => null);

// Icon resolver for courses returned by backend API
String _resolveCourseIconKey(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('english') || lower.contains('communicative')) return 'english';
  if (lower.contains('math') || lower.contains('calculus') || lower.contains('algebra')) return 'math';
  if (lower.contains('physic')) return 'physics';
  if (lower.contains('logic') || lower.contains('critical')) return 'logic';
  if (lower.contains('psychology')) return 'psychology';
  if (lower.contains('chem')) return 'physics';
  if (lower.contains('programming') || lower.contains('computer') || lower.contains('c++')) return 'logic';
  return 'book';
}

// Courses provider with optional filters (Freshman = Year 1)
class CoursesParams {
  final int? streamId;
  final int? departmentId;
  final int year;
  final int page;

  const CoursesParams({
    this.streamId,
    this.departmentId,
    this.year = 1,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoursesParams &&
          streamId == other.streamId &&
          departmentId == other.departmentId &&
          year == other.year &&
          page == other.page;

  @override
  int get hashCode => Object.hash(streamId, departmentId, year, page);
}

final coursesProvider = AutoDisposeFutureProvider.family<
    ({List<CourseItem> courses, PaginationModel pagination}),
    CoursesParams>((ref, params) async {
  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    final result = await ds.getCourses(
      streamId: params.streamId,
      departmentId: params.departmentId,
      year: params.year,
      page: params.page,
    );
    // If backend returns courses, map and return them
    if (result.courses.isNotEmpty) {
      final courses = result.courses
          .map((m) => CourseItem(
                id: m.id,
                departmentId: m.departmentId,
                name: m.name,
                academicYear: m.academicYear,
                iconKey: _resolveCourseIconKey(m.name),
                resourceCount: 16,
                semesterLabel: 'Semester 1',
              ))
          .toList();
      return (courses: courses, pagination: result.pagination);
    }
  } catch (e) {
    debugPrint('[coursesProvider] Remote fetch failed ($e), using fallback.');
  }

  // Graceful fallback for freshman courses when backend database is not yet seeded
  var fallbackCourses = MockResourceDatasource.freshmanCourses;
  if (params.year != 0) {
    fallbackCourses = fallbackCourses
        .where((c) => c.academicYear == params.year)
        .toList();
  }
  return (
    courses: fallbackCourses,
    pagination: PaginationModel(
      page: params.page,
      limit: 20,
      total: fallbackCourses.length,
      totalPages: 1,
    ),
  );
});

// Course resources provider
class CourseResourcesParams {
  final int courseId;
  final ResourceCategoryType category;
  final int page;

  const CourseResourcesParams({
    required this.courseId,
    required this.category,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseResourcesParams &&
          courseId == other.courseId &&
          category == other.category &&
          page == other.page;

  @override
  int get hashCode => Object.hash(courseId, category, page);
}

final courseResourcesProvider = AutoDisposeFutureProvider.family<
    ({List<ResourceItem> resources, PaginationModel pagination}),
    CourseResourcesParams>((ref, params) async {
  final isPremium = await ref.watch(isPremiumProvider.future);
  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    final result = await ds.getCourseResources(
      courseId: params.courseId,
      category: params.category.apiValue,
      page: params.page,
    );
    // Accept the API result even if empty — empty means no resources exist
    // for this (course, category) pair yet. The UI should show "No resources"
    // instead of fake mock data.
    final resources = result.resources
        .map((m) => ResourceItem(
              id: m.id,
              courseId: params.courseId,
              title: m.title,
              description: m.description,
              category: m.categoryType,
              isFreeSample: m.isFreeSample,
              locked: isPremium ? false : m.locked,
              reasonCode: isPremium ? null : m.reasonCode,
              message: isPremium ? null : m.message,
              fileUrl: m.fileUrl,
              fileSizeBytes: m.fileSizeBytes ?? 0,
              checksum: m.checksum,
            ))
        .toList();
    return (resources: resources, pagination: result.pagination);
  } catch (e) {
    debugPrint(
        '[courseResourcesProvider] Remote fetch failed ($e), using fallback.');
  }

  // Mock fallback only on network/parse error — never on empty API results.
  final rawFallback = const MockResourceDatasource()
      .getCategoryResources(courseId: params.courseId, category: params.category);
  final fallbackList = rawFallback.map((item) {
    if (isPremium || item.isFreeSample) {
      return item;
    }
    return ResourceItem(
      id: item.id,
      courseId: item.courseId,
      title: item.title,
      description: item.description,
      category: item.category,
      isFreeSample: item.isFreeSample,
      locked: true,
      reasonCode: 'premium_required',
      message: 'Upgrade to Premium to access this resource.',
      fileUrl: null,
      fileSizeBytes: item.fileSizeBytes,
      checksum: item.checksum,
      courseName: item.courseName,
      semester: item.semester,
      academicYear: item.academicYear,
    );
  }).toList();

  return (
    resources: fallbackList,
    pagination: PaginationModel(
      page: params.page,
      limit: 20,
      total: fallbackList.length,
      totalPages: 1,
    ),
  );
});

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    AutoDisposeFutureProvider<List<SearchResultModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    return await ds.search(query: query);
  } catch (e) {
    debugPrint('[searchResultsProvider] Search failed ($e)');
    return [];
  }
});
