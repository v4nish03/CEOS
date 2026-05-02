import 'package:flutter/material.dart';
import '../../domain/entities/material_entity.dart';

class MaterialCard extends StatelessWidget {
  final MaterialEntity material;
  final bool canEdit;
  final VoidCallback? onEdit;
  final Function(String type)? onMovement;

  const MaterialCard({
    super.key,
    required this.material,
    required this.canEdit,
    this.onEdit,
    this.onMovement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = material.stockActual <= material.stockMinimo;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isLowStock ? Border.all(color: Colors.redAccent.withAlpha(150), width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canEdit ? onEdit : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon / Indicator
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLowStock ? Colors.redAccent.withAlpha(30) : theme.colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                    color: isLowStock ? Colors.redAccent : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.categoria,
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha(150)),
                      ),
                    ],
                  ),
                ),

                // Stock Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${material.stockActual}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 20,
                        color: isLowStock ? Colors.redAccent : theme.colorScheme.primary,
                      ),
                    ),
                    const Text('Stock', style: TextStyle(fontSize: 12)),
                  ],
                ),

                // Action Buttons for Inventory/Admin
                if (canEdit) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withAlpha(50),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => onMovement?.call('entrada'),
                        child: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => onMovement?.call('salida'),
                        child: const Icon(Icons.remove_circle, color: Colors.orange, size: 28),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
