import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_summary_entity.dart';

class UserCard extends StatelessWidget {
  final UserSummaryEntity user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = user.name.trim().isNotEmpty ? user.name.trim().substring(0, 1).toUpperCase() : '?';
    
    // Asignar colores según el rol para identificarlos visualmente
    Color roleColor;
    switch (user.role) {
      case 'SUPERADMIN':
        roleColor = Colors.deepPurple;
        break;
      case 'ADMIN':
        roleColor = Colors.blueAccent;
        break;
      case 'INVENTARIO':
        roleColor = Colors.teal;
        break;
      case 'DOCTOR':
        roleColor = Colors.green;
        break;
      default:
        roleColor = Colors.grey;
    }

    return Container(
      decoration: PremiumGlass.glassDecoration(borderColor: roleColor.withAlpha(70)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: roleColor.withAlpha(30),
              child: Text(
                initial,
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: PremiumGlass.slate800, letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge del Rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: roleColor.withAlpha(100)),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
