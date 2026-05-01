import '../entities/material_entity.dart';

abstract class InventoryRepository {
  // Materiales
  Future<List<MaterialEntity>> getMateriales();
  Future<void> createMaterial(MaterialEntity material);
  
  // Movimientos (Punto 3-D)
  Future<void> registrarMovimiento({
    required String materialId,
    required String tipo, // 'entrada', 'salida', 'ajuste'
    required int cantidad,
    String? motivo,
  });

  // Alertas (Punto 3-E)
  Future<List<Map<String, dynamic>>> getAlertas();
}