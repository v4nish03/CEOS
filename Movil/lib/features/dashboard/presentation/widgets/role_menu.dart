import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleMenu extends StatelessWidget {
  const RoleMenu({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    final permissions = permissionsForRole(role.name.toUpperCase());

    if (permissions.canViewInventory) {
      tiles.add(_tile(context, 'Inventario', Icons.inventory_2_outlined, '/inventory'));
    }

    if (permissions.canViewReports) {
      tiles.add(_tile(context, 'Reportes', Icons.analytics_outlined, '/reports'));
    }

    if (permissions.canViewUsers) {
      tiles.add(_tile(context, 'Usuarios', Icons.groups_outlined, '/users'));
    }

    if (permissions.canCreateRequests) {
      tiles.add(_tile(context, 'Disponibilidad', Icons.medical_information_outlined, '/inventory'));
    }

    return Wrap(spacing: 10, runSpacing: 10, children: tiles);
  }

  Widget _tile(BuildContext context, String text, IconData icon, String route) {
    return ActionChip(avatar: Icon(icon), label: Text(text), onPressed: () => context.go(route));
  }
}
