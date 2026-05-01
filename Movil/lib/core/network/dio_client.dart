import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1', // Usamos 127.0.0.1 gracias a adb reverse
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  // Agregamos el interceptor para que todas las peticiones lleven el token
  dio.interceptors.add(AuthInterceptor());

  return dio;
});