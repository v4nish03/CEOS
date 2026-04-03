import 'package:ceos/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/usuarios');
  return response.data as List<dynamic>;
});
