import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this.repository);
  final AuthRepository repository;

  Future<AuthSession> call(String email, String password) {
    return repository.login(email, password);
  }
}
