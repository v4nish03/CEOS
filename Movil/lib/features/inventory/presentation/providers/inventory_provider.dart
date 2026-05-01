import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... imports de repo e impl

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  // Aquí usamos el Dio que ya tiene el Interceptor de seguridad [cite: 248, 271]
  final dio = ref.watch(dioProvider); 
  return InventoryRepositoryImpl(dio);
});

final materialsProvider = FutureProvider<List<MaterialEntity>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return await repo.getMateriales();
});