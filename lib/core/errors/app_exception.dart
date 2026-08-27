/// ================================================================
/// APP EXCEPTION
///
/// Typed exceptions thrown throughout the app before being
/// mapped to Failure objects by error_mapper.dart.
/// ================================================================

/// Base class for all application exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => '$runtimeType(message: $message, code: $statusCode)';
}

// ── Network ──────────────────────────────────────────────────────

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection.'});
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timed out.'});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

// ── Auth ─────────────────────────────────────────────────────────

class UnauthorisedException extends AppException {
  const UnauthorisedException(
      {super.message = 'Session expired. Please log in again.'});
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException(
      {super.message = 'Invalid email or password.'});
}

// ── Premium ───────────────────────────────────────────────────────

class PremiumRequiredException extends AppException {
  const PremiumRequiredException(
      {super.message = 'This resource requires a premium subscription.'});
}

// ── Device ───────────────────────────────────────────────────────

class DeviceMismatchException extends AppException {
  const DeviceMismatchException(
      {super.message = 'This account is linked to a different device.'});
}

class ReverificationOverdueException extends AppException {
  const ReverificationOverdueException(
      {super.message =
          'Re-verification required. Please connect to the internet.'});
}

// ── Cache ────────────────────────────────────────────────────────

class CacheException extends AppException {
  const CacheException({required super.message});
}

// ── Validation ───────────────────────────────────────────────────

class ValidationException extends AppException {
  const ValidationException({required super.message});
}

// ── Unknown ──────────────────────────────────────────────────────

class UnknownException extends AppException {
  const UnknownException({super.message = 'An unexpected error occurred.'});
}
