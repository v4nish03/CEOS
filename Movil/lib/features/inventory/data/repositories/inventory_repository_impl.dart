import 'package:dio/dio.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/material_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final Dio _dio;

  InventoryRepositoryImpl(this._dio);

  @override
  Future<List<MaterialEntity>> getMateriales() async {
    final response = await _dio.get('/materiales');
    final List data = response.data;
    return data.map((json) => MaterialModel.fromJson(json)).toList();
  }

  @override
  Future<void> createMaterial(MaterialEntity material) async {
    final model = MaterialModel(
      id: material.id,
      nombre: material.nombre,
      categoria: material.categoria,
      stockMinimo: material.stockMinimo,
      stockActual: material.stockActual,
    );
    await _dio.post('/materiales', data: model.toJson());
  }

  @override
  Future<void> registrarMovimiento({
    required String materialId,
    required String tipo,
    required int cantidad,
    String? motivo,
  }) async {
    await _dio.post('/inventario/movimientos', data: {
      'material_id': materialId,
      'tipo': tipo,
      'cantidad': cantidad,
      'motivo': motivo,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAlertas() async {
    final response = await _dio.get('/inventario/alertas');
    return List<Map<String, dynamic>>.from(response.data);
  }
}