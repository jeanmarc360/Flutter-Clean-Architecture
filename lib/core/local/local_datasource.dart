import 'package:flutter_provider/core/local/secure_storage_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_datasource.g.dart';

@riverpod
LocalDataSource localDataSource(Ref ref) {
  return LocalDataSource(ref.watch(secureStorageProvider));
}

class LocalDataSource {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage;

  LocalDataSource(this._secureStorage);

  // --- Secure (token, données sensibles) ---

  Future<void> saveToken(String token) =>
      _secureStorage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _secureStorage.read(key: _tokenKey);

  Future<void> clearToken() => _secureStorage.delete(key: _tokenKey);

}
