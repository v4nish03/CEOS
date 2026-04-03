import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:ceos/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:ceos/features/inventory/domain/entities/material_entity.dart';
import 'package:ceos/features/inventory/domain/usecases/get_materials_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryRepositoryProvider = Provider<InventoryRepositoryImpl>((ref) {
  return InventoryRepositoryImpl(InventoryRemoteDatasource(ref.watch(dioProvider)));
});

final materialsProvider = FutureProvider<List<MaterialEntity>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetMaterialsUseCase(repository).call();
});
