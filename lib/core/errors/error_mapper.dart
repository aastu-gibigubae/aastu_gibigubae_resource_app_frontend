import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    final normalized = code.toLowerCase();
    switch (normalized) {
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
        return const InvalidCredentialsFailure();
      case 'session_expired':
        return const SessionExpiredFailure();
      case 'email_already_exists':
        return ValidationFailure(
            message ?? 'An account with this email already exists. Please log in.');
      case 'validation_error':
        return ValidationFailure(
            message ?? 'Validation failed. Please check your inputs.');
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

  // ── Document / PDF Errors ──────────────────────────────────────

  /// Converts document loading, caching, or file resolution errors into a Failure
  /// without exposing low-level paths, sockets, or platform stack traces.
  static Failure fromDocumentError(Object error) {
    debugPrint('[ErrorMapper] Document error: $error');

    if (error is Failure) return error;
    if (error is DioException) return fromDioException(error);
    if (error is AppException) return fromAppException(error);

    final str = error.toString().toLowerCase();

    if (str.contains('socketexception') ||
        str.contains('network is unreachable') ||
        str.contains('failed host lookup') ||
        str.contains('connection refused') ||
        str.contains('connection reset') ||
        str.contains('handshake') ||
        str.contains('clientexception')) {
      return const NetworkFailure(
        'Unable to connect to download the document. Please check your internet connection.',
      );
    }

    if (str.contains('timeoutexception') || str.contains('timed out')) {
      return const TimeoutFailure(
        'Connection timed out while loading the document. Please try again.',
      );
    }

    if (str.contains('404') || str.contains('not found')) {
      return const DocumentFailure(
        'The requested document is not currently available.',
      );
    }

    if (str.contains('403') || str.contains('unauthorized')) {
      return const PremiumRequiredFailure(
        'This document requires active premium access.',
      );
    }

    if (str.contains('filenotfound') ||
        str.contains('pathnotfound') ||
        str.contains('no such file')) {
      return const DocumentFailure(
        'Document file could not be found on device storage.',
      );
    }

    if (str.contains('format') ||
        str.contains('corrupt') ||
        str.contains('pdf') ||
        str.contains('invalid')) {
      return const DocumentFailure(
        'Unable to open document. The file may be damaged or in an unsupported format.',
      );
    }

    return const DocumentFailure(
      'Could not load the document. Please try again.',
    );
  }

  /// Converts PDFView rendering errors (from onError callback) into a user-friendly Failure.
  static Failure fromPdfRenderError(Object? error) {
    debugPrint('[ErrorMapper] PDF render error: $error');
    if (error == null) {
      return const DocumentFailure(
        'Unable to display document. The file may be damaged or in an unsupported format.',
      );
    }
    final str = error.toString().toLowerCase();
    if (str.contains('password') || str.contains('encrypt')) {
      return const DocumentFailure(
        'This document is password protected and cannot be opened.',
      );
    }
    return const DocumentFailure(
      'Unable to display document. The file may be damaged or in an unsupported format.',
    );
  }

  /// Safe, user-facing error message extractor.
  /// Never leaks stack traces, class names, internal file paths, or sensitive exceptions.
  static String userMessage(
    Object error, {
    String? defaultMessage,
  }) {
    debugPrint('[ErrorMapper] userMessage: $error');

    if (error is Failure) return error.message;
    if (error is DioException) return fromDioException(error).message;
    if (error is AppException) return fromAppException(error).message;

    final str = error.toString().toLowerCase();

    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (str.contains('timeoutexception') || str.contains('timed out')) {
      return 'The request timed out. Please try again.';
    }

    if (str.contains('filesystemexception') ||
        str.contains('permission denied') ||
        str.contains('no space left')) {
      return 'Unable to access device storage. Please check permissions and available space.';
    }

    if (str.contains('sqliteexception') || str.contains('database')) {
      return 'Unable to update local app database. Please try again.';
    }

    if (defaultMessage != null && defaultMessage.isNotEmpty) {
      return defaultMessage;
    }

    final cleaned = _cleanMessage(error.toString());
    if (cleaned.contains(r'\') ||
        cleaned.contains(r'/') ||
        cleaned.contains('Exception') ||
        cleaned.contains('Error:')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return cleaned.isNotEmpty
        ? cleaned
        : 'An unexpected error occurred. Please try again.';
  }

  // ── Generic catch → Failure ───────────────────────────────────

  static Failure fromError(Object error) {
    if (error is Failure) return error;
    if (error is DioException) return fromDioException(error);
    if (error is AppException) return fromAppException(error);
    return UnknownFailure(_cleanMessage(error.toString()));
  }

  static String _cleanMessage(String raw) {
    var cleaned = raw;
    final match =
        RegExp(r'message:\s*([^,\)\n]+)', caseSensitive: false).firstMatch(cleaned);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    cleaned = cleaned.replaceAll(
        RegExp(r'^DioException\s*\[.*?\]:\s*', caseSensitive: false), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '');
    return cleaned.trim();
  }
}
