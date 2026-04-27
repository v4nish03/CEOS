import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Inventario',
      description:
          'La vista de inventario fue retirada para rehacer el flujo de materiales desde cero sobre la misma estructura de carpetas.',
    );
  }
}
