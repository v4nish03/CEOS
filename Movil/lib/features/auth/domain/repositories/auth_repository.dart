import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Define la acción de login y qué esperamos de vuelta
  Future<UserEntity> login(String email, String password);
  
  // Para el bootstrap: valida el token actual [cite: 43]
  Future<UserEntity> checkAuthStatus(String token);
}