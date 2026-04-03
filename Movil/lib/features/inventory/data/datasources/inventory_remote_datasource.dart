import 'package:ceos/features/inventory/data/models/material_model.dart';
import 'package:dio/dio.dart';

class InventoryRemoteDatasource {
  const InventoryRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<MaterialModel>> getMaterials() async {
    final response = await _dio.get('/materiales');
    final data = response.data as List<dynamic>;
    return data.map((e) => MaterialModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> registerMovement({required int materialId, required String tipo, required int cantidad}) async {
    await _dio.post('/inventario/movimientos', data: {'material_id': materialId, 'tipo': tipo, 'cantidad': cantidad});
  }
}
