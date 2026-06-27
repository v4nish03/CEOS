import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/auth/presentation/widgets/dashboard_view.dart';
import 'package:ceos/features/home/presentation/screens/more_screen.dart';
import 'package:ceos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:ceos/features/reports/presentation/screens/reports_screen.dart';
import 'package:ceos/features/request/presentation/screens/requests_screen.dart';
import 'package:ceos/features/users/presentation/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final role = ref.watch(authProvider).role ?? 'DOCTOR';
    final destinations = _destinationsForRole(role);

    int safeIndex = selectedIndex;
    if (safeIndex >= destinations.length) {
      safeIndex = 0;
      Future.microtask(() => ref.read(navigationIndexProvider.notifier).state = 0);
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: destinations.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) => ref.read(navigationIndexProvider.notifier).state = index,
        destinations: destinations
            .map((item) => NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label))
            .toList(),
      ),
    );
  }

  List<_RoleDestination> _destinationsForRole(String role) {
    final base = <_RoleDestination>[
      const _RoleDestination(label: 'Inicio', icon: Icons.home_outlined, selectedIcon: Icons.home, screen: DashboardView()),
    ];

    switch (role) {
      case 'DOCTOR':
        return [
          ...base,
          const _RoleDestination(label: 'Materiales', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, screen: InventoryScreen()),
          const _RoleDestination(label: 'Solicitudes', icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, screen: RequestsScreen()),
          const _RoleDestination(label: 'Más', icon: Icons.more_horiz, selectedIcon: Icons.more, screen: MoreScreen()),
        ];
      case 'INVENTARIO':
        return [
          ...base,
          const _RoleDestination(label: 'Inventario', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, screen: InventoryScreen()),
          const _RoleDestination(label: 'Solicitudes', icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, screen: RequestsScreen()),
          const _RoleDestination(label: 'Reportes', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, screen: ReportsScreen()),
          const _RoleDestination(label: 'Más', icon: Icons.more_horiz, selectedIcon: Icons.more, screen: MoreScreen()),
        ];
      case 'SUPERADMIN':
        return [
          ...base,
          const _RoleDestination(label: 'Usuarios', icon: Icons.people_outline, selectedIcon: Icons.people, screen: UsersScreen()),
          const _RoleDestination(label: 'Inventario', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, screen: InventoryScreen()),
          const _RoleDestination(label: 'Solicitudes', icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, screen: RequestsScreen()),
          const _RoleDestination(label: 'Reportes', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, screen: ReportsScreen()),
          const _RoleDestination(label: 'Más', icon: Icons.more_horiz, selectedIcon: Icons.more, screen: MoreScreen()),
        ];
      case 'ADMIN':
      default:
        return [
          ...base,
          const _RoleDestination(label: 'Usuarios', icon: Icons.people_outline, selectedIcon: Icons.people, screen: UsersScreen()),
          const _RoleDestination(label: 'Inventario', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, screen: InventoryScreen()),
          const _RoleDestination(label: 'Solicitudes', icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, screen: RequestsScreen()),
          const _RoleDestination(label: 'Reportes', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, screen: ReportsScreen()),
          const _RoleDestination(label: 'Más', icon: Icons.more_horiz, selectedIcon: Icons.more, screen: MoreScreen()),
        ];
    }
  }
}

class _RoleDestination {
  const _RoleDestination({required this.label, required this.icon, required this.selectedIcon, required this.screen});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}

List<String> getLabelsForRole(String role) {
  final base = ['inicio'];
  switch (role) {
    case 'DOCTOR':
      return [...base, 'materiales', 'solicitudes', 'más'];
    case 'INVENTARIO':
      return [...base, 'inventario', 'solicitudes', 'reportes', 'más'];
    case 'SUPERADMIN':
      return [...base, 'usuarios', 'inventario', 'solicitudes', 'reportes', 'más'];
    case 'ADMIN':
    default:
      return [...base, 'usuarios', 'inventario', 'solicitudes', 'reportes', 'más'];
  }
}
