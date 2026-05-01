import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final session = ref.watch(authNotifierProvider).session;

  if (session == null) {
    return {'resumen': null, 'alertas': const <dynamic>[], 'mensaje': 'Inicia sesión para ver el panel'};
  }

  if (session.role == UserRole.doctor) {
    final materiales = await dio.get('/materiales');
    final items = materiales.data as List<dynamic>;
    return {
      'resumen': {
        'total_materiales': items.length,
        'stock_total_unidades': items.fold<int>(0, (acc, e) => acc + ((e['stock_actual'] as int?) ?? 0)),
      },
      'alertas': const <dynamic>[],
      'mensaje': 'Vista de doctor: consulta de disponibilidad de materiales',
    };
  }

  final resumen = await dio.get('/reportes/resumen-inventario');
  final alertas = await dio.get('/inventario/alertas');
  return {'resumen': resumen.data, 'alertas': alertas.data, 'mensaje': null};
});
