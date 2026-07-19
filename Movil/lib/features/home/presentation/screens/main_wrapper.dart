import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/auth/presentation/widgets/dashboard_view.dart';
import 'package:ceos/features/home/presentation/screens/more_screen.dart';
import 'package:ceos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:ceos/features/inventory/presentation/screens/movements_screen.dart';
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
      backgroundColor: const Color(0xFFF1F5F9),
      extendBody: true,
      body: IndexedStack(
        index: safeIndex,
        children: destinations.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(170),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withAlpha(220)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 12)),
                ],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIndex: safeIndex,
                onDestinationSelected: (index) => ref.read(navigationIndexProvider.notifier).state = index,
                destinations: destinations
                    .map((item) => NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_RoleDestination> _destinationsForRole(String role) {
    final permissions = permissionsForRole(role);
    final destinations = <_RoleDestination>[
      const _RoleDestination(label: 'Inicio', icon: Icons.home_outlined, selectedIcon: Icons.home, screen: DashboardView()),
    ];

    if (permissions.canViewUsers) {
      destinations.add(const _RoleDestination(label: 'Usuarios', icon: Icons.people_outline, selectedIcon: Icons.people, screen: UsersScreen()));
    }
    if (permissions.canViewInventory) {
      destinations.add(_RoleDestination(
        label: role == 'DOCTOR' ? 'Materiales' : 'Inventario',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        screen: const InventoryScreen(),
      ));
    }
    if (role == 'INVENTARIO') {
      destinations.add(const _RoleDestination(label: 'Movimientos', icon: Icons.swap_vert_outlined, selectedIcon: Icons.swap_vert, screen: MovementsScreen()));
    }
    if (permissions.canReviewRequests || permissions.canCreateRequests) {
      destinations.add(const _RoleDestination(label: 'Solicitudes', icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, screen: RequestsScreen()));
    }
    if (permissions.canViewReports) {
      destinations.add(const _RoleDestination(label: 'Reportes', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, screen: ReportsScreen()));
    }
    destinations.add(const _RoleDestination(label: 'Más', icon: Icons.more_horiz, selectedIcon: Icons.more, screen: MoreScreen()));

    return destinations;
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
  final permissions = permissionsForRole(role);
  final labels = ['inicio'];

  if (permissions.canViewUsers) labels.add('usuarios');
  if (permissions.canViewInventory) labels.add(role == 'DOCTOR' ? 'materiales' : 'inventario');
  if (role == 'INVENTARIO') labels.add('movimientos');
  if (permissions.canReviewRequests || permissions.canCreateRequests) labels.add('solicitudes');
  if (permissions.canViewReports) labels.add('reportes');
  labels.add('más');

  return labels;
}
