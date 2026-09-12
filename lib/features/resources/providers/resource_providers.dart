import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/errors/error_mapper.dart';
import '../../resources/data/models/pagination_model.dart';
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

// Streams provider
final streamsProvider =
    AutoDisposeFutureProvider<List<StreamItem>>((ref) async {
  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    final models = await ds.getStreams();
    return models
        .map((m) => StreamItem(id: m.id, name: m.name))
        .toList();
  } on DioException catch (e) {
    throw ErrorMapper.fromDioException(e);
  }
});

// Courses provider with optional filters
class CoursesParams {
  final int? streamId;
  final int? departmentId;
  final int? year;
  final int page;

  const CoursesParams({
    this.streamId,
    this.departmentId,
    this.year,
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
    final courses = result.courses
        .map((m) => CourseItem.fromJson({
              'id': m.id,
              'department_id': m.departmentId,
              'academic_year': m.academicYear,
              'name': m.name,
            }))
        .toList();
    return (courses: courses, pagination: result.pagination);
  } on DioException catch (e) {
    throw ErrorMapper.fromDioException(e);
  }
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
  final ds = ref.watch(resourceRemoteDatasourceProvider);
  try {
    final result = await ds.getCourseResources(
      courseId: params.courseId,
      category: params.category.apiValue,
      page: params.page,
    );
    final resources = result.resources
        .map((m) => ResourceItem(
              id: m.id,
              courseId: params.courseId,
              title: m.title,
              description: m.description,
              category: m.categoryType,
              isFreeSample: m.isFreeSample,
              locked: m.locked,
              reasonCode: m.reasonCode,
              message: m.message,
              fileUrl: m.fileUrl,
              fileSizeBytes: m.fileSizeBytes ?? 0,
              checksum: m.checksum,
            ))
        .toList();
    return (resources: resources, pagination: result.pagination);
  } on DioException catch (e) {
    throw ErrorMapper.fromDioException(e);
  }
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
  } on DioException catch (e) {
    throw ErrorMapper.fromDioException(e);
  }
});
