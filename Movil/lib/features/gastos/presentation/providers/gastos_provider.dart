import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/gasto_model.dart';

final gastosProvider = FutureProvider<List<GastoModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/gastos');
  final List data = response.data;
  return data.map((json) => GastoModel.fromJson(json as Map<String, dynamic>)).toList();
});

final gastosTotalProvider = FutureProvider<double>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/gastos/total');
  return (response.data['total_gastado'] as num?)?.toDouble() ?? 0.0;
});

class GastosNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  GastosNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> crearGasto({
    required String concepto,
    required double monto,
    String? descripcion,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = _ref.read(dioProvider);
      await dio.post('/gastos', data: {
        'concepto': concepto,
        'monto': monto,
        'descripcion': descripcion,
      });
      state = const AsyncValue.data(null);
      // Invalidar ambos proveedores para refrescar UI inmediatamente
      _ref.invalidate(gastosProvider);
      _ref.invalidate(gastosTotalProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final gastosNotifierProvider = StateNotifierProvider<GastosNotifier, AsyncValue<void>>((ref) {
  return GastosNotifier(ref);
});
