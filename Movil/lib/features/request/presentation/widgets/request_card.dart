import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/request_entity.dart';

class RequestCard extends StatelessWidget {
  final RequestEntity request;
  final bool canReview;
  final Function(String status)? onReview;

  const RequestCard({
    super.key,
    required this.request,
    required this.canReview,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.estado == RequestStatus.pendiente;
    final isApproved = request.estado == RequestStatus.aprobada;

    // Paleta de colores e iconos según el estado
    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;
    final String statusText;

    if (isPending) {
      statusColor = const Color(0xFFD97706); // Amber 600
      statusBg = const Color(0xFFFEF3C7);    // Amber 100
      statusIcon = Icons.hourglass_top_rounded;
      statusText = 'PENDIENTE';
    } else if (isApproved) {
      statusColor = const Color(0xFF059669); // Emerald 600
      statusBg = const Color(0xFFD1FAE5);    // Emerald 100
      statusIcon = Icons.check_circle_rounded;
      statusText = 'APROBADA';
    } else {
      statusColor = const Color(0xFFDC2626); // Red 600
      statusBg = const Color(0xFFFEE2E2);    // Red 100
      statusIcon = Icons.cancel_rounded;
      statusText = 'RECHAZADA';
    }

    final requesterInitial = request.solicitadoPor.isNotEmpty
        ? request.solicitadoPor[0].toUpperCase()
        : 'U';

    return GlassContainer(
      padding: EdgeInsets.zero,
      color: Colors.white.withAlpha(190),
      borderRadius: 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPending
                ? statusColor.withAlpha(50)
                : Colors.white.withAlpha(180),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Encabezado: Avatar + Solicitante + Badge de Estado
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: PremiumGlass.slate800.withAlpha(20),
                  child: Text(
                    requesterInitial,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: PremiumGlass.slate800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.solicitadoPor,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PremiumGlass.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Solicitante',
                        style: TextStyle(
                          fontSize: 10,
                          color: PremiumGlass.slate500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de Estado estilo Glass
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 2. Cuerpo: Detalle del Material + Bloque Destacado de Cantidad
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.materialNombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: PremiumGlass.slate800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (request.motivo != null && request.motivo!.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.notes_rounded,
                              size: 14,
                              color: PremiumGlass.slate500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                request.motivo!,
                                style: const TextStyle(
                                  color: PremiumGlass.slate500,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'Sin motivo especificado',
                          style: TextStyle(
                            color: PremiumGlass.slate500,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Contenedor numérico de cantidad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${request.cantidad}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: PremiumGlass.slate800,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
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
              ],
            ),

            // 3. Barra de Acciones (Sólo visible si es revisor y la solicitud está PENDIENTE)
            if (canReview && isPending) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0x1F000000)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onReview?.call('RECHAZADA'),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onReview?.call('APROBADA'),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (!isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.lock_clock_outlined,
                    size: 13,
                    color: PremiumGlass.slate500.withAlpha(180),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Solicitud ${statusText.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: PremiumGlass.slate500.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}