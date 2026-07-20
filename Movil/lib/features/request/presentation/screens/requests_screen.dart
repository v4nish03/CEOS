import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../widgets/request_card.dart';
import '../widgets/request_form_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider local para gestionar el filtro activo en la pantalla
final requestFilterProvider = StateProvider.autoDispose<String>((ref) => 'TODAS');

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);
    final selectedFilter = ref.watch(requestFilterProvider);
    final role = ref.watch(authProvider).role;

    final permissions = permissionsForRole(role);
    final isDoctor = permissions.canCreateRequests;
    final canReview = permissions.canReviewRequests;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isDoctor ? 'Mis Solicitudes' : 'Revisión de Solicitudes',
          style: const TextStyle(
            color: PremiumGlass.slate800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: PremiumGlass.slate800),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(requestsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton.extended(
              onPressed: () => _showRequestForm(context, ref),
              backgroundColor: AppTheme.clinicalTeal,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Nueva Solicitud',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      body: PremiumBackground(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: requestsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          error: (error, stack) => _buildErrorView(context, ref, error),
          data: (allRequests) {
            // Filtrado de lista usando req.estado.name
            final filteredRequests = allRequests.where((req) {
              if (selectedFilter == 'TODAS') return true;
              return req.estado.name.toUpperCase() == selectedFilter;
            }).toList();

            // Métricas para los contadores rápidos usando req.estado.name
            final pendingCount = allRequests.where((r) => r.estado.name.toUpperCase() == 'PENDIENTE').length;
            final approvedCount = allRequests.where((r) => r.estado.name.toUpperCase() == 'APROBADA').length;
            final rejectedCount = allRequests.where((r) => r.estado.name.toUpperCase() == 'RECHAZADA').length;

            return Column(
              children: [
                // 1. Barra de Chips de Selección / Métricas
                _FilterChipsBar(
                  selectedFilter: selectedFilter,
                  totalCount: allRequests.length,
                  pendingCount: pendingCount,
                  approvedCount: approvedCount,
                  rejectedCount: rejectedCount,
                  onSelected: (filter) {
                    ref.read(requestFilterProvider.notifier).state = filter;
                  },
                ),

                const SizedBox(height: 12),

                // 2. Lista de Solicitudes
                Expanded(
                  child: filteredRequests.isEmpty
                      ? _buildEmptyState(selectedFilter)
                      : RefreshIndicator(
                          onRefresh: () async => ref.invalidate(requestsProvider),
                          child: ListView.separated(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 110,
                            ),
                            itemCount: filteredRequests.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final request = filteredRequests[index];
                              return RequestCard(
                                request: request,
                                canReview: canReview,
                                onReview: (status) => _handleReviewStatus(context, ref, request.id, status),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Procesa el cambio de estado de la solicitud
  Future<void> _handleReviewStatus(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String status,
  ) async {
    try {
      await ref.read(requestRepositoryProvider).updateRequestStatus(requestId, status);
      ref.invalidate(requestsProvider);

      if (!context.mounted) return;

      final isApproved = status == 'APROBADA';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isApproved ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          content: Row(
            children: [
              Icon(
                isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isApproved
                      ? 'Solicitud aprobada y stock actualizado.'
                      : 'Solicitud rechazada.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la solicitud: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// Vista de Estado Vacío cuando no hay resultados
  Widget _buildEmptyState(String filter) {
    String message = 'No hay solicitudes registradas.';
    if (filter == 'PENDIENTE') message = 'No tienes solicitudes pendientes por revisar.';
    if (filter == 'APROBADA') message = 'No hay solicitudes aprobadas históricas.';
    if (filter == 'RECHAZADA') message = 'No hay solicitudes rechazadas.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PremiumGlass.slate800.withAlpha(12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 44,
                  color: PremiumGlass.slate500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: PremiumGlass.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Vista estilizada de Error
  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text(
                'Ocurrió un problema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PremiumGlass.slate800),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: PremiumGlass.slate500),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.clinicalTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => ref.invalidate(requestsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const RequestFormModal(),
    );
  }
}

/// Widget interno para la barra horizontal de filtros por estado
class _FilterChipsBar extends StatelessWidget {
  final String selectedFilter;
  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final ValueChanged<String> onSelected;

  const _FilterChipsBar({
    required this.selectedFilter,
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'TODAS', 'label': 'Todas', 'count': totalCount},
      {'key': 'PENDIENTE', 'label': 'Pendientes', 'count': pendingCount},
      {'key': 'APROBADA', 'label': 'Aprobadas', 'count': approvedCount},
      {'key': 'RECHAZADA', 'label': 'Rechazadas', 'count': rejectedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((f) {
          final key = f['key'] as String;
          final label = f['label'] as String;
          final count = f['count'] as int;
          final isSelected = selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withAlpha(60)
                          : PremiumGlass.slate800.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : PremiumGlass.slate800,
                      ),
                    ),
                  ),
                ],
              ),
              selectedColor: AppTheme.clinicalTeal,
              backgroundColor: Colors.white.withAlpha(160),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.clinicalTeal
                    : Colors.black.withAlpha(12),
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : PremiumGlass.slate800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) => onSelected(key),
            ),
          );
        }).toList(),
      ),
    );
  }
}