import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceos/core/permissions/role_permissions.dart';
import '../providers/users_provider.dart';
import '../widgets/user_card.dart';
import '../widgets/user_form_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final session = ref.watch(authProvider);
    
    // Solo ADMIN y SUPERADMIN deberían poder ver esta vista, 
    // pero igual la protegemos visualmente por si acaso.
    final role = session.role ?? 'DOCTOR';
    final permissions = permissionsForRole(role);
    final canManage = permissions.canManageUsers;

    if (!canManage) {
      return const Scaffold(
        backgroundColor: PremiumGlass.canvas,
        body: PremiumBackground(child: Center(child: Text('Acceso Denegado. Solo administradores.'))),
      );
    }

    return Scaffold(
      backgroundColor: PremiumGlass.canvas,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(usersProvider),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(context, ref, role),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Usuario'),
      ),
      body: PremiumBackground(
        child: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar usuarios:\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(usersProvider),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No hay usuarios registrados.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(usersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return UserCard(user: users[index]);
              },
            ),
          );
        },
      ),
      ),
    );
  }

  void _showUserForm(BuildContext context, WidgetRef ref, String currentRole) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => UserFormModal(currentRole: currentRole),
    );
  }
}
