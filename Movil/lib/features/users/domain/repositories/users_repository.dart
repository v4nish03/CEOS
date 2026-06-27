import '../entities/user_summary_entity.dart';

abstract class UsersRepository {
  Future<List<UserSummaryEntity>> getUsers();
  Future<void> createUser({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  });
}
