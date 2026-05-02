import '../entities/material_entity.dart';
import '../repositories/inventory_repository.dart';

class GetMaterialsUseCase {
  final InventoryRepository _repository;
  GetMaterialsUseCase(this._repository);

  Future<List<MaterialEntity>> execute() async {
    return await _repository.getMateriales();
  }
}