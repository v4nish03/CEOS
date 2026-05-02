import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../../data/repositories/request_repository_impl.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RequestRepositoryImpl(dio);
});

final requestsProvider = FutureProvider<List<RequestEntity>>((ref) async {
  final repo = ref.watch(requestRepositoryProvider);
  return await repo.getRequests();
});
