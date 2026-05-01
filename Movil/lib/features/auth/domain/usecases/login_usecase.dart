import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Ejecuta la lógica de autenticación [cite: 39]
  Future<UserEntity> execute(String email, String password) async {
    // Aquí podrías agregar validaciones de formato antes de llamar al repo
    if (!email.contains('@')) throw Exception('Email no válido');
    
    return await _repository.login(email, password);
  }
}