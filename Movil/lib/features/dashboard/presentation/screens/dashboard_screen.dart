import 'package:ceos/core/widgets/app_state_widgets.dart';
import 'package:ceos/core/widgets/ceos_navigation_scaffold.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:ceos/features/dashboard/presentation/widgets/role_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).session;
    final data = ref.watch(dashboardSummaryProvider);

    return CeosNavigationScaffold(
      title: 'Dashboard',
      currentRoute: '/dashboard',
      actions: [
        IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
        ),
      ],
      child: data.when(
        loading: () => const AppLoadingView(message: 'Cargando resumen...'),
        error: (e, _) => AppErrorView(message: 'No se pudo cargar dashboard: $e', onRetry: () => ref.invalidate(dashboardSummaryProvider)),
        data: (payload) {
          final resumen = payload['resumen'] as Map<String, dynamic>;
          final alertas = payload['alertas'] as List<dynamic>;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WelcomeCard(name: session?.name ?? 'Usuario', role: session?.role.name ?? ''),
              const SizedBox(height: 12),
              if (session != null) RoleMenu(role: session.role),
              const SizedBox(height: 14),
              _MetricsRow(resumen: resumen, alertas: alertas.length),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Actividad y alertas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Alertas activas: ${alertas.length}'),
                      const SizedBox(height: 4),
                      Text('Materiales con stock bajo: ${resumen['materiales_stock_bajo']}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name, required this.role});
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                Text('Rol: $role', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.resumen, required this.alertas});
  final Map<String, dynamic> resumen;
  final int alertas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(title: 'Materiales', value: '${resumen['total_materiales']}', icon: Icons.inventory),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(title: 'Alertas', value: '$alertas', icon: Icons.warning_amber_outlined),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
