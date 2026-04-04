import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/core/widgets/app_state_widgets.dart';
import 'package:ceos/core/widgets/ceos_navigation_scaffold.dart';
import 'package:ceos/features/users/presentation/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return CeosNavigationScaffold(
      title: 'Gestión de usuarios',
      currentRoute: '/users',
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: users.when(
                loading: () => const AppLoadingView(message: 'Cargando usuarios...'),
                error: (e, _) => AppErrorView(message: 'Error al cargar usuarios: $e', onRetry: () => ref.invalidate(usersProvider)),
                data: (items) {
                  if (items.isEmpty) return const AppEmptyView(title: 'No hay usuarios', subtitle: 'Crea el primero desde el botón +');
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final user = items[i] as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: Text(user['nombre'].toString().substring(0, 1).toUpperCase()),
                          ),
                          title: Text(user['nombre'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text("${user['email']}\nRol: ${user['rol']}"),
                          isThreeLine: true,
                          trailing: const Icon(Icons.manage_accounts_outlined),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateUser(context, ref),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Crear usuario'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateUser(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();
    var role = 'DOCTOR';

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre completo')),
                const SizedBox(height: 10),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 10),
                TextField(controller: pass, decoration: const InputDecoration(labelText: 'Contraseña temporal')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: role,
                  items: const ['ADMIN', 'INVENTARIO', 'DOCTOR']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
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
    );
  }
}
