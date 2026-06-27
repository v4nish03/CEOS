import 'package:dio/dio.dart';
import '../models/user_summary_model.dart';
import '../../domain/entities/user_summary_entity.dart';
import '../../domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final Dio _dio;

  UsersRepositoryImpl(this._dio);

  @override
  Future<List<UserSummaryEntity>> getUsers() async {
    final response = await _dio.get('/usuarios');
    final List data = response.data;
    return data.map((json) => UserSummaryModel.fromJson(json as Map<String, dynamic>)).toList();
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
