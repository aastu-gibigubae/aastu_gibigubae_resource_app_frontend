/// ================================================================
/// FAILURE
///
/// Immutable value objects representing domain-layer failures.
/// Use cases return Either<Failure, T>; UI reads the Failure
/// message to show user-friendly strings.
/// ================================================================

abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// ── Network ──────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

// ── Auth ─────────────────────────────────────────────────────────

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(
      [super.message = 'Invalid email or password.']);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure(
      [super.message = 'Session expired. Please log in again.']);
}

// ── Premium ───────────────────────────────────────────────────────

class PremiumRequiredFailure extends Failure {
  const PremiumRequiredFailure(
      [super.message = 'Upgrade to Premium to access this resource.']);
}

// ── Device ───────────────────────────────────────────────────────

class DeviceMismatchFailure extends Failure {
  const DeviceMismatchFailure(
      [super.message = 'This account is registered on another device.']);
}

class ReverificationOverdueFailure extends Failure {
  const ReverificationOverdueFailure(
      [super.message =
          'Re-verification required. Please connect to the internet.']);
}

// ── Cache ────────────────────────────────────────────────────────

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to read cached data.']);
}

// ── Validation ───────────────────────────────────────────────────

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Please check the form fields.']);
}

// ── Unknown ──────────────────────────────────────────────────────

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
