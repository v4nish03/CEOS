import 'package:dio/dio.dart';
import 'package:ceos/features/auth/domain/entities/user_entity.dart';
import 'package:ceos/features/auth/data/models/user_model.dart';
import '../../domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final Dio _dio;

  UsersRepositoryImpl(this._dio);

  @override
  Future<List<UserEntity>> getUsers() async {
    final response = await _dio.get('/usuarios');
    final List data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<void> createUser({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  }) async {
    await _dio.post('/usuarios', data: {
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
    });
  }
}
