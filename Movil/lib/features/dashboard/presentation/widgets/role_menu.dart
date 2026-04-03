import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleMenu extends StatelessWidget {
  const RoleMenu({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    if (role == UserRole.superadmin || role == UserRole.admin) {
      tiles.add(_tile(context, 'Reportes', Icons.analytics_outlined, '/reports'));
    }
    if (role == UserRole.inventario || role == UserRole.superadmin) {
      tiles.add(_tile(context, 'Inventario', Icons.inventory_2_outlined, '/inventory'));
    }
    if (role == UserRole.doctor || role == UserRole.inventario) {
      tiles.add(_tile(context, 'Disponibilidad', Icons.medical_information_outlined, '/inventory'));
    }
    if (role == UserRole.superadmin) {
      tiles.add(_tile(context, 'Usuarios', Icons.groups_outlined, '/users'));
    }
    return Wrap(spacing: 10, runSpacing: 10, children: tiles);
  }

  Widget _tile(BuildContext context, String text, IconData icon, String route) {
    return ActionChip(avatar: Icon(icon), label: Text(text), onPressed: () => context.go(route));
  }
}
