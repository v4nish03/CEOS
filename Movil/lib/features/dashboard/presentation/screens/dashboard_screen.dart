import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Dashboard',
      description:
          'Vista de dashboard deshabilitada. Mantén este archivo para reactivar los widgets de resumen cuando reinicie el desarrollo móvil.',
    );
  }
}
