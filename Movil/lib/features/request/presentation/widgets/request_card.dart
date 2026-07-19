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
    final theme = Theme.of(context);
    final isPending = request.estado == RequestStatus.pendiente;
    final isApproved = request.estado == RequestStatus.aprobada;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isPending) {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.hourglass_empty;
      statusText = 'Pendiente';
    } else if (isApproved) {
      statusColor = const Color(0xFF22C55E);
      statusIcon = Icons.check_circle;
      statusText = 'Aprobada';
    } else {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel;
      statusText = 'Rechazada';
    }

    return Container(
      decoration: PremiumGlass.glassDecoration(borderColor: statusColor.withAlpha(90)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Solicitado por: ${request.solicitadoPor}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.materialNombre,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: PremiumGlass.slate800, letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 4),
                      if (request.motivo != null && request.motivo!.isNotEmpty)
                        Text(
                          'Motivo: ${request.motivo}',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha(200)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${request.cantidad}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 24,
                      ),
                    ),
                    const Text('Unidades', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (canReview && isPending) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => onReview?.call('RECHAZADA'),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    label: const Text('Rechazar', style: TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => onReview?.call('APROBADA'),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: PremiumGlass.primaryButtonStyle(context).copyWith(backgroundColor: WidgetStateProperty.all(const Color(0xFF22C55E))),
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
