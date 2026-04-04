import 'package:ceos/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) => _storage.write(key: AppConstants.tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);
  Future<void> clearSession() => _storage.delete(key: AppConstants.tokenKey);
}
