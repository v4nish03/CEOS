import 'package:ceos/features/inventory/domain/entities/material_entity.dart';
import 'package:flutter/material.dart';

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.material,
    this.onEntrada,
    this.onSalida,
  });

  final MaterialEntity material;
  final VoidCallback? onEntrada;
  final VoidCallback? onSalida;

  @override
  Widget build(BuildContext context) {
    final low = material.stockActual <= material.stockMinimo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(material.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                if (low)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Stock bajo', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Categoría: ${material.categoria}'),
            Text('Stock actual: ${material.stockActual} · Mínimo: ${material.stockMinimo}'),
            if (material.fechaVencimiento != null)
              Text('Caducidad: ${material.fechaVencimiento}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSalida,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Salida'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onEntrada,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Entrada'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
