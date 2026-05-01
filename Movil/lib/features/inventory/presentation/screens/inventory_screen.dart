import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider).session;
    final materials = ref.watch(materialsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: materials.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Sin materiales'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return MaterialCard(
                material: item,
                onEntrada: auth != null && (auth.role == UserRole.inventario || auth.role == UserRole.admin || auth.role == UserRole.superadmin)
                    ? () => _register(context, ref, item.id, 'entrada')
                    : null,
                onSalida: auth != null && (auth.role == UserRole.inventario || auth.role == UserRole.admin || auth.role == UserRole.superadmin)
                    ? () => _register(context, ref, item.id, 'salida')
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _register(BuildContext context, WidgetRef ref, int materialId, String tipo) async {
    final controller = TextEditingController();
    final repository = ref.read(inventoryRepositoryProvider);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar $tipo'),
        content: TextField(controller: controller, keyboardType: TextInputType.number),
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
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Inventario',
      description:
          'La vista de inventario fue retirada para rehacer el flujo de materiales desde cero sobre la misma estructura de carpetas.',
    );
  }
}
