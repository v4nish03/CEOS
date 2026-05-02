import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/inventory_provider.dart';

class MovementFormModal extends ConsumerStatefulWidget {
  final MaterialEntity material;
  final String type; // 'entrada' or 'salida'

  const MovementFormModal({super.key, required this.material, required this.type});

  @override
  ConsumerState<MovementFormModal> createState() => _MovementFormModalState();
}

class _MovementFormModalState extends ConsumerState<MovementFormModal> {
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final cantidadStr = _cantidadController.text.trim();
    if (cantidadStr.isEmpty) return;
    
    final cantidad = int.tryParse(cantidadStr);
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cantidad inválida')));
      return;
    }

    if (widget.type == 'salida' && cantidad > widget.material.stockActual) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay suficiente stock')));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.type == 'entrada' ? 'Entrada' : 'Salida'} registrada con éxito')),
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
    final isEntrada = widget.type == 'entrada';
    final color = isEntrada ? Colors.green : Colors.orange;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isEntrada ? Icons.add_circle : Icons.remove_circle, color: color, size: 30),
              const SizedBox(width: 10),
              Text(
                'Registrar ${isEntrada ? 'Entrada' : 'Salida'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.material.nombre,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _motivoController,
            decoration: InputDecoration(
              labelText: 'Motivo (Opcional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.note),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar Operación', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
