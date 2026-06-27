import 'package:ceos/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      // Mapeo de la respuesta del backend a nuestra entidad
      return UserEntity(
        id: '0', // No viene en el login, pero no importa para el token
        name: response.data['nombre'] ?? '',
        email: email,
        role: response.data['rol'] ?? 'UNKNOWN',
        token: response.data['access_token'] ?? '',
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error de conexión');
    }
  }

  @override
  Future<UserEntity> checkAuthStatus(String token) async {
    // Endpoint para validar si el token sigue vivo
    final response = await _dio.get('/usuarios/me', 
      options: Options(headers: {'Authorization': 'Bearer $token'})
    );
    return UserEntity(
      id: response.data['id'].toString(),
      name: response.data['nombre'] ?? '',
      email: response.data['email'] ?? '',
      role: response.data['rol'] ?? 'UNKNOWN',
      token: token,
    );
  }
}