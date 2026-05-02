import 'package:flutter/material.dart';
import 'package:ceos/features/auth/domain/entities/user_entity.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: roleColor.withAlpha(50), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: roleColor.withAlpha(30),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
