import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

// Remote datasource for notification API calls.
class NotificationRemoteDatasource {
  final Dio _dio;

  const NotificationRemoteDatasource(this._dio);

  // GET /notifications
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    final data = response.data as Map<String, dynamic>;
    final list = data['notifications'] as List;
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // POST /notifications/{id}/read
  Future<void> markAsRead({required int notificationId}) async {
    await _dio.post(
      ApiConstants.withId(
        ApiConstants.markNotificationRead,
        notificationId.toString(),
      ),
    );
  }
}
