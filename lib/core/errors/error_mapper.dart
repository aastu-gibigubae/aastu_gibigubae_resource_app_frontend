import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'failure.dart';

/// ================================================================
/// ERROR MAPPER
///
/// Converts low-level exceptions (Dio, platform, unknown) into
/// domain Failure objects that the UI can display.
///
/// Also maps backend reason_code strings to specific Failures.
/// ================================================================

class ErrorMapper {
  ErrorMapper._();

  // ── DioException → Failure ────────────────────────────────────

  static Failure fromDioException(DioException e) {
    // ErrorInterceptor already converted the error into a typed
    // AppException and stored it in e.error — unwrap it first.
    if (e.error is AppException) {
      return fromAppException(e.error as AppException);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _fromResponse(e.response);

      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled.');

      default:
        return const UnknownFailure();
    }
  }

  // ── HTTP Response → Failure ───────────────────────────────────

  static Failure _fromResponse(Response? response) {
    if (response == null) return const ServerFailure();

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract reason_code or message from backend body
    String? reasonCode;
    String? serverMessage;

    if (data is Map<String, dynamic>) {
      reasonCode = data['reason_code'] as String?;
      serverMessage = data['message'] as String?;

      final error = data['error'];
      if (error is Map<String, dynamic>) {
        reasonCode = (error['code'] as String?) ?? reasonCode;
        serverMessage = (error['message'] as String?) ?? serverMessage;
      }
    }

    // Map known backend reason codes first
    if (reasonCode != null) {
      return fromReasonCode(reasonCode, serverMessage);
    }

    // Fall back to HTTP status code
    switch (statusCode) {
      case 400:
        return ValidationFailure(serverMessage ?? 'Invalid request.');
      case 401:
        return SessionExpiredFailure(
            serverMessage ?? 'Session expired. Please log in again.');
      case 403:
        return AuthFailure(
            serverMessage ?? 'You do not have permission to do this.');
      case 404:
        return ServerFailure(serverMessage ?? 'Resource not found.');
      case 409:
        return ServerFailure(
            serverMessage ?? 'Conflict. Resource already exists.');
      case 422:
        return ValidationFailure(
            serverMessage ?? 'Validation failed on the server.');
      case >= 500:
        return ServerFailure(
            serverMessage ?? 'Server error. Please try again later.');
      default:
        return UnknownFailure(serverMessage ?? 'Unexpected error ($statusCode).');
    }
  }

  // ── Backend reason_code → Failure ─────────────────────────────

  static Failure fromReasonCode(String code, [String? message]) {
    switch (code) {
      case 'premium_required':
        return PremiumRequiredFailure(
            message ?? 'Upgrade to Premium to access this resource.');
      case 'device_mismatch':
        return DeviceMismatchFailure(
            message ?? 'This account is registered on another device.');
      case 'reverification_overdue':
        return ReverificationOverdueFailure(
            message ??
                'Re-verification required. Please connect to the internet.');
      case 'invalid_credentials':
      case 'INVALID_CREDENTIALS':
        return const InvalidCredentialsFailure();
      case 'session_expired':
        return const SessionExpiredFailure();
      default:
        return UnknownFailure(message ?? 'Unknown error: $code');
    }
  }

  // ── AppException → Failure ────────────────────────────────────

  static Failure fromAppException(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is TimeoutException) return TimeoutFailure(e.message);
    if (e is ServerException) {
      // 400 errors are validation failures — show the backend message directly.
      if (e.statusCode == 400 || e.statusCode == 422) {
        return ValidationFailure(e.message);
      }
      return ServerFailure(e.message);
    }
    if (e is UnauthorisedException) return SessionExpiredFailure(e.message);
    if (e is InvalidCredentialsException) {
      return InvalidCredentialsFailure(e.message);
    }
    if (e is PremiumRequiredException) return PremiumRequiredFailure(e.message);
    if (e is DeviceMismatchException) return DeviceMismatchFailure(e.message);
    if (e is ReverificationOverdueException) {
      return ReverificationOverdueFailure(e.message);
    }
    if (e is CacheException) return CacheFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return UnknownFailure(e.message);
  }

  // ── Generic catch → Failure ───────────────────────────────────

  static Failure fromError(Object error) {
    if (error is DioException) return fromDioException(error);
    if (error is AppException) return fromAppException(error);
    return UnknownFailure(error.toString());
  }
}
