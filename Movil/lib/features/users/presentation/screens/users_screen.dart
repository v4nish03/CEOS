import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Usuarios',
      description:
          'La gestión de usuarios móvil fue removida temporalmente. Este archivo queda como punto de entrada para la nueva versión.',
    );
  }
}
