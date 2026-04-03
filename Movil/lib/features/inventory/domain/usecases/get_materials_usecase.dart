import 'package:ceos/features/inventory/domain/entities/material_entity.dart';
import 'package:ceos/features/inventory/domain/repositories/inventory_repository.dart';

class GetMaterialsUseCase {
  const GetMaterialsUseCase(this.repository);
  final InventoryRepository repository;

  Future<List<MaterialEntity>> call() => repository.getMaterials();
}
