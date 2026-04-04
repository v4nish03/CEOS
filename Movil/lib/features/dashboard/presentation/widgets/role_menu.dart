import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleMenu extends StatelessWidget {
  const RoleMenu({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final tiles = <_RoleTileData>[];

    if (role == UserRole.superadmin || role == UserRole.admin) {
      tiles.add(const _RoleTileData('Reportes', Icons.analytics_outlined, '/reports'));
    }
    if (role == UserRole.inventario || role == UserRole.superadmin) {
      tiles.add(const _RoleTileData('Inventario', Icons.inventory_2_outlined, '/inventory'));
    }
    if (role == UserRole.doctor || role == UserRole.inventario) {
      tiles.add(const _RoleTileData('Disponibilidad', Icons.medical_information_outlined, '/inventory'));
    }
    if (role == UserRole.superadmin) {
      tiles.add(const _RoleTileData('Usuarios', Icons.groups_outlined, '/users'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go(tile.route),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E5E5)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tile.icon),
                const SizedBox(width: 8),
                Text(tile.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleTileData {
  const _RoleTileData(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;
}
