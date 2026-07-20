import 'dart:ui';

import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/dashboard/presentation/widgets/dashboard_widgets.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final role = session.role ?? 'DOCTOR';
    final nombre = session.name ?? 'Usuario';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + MediaQuery.of(context).padding.top),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(160), // Capa traslúcida esmerilada
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withAlpha(220), // Brillo inferior de cristal
                    width: 1.2,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel de Control', 
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: FontWeight.w600, 
                        color: PremiumGlass.slate500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      nombre, 
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: PremiumGlass.slate800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => ref.read(authProvider.notifier).logout(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(15), // Rojo pastel sutil
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withAlpha(40),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout_rounded, 
                              color: Color(0xFFEF4444), 
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Salir',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: PremiumBackground(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
        child: _buildDashboardForRole(role, nombre),
      ),
    );
  }

  Widget _buildDashboardForRole(String role, String nombre) {
    switch (role) {
      case 'SUPERADMIN':
      case 'ADMIN':
        return AdminDashboard(nombre: nombre, role: role);
      case 'INVENTARIO':
        return InventoryDashboard(nombre: nombre);
      case 'DOCTOR':
      default:
        return DoctorDashboard(nombre: nombre);
    }
  }
}