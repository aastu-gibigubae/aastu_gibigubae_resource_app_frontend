import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// ================================================================
/// ERROR INTERCEPTOR
///
/// Converts Dio errors into typed AppExceptions so all
/// repositories deal with a consistent error type.
/// ================================================================

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const TimeoutException(),
            type: err.type,
            response: err.response,
          ),
        );

      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(),
            type: err.type,
            response: err.response,
          ),
        );

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        String message = 'Server error ($statusCode).';
        String? reasonCode;

        if (data is Map<String, dynamic>) {
          message = (data['message'] as String?) ?? message;
          reasonCode = data['reason_code'] as String?;

          final error = data['error'];
          if (error is Map<String, dynamic>) {
            message = (error['message'] as String?) ?? message;
            reasonCode = (error['code'] as String?) ?? reasonCode;
          }
        }

        final AppException appEx = _fromStatus(statusCode, message, reasonCode);
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: appEx,
            type: err.type,
            response: err.response,
          ),
        );

      default:
        handler.next(err);
    }
  }

  AppException _fromStatus(int code, String message, String? reasonCode) {
    final normalizedCode = reasonCode?.toLowerCase();

    if (normalizedCode == 'invalid_credentials') {
      return InvalidCredentialsException(message: message);
    }

    if (reasonCode == 'premium_required') {
      return PremiumRequiredException(message: message);
    }
    if (reasonCode == 'device_mismatch') {
      return DeviceMismatchException(message: message);
    }
    if (reasonCode == 'reverification_overdue') {
      return ReverificationOverdueException(message: message);
    }

    switch (code) {
      case 401:
        return const UnauthorisedException();
      case 403:
        return ServerException(message: message, statusCode: code);
      default:
        return ServerException(message: message, statusCode: code);
    }
  }
}
