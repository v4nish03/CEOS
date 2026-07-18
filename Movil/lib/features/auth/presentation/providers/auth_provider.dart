import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// 1. Estados de autenticación [cite: 316]
enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? role;
  final String? name;

  AuthState({
    this.status = AuthStatus.checking,
    this.token,
    this.role,
    this.name,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? role,
    String? name,
  }) => AuthState(
    status: status ?? this.status,
    token: token ?? this.token,
    role: role ?? this.role,
    name: name ?? this.name,
  );
}

// 2. Notifier con Inyección de Dependencias [cite: 328, 330]
class AuthNotifier extends StateNotifier<AuthState> {
  final SessionStorage _storage = SessionStorage();
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus(); // Bootstrap al iniciar [cite: 335]
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getToken();
    
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      // Punto 1.4: Validar sesión con el backend [cite: 212, 300]
      final user = await _authRepository.checkAuthStatus(token);
      final role = await _storage.getRole();
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        role: role ?? user.role,
        name: user.name,
      );
    } catch (e) {
      logout(); // Limpia sesión si el token expiró (401) [cite: 212, 327]
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.checking);
    try {
      // Punto 1.1: Enviar email/password al backend [cite: 208, 326]
      final user = await _authRepository.login(email, password);
      
      // Punto 1.2: Guardado de sesión [cite: 209, 322]
      await _storage.saveSession(
        token: user.token, 
        role: user.role,
        name: user.name,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: user.token,
        role: user.role,
        name: user.name,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      rethrow; // Permite a la UI mostrar el error "Credenciales inválidas" [cite: 217]
    }
  }

  Future<void> logout() async {
    await _storage.clearSession(); // [cite: 324]
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      token: null,
      role: null,
      name: null,
    );
  }
}

// 3. Provider Global que inyecta la implementación de Data [cite: 327]
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl(); 
  return AuthNotifier(authRepository);
});