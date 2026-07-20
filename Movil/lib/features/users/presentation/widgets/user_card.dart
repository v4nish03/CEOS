import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_summary_entity.dart';

class UserCard extends StatelessWidget {
  final UserSummaryEntity user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.name.trim().isNotEmpty ? user.name.trim().substring(0, 1).toUpperCase() : '?';

    Color roleColor;
    switch (user.role.toUpperCase()) {
      case 'SUPERADMIN':
        roleColor = const Color(0xFF8B5CF6);
        break;
      case 'ADMIN':
        roleColor = const Color(0xFF3B82F6);
        break;
      case 'INVENTARIO':
        roleColor = const Color(0xFF0D9488);
        break;
      case 'DOCTOR':
        roleColor = const Color(0xFF10B981);
        break;
      default:
        roleColor = const Color(0xFF64748B);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: GlassContainer(
          padding: const EdgeInsets.all(14.0),
          borderRadius: 18,
          child: Row(
            children: [
              // Avatar con anillo resplandeciente
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      roleColor.withAlpha(45),
                      roleColor.withAlpha(15),
                    ],
                  ),
                  border: Border.all(
                    color: roleColor.withAlpha(90),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Información del Usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: PremiumGlass.slate800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PremiumGlass.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Badge del Rol Biselado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: roleColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: roleColor.withAlpha(70), width: 1),
                ),
                child: Text(
                  user.role,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Icono sutil de editar
              const Icon(
                Icons.chevron_right_rounded,
                color: PremiumGlass.slate500,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}