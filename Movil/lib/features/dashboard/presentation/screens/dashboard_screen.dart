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

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard · ${session?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (payload) {
            final resumen = payload['resumen'] as Map<String, dynamic>?;
            final alertas = payload['alertas'] as List<dynamic>;
            final mensaje = payload['mensaje'] as String?;

            return ListView(
              children: [
                if (session != null) RoleMenu(role: session.role),
                if (mensaje != null) ...[
                  const SizedBox(height: 12),
                  Card(child: ListTile(leading: const Icon(Icons.info_outline), title: Text(mensaje))),
                ],
                const SizedBox(height: 16),
                if (resumen != null)
                  Card(
                    child: ListTile(
                      title: const Text('Resumen diario'),
                      subtitle: Text('Materiales: ${resumen['total_materiales']} · Unidades: ${resumen['stock_total_unidades']}'),
                    ),
                  ),
                if (session?.role.name != 'doctor')
                  Card(
                    child: ListTile(title: const Text('Alertas activas'), subtitle: Text('${alertas.length} alertas en inventario')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
