import 'dart:ui';

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
    final theme = Theme.of(context);

    int safeIndex = selectedIndex;
    if (safeIndex >= destinations.length) {
      safeIndex = 0;
      Future.microtask(() => ref.read(navigationIndexProvider.notifier).state = 0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 base
      extendBody: true,
      body: Stack(
        children: [
          // 🌌 Fondo Orgánico de Cristal: Esferas de luz sutiles para enriquecer el efecto glassmorphism
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withAlpha(25),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withAlpha(20), // Indigo pastel
              ),
            ),
          ),

          // 📱 Vistas principales montadas en Stack
          IndexedStack(
            index: safeIndex,
            children: destinations.map((item) => item.screen).toList(),
          ),
        ],
      ),

      // 💎 Cápsula Flotante de Cristal (Bottom Navigation Dock)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withAlpha(12), // Sombra hiper-suave Slate 900
                  blurRadius: 28,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: theme.primaryColor.withAlpha(8), // Resplandor orgánico suave
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Cristal esmerilado profundo
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(185), // Blended translucency
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withAlpha(230), // Borde brillante de cristal
                      width: 1.5,
                    ),
                  ),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      height: 68,
                      indicatorColor: theme.primaryColor.withAlpha(28),
                      indicatorShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      labelTextStyle: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B), // Slate 800
                            letterSpacing: 0.2,
                          );
                        }
                        return const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B), // Slate 500
                        );
                      }),
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return IconThemeData(
                            color: theme.primaryColor,
                            size: 24,
                          );
                        }
                        return const IconThemeData(
                          color: Color(0xFF64748B),
                          size: 22,
                        );
                      }),
                    ),
                    child: NavigationBar(
                      selectedIndex: safeIndex,
                      animationDuration: const Duration(milliseconds: 350),
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (index) =>
                          ref.read(navigationIndexProvider.notifier).state = index,
                      destinations: destinations
                          .map((item) => NavigationDestination(
                                icon: Icon(item.icon),
                                selectedIcon: Icon(item.selectedIcon),
                                label: item.label,
                              ))
                          .toList(),
                    ),
                  ),
                ),
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
      _RoleDestination(
        label: 'Inicio',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        screen: DashboardView(),
      ),
    ];

    if (permissions.canViewUsers) {
      destinations.add(_RoleDestination(
        label: 'Usuarios',
        icon: Icons.people_outline_rounded,
        selectedIcon: Icons.people_rounded,
        screen: UsersScreen(),
      ));
    }
    if (permissions.canViewInventory) {
      destinations.add(_RoleDestination(
        label: role == 'DOCTOR' ? 'Materiales' : 'Inventario',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        screen: const InventoryScreen(),
      ));
    }
    if (role == 'INVENTARIO') {
      destinations.add(_RoleDestination(
        label: 'Movimientos',
        icon: Icons.swap_vert_rounded,
        selectedIcon: Icons.swap_vert_rounded,
        screen: MovementsScreen(),
      ));
    }
    if (permissions.canReviewRequests || permissions.canCreateRequests) {
      destinations.add(_RoleDestination(
        label: 'Solicitudes',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment_rounded,
        screen: RequestsScreen(),
      ));
    }
    if (permissions.canViewReports) {
      destinations.add(_RoleDestination(
        label: 'Reportes',
        icon: Icons.bar_chart_rounded,
        selectedIcon: Icons.bar_chart_rounded,
        screen: ReportsScreen(),
      ));
    }
    destinations.add(_RoleDestination(
      label: 'Más',
      icon: Icons.more_horiz_rounded,
      selectedIcon: Icons.more_horiz_rounded,
      screen: MoreScreen(),
    ));

    return destinations;
  }
}

class _RoleDestination {
  const _RoleDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

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