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

    return Scaffold(
      backgroundColor: PremiumGlass.canvas,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Panel de Control', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
            Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: PremiumBackground(child: _buildDashboardForRole(role, nombre)),
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