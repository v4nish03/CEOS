import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CeosNavigationScaffold extends ConsumerWidget {
  const CeosNavigationScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.actions,
  });

  final String title;
  final String currentRoute;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).session;
    final items = _navItemsForRole(session?.role);
    final currentIndex = items.indexWhere((item) => item.route == currentRoute);

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(title),
        actions: [
          ...?actions,
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        destinations: [
          for (final item in items)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
        onDestinationSelected: (index) {
          final target = items[index].route;
          if (target != currentRoute) context.go(target);
        },
      ),
    );
  }

  List<_NavItem> _navItemsForRole(UserRole? role) {
    final items = <_NavItem>[
      const _NavItem(route: '/dashboard', label: 'Inicio', icon: Icons.dashboard_outlined),
      const _NavItem(route: '/inventory', label: 'Inventario', icon: Icons.inventory_2_outlined),
      const _NavItem(route: '/reports', label: 'Reportes', icon: Icons.analytics_outlined),
    ];
    if (role == UserRole.superadmin || role == UserRole.admin) {
      items.add(const _NavItem(route: '/users', label: 'Usuarios', icon: Icons.groups_2_outlined));
    }
    return items;
  }
}

class _NavItem {
  const _NavItem({required this.route, required this.label, required this.icon});
  final String route;
  final String label;
  final IconData icon;
}
