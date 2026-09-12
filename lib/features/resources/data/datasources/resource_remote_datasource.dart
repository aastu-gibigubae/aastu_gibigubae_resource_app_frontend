import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/course_model.dart';
import '../models/department_model.dart';
import '../models/issue_report_model.dart';
import '../models/pagination_model.dart';
import '../models/search_result_model.dart';
import '../models/stream_model.dart';
import '../models/student_resource_model.dart';

// Remote datasource for all resource/catalog API calls.
// Uses the app's shared Dio instance (with auth interceptor already attached).
class ResourceRemoteDatasource {
  final Dio _dio;

  const ResourceRemoteDatasource(this._dio);

  // GET /streams
  Future<List<StreamModel>> getStreams() async {
    final response = await _dio.get(ApiConstants.streams);
    final data = response.data as Map<String, dynamic>;
    final list = data['streams'] as List;
    return list
        .map((e) => StreamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /departments?stream_id=
  Future<List<DepartmentModel>> getDepartments({required int streamId}) async {
    final response = await _dio.get(
      ApiConstants.departments,
      queryParameters: {'stream_id': streamId},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['departments'] as List;
    return list
        .map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /courses?stream_id=&department_id=&year=&page=&limit=
  Future<({List<CourseModel> courses, PaginationModel pagination})> getCourses({
    int? streamId,
    int? departmentId,
    int? year,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (streamId != null) queryParams['stream_id'] = streamId;
    if (departmentId != null) queryParams['department_id'] = departmentId;
    if (year != null) queryParams['year'] = year;

    final response = await _dio.get(
      ApiConstants.courses,
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    final coursesList = (data['courses'] as List)
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>);

    return (courses: coursesList, pagination: pagination);
  }

  // GET /courses/{id}/resources?category=&page=&limit=
  Future<
      ({
        List<StudentResourceModel> resources,
        PaginationModel pagination,
      })> getCourseResources({
    required int courseId,
    required String category,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.courseResources(courseId.toString()),
      queryParameters: {
        'category': category,
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final resourcesList = (data['resources'] as List)
        .map((e) => StudentResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination =
        PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>);

    return (resources: resourcesList, pagination: pagination);
  }

  // GET /search?q=
  Future<List<SearchResultModel>> search({required String query}) async {
    final response = await _dio.get(
      ApiConstants.search,
      queryParameters: {'q': query},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['results'] as List;
    return list
        .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // POST /resources/{id}/report
  Future<IssueReportMinimalModel> reportResource({
    required int resourceId,
    required String reason,
    String? otherText,
  }) async {
    final body = <String, dynamic>{'reason': reason};
    if (otherText != null && otherText.isNotEmpty) {
      body['other_text'] = otherText;
    }

    final response = await _dio.post(
      ApiConstants.withId(ApiConstants.reportResource, resourceId.toString()),
      data: body,
    );
    return IssueReportMinimalModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
