import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/features/auth/domain/entities/auth_session.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceos/features/users/presentation/providers/users_provider.dart';
import 'package:ceos/core/widgets/work_in_progress_view.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authNotifierProvider).session;
    final canManage = session != null && (session.role == UserRole.superadmin || session.role == UserRole.admin);

    if (!canManage) {
      return const Scaffold(
        body: Center(child: Text('Tu rol no tiene acceso a gestión de usuarios.')),
      );
    }

    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUser(context, ref, session.role),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Crear'),
      ),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No hay usuarios'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final user = items[i] as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user['nombre'].toString()),
                subtitle: Text('${user['email']} · ${user['rol']}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateUser(BuildContext context, WidgetRef ref, UserRole currentRole) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();
    var role = 'DOCTOR';

    final roles = currentRole == UserRole.superadmin
        ? const ['ADMIN', 'INVENTARIO', 'DOCTOR', 'SUPERADMIN']
        : const ['ADMIN', 'INVENTARIO', 'DOCTOR'];

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password')),
                DropdownButtonFormField<String>(
                  value: role,
                  items: roles.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => role = v ?? 'DOCTOR'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final dio = ref.read(dioProvider);
                await dio.post('/usuarios', data: {
                  'nombre': name.text,
                  'email': email.text,
                  'password': pass.text,
                  'rol': role,
                });
                ref.invalidate(usersProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
  Widget build(BuildContext context) {
    return const WorkInProgressView(
      title: 'Usuarios',
      description:
          'La gestión de usuarios móvil fue removida temporalmente. Este archivo queda como punto de entrada para la nueva versión.',
    );
  }
}
