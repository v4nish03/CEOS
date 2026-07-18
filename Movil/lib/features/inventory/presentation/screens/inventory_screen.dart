import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';
import '../widgets/material_card.dart';
import '../widgets/material_form_modal.dart';
import '../widgets/movement_form_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/material_entity.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _filter = 'todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider);
    final role = ref.watch(authProvider).role ?? 'DOCTOR';
    final permissions = permissionsForRole(role);
    final canEdit = permissions.canModifyInventory;

    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'DOCTOR' ? 'Materiales' : 'Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(materialsProvider),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showMaterialForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo material'),
            )
          : null,
      body: materialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _InventoryError(onRetry: () => ref.invalidate(materialsProvider), error: error),
        data: (materials) {
          final filtered = _applyFilters(materials);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(materialsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _InventoryHeader(materials: materials),
                const SizedBox(height: 14),
                // Banner de modo supervisión para ADMIN
                if (permissions.isInventoryReadOnly)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withAlpha(60)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Modo supervisión: puedes consultar el inventario pero los movimientos los gestiona el equipo de Inventario.',
                            style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o categoría',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                _FilterChips(selected: _filter, onChanged: (value) => setState(() => _filter = value)),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _EmptyInventory(canEdit: canEdit, onCreate: () => _showMaterialForm(context))
                else
                  ...filtered.map(
                    (material) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MaterialCard(
                        material: material,
                        canEdit: canEdit,
                        onEdit: () => _showMaterialForm(context, material: material),
                        onMovement: (type) => _showMovementForm(context, material, type),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<MaterialEntity> _applyFilters(List<MaterialEntity> materials) {
    final query = _searchController.text.trim().toLowerCase();
    return materials.where((material) {
      final matchesQuery = query.isEmpty ||
          material.nombre.toLowerCase().contains(query) ||
          material.categoria.toLowerCase().contains(query);
      final isLow = material.stockActual <= material.stockMinimo;
      final isEmpty = material.stockActual == 0;
      final matchesFilter = switch (_filter) {
        'bajo' => isLow,
        'sin_stock' => isEmpty,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _showMaterialForm(BuildContext context, {MaterialEntity? material}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => MaterialFormModal(material: material),
    );
  }

  void _showMovementForm(BuildContext context, MaterialEntity material, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => MovementFormModal(material: material, type: type),
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader({required this.materials});

  final List<MaterialEntity> materials;

  @override
  Widget build(BuildContext context) {
    final low = materials.where((m) => m.stockActual <= m.stockMinimo).length;
    final totalStock = materials.fold<int>(0, (sum, item) => sum + item.stockActual);
    return Row(
      children: [
        Expanded(child: _MiniStat(label: 'Materiales', value: materials.length.toString(), icon: Icons.inventory_2_outlined, color: AppTheme.clinicalTeal)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(label: 'Unidades', value: totalStock.toString(), icon: Icons.layers_outlined, color: AppTheme.graphite)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(label: 'Stock bajo', value: low.toString(), icon: Icons.warning_amber_rounded, color: low > 0 ? AppTheme.danger : AppTheme.success)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.slate, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('todos', 'Todos'),
          const SizedBox(width: 8),
          _chip('bajo', 'Stock bajo'),
          const SizedBox(width: 8),
          _chip('sin_stock', 'Sin stock'),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onChanged(value),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory({required this.canEdit, required this.onCreate});

  final bool canEdit;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 60, color: AppTheme.slate),
            const SizedBox(height: 14),
            const Text('No hay materiales para mostrar.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Ajusta los filtros o registra un nuevo material.', textAlign: TextAlign.center),
            if (canEdit) ...[
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Nuevo material')),
            ],
          ],
        ),
      ),
    );
  }
}

class _InventoryError extends StatelessWidget {
  const _InventoryError({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: AppTheme.danger),
            const SizedBox(height: 16),
            Text('Error al cargar inventario:\n$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
