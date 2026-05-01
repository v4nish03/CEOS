import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/reportes/materiales-mas-usados');
  return response.data as List<dynamic>;
});

class ReportsScreen extends ConsumerWidget {
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
    );
  }
}
