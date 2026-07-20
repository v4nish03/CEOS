import 'dart:ui';

import 'package:ceos/core/constants/app_constants.dart';
import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/gastos/presentation/providers/gastos_provider.dart';
import 'package:dio/dio.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final role = session.role ?? 'DOCTOR';
    final permissions = permissionsForRole(role);
    final canSeeGastos = permissions.canViewExpenses;
    final canBackup = permissions.canCreateBackups;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + MediaQuery.of(context).padding.top),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(160),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withAlpha(220),
                    width: 1.2,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: const Text(
                  'Más Opciones',
                  style: TextStyle(
                    color: PremiumGlass.slate800,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: PremiumBackground(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(gastosTotalProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              _ProfileHeader(name: session.name ?? 'Usuario', role: role),
              const SizedBox(height: 20),
              if (canSeeGastos) _GastosSummary(ref: ref),
              if (canSeeGastos) const SizedBox(height: 20),
              const _SectionTitle(title: 'Herramientas y Gestión'),
              const SizedBox(height: 8),
              if (canBackup)
                _ActionTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Generar respaldo',
                  subtitle: 'Crea una copia de seguridad manual de la base de datos.',
                  color: AppTheme.clinicalTeal,
                  onTap: () => _confirmBackup(context, ref),
                ),
              if (canSeeGastos)
                _ActionTile(
                  icon: Icons.payments_outlined,
                  title: 'Gastos de Operación',
                  subtitle: 'Registrar y revisar compras del hospital.',
                  color: const Color(0xFFF59E0B),
                  onTap: () async {
                    await context.push('/gastos');
                    ref.invalidate(gastosTotalProvider);
                  },
                ),
              _ActionTile(
                icon: Icons.settings_outlined,
                title: 'Configuración de Servidor',
                subtitle: 'Servidor: ${AppConstants.baseUrl}',
                color: const Color(0xFF64748B),
                onTap: () => _showComingSoon(context, 'Configuración avanzada pendiente.'),
              ),
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Cuenta y Sesión'),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.logout_rounded,
                title: 'Cerrar sesión',
                subtitle: 'Salir de la aplicación CEOS en este dispositivo.',
                color: const Color(0xFFEF4444),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBackup(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withAlpha(245),
        title: const Text('Generar respaldo', style: TextStyle(fontWeight: FontWeight.bold, color: PremiumGlass.slate800)),
        content: const Text('Se creará una copia de seguridad de la base de datos. ¿Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: PremiumGlass.slate500)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.clinicalTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generar'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Generando respaldo...')));
      final dio = ref.read(dioProvider);
      final response = await dio.post('/backups/database');
      final file = response.data is Map ? response.data['backup_file'] : null;
      messenger.showSnackBar(SnackBar(content: Text(file == null ? 'Respuesta de backup recibida.' : 'Backup creado: $file')));
    } on DioException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo generar backup: ${e.response?.data ?? e.message}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo generar backup: $e')));
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withAlpha(245),
        title: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold, color: PremiumGlass.slate800)),
        content: const Text('¿Estás seguro de que deseas salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: PremiumGlass.slate500)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      'SUPERADMIN': const Color(0xFF8B5CF6),
      'ADMIN': const Color(0xFF3B82F6),
      'INVENTARIO': const Color(0xFF0D9488),
      'DOCTOR': const Color(0xFF10B981),
    };
    final color = roleColors[role] ?? const Color(0xFF64748B);

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(60), width: 1.5),
            ),
            child: Icon(Icons.person_outline_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: PremiumGlass.slate800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(70)),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GastosSummary extends StatelessWidget {
  const _GastosSummary({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final totalAsync = ref.watch(gastosTotalProvider);
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.clinicalTeal.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.payments_outlined, color: AppTheme.clinicalTeal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gasto total registrado',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: PremiumGlass.slate500,
                  ),
                ),
                const SizedBox(height: 2),
                totalAsync.when(
                  loading: () => const Text(
                    'Cargando...',
                    style: TextStyle(color: PremiumGlass.slate500, fontSize: 16),
                  ),
                  error: (_, __) => const Text(
                    'No disponible',
                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  data: (total) => Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: PremiumGlass.slate800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: PremiumGlass.slate800,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: PremiumGlass.slate800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: PremiumGlass.slate500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: PremiumGlass.slate500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}