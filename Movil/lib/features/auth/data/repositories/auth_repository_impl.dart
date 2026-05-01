import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'TU_URL_AQUI'));

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      // Mapeo de la respuesta del backend a nuestra entidad
      return UserEntity(
        id: response.data['user']['id'].toString(),
        name: response.data['user']['name'],
        email: response.data['user']['email'],
        role: response.data['user']['role'], // DOCTOR, ADMIN, etc
        token: response.data['token'],
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de conexión');
    }
  }

  @override
  Future<UserEntity> checkAuthStatus(String token) async {
    // Endpoint para validar si el token sigue vivo
    final response = await _dio.get('/auth/check-status', 
      options: Options(headers: {'Authorization': 'Bearer $token'})
    );
    return UserEntity(
      id: response.data['id'].toString(),
      name: response.data['name'],
      email: response.data['email'],
      role: response.data['role'],
      token: token,
    );
  }
}