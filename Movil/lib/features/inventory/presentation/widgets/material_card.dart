import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
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
    final isOut = material.stockActual == 0;
    final isLow = !isOut && material.stockActual <= material.stockMinimo;

    // Colores de estado
    final stateColor = isOut
        ? const Color(0xFFEF4444) // Rojo crítico
        : isLow
            ? const Color(0xFFF59E0B) // Ámbar advertencia
            : AppTheme.clinicalTeal; // Teal saludable

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      color: isOut
          ? const Color(0xFFFEF2F2).withAlpha(120)
          : isLow
              ? const Color(0xFFFFFBEB).withAlpha(120)
              : Colors.white.withAlpha(160),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canEdit ? onEdit : null,
          splashColor: stateColor.withAlpha(20),
          highlightColor: stateColor.withAlpha(10),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // ── Icono / Contenedor de Estado ──
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stateColor.withAlpha(45),
                        stateColor.withAlpha(15),
                      ],
                    ),
                    border: Border.all(
                      color: stateColor.withAlpha(80),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    isOut
                        ? Icons.remove_shopping_cart_rounded
                        : isLow
                            ? Icons.warning_amber_rounded
                            : Icons.inventory_2_outlined,
                    color: stateColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // ── Información Principal ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: PremiumGlass.slate800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Badge de Categoría
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: PremiumGlass.slate500.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              material.categoria,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: PremiumGlass.slate500,
                              ),
                            ),
                          ),
                          if (isLow || isOut) ...[
                            const SizedBox(width: 6),
                            Text(
                              isOut ? '• Agotado' : '• Min: ${material.stockMinimo}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: stateColor,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Indicador de Stock Actual ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: stateColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: stateColor.withAlpha(40), width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${material.stockActual}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: stateColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'UNID.',
                        style: TextStyle(
                          fontSize: 9,
                          color: PremiumGlass.slate500,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Acciones de Entrada / Salida Rápida ──
                if (canEdit) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 1,
                    height: 36,
                    color: PremiumGlass.slate500.withAlpha(35),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Entrada (+)
                      _ActionButton(
                        icon: Icons.add_rounded,
                        color: const Color(0xFF10B981),
                        tooltip: 'Entrada de stock',
                        onTap: () => onMovement?.call('entrada'),
                      ),
                      const SizedBox(height: 6),
                      // Botón Salida (-)
                      _ActionButton(
                        icon: Icons.remove_rounded,
                        color: const Color(0xFFF59E0B),
                        tooltip: 'Salida de stock',
                        onTap: () => onMovement?.call('salida'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Botón Táctil de Acción ──
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(60), width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }
}