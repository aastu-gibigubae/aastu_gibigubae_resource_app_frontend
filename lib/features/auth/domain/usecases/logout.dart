import '../repositories/auth_repository.dart';

/// ================================================================
/// LOGOUT USE CASE
/// ================================================================

class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<void> call() async {
    await _repository.logout();
  }
}
