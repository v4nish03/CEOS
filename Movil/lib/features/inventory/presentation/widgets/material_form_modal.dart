import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/inventory_provider.dart';

class MaterialFormModal extends ConsumerStatefulWidget {
  final MaterialEntity? material;

  const MaterialFormModal({super.key, this.material});

  @override
  ConsumerState<MaterialFormModal> createState() => _MaterialFormModalState();
}

class _MaterialFormModalState extends ConsumerState<MaterialFormModal> {
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _stockActualController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreController.text = widget.material!.nombre;
      _categoriaController.text = widget.material!.categoria;
      _stockMinimoController.text = widget.material!.stockMinimo.toString();
      _stockActualController.text = widget.material!.stockActual.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _stockMinimoController.dispose();
    _stockActualController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nombre = _nombreController.text.trim();
    final categoria = _categoriaController.text.trim();
    final stockMinimo = int.tryParse(_stockMinimoController.text) ?? 0;
    final stockActual = int.tryParse(_stockActualController.text) ?? 0;

    if (nombre.isEmpty || categoria.isEmpty) {
      _showSnackBar('El nombre y la categoría son obligatorios', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(inventoryRepositoryProvider);

      final newMaterial = MaterialEntity(
        id: widget.material?.id ?? 0,
        nombre: nombre,
        categoria: categoria,
        stockMinimo: stockMinimo,
        stockActual: stockActual,
      );

      if (!_isEditing) {
        await repo.createMaterial(newMaterial);
      } else {
        await repo.updateMaterial(widget.material!.id, newMaterial);
      }

      ref.invalidate(materialsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar(
          _isEditing ? '✓ Material actualizado con éxito' : '✓ Material registrado con éxito',
        );
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
        borderSide: const BorderSide(color: AppTheme.clinicalTeal, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withAlpha(15)),
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
          // Drag handle indicador
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

          // Header del Modal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.clinicalTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.clinicalTeal.withAlpha(50)),
                ),
                child: Icon(
                  _isEditing ? Icons.edit_note_rounded : Icons.add_box_rounded,
                  color: AppTheme.clinicalTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Editar Material' : 'Nuevo Material',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PremiumGlass.slate800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    _isEditing ? 'Modifica los parámetros del insumo' : 'Registra un insumo en el inventario',
                    style: const TextStyle(fontSize: 12, color: PremiumGlass.slate500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Nombre del Material
          TextField(
            controller: _nombreController,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Nombre del insumo / material',
              prefixIcon: const Icon(Icons.inventory_2_outlined, color: PremiumGlass.slate500, size: 20),
            ),
          ),
          const SizedBox(height: 12),

          // Categoría
          TextField(
            controller: _categoriaController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Categoría (ej. Anestesia, Resinas...)',
              prefixIcon: const Icon(Icons.category_outlined, color: PremiumGlass.slate500, size: 20),
            ),
          ),
          const SizedBox(height: 12),

          // Métricas de Stock (Filas en paralelo)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockMinimoController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Stock Mínimo',
                    prefixIcon: const Icon(Icons.warning_amber_rounded, color: PremiumGlass.slate500, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stockActualController,
                  keyboardType: TextInputType.number,
                  enabled: !_isEditing,
                  style: TextStyle(
                    color: _isEditing ? PremiumGlass.slate500 : PremiumGlass.slate800,
                    fontSize: 14,
                  ),
                  decoration: inputDecoration.copyWith(
                    labelText: _isEditing ? 'Stock Actual' : 'Stock Inicial',
                    fillColor: _isEditing ? Colors.black.withAlpha(8) : Colors.white.withAlpha(180),
                    prefixIcon: Icon(
                      Icons.layers_outlined,
                      color: _isEditing ? PremiumGlass.slate500.withAlpha(100) : PremiumGlass.slate500,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '* El stock actual se gestiona mediante el registro de entradas y salidas.',
                style: TextStyle(fontSize: 11, color: PremiumGlass.slate500, fontStyle: FontStyle.italic),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Botón Submit
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.clinicalTeal.withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.clinicalTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(_isEditing ? 'Guardar Cambios' : 'Registrar Material'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}