import 'package:ceos/core/constants/app_constants.dart';
import 'package:ceos/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl, connectTimeout: const Duration(seconds: 20)));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await storage.clearSession();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => const SecureStorageService(FlutterSecureStorage()),
);
