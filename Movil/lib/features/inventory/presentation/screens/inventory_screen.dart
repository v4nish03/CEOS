import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';
import '../widgets/material_card.dart';
import '../widgets/material_form_modal.dart';
import '../widgets/movement_form_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/material_entity.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);
    final role = ref.watch(authProvider).role;
    // DOCTOR can only view, others can edit
    final canEdit = role != 'DOCTOR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario Médico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(materialsProvider),
          )
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showMaterialForm(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Material'),
            )
          : null,
      body: materialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar inventario:\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(materialsProvider),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
        data: (materials) {
          if (materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No hay materiales registrados.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(materialsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Padding inferior para el FAB
              itemCount: materials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final material = materials[index];
                return MaterialCard(
                  material: material,
                  canEdit: canEdit,
                  onEdit: () => _showMaterialForm(context, ref, material: material),
                  onMovement: (type) => _showMovementForm(context, ref, material, type),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showMaterialForm(BuildContext context, WidgetRef ref, {MaterialEntity? material}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => MaterialFormModal(material: material),
    );
  }

  void _showMovementForm(BuildContext context, WidgetRef ref, MaterialEntity material, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => MovementFormModal(material: material, type: type),
    );
  }
}
