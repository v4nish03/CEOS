import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_summary_entity.dart';
import '../providers/users_provider.dart';
import '../widgets/user_card.dart';
import '../widgets/user_form_modal.dart';

class UsersScreen extends ConsumerStatefulWidget {
  final String currentRole;

  const UsersScreen({
    super.key,
    this.currentRole = 'SUPERADMIN',
  });

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openUserModal([UserSummaryEntity? userToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserFormModal(
        currentRole: widget.currentRole,
        userToEdit: userToEdit,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(usersProvider);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _GlassFAB(
        onPressed: () => _openUserModal(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, correo o rol...',
                    hintStyle: TextStyle(color: PremiumGlass.slate500.withAlpha(180), fontSize: 13),
                    icon: const Icon(Icons.search_rounded, color: AppTheme.clinicalTeal, size: 22),
                    border: InputBorder.none,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: PremiumGlass.slate500),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppTheme.clinicalTeal,
                backgroundColor: Colors.white,
                child: usersAsync.when(
                  loading: () => const _UsersSkeletonList(),
                  error: (err, stack) => _ErrorState(onRetry: _handleRefresh),
                  data: (users) {
                    final filteredUsers = users.where((u) {
                      final query = _searchQuery.toLowerCase();
                      return u.name.toLowerCase().contains(query) ||
                          u.email.toLowerCase().contains(query) ||
                          u.role.toLowerCase().contains(query);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: _EmptyUsersState(isSearching: _searchQuery.isNotEmpty),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: UserCard(
                            user: user,
                            onTap: () => _openUserModal(user),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _GlassFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.clinicalTeal.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            color: AppTheme.clinicalTeal.withAlpha(220),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Nuevo Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyUsersState extends StatelessWidget {
  final bool isSearching;

  const _EmptyUsersState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.clinicalTeal.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearching ? Icons.person_search_rounded : Icons.people_outline_rounded,
                  size: 42,
                  color: AppTheme.clinicalTeal,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSearching ? 'Sin coincidencias' : 'No hay usuarios registrados',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PremiumGlass.slate800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSearching
                    ? 'Intenta ajustar los términos de búsqueda.'
                    : 'Toca el botón "+ Nuevo Usuario" para dar de alta a un integrante.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: PremiumGlass.slate500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersSkeletonList extends StatelessWidget {
  const _UsersSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassContainer(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PremiumGlass.slate500.withAlpha(30),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: PremiumGlass.slate500.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 180,
                      height: 10,
                      decoration: BoxDecoration(
                        color: PremiumGlass.slate500.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFEF4444).withAlpha(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
            const SizedBox(height: 10),
            const Text(
              'Ocurrió un error al cargar la lista',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}