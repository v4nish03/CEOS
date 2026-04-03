import 'package:ceos/features/inventory/domain/entities/material_entity.dart';

abstract class InventoryRepository {
  Future<List<MaterialEntity>> getMaterials();
  Future<void> registerMovement({required int materialId, required String tipo, required int cantidad});
}
