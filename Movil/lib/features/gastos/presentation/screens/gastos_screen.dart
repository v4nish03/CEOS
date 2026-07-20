import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
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
    final currencyFormat = NumberFormat.currency(locale: 'es_US', symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Gestión de Gastos',
          style: TextStyle(
            color: PremiumGlass.slate800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: PremiumGlass.slate800),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.invalidate(gastosProvider);
              ref.invalidate(gastosTotalProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PremiumBackground(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(gastosProvider);
            ref.invalidate(gastosTotalProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              // ──────── Resumen de Gastos ────────
              totalAsync.when(
                loading: () => const _TotalSkeleton(),
                error: (e, _) => GlassContainer(
                  padding: const EdgeInsets.all(16.0),
                  borderRadius: 20,
                  color: AppTheme.danger.withAlpha(20),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: AppTheme.danger),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No se pudo obtener el total acumulado de gastos.',
                          style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (total) => GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 24,
                  color: Colors.white.withAlpha(180),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.clinicalTeal.withAlpha(70),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PRESUPUESTO EJECUTADO',
                              style: TextStyle(
                                color: PremiumGlass.slate500,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(total),
                              style: const TextStyle(
                                fontSize: 26,
                                color: PremiumGlass.slate800,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ──────── Banner de Supervisión (Solo Lectura) ────────
              if (!canCreateGasto) ...[
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderRadius: 16,
                  color: Colors.blueAccent.withAlpha(15),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Modo supervisión: Consulta habilitada. Registro restringido a administradores.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ──────── Encabezado de Sección ────────
              const Row(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 20, color: AppTheme.clinicalTeal),
                  SizedBox(width: 8),
                  Text(
                    'Historial de Compras y Gastos',
                    style: TextStyle(
                      color: PremiumGlass.slate800,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ──────── Lista de Gastos ────────
              gastosAsync.when(
                loading: () => const _LoadingGastosList(),
                error: (e, _) => _ErrorState(
                  onRetry: () {
                    ref.invalidate(gastosProvider);
                    ref.invalidate(gastosTotalProvider);
                  },
                ),
                data: (gastos) {
                  if (gastos.isEmpty) {
                    return _EmptyGastosView(canCreate: canCreateGasto);
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gastos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final gasto = gastos[index];
                      final fechaString = DateFormat('dd/MM/yyyy • HH:mm').format(gasto.fecha);
                      return GlassContainer(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 18,
                        color: Colors.white.withAlpha(180),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.clinicalTeal.withAlpha(20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.clinicalTeal.withAlpha(40),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppTheme.clinicalTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gasto.concepto,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: PremiumGlass.slate800,
                                    ),
                                  ),
                                  if (gasto.descripcion != null && gasto.descripcion!.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      gasto.descripcion!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: PremiumGlass.slate500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: PremiumGlass.slate500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        fechaString,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: PremiumGlass.slate500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currencyFormat.format(gasto.monto),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: canCreateGasto
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarDialogoGasto(context),
              backgroundColor: AppTheme.clinicalTeal,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Registrar Gasto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

// ──────── Estados de Carga y Vacío ────────

class _TotalSkeleton extends StatelessWidget {
  const _TotalSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: Colors.white.withAlpha(120),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PremiumGlass.slate500.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: PremiumGlass.slate500.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 24,
                  decoration: BoxDecoration(
                    color: PremiumGlass.slate500.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
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

class _LoadingGastosList extends StatelessWidget {
  const _LoadingGastosList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            color: Colors.white.withAlpha(120),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PremiumGlass.slate500.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                          color: PremiumGlass.slate500.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 90,
                        height: 10,
                        decoration: BoxDecoration(
                          color: PremiumGlass.slate500.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
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

class _EmptyGastosView extends StatelessWidget {
  final bool canCreate;
  const _EmptyGastosView({required this.canCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: 24,
        color: Colors.white.withAlpha(160),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.clinicalTeal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppTheme.clinicalTeal,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin gastos registrados',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: PremiumGlass.slate800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              canCreate
                  ? 'Usa el botón "+ Registrar Gasto" para añadir compras o desembolsos.'
                  : 'No existen registros de gastos almacenados en el sistema.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: PremiumGlass.slate500,
              ),
            ),
          ],
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      color: Colors.white.withAlpha(180),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 36),
          const SizedBox(height: 8),
          const Text(
            'No se pudieron cargar los gastos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: PremiumGlass.slate800,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.clinicalTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

// ──────── Formulario Modal para Nuevo Gasto ────────

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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Gasto registrado con éxito'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar el gasto: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PremiumGlass.slate500.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nuevo Gasto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: PremiumGlass.slate800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: PremiumGlass.slate500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conceptoController,
                  decoration: InputDecoration(
                    labelText: 'Concepto *',
                    hintText: 'Ej. Compra de insumos médicos',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El concepto es obligatorio';
                    if (value.trim().length < 2) return 'Debe tener al menos 2 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _montoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto (\$) *',
                    hintText: 'Ej. 150.50',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'El monto es obligatorio';
                    final numValue = double.tryParse(value);
                    if (numValue == null) return 'Ingrese un número válido';
                    if (numValue <= 0) return 'El monto debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    hintText: 'Ej. Factura N° 1024, proveedor DentalMed',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.clinicalTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _guardar,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Guardar Gasto',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
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