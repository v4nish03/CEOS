import 'package:dio/dio.dart';
import '../storage/session_storage.dart';

class AuthInterceptor extends Interceptor {
  final SessionStorage _storage = SessionStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Recuperamos el token del storage
    final token = await _storage.getToken();

    // Si existe, lo inyectamos en la cabecera de CUALQUIER petición
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si el backend responde 401 (Unauthorized), podrías forzar logout aquí
    if (err.response?.statusCode == 401) {
      _storage.clearSession();
    }
    return handler.next(err);
  }
}