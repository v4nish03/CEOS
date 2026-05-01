import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'TU_URL_DE_BACKEND_AQUÍ', // Cambiar por la URL real
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  // Agregamos el interceptor para que todas las peticiones lleven el token
  dio.interceptors.add(AuthInterceptor());

  return dio;
});