import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ================================================================
/// SECURE STORAGE
///
/// Thin wrapper around flutter_secure_storage.
/// Stores tokens and other sensitive key-value pairs.
/// ================================================================

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  /// Factory with recommended Android options (encrypted shared prefs).
  factory SecureStorage.create() {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    return SecureStorage(storage);
  }

  // ── CRUD ───────────────────────────────────────────────────────

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }
}
