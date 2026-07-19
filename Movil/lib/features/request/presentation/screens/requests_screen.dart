import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../widgets/request_card.dart';
import '../widgets/request_form_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);
    final role = ref.watch(authProvider).role;
    
    final permissions = permissionsForRole(role);
    final isDoctor = permissions.canCreateRequests;
    final canReview = permissions.canReviewRequests;

    return Scaffold(
      backgroundColor: PremiumGlass.canvas,
      appBar: AppBar(
        title: Text(isDoctor ? 'Mis Solicitudes' : 'Revisión de Solicitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(requestsProvider),
          )
        ],
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton.extended(
              onPressed: () => _showRequestForm(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Solicitud'),
            )
          : null,
      body: PremiumBackground(
        child: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar solicitudes:\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(requestsProvider),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No hay solicitudes registradas.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(requestsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                return RequestCard(
                  request: request,
                  canReview: canReview,
                  onReview: (status) async {
                    try {
                      await ref.read(requestRepositoryProvider).updateRequestStatus(request.id, status);
                      ref.invalidate(requestsProvider);
                      // Invalidate inventory if approved to reflect stock reduction
                      if (status == 'APROBADA' && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud Aprobada y Stock Actualizado')));
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud Rechazada')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }

  void _showRequestForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const RequestFormModal(),
    );
  }
}
