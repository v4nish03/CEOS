import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceos/features/reports/presentation/providers/reports_provider.dart';
import 'package:ceos/features/reports/data/models/report_models.dart';

class AdminDashboard extends ConsumerWidget {
  final String nombre;
  final String role;

  const AdminDashboard({super.key, required this.nombre, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenInventarioProvider);
    final alertasAsync = ref.watch(alertasInventarioProvider);
    final topAsync = ref.watch(materialesMasUsadosProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Cabecera ──
        _WelcomeHeader(nombre: nombre, role: role),
        const SizedBox(height: 20),

        // ── KPI Cards ──
        Text('Estado del Inventario', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        resumenAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(message: 'No se pudo cargar el resumen', onRetry: () => ref.invalidate(resumenInventarioProvider)),
          data: (r) => _KpiRow(resumen: r),
        ),
        const SizedBox(height: 24),

        // ── Alertas ──
        Text('Alertas Activas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        alertasAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(message: 'Error cargando alertas', onRetry: () => ref.invalidate(alertasInventarioProvider)),
          data: (alertas) => _AlertasSection(alertas: alertas),
        ),
        const SizedBox(height: 24),

        // ── Top materiales ──
        Text('Materiales más Solicitados', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        topAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (materiales) => materiales.isEmpty
              ? const _EmptyInfo(text: 'Sin movimientos registrados aún.')
              : _TopMiniList(materiales: materiales.take(5).toList()),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────

class InventoryDashboard extends ConsumerWidget {
  final String nombre;

  const InventoryDashboard({super.key, required this.nombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenInventarioProvider);
    final alertasAsync = ref.watch(alertasInventarioProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WelcomeHeader(nombre: nombre, role: 'INVENTARIO'),
        const SizedBox(height: 20),

        Text('Stock Actual', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        resumenAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(message: 'No se pudo cargar', onRetry: () => ref.invalidate(resumenInventarioProvider)),
          data: (r) => _KpiRow(resumen: r),
        ),
        const SizedBox(height: 24),

        Text('Alertas de Stock Bajo / Vencimiento', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        alertasAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(message: 'Error cargando alertas', onRetry: () => ref.invalidate(alertasInventarioProvider)),
          data: (alertas) => _AlertasSection(alertas: alertas),
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal.withAlpha(60)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.teal),
              SizedBox(width: 10),
              Expanded(child: Text('Usa la pestaña "Inventario" para registrar entradas y salidas.', style: TextStyle(color: Colors.teal))),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────

class DoctorDashboard extends ConsumerWidget {
  final String nombre;

  const DoctorDashboard({super.key, required this.nombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(doctorKpisProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WelcomeHeader(nombre: nombre, role: 'DOCTOR'),
        const SizedBox(height: 20),

        // Card principal de bienvenida
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.teal.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.green.withAlpha(60), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_services_outlined, color: Colors.white, size: 36),
              SizedBox(height: 12),
              Text('Sistema de Solicitudes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Consulta el inventario y crea solicitudes de materiales médicos desde la barra inferior.',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Disponibilidad de Materiales', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        kpisAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (kpis) => Row(
            children: [
              Expanded(child: _SimpleKpiCard(
                value: kpis['total_materiales'].toString(),
                label: 'Materiales\nDisponibles',
                icon: Icons.inventory_2_outlined,
                color: Colors.blueAccent,
              )),
              const SizedBox(width: 12),
              Expanded(child: _SimpleKpiCard(
                value: kpis['stock_total'].toString(),
                label: 'Unidades\nEn Stock',
                icon: Icons.layers_outlined,
                color: Colors.teal,
              )),
              const SizedBox(width: 12),
              Expanded(child: _SimpleKpiCard(
                value: kpis['sin_stock_suficiente'].toString(),
                label: 'Con Stock\nBajo',
                icon: Icons.warning_amber_rounded,
                color: (kpis['sin_stock_suficiente'] ?? 0) > 0 ? Colors.redAccent : Colors.green,
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Acciones rápidas
        Text('Acciones Rápidas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _QuickAction(icon: Icons.add_circle_outline, label: 'Nueva\nSolicitud', color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _QuickAction(icon: Icons.history, label: 'Mis\nSolicitudes', color: Colors.orange)),
          ],
        ),
      ],
    );
  }
}

// ════════════════════ Widgets Compartidos ════════════════════

class _WelcomeHeader extends StatelessWidget {
  final String nombre;
  final String role;

  const _WelcomeHeader({required this.nombre, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      'SUPERADMIN': Colors.deepPurple,
      'ADMIN': Colors.blueAccent,
      'INVENTARIO': Colors.teal,
      'DOCTOR': Colors.green,
    };
    final color = roleColors[role] ?? Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buenos días,', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Text(role, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  final ResumenInventario resumen;
  const _KpiRow({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SimpleKpiCard(value: resumen.totalMateriales.toString(), label: 'Materiales\nRegistrados', icon: Icons.inventory_2_outlined, color: Colors.blueAccent)),
        const SizedBox(width: 10),
        Expanded(child: _SimpleKpiCard(value: resumen.stockTotalUnidades.toString(), label: 'Unidades\nEn Stock', icon: Icons.layers_outlined, color: Colors.teal)),
        const SizedBox(width: 10),
        Expanded(child: _SimpleKpiCard(
          value: resumen.materialesStockBajo.toString(),
          label: 'Stock\nBajo Mín.',
          icon: Icons.warning_amber_rounded,
          color: resumen.materialesStockBajo > 0 ? Colors.redAccent : Colors.green,
        )),
      ],
    );
  }
}

class _SimpleKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _SimpleKpiCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 3))],
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AlertasSection extends StatelessWidget {
  final List<AlertaInventario> alertas;
  const _AlertasSection({required this.alertas});

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withAlpha(60)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Expanded(child: Text('Sin alertas activas. Todo en orden.', style: TextStyle(color: Colors.green))),
          ],
        ),
      );
    }

    return Column(
      children: alertas.take(6).map((a) {
        final isStockBajo = a.isStockBajo;
        final color = isStockBajo ? Colors.redAccent : Colors.orange;
        final icon = isStockBajo ? Icons.warning_amber_rounded : Icons.schedule;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(70)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.materialNombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(a.detalle, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TopMiniList extends StatelessWidget {
  final List<MaterialMasUsado> materiales;
  const _TopMiniList({required this.materiales});

  @override
  Widget build(BuildContext context) {
    final maxVal = materiales.isNotEmpty ? materiales.first.totalSalida : 1;
    return Column(
      children: materiales.asMap().entries.map((e) {
        final i = e.key;
        final m = e.value;
        final progress = maxVal > 0 ? m.totalSalida / maxVal : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text('#${i + 1}  ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Flexible(child: Text(m.materialNombre, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ]),
                  Text('${m.totalSalida} uds.', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: Colors.grey.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()));
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final String text;
  const _EmptyInfo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(color: Colors.grey)));
  }
}
