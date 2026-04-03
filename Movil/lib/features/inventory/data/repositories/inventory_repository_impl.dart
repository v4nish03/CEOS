import 'package:ceos/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:ceos/features/inventory/domain/entities/material_entity.dart';
import 'package:ceos/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._remote);
  final InventoryRemoteDatasource _remote;

  @override
  Future<List<MaterialEntity>> getMaterials() async {
    final result = await _remote.getMaterials();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> registerMovement({required int materialId, required String tipo, required int cantidad}) {
    return _remote.registerMovement(materialId: materialId, tipo: tipo, cantidad: cantidad);
  }
}
