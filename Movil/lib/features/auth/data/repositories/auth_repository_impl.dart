import 'package:ceos/core/storage/secure_storage_service.dart';
import 'package:ceos/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/domain/repositories/auth_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);
  final AuthRemoteDatasource _remote;
  final SecureStorageService _storage;

  @override
  Future<AuthSession> login(String email, String password) async {
    final model = await _remote.login(email, password);
    await _storage.saveToken(model.accessToken);
    return model.toEntity();
  }

  @override
  Future<void> logout() => _storage.clearSession();

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty || JwtDecoder.isExpired(token)) {
      await _storage.clearSession();
      return null;
    }
    final payload = JwtDecoder.decode(token);
    final role = (payload['role'] ?? payload['rol'] ?? 'DOCTOR').toString();
    final name = (payload['name'] ?? 'Usuario').toString();
    return AuthSession(
      token: token,
      name: name,
      role: role.toUpperCase() == 'SUPERADMIN'
          ? UserRole.superadmin
          : role.toUpperCase() == 'ADMIN'
              ? UserRole.admin
              : role.toUpperCase() == 'INVENTARIO'
                  ? UserRole.inventario
                  : UserRole.doctor,
    );
  }
}
