import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/gastos_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class GastosScreen extends ConsumerWidget {
  const GastosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastosProvider);
    final totalAsync = ref.watch(gastosTotalProvider);
    final role = ref.watch(authProvider).role ?? 'DOCTOR';
    final permissions = permissionsForRole(role);
    final canCreateGasto = permissions.canCreateExpenses;
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'es_US', symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Gastos'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(gastosProvider);
          ref.invalidate(gastosTotalProvider);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Card del total gastado
              totalAsync.when(
                loading: () => const _TotalSkeleton(),
                error: (e, _) => Card(
                  color: AppTheme.danger.withAlpha(20),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Error al cargar el total de gastos')),
                  ),
                ),
                data: (total) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.softTeal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.clinicalTeal.withAlpha(50), width: 1.5),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.clinicalTeal.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.payments, color: AppTheme.clinicalTeal, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Presupuesto Ejecutado',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.clinicalTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(total),
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 28,
                                color: AppTheme.clinicalTeal,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Banner solo lectura para ADMIN
              if (!canCreateGasto)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withAlpha(60)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Modo supervisión: puedes consultar los gastos registrados. Solo SUPERADMIN e Inventario pueden crear nuevas entradas.',
                          style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Historial de Compras y Gastos',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              // Listado de gastos
              Expanded(
                child: gastosAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorState(
                    onRetry: () {
                      ref.invalidate(gastosProvider);
                      ref.invalidate(gastosTotalProvider);
                    },
                  ),
                  data: (gastos) {
                    if (gastos.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payments_outlined, size: 64, color: AppTheme.slate),
                                SizedBox(height: 16),
                                Text(
                                  'No hay gastos registrados aún.',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Registra compras usando el botón + abajo.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.slate),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: gastos.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final gasto = gastos[index];
                        final fechaString = DateFormat('dd/MM/yyyy HH:mm').format(gasto.fecha);
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.porcelain,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_long, color: AppTheme.ink),
                            ),
                            title: Text(
                              gasto.concepto,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.ink),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (gasto.descripcion != null && gasto.descripcion!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    gasto.descripcion!,
                                    style: const TextStyle(fontSize: 13, color: AppTheme.slate),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  fechaString,
                                  style: TextStyle(fontSize: 11, color: AppTheme.slate.withAlpha(200)),
                                ),
                              ],
                            ),
                            trailing: Text(
                              currencyFormat.format(gasto.monto),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: canCreateGasto
          ? FloatingActionButton(
              onPressed: () => _mostrarDialogoGasto(context),
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _mostrarDialogoGasto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GastoFormModal(),
    );
  }
}

class _TotalSkeleton extends StatelessWidget {
  const _TotalSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.border.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
          const SizedBox(height: 16),
          const Text('No se pudieron cargar los gastos.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _GastoFormModal extends ConsumerStatefulWidget {
  const _GastoFormModal();

  @override
  ConsumerState<_GastoFormModal> createState() => _GastoFormModalState();
}

class _GastoFormModalState extends ConsumerState<_GastoFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text);
      await ref.read(gastosNotifierProvider.notifier).crearGasto(
            concepto: _conceptoController.text.trim(),
            monto: monto,
            descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto registrado con éxito'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar el gasto: ${e.toString()}'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registrar Gasto',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _conceptoController,
                  decoration: const InputDecoration(
                    labelText: 'Concepto *',
                    hintText: 'Ej. Compra de guantes de látex',
                    prefixIcon: Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El concepto es obligatorio';
                    if (value.trim().length < 2) return 'Debe tener al menos 2 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _montoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto (\$) *',
                    hintText: 'Ej. 150.50',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El monto es obligatorio';
                    final numValue = double.tryParse(value);
                    if (numValue == null) return 'Ingrese un número válido';
                    if (numValue <= 0) return 'El monto debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    hintText: 'Ej. Factura N° 1024, proveedor DentalMed',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _guardar,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar Gasto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
