import 'package:ceos/features/auth/domain/entities/user_entity.dart';

abstract class UsersRepository {
  Future<List<UserEntity>> getUsers();
  Future<void> createUser({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  });
}
