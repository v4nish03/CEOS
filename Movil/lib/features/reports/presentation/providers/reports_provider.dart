import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/reports/data/models/report_models.dart';

// ── Resumen de inventario (admin/inventario) ──
final resumenInventarioProvider = FutureProvider<ResumenInventario>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/reportes/resumen-inventario');
  return ResumenInventario.fromJson(response.data);
});

// ── Top materiales más usados ──
final materialesMasUsadosProvider = FutureProvider<List<MaterialMasUsado>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/reportes/materiales-mas-usados?limit=8');
  final List data = response.data;
  return data.map((e) => MaterialMasUsado.fromJson(e)).toList();
});

// ── Alertas de stock bajo y vencimiento ──
final alertasInventarioProvider = FutureProvider<List<AlertaInventario>>((ref) async {
  final dio = ref.watch(dioProvider);
  final role = ref.watch(authProvider).role;
  if (role == 'DOCTOR') return [];
  final response = await dio.get('/inventario/alertas');
  final List data = response.data;
  return data.map((e) => AlertaInventario.fromJson(e)).toList();
});

// ── Historial de movimientos (reports) ──
final movimientosReporteProvider = FutureProvider<List<MovimientoReporte>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/reportes/movimientos');
  final List data = response.data;
  return data.map((e) => MovimientoReporte.fromJson(e)).toList();
});

// ── KPIs locales del doctor (materiales disponibles) ──
final doctorKpisProvider = FutureProvider<Map<String, int>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/materiales');
  final List items = response.data;
  final total = items.length;
  final stockTotal = items.fold<int>(0, (acc, e) => acc + ((e['stock_actual'] as num?)?.toInt() ?? 0));
  final bajo = items.where((e) => (e['stock_actual'] as num? ?? 0) <= (e['stock_minimo'] as num? ?? 0)).length;
  return {'total_materiales': total, 'stock_total': stockTotal, 'sin_stock_suficiente': bajo};
});
