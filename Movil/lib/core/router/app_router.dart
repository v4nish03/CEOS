import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/auth/presentation/screens/login_screen.dart';
import 'package:ceos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ceos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:ceos/features/reports/presentation/screens/reports_screen.dart';
import 'package:ceos/features/users/presentation/screens/users_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = auth.session != null;
      final onLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !onLogin) return '/login';
      if (isLoggedIn && onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/inventory', builder: (_, __) => const InventoryScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
    ],
  );
});
