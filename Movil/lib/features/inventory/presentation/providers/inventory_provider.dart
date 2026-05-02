import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/repositories/inventory_repository_impl.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  // Aquí usamos el Dio que ya tiene el Interceptor de seguridad [cite: 248, 271]
  final dio = ref.watch(dioProvider); 
  return InventoryRepositoryImpl(dio);
});

final materialsProvider = FutureProvider<List<MaterialEntity>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return await repo.getMateriales();
});