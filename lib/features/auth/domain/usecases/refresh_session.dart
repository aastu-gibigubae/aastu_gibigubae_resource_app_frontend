import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// ================================================================
/// REFRESH SESSION USE CASE
/// ================================================================

class RefreshSessionUseCase {
  final AuthRepository _repository;

  const RefreshSessionUseCase(this._repository);

  /// Returns the new access token, or throws a [SessionExpiredFailure]
  /// if the refresh token is invalid or expired.
  Future<String> call() async {
    try {
      return await _repository.refreshSession();
    } catch (e) {
      if (e is Failure) throw e;
      throw SessionExpiredFailure(e.toString());
    }
  }
}
