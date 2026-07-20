import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/inventory_provider.dart';
import '../widgets/material_card.dart';
import '../widgets/material_form_modal.dart';
import '../widgets/movement_form_modal.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          role == 'DOCTOR' ? 'Materiales' : 'Inventario',
          style: const TextStyle(
            color: PremiumGlass.slate800,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: PremiumGlass.slate800),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(materialsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: canEdit
          ? _GlassFAB(
              onPressed: () => _showMaterialForm(context),
            )
          : null,
      body: PremiumBackground(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
        child: materialsAsync.when(
          loading: () => const _InventorySkeletonList(),
          error: (error, stack) => _InventoryError(
            onRetry: () => ref.invalidate(materialsProvider),
            error: error,
          ),
          data: (materials) {
            final filtered = _applyFilters(materials);
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(materialsProvider),
              color: AppTheme.clinicalTeal,
              backgroundColor: Colors.white,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: [
                  // ── Metrics Header ──
                  _InventoryHeader(materials: materials),
                  const SizedBox(height: 14),

                  // ── Banner Supervisión ADMIN ──
                  if (permissions.isInventoryReadOnly)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        color: const Color(0xFF3B82F6).withAlpha(15),
                        borderRadius: 16,
                        child: const Row(
                          children: [
                            Icon(Icons.visibility_outlined, color: Color(0xFF2563EB), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Modo supervisión: Consulta habilitada. La gestión de movimientos es exclusiva del equipo de Inventario.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E40AF),
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Buscador Flotante Glass ──
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o categoría...',
                        hintStyle: TextStyle(color: PremiumGlass.slate500.withAlpha(180), fontSize: 13),
                        icon: const Icon(Icons.search_rounded, color: AppTheme.clinicalTeal, size: 22),
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: PremiumGlass.slate500),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Chips de Filtro ──
                  _FilterChips(
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 16),

                  // ── Lista o Estado Vacío ──
                  if (filtered.isEmpty)
                    _EmptyInventory(
                      canEdit: canEdit,
                      onCreate: () => _showMaterialForm(context),
                      isSearching: _searchController.text.isNotEmpty || _filter != 'todos',
                    )
                  else
                    ...filtered.map(
                      (material) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
      backgroundColor: Colors.transparent,
      builder: (context) => MaterialFormModal(material: material),
    );
  }

  void _showMovementForm(BuildContext context, MaterialEntity material, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MovementFormModal(material: material, type: type),
    );
  }
}

// ════════════════════ Header de Estadísticas ════════════════════

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader({required this.materials});

  final List<MaterialEntity> materials;

  @override
  Widget build(BuildContext context) {
    final low = materials.where((m) => m.stockActual <= m.stockMinimo).length;
    final totalStock = materials.fold<int>(0, (sum, item) => sum + item.stockActual);

    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            label: 'Materiales',
            value: materials.length.toString(),
            icon: Icons.inventory_2_outlined,
            color: AppTheme.clinicalTeal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStat(
            label: 'Unidades',
            value: totalStock.toString(),
            icon: Icons.layers_outlined,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStat(
            label: 'Stock Bajo',
            value: low.toString(),
            icon: Icons.warning_amber_rounded,
            color: low > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            isAlert: low > 0,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              if (isAlert)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: PremiumGlass.slate800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: PremiumGlass.slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════ Chips de Filtro ════════════════════

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _chip('todos', 'Todos los artículos'),
          const SizedBox(width: 8),
          _chip('bajo', 'Stock bajo'),
          const SizedBox(width: 8),
          _chip('sin_stock', 'Sin stock'),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: isSelected ? AppTheme.clinicalTeal.withAlpha(220) : Colors.white.withAlpha(120),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : PremiumGlass.slate800,
          ),
        ),
      ),
    );
  }
}

// ════════════════════ Componentes Auxiliares ════════════════════

class _GlassFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _GlassFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.clinicalTeal.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            color: AppTheme.clinicalTeal.withAlpha(220),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  'Nuevo Material',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory({
    required this.canEdit,
    required this.onCreate,
    required this.isSearching,
  });

  final bool canEdit;
  final VoidCallback onCreate;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(28),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.clinicalTeal.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearching ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                  size: 42,
                  color: AppTheme.clinicalTeal,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSearching ? 'Sin resultados' : 'Inventario vacío',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: PremiumGlass.slate800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSearching
                    ? 'Prueba modificando la búsqueda o los filtros aplicados.'
                    : 'No hay insumos o productos registrados en este momento.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: PremiumGlass.slate500,
                  height: 1.3,
                ),
              ),
              if (canEdit && !isSearching) ...[
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.clinicalTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Registrar Material', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InventorySkeletonList extends StatelessWidget {
  const _InventorySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PremiumGlass.slate500.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: PremiumGlass.slate500.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 90,
                      height: 10,
                      decoration: BoxDecoration(
                        color: PremiumGlass.slate500.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      child: GlassContainer(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        color: const Color(0xFFEF4444).withAlpha(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 40),
            const SizedBox(height: 12),
            const Text(
              'Error al cargar inventario',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 11, color: PremiumGlass.slate500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}