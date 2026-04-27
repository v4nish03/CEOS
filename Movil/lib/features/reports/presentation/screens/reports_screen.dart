import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Reportes',
      description:
          'La vista de reportes está en pausa. Reemplaza este placeholder por nuevas gráficas/listados cuando se retome el módulo.',
    );
  }
}
