import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceos/features/reports/presentation/providers/reports_provider.dart';
import 'package:ceos/features/reports/data/models/report_models.dart';
import 'package:ceos/features/request/presentation/providers/request_provider.dart';
import 'package:ceos/features/request/domain/entities/request_entity.dart';
import 'package:ceos/features/home/presentation/screens/main_wrapper.dart';

class AdminDashboard extends ConsumerWidget {
  final String nombre;
  final String role;

  const AdminDashboard({super.key, required this.nombre, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenInventarioProvider);
    final alertasAsync = ref.watch(alertasInventarioProvider);
    final topAsync = ref.watch(materialesMasUsadosProvider);
    final requestsAsync = ref.watch(requestsProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Cabecera ──
        _WelcomeHeader(nombre: nombre, role: role),
        const SizedBox(height: 20),

        // ── Accesos Rápidos ──
        Text('Accesos Rápidos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _AdminQuickActions(role: role),
        const SizedBox(height: 24),

        // ── Solicitudes Pendientes Banner ──
        requestsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (requests) {
            final pendingCount = requests.where((r) => r.estado == RequestStatus.pendiente).length;
            if (pendingCount == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                color: Colors.orange.shade50,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.orange.shade300, width: 1.2),
                ),
                child: InkWell(
                  onTap: () {
                    final labels = getLabelsForRole(role);
                    final targetIdx = labels.indexWhere((l) => l.toLowerCase() == 'solicitudes');
                    if (targetIdx != -1) {
                      ref.read(navigationIndexProvider.notifier).state = targetIdx;
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.assignment_late_outlined, color: Colors.orange, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tienes $pendingCount solicitudes pendientes',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange.shade900),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Haz clic para revisar y procesar',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // ── Nota de permisos ADMIN ──
        if (role == 'ADMIN')
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withAlpha(60)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modo Administrador: puedes supervisar inventario y gestionar usuarios, solicitudes y reportes.',
                    style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),

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

class _AdminQuickActions extends ConsumerWidget {
  final String role;
  const _AdminQuickActions({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInventory = role == 'SUPERADMIN' || role == 'ADMIN';

    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            label: 'Usuarios',
            icon: Icons.people_outline,
            color: Colors.blueAccent,
            onTap: () => _navigateToTab(ref, 'usuarios'),
          ),
        ),
        const SizedBox(width: 8),
        if (hasInventory) ...[
          Expanded(
            child: _QuickActionCard(
              label: 'Inventario',
              icon: Icons.inventory_2_outlined,
              color: Colors.teal,
              onTap: () => _navigateToTab(ref, 'inventario'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: _QuickActionCard(
            label: 'Solicitudes',
            icon: Icons.assignment_outlined,
            color: Colors.orange,
            onTap: () => _navigateToTab(ref, 'solicitudes'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionCard(
            label: 'Reportes',
            icon: Icons.bar_chart_outlined,
            color: Colors.purple,
            onTap: () => _navigateToTab(ref, 'reportes'),
          ),
        ),
      ],
    );
  }

  void _navigateToTab(WidgetRef ref, String label) {
    final labels = getLabelsForRole(role);
    final idx = labels.indexWhere((l) => l.toLowerCase() == label.toLowerCase());
    if (idx != -1) {
      ref.read(navigationIndexProvider.notifier).state = idx;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
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
    final requestsAsync = ref.watch(requestsProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WelcomeHeader(nombre: nombre, role: 'INVENTARIO'),
        const SizedBox(height: 20),

        // ── Accesos Rápidos ──
        Text('Accesos Rápidos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _QuickActionCard(
              label: 'Inventario',
              icon: Icons.inventory_2_outlined,
              color: Colors.teal,
              onTap: () => _nav(ref, 'inventario'),
            )),
            const SizedBox(width: 8),
            Expanded(child: _QuickActionCard(
              label: 'Movimientos',
              icon: Icons.swap_vert,
              color: Colors.blueAccent,
              onTap: () => _nav(ref, 'movimientos'),
            )),
            const SizedBox(width: 8),
            Expanded(child: _QuickActionCard(
              label: 'Solicitudes',
              icon: Icons.assignment_outlined,
              color: Colors.orange,
              onTap: () => _nav(ref, 'solicitudes'),
            )),
            const SizedBox(width: 8),
            Expanded(child: _QuickActionCard(
              label: 'Reportes',
              icon: Icons.bar_chart_outlined,
              color: Colors.purple,
              onTap: () => _nav(ref, 'reportes'),
            )),
          ],
        ),
        const SizedBox(height: 24),

        // ── Solicitudes Pendientes Banner ──
        requestsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (requests) {
            final pendingCount = requests.where((r) => r.estado == RequestStatus.pendiente).length;
            if (pendingCount == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                color: Colors.orange.shade50,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.orange.shade300, width: 1.2),
                ),
                child: InkWell(
                  onTap: () => _nav(ref, 'solicitudes'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.assignment_late_outlined, color: Colors.orange, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$pendingCount solicitudes pendientes',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange.shade900),
                              ),
                              const Text('Toca para revisar y procesar', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // ── KPIs Stock ──
        Text('Estado del Inventario', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        resumenAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(message: 'No se pudo cargar', onRetry: () => ref.invalidate(resumenInventarioProvider)),
          data: (r) => _KpiRow(resumen: r),
        ),
        const SizedBox(height: 24),

        // ── Alertas ──
        Text('Alertas de Stock Bajo / Vencimiento', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        alertasAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(message: 'Error cargando alertas', onRetry: () => ref.invalidate(alertasInventarioProvider)),
          data: (alertas) => _AlertasSection(alertas: alertas),
        ),
      ],
    );
  }

  void _nav(WidgetRef ref, String label) {
    final labels = getLabelsForRole('INVENTARIO');
    final idx = labels.indexWhere((l) => l == label);
    if (idx != -1) ref.read(navigationIndexProvider.notifier).state = idx;
  }
}

// ────────────────────────────────────────────────────

class DoctorDashboard extends ConsumerWidget {
  final String nombre;

  const DoctorDashboard({super.key, required this.nombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(doctorKpisProvider);
    final requestsAsync = ref.watch(requestsProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WelcomeHeader(nombre: nombre, role: 'DOCTOR'),
        const SizedBox(height: 20),

        // Card de bienvenida
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

        // KPIs de disponibilidad
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
                label: 'Stock\nBajo',
                icon: Icons.warning_amber_rounded,
                color: (kpis['sin_stock_suficiente'] ?? 0) > 0 ? Colors.redAccent : Colors.green,
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Mis solicitudes recientes
        Text('Mis Solicitudes Recientes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        requestsAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (requests) {
            if (requests.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withAlpha(40)),
                ),
                child: const Text('No tienes solicitudes enviadas aún.', style: TextStyle(color: Colors.grey)),
              );
            }
            final recent = requests.take(3).toList();
            return Column(
              children: recent.map((r) {
                final color = r.estado.name == 'aprobada'
                    ? Colors.green
                    : r.estado.name == 'rechazada'
                        ? Colors.red
                        : Colors.orange;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Material #${r.materialId} — ${r.cantidad} ud.',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withAlpha(80)),
                        ),
                        child: Text(
                          r.estado.name.toUpperCase(),
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),

        // Acciones rápidas
        Text('Acciones Rápidas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                label: 'Nueva\nSolicitud',
                icon: Icons.add_circle_outline,
                color: Colors.green,
                onTap: () {
                  final labels = getLabelsForRole('DOCTOR');
                  final idx = labels.indexWhere((l) => l == 'solicitudes');
                  if (idx != -1) ref.read(navigationIndexProvider.notifier).state = idx;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                label: 'Ver\nMateriales',
                icon: Icons.inventory_2_outlined,
                color: Colors.blueAccent,
                onTap: () {
                  final labels = getLabelsForRole('DOCTOR');
                  final idx = labels.indexWhere((l) => l == 'materiales');
                  if (idx != -1) ref.read(navigationIndexProvider.notifier).state = idx;
                },
              ),
            ),
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
