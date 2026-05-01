import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).session;
    final canView = session != null &&
        (session.role == UserRole.superadmin || session.role == UserRole.admin || session.role == UserRole.inventario);

    if (!canView) {
      return const Scaffold(
        body: Center(child: Text('Tu rol no tiene acceso a reportes.')),
      );
    }

    final reports = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Sin datos de reportes'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final row = items[i] as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: Text(row['material_nombre'].toString()),
                subtitle: Text('Salidas: ${row['total_salida']}'),
              );
            },
          );
        },
      ),
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Reportes',
      description:
          'La vista de reportes está en pausa. Reemplaza este placeholder por nuevas gráficas/listados cuando se retome el módulo.',
    );
  }
}
