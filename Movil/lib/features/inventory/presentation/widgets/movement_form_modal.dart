import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/inventory_provider.dart';

class MovementFormModal extends ConsumerStatefulWidget {
  final MaterialEntity material;
  final String type; // 'entrada', 'salida' o 'ajuste'

  const MovementFormModal({super.key, required this.material, required this.type});

  @override
  ConsumerState<MovementFormModal> createState() => _MovementFormModalState();
}

class _MovementFormModalState extends ConsumerState<MovementFormModal> {
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cantidadStr = _cantidadController.text.trim();
    if (cantidadStr.isEmpty) {
      _showSnackBar('Ingresa una cantidad válida', isError: true);
      return;
    }

    final cantidad = int.tryParse(cantidadStr);
    if (cantidad == null || cantidad <= 0) {
      _showSnackBar('La cantidad debe ser mayor a 0', isError: true);
      return;
    }

    if (widget.type == 'salida' && cantidad > widget.material.stockActual) {
      _showSnackBar('No hay suficiente stock para realizar esta salida', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.registrarMovimiento(
        materialId: widget.material.id.toString(),
        tipo: widget.type,
        cantidad: cantidad,
        motivo: _motivoController.text.trim().isNotEmpty ? _motivoController.text.trim() : null,
      );

      ref.invalidate(materialsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        final label = widget.type == 'entrada'
            ? 'Entrada'
            : widget.type == 'salida'
                ? 'Salida'
                : 'Ajuste';
        _showSnackBar('✓ $label registrado con éxito');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFEF4444) : AppTheme.clinicalTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEntrada = widget.type == 'entrada';
    final isAjuste = widget.type == 'ajuste';

    // Paleta dinámica por tipo de movimiento
    final color = isEntrada
        ? const Color(0xFF10B981) // Verde esmeralda
        : isAjuste
            ? const Color(0xFF6366F1) // Índigo/Violeta
            : const Color(0xFFF59E0B); // Naranja/Ámbar

    final icon = isEntrada
        ? Icons.add_circle_outline_rounded
        : (isAjuste ? Icons.tune_rounded : Icons.remove_circle_outline_rounded);

    final label = isEntrada ? 'Entrada' : (isAjuste ? 'Ajuste' : 'Salida');

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha(180),
      labelStyle: const TextStyle(color: PremiumGlass.slate500, fontSize: 13, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(200)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(180)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
    );

    return GlassContainer(
      borderRadius: 28,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Indicator
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: PremiumGlass.slate500.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withAlpha(60), width: 1),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar $label',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: PremiumGlass.slate800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      widget.material.nombre,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PremiumGlass.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Banner con métricas del stock actual
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderRadius: 16,
            color: color.withAlpha(15),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: color, size: 18),
                const SizedBox(width: 10),
                const Text(
                  'Stock actual:',
                  style: TextStyle(color: PremiumGlass.slate500, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.material.stockActual} unidades',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(120),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mín: ${widget.material.stockMinimo}',
                    style: const TextStyle(
                      color: PremiumGlass.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Campo de Cantidad
          TextField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: inputDecoration.copyWith(
              labelText: 'Cantidad a ${label.toLowerCase()}',
              prefixIcon: Icon(Icons.pin_outlined, color: color, size: 20),
              helperText: isEntrada
                  ? '• Unidades que ingresan al stock'
                  : isAjuste
                      ? '• Nuevo valor absoluto del stock'
                      : '• Disponible para retirar: ${widget.material.stockActual} uds.',
              helperStyle: TextStyle(color: color.withAlpha(220), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),

          // Campo de Motivo
          TextField(
            controller: _motivoController,
            maxLines: 2,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Motivo u observación (opcional)',
              prefixIcon: const Icon(Icons.notes_rounded, color: PremiumGlass.slate500, size: 20),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 22),

          // Botón Confirmar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Icon(icon, size: 20),
                label: Text(_isLoading ? 'Procesando...' : 'Confirmar $label'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}