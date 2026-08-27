import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../core/device/device_fingerprint_service.dart';
import '../../core/device/device_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/cache_manager.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/refresh_session.dart';
import '../../features/auth/domain/usecases/signup.dart';
import '../router/app_router.dart';
import '../router/route_guards.dart';

/// ================================================================
/// APP PROVIDERS
///
/// Global providers wired here so they are available app-wide.
/// Feature-specific providers live in `features/<feature>/providers/`.
/// ================================================================

// ── Infrastructure ──────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final deviceInfoProvider = Provider<DeviceInfoPlugin>((ref) {
  return DeviceInfoPlugin();
});

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService(ref.watch(deviceInfoProvider));
});

final deviceFingerprintServiceProvider =
    Provider<DeviceFingerprintService>((ref) {
  return DeviceFingerprintService(
    deviceService: ref.watch(deviceServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return const CacheManager();
});

// ── Networking ──────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(
    secureStorage: ref.watch(secureStorageProvider),
    onSessionExpired: () {
      // The auth provider listens and handles redirect.
    },
  );
});

// ── Auth data layer ─────────────────────────────────────────────

final authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

// ── Auth use cases ──────────────────────────────────────────────

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  return SignupUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final refreshSessionUseCaseProvider = Provider<RefreshSessionUseCase>((ref) {
  return RefreshSessionUseCase(ref.watch(authRepositoryProvider));
});

// ── Router ──────────────────────────────────────────────────────

final routeGuardsProvider = Provider<RouteGuards>((ref) {
  return RouteGuards(ref.watch(secureStorageProvider));
});

final routerProvider = Provider((ref) {
  return createRouter(guards: ref.watch(routeGuardsProvider));
});
