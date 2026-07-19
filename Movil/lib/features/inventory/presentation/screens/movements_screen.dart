import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/dio_client.dart';
import '../providers/inventory_provider.dart';
import '../../domain/entities/material_entity.dart';
import '../widgets/movement_form_modal.dart';

// Provider para el historial de movimientos
final movimientosProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/inventario/movimientos');
  return List<Map<String, dynamic>>.from(response.data as List);
});

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientosAsync = ref.watch(movimientosProvider);

    return Scaffold(
      backgroundColor: PremiumGlass.canvas,
      appBar: AppBar(
        title: const Text('Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(movimientosProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMaterialPicker(context, ref),
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.swap_vert),
        label: const Text('Registrar'),
      ),
      body: PremiumBackground(
        child: Column(
        children: [
          // Resumen rápido de tipos
          _MovementSummaryBar(),
          Expanded(
            child: movimientosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorState(
                onRetry: () => ref.invalidate(movimientosProvider),
              ),
              data: (movimientos) {
                if (movimientos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_vert, size: 64, color: AppTheme.slate.withAlpha(100)),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay movimientos registrados.',
                          style: TextStyle(color: AppTheme.slate, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Usa el botón + para registrar una entrada o salida.',
                          style: TextStyle(color: AppTheme.slate, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(movimientosProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: movimientos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _MovementTile(data: movimientos[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Muestra un selector de material antes de abrir el form de movimiento
  void _showMaterialPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MaterialPickerSheet(ref: ref),
    );
  }
}

// ── Barra resumen ────────────────────────────────────────────

class _MovementSummaryBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientosAsync = ref.watch(movimientosProvider);
    return movimientosAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (movimientos) {
        final entradas = movimientos.where((m) => m['tipo'] == 'entrada').length;
        final salidas = movimientos.where((m) => m['tipo'] == 'salida').length;
        final ajustes = movimientos.where((m) => m['tipo'] == 'ajuste').length;
        return Container(
          color: AppTheme.porcelain,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _SummaryChip(label: 'Entradas', count: entradas, color: AppTheme.success),
              const SizedBox(width: 10),
              _SummaryChip(label: 'Salidas', count: salidas, color: AppTheme.danger),
              const SizedBox(width: 10),
              _SummaryChip(label: 'Ajustes', count: ajustes, color: AppTheme.warning),
              const Spacer(),
              Text(
                '${movimientos.length} total',
                style: const TextStyle(fontSize: 12, color: AppTheme.slate, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('$count $label', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Tile de movimiento ────────────────────────────────────────

class _MovementTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MovementTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final tipo = data['tipo'] as String? ?? 'entrada';
    final cantidad = (data['cantidad'] as num?)?.toInt() ?? 0;
    final materialId = data['material_id'];
    final fecha = DateTime.tryParse(data['fecha'] as String? ?? '') ?? DateTime.now();
    final fechaStr = DateFormat('dd/MM/yy HH:mm').format(fecha);

    final isEntrada = tipo == 'entrada';
    final isAjuste = tipo == 'ajuste';
    final color = isEntrada ? AppTheme.success : (isAjuste ? AppTheme.warning : AppTheme.danger);
    final icon = isEntrada ? Icons.add_circle_outline : (isAjuste ? Icons.tune : Icons.remove_circle_outline);
    final prefix = isEntrada ? '+' : (isAjuste ? '±' : '-');

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          'Material #$materialId',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: PremiumGlass.slate800, letterSpacing: 0.2),
        ),
        subtitle: Text(
          fechaStr,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$prefix$cantidad',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tipo.toUpperCase(),
                style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selector de material ────────────────────────────────────

class _MaterialPickerSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _MaterialPickerSheet({required this.ref});

  @override
  ConsumerState<_MaterialPickerSheet> createState() => _MaterialPickerSheetState();
}

class _MaterialPickerSheetState extends ConsumerState<_MaterialPickerSheet> {
  MaterialEntity? _selected;
  String _type = 'entrada';

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nuevo Movimiento', style: theme.textTheme.titleLarge),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tipo de movimiento
          Text('Tipo de movimiento', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _TypeChip(label: 'Entrada', value: 'entrada', current: _type, color: AppTheme.success, onTap: (v) => setState(() => _type = v))),
              const SizedBox(width: 8),
              Expanded(child: _TypeChip(label: 'Salida', value: 'salida', current: _type, color: AppTheme.danger, onTap: (v) => setState(() => _type = v))),
              const SizedBox(width: 8),
              Expanded(child: _TypeChip(label: 'Ajuste', value: 'ajuste', current: _type, color: AppTheme.warning, onTap: (v) => setState(() => _type = v))),
            ],
          ),
          const SizedBox(height: 20),
          // Selector de material
          Text('Seleccionar material', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          materialsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error al cargar materiales', style: TextStyle(color: AppTheme.danger)),
            data: (materials) => DropdownButtonFormField<MaterialEntity>(
              decoration: InputDecoration(
                hintText: 'Selecciona un material',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              value: _selected,
              items: materials.map((m) => DropdownMenuItem(
                value: m,
                child: Text('${m.nombre} (stock: ${m.stockActual})', overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (val) => setState(() => _selected = val),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selected == null
                ? null
                : () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) => MovementFormModal(material: _selected!, type: _type),
                    ).then((_) => ref.invalidate(movimientosProvider));
                  },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label, value, current;
  final Color color;
  final ValueChanged<String> onTap;
  const _TypeChip({required this.label, required this.value, required this.current, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : color.withAlpha(60)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
          const SizedBox(height: 16),
          const Text('No se pudo cargar el historial.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
