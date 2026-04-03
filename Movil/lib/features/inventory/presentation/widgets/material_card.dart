import 'package:ceos/features/inventory/domain/entities/material_entity.dart';
import 'package:flutter/material.dart';

class MaterialCard extends StatelessWidget {
  const MaterialCard({super.key, required this.material, this.onEntrada, this.onSalida});

  final MaterialEntity material;
  final VoidCallback? onEntrada;
  final VoidCallback? onSalida;

  @override
  Widget build(BuildContext context) {
    final low = material.stockActual <= material.stockMinimo;
    return Card(
      child: ListTile(
        title: Text(material.nombre),
        subtitle: Text('${material.categoria} · Stock: ${material.stockActual}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (low) const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            IconButton(onPressed: onEntrada, icon: const Icon(Icons.add_circle_outline)),
            IconButton(onPressed: onSalida, icon: const Icon(Icons.remove_circle_outline)),
          ],
        ),
      ),
    );
  }
}
