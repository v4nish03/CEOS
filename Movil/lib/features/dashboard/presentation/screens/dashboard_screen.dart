import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Dashboard',
      description:
          'Vista de dashboard deshabilitada. Mantén este archivo para reactivar los widgets de resumen cuando reinicie el desarrollo móvil.',
    );
  }
}
