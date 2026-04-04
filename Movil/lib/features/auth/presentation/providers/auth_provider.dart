import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ceos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({this.session, this.loading = false, this.error});
  final AuthSession? session;
  final bool loading;
  final String? error;

  AuthState copyWith({AuthSession? session, bool? loading, String? error}) {
    return AuthState(
      session: session ?? this.session,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._loginUseCase, this._repository) : super(const AuthState());

  final LoginUseCase _loginUseCase;
  final AuthRepositoryImpl _repository;

  Future<void> bootstrap() async {
    final session = await _repository.restoreSession();
    state = state.copyWith(session: session);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final session = await _loginUseCase(email, password);
      state = state.copyWith(session: session, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false, error: 'No se pudo iniciar sesión');
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    AuthRemoteDatasource(ref.watch(dioProvider)),
    ref.watch(secureStorageProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(LoginUseCase(repository), repository);
});

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authNotifierProvider.notifier).bootstrap();
});
