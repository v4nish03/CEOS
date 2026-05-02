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

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nombreController.text = widget.material!.nombre;
      _categoriaController.text = widget.material!.categoria;
      _stockMinimoController.text = widget.material!.stockMinimo.toString();
      _stockActualController.text = widget.material!.stockActual.toString();
    }
  }

  Future<void> _submit() async {
    final nombre = _nombreController.text.trim();
    final categoria = _categoriaController.text.trim();
    final stockMinimo = int.tryParse(_stockMinimoController.text) ?? 0;
    final stockActual = int.tryParse(_stockActualController.text) ?? 0;

    if (nombre.isEmpty || categoria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Llena los campos obligatorios')));
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

      if (widget.material == null) {
        await repo.createMaterial(newMaterial);
      } else {
        await repo.updateMaterial(widget.material!.id, newMaterial);
      }
      
      ref.invalidate(materialsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.material == null ? 'Material creado' : 'Material actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.material != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Editar Material' : 'Nuevo Material',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del material',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoriaController,
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockMinimoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock Mínimo',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _stockActualController,
                  keyboardType: TextInputType.number,
                  enabled: !isEditing, // Only allow setting current stock on creation
                  decoration: InputDecoration(
                    labelText: 'Stock Inicial',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? 'Guardar Cambios' : 'Crear Material', style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
