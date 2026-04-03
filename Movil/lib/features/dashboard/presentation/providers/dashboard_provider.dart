import 'package:ceos/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final resumen = await dio.get('/reportes/resumen-inventario');
  final alertas = await dio.get('/inventario/alertas');
  return {'resumen': resumen.data, 'alertas': alertas.data};
});
