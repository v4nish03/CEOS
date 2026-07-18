import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import 'package:ceos/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:ceos/features/inventory/domain/entities/material_entity.dart';

class RequestFormModal extends ConsumerStatefulWidget {
  const RequestFormModal({super.key});

  @override
  ConsumerState<RequestFormModal> createState() => _RequestFormModalState();
}

class _RequestFormModalState extends ConsumerState<RequestFormModal> {
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();
  MaterialEntity? _selectedMaterial;
  bool _isLoading = false;

  Future<void> _submit() async {
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un material')));
      return;
    }

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa una cantidad válida')));
      return;
    }

    if (cantidad > _selectedMaterial!.stockActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad solicitada ($cantidad) supera el stock disponible (${_selectedMaterial!.stockActual})'))
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(requestRepositoryProvider);
      await repo.createRequest(
        materialId: _selectedMaterial!.id.toString(),
        cantidad: cantidad,
        motivo: _motivoController.text.trim().isNotEmpty ? _motivoController.text.trim() : null,
      );
      
      ref.invalidate(requestsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud creada con éxito')));
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
    final materialsAsync = ref.watch(materialsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blueAccent, size: 30),
              SizedBox(width: 10),
              Text(
                'Nueva Solicitud',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          materialsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error al cargar materiales: $e', style: const TextStyle(color: Colors.red)),
            data: (materials) {
              return DropdownButtonFormField<MaterialEntity>(
                decoration: InputDecoration(
                  labelText: 'Material a solicitar',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
                value: _selectedMaterial,
                items: materials.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('${m.nombre} (Stock: ${m.stockActual})'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedMaterial = val),
              );
            },
          ),
          const SizedBox(height: 16),
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
              labelText: 'Motivo de solicitud',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.note),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading || _selectedMaterial == null ? null : _submit,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar Solicitud', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
