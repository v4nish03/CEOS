import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_bootstrap_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/main_wrapper.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    // Lógica de Redirección Automática
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isChecking = authState.status == AuthStatus.checking;
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      // Si está cargando el token, no redirigir aún
      if (isChecking) return null;

      // Si no está autenticado y no está en login, mandarlo a login
      if (!isLoggedIn && !isLoggingIn) return '/login';

      // Si ya está autenticado e intenta ir al login, mandarlo al inicio
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      // Pantalla de Logo/Carga inicial
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthBootstrapScreen(),
      ),
      // Pantalla de Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Pantalla Principal (Contiene el Dashboard y BottomBar)
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainWrapper(),
      ),
    ],
  );
});