import 'package:ceos/core/constants/app_constants.dart';
import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/gastos/presentation/providers/gastos_provider.dart';
import 'package:dio/dio.dart';
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
      appBar: AppBar(title: const Text('Más')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(gastosTotalProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ProfileHeader(name: session.name ?? 'Usuario', role: role),
            const SizedBox(height: 18),
            if (canSeeGastos) _GastosSummary(ref: ref),
            if (canSeeGastos) const SizedBox(height: 12),
            _SectionTitle(title: 'Herramientas'),
            if (canBackup)
              _ActionTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Generar respaldo',
                subtitle: 'Crea un backup manual de la base de datos.',
                color: AppTheme.clinicalTeal,
                onTap: () => _confirmBackup(context, ref),
              ),
            if (canSeeGastos)
              _ActionTile(
                icon: Icons.payments_outlined,
                title: 'Gastos',
                subtitle: 'Registrar y revisar compras del hospital.',
                color: AppTheme.warning,
                onTap: () async {
                  await context.push('/gastos');
                  ref.invalidate(gastosTotalProvider);
                },
              ),
            _ActionTile(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              subtitle: 'Servidor: ${AppConstants.baseUrl}',
              color: AppTheme.graphite,
              onTap: () => _showComingSoon(context, 'Configuración avanzada pendiente.'),
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Sesión'),
            _ActionTile(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              subtitle: 'Salir de CEOS en este dispositivo.',
              color: AppTheme.danger,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBackup(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar respaldo'),
        content: const Text('Se creará una copia de seguridad de la base de datos. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generar')),
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
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de la aplicación?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar sesión')),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.local_hospital_rounded, color: AppTheme.ink, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(role, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.softTeal, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.payments_outlined, color: AppTheme.clinicalTeal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gasto total registrado', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  totalAsync.when(
                    loading: () => const Text('Cargando...', style: TextStyle(color: AppTheme.slate)),
                    error: (_, __) => const Text('No disponible', style: TextStyle(color: AppTheme.slate)),
                    data: (total) => Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
