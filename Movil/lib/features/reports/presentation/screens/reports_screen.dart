import 'package:ceos/core/widgets/app_state_widgets.dart';
import 'package:ceos/core/widgets/ceos_navigation_scaffold.dart';
import 'package:ceos/core/network/dio_client.dart';
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
    final reports = ref.watch(reportsProvider);

    return CeosNavigationScaffold(
      title: 'Reportes de consumo',
      currentRoute: '/reports',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: reports.when(
          loading: () => const AppLoadingView(message: 'Cargando reportes...'),
          error: (e, _) => AppErrorView(message: 'Error al cargar reportes: $e', onRetry: () => ref.invalidate(reportsProvider)),
          data: (items) {
            if (items.isEmpty) return const AppEmptyView(title: 'Sin reportes', subtitle: 'Aún no hay salidas registradas');
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final row = items[i] as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(row['material_nombre'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('Total de salidas: ${row['total_salida']}'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
