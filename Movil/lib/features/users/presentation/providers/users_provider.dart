import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_summary_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../../data/repositories/users_repository_impl.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersRepositoryImpl(dio);
});

final usersProvider = FutureProvider<List<UserSummaryEntity>>((ref) async {
  final repo = ref.watch(usersRepositoryProvider);
  return await repo.getUsers();
});
