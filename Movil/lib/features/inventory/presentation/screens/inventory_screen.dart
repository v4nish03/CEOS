import 'package:ceos/core/widgets/app_state_widgets.dart';
import 'package:ceos/core/widgets/ceos_navigation_scaffold.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/inventory/domain/entities/material_entity.dart';
import 'package:ceos/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:ceos/features/inventory/presentation/widgets/material_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider).session;
    final materialsAsync = ref.watch(materialsProvider);

    return CeosNavigationScaffold(
      title: 'Inventario de materiales',
      currentRoute: '/inventory',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o categoría',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _search.clear()),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: materialsAsync.when(
                loading: () => const AppLoadingView(message: 'Cargando inventario...'),
                error: (e, _) => AppErrorView(message: 'Error al cargar inventario: $e', onRetry: () => ref.invalidate(materialsProvider)),
                data: (items) {
                  final filtered = _applyFilter(items, _search.text);
                  if (filtered.isEmpty) {
                    return const AppEmptyView(title: 'Sin resultados', subtitle: 'Intenta con otro término de búsqueda');
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return MaterialCard(
                        material: item,
                        onEntrada: auth?.role == UserRole.inventario ? () => _register(context, ref, item.id, 'entrada') : null,
                        onSalida: auth?.role == UserRole.inventario ? () => _register(context, ref, item.id, 'salida') : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MaterialEntity> _applyFilter(List<MaterialEntity> items, String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((e) => e.nombre.toLowerCase().contains(q) || e.categoria.toLowerCase().contains(q)).toList();
  }

  Future<void> _register(BuildContext context, WidgetRef ref, int materialId, String tipo) async {
    final controller = TextEditingController();
    final repository = ref.read(inventoryRepositoryProvider);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar $tipo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final qty = int.tryParse(controller.text) ?? 0;
              if (qty > 0) {
                await repository.registerMovement(materialId: materialId, tipo: tipo, cantidad: qty);
                ref.invalidate(materialsProvider);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
