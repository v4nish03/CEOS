import 'package:ceos/features/auth/data/models/login_response_model.dart';
import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._dio);
  final Dio _dio;

  Future<LoginResponseModel> login(String email, String password) async {
    final response = await _dio.post('/login', data: {'email': email, 'password': password});
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
