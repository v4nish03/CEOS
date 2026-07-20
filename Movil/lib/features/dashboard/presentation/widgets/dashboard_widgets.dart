import 'package:ceos/core/permissions/role_permissions.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:ceos/core/theme/app_theme.dart';
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
    final permissions = permissionsForRole(role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        // ── Cabecera ──
        _WelcomeHeader(nombre: nombre, role: role),
        const SizedBox(height: 20),

        // ── Accesos Rápidos ──
        const _SectionHeader(title: 'Accesos Rápidos'),
        const SizedBox(height: 12),
        _AdminQuickActions(role: role, permissions: permissions),
        const SizedBox(height: 20),

        // ── Solicitudes Pendientes Banner ──
        requestsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (requests) {
            final pendingCount = requests.where((r) => r.estado == RequestStatus.pendiente).length;
            if (pendingCount == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                color: const Color(0xFFFFFBEB).withAlpha(190),
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
                            color: const Color(0xFFF59E0B).withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.assignment_late_outlined, color: Color(0xFFD97706), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tienes $pendingCount solicitudes pendientes',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Toca para revisar y procesar',
                                style: TextStyle(fontSize: 12, color: PremiumGlass.slate500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFD97706)),
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
          GlassContainer(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: const Color(0xFF3B82F6).withAlpha(18),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modo Administrador: puedes supervisar inventario y gestionar usuarios, solicitudes y reportes.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

        // ── KPI Cards ──
        const _SectionHeader(title: 'Estado del Inventario'),
        const SizedBox(height: 12),
        resumenAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(
            message: 'No se pudo cargar el resumen',
            onRetry: () => ref.invalidate(resumenInventarioProvider),
          ),
          data: (r) => _KpiRow(resumen: r),
        ),
        const SizedBox(height: 24),

        // ── Alertas ──
        const _SectionHeader(title: 'Alertas Activas'),
        const SizedBox(height: 12),
        alertasAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(
            message: 'Error cargando alertas',
            onRetry: () => ref.invalidate(alertasInventarioProvider),
          ),
          data: (alertas) => _AlertasSection(alertas: alertas),
        ),
        const SizedBox(height: 24),

        // ── Top materiales ──
        const _SectionHeader(title: 'Materiales más Solicitados'),
        const SizedBox(height: 12),
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
  final RolePermissions permissions;

  const _AdminQuickActions({required this.role, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = <_QuickActionCard>[
      if (permissions.canViewUsers)
        _QuickActionCard(
          label: 'Usuarios',
          icon: Icons.people_outline_rounded,
          color: const Color(0xFF3B82F6),
          onTap: () => _navigateToTab(ref, 'usuarios'),
        ),
      if (permissions.canViewInventory)
        _QuickActionCard(
          label: permissions.canModifyInventory ? 'Inventario' : 'Supervisión',
          icon: permissions.canModifyInventory ? Icons.inventory_2_outlined : Icons.visibility_outlined,
          color: AppTheme.clinicalTeal,
          onTap: () => _navigateToTab(ref, 'inventario'),
        ),
      if (permissions.canReviewRequests)
        _QuickActionCard(
          label: 'Solicitudes',
          icon: Icons.assignment_outlined,
          color: const Color(0xFFF59E0B),
          onTap: () => _navigateToTab(ref, 'solicitudes'),
        ),
      if (permissions.canViewReports)
        _QuickActionCard(
          label: 'Reportes',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => _navigateToTab(ref, 'reportes'),
        ),
    ];

    return Row(
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          Expanded(child: actions[index]),
          if (index < actions.length - 1) const SizedBox(width: 8),
        ],
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 18,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withAlpha(45),
                        color.withAlpha(15),
                      ],
                    ),
                    border: Border.all(
                      color: color.withAlpha(80),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PremiumGlass.slate800,
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

// ────────────────────────────────────────────────────

class InventoryDashboard extends ConsumerWidget {
  final String nombre;

  const InventoryDashboard({super.key, required this.nombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenInventarioProvider);
    final alertasAsync = ref.watch(alertasInventarioProvider);
    final requestsAsync = ref.watch(requestsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        _WelcomeHeader(nombre: nombre, role: 'INVENTARIO'),
        const SizedBox(height: 20),

        // ── Accesos Rápidos ──
        const _SectionHeader(title: 'Accesos Rápidos'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                label: 'Inventario',
                icon: Icons.inventory_2_outlined,
                color: AppTheme.clinicalTeal,
                onTap: () => _nav(ref, 'inventario'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionCard(
                label: 'Movimientos',
                icon: Icons.swap_vert_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => _nav(ref, 'movimientos'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionCard(
                label: 'Solicitudes',
                icon: Icons.assignment_outlined,
                color: const Color(0xFFF59E0B),
                onTap: () => _nav(ref, 'solicitudes'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionCard(
                label: 'Reportes',
                icon: Icons.bar_chart_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => _nav(ref, 'reportes'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Solicitudes Pendientes Banner ──
        requestsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (requests) {
            final pendingCount = requests.where((r) => r.estado == RequestStatus.pendiente).length;
            if (pendingCount == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                color: const Color(0xFFFFFBEB).withAlpha(190),
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
                            color: const Color(0xFFF59E0B).withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.assignment_late_outlined, color: Color(0xFFD97706), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$pendingCount solicitudes pendientes',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Toca para revisar y procesar',
                                style: TextStyle(fontSize: 12, color: PremiumGlass.slate500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFD97706)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // ── KPIs Stock ──
        const _SectionHeader(title: 'Estado del Inventario'),
        const SizedBox(height: 12),
        resumenAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(
            message: 'No se pudo cargar el resumen',
            onRetry: () => ref.invalidate(resumenInventarioProvider),
          ),
          data: (r) => _KpiRow(resumen: r),
        ),
        const SizedBox(height: 24),

        // ── Alertas ──
        const _SectionHeader(title: 'Alertas de Stock Bajo / Vencimiento'),
        const SizedBox(height: 12),
        alertasAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (e, _) => _InlineError(
            message: 'Error cargando alertas',
            onRetry: () => ref.invalidate(alertasInventarioProvider),
          ),
          data: (alertas) => _AlertasSection(alertas: alertas),
        ),
      ],
    );
  }

  void _nav(WidgetRef ref, String label) {
    final labels = getLabelsForRole('INVENTARIO');
    final idx = labels.indexWhere((l) => l.toLowerCase() == label.toLowerCase());
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        _WelcomeHeader(nombre: nombre, role: 'DOCTOR'),
        const SizedBox(height: 20),

        // Card de bienvenida
        GlassContainer(
          padding: const EdgeInsets.all(20),
          color: AppTheme.clinicalTeal.withAlpha(20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_services_outlined, color: AppTheme.clinicalTeal, size: 32),
              SizedBox(height: 10),
              Text(
                'Sistema de Solicitudes',
                style: TextStyle(
                  color: PremiumGlass.slate800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Consulta el inventario y crea solicitudes de materiales médicos desde la barra inferior.',
                style: TextStyle(color: PremiumGlass.slate500, fontSize: 13, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // KPIs de disponibilidad
        const _SectionHeader(title: 'Disponibilidad de Materiales'),
        const SizedBox(height: 12),
        kpisAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (kpis) => Row(
            children: [
              Expanded(
                child: _SimpleKpiCard(
                  value: kpis['total_materiales'].toString(),
                  label: 'Materiales\nDisponibles',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SimpleKpiCard(
                  value: kpis['stock_total'].toString(),
                  label: 'Unidades\nEn Stock',
                  icon: Icons.layers_outlined,
                  color: AppTheme.clinicalTeal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SimpleKpiCard(
                  value: kpis['sin_stock_suficiente'].toString(),
                  label: 'Stock\nBajo',
                  icon: Icons.warning_amber_rounded,
                  color: (kpis['sin_stock_suficiente'] ?? 0) > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Mis solicitudes recientes
        const _SectionHeader(title: 'Mis Solicitudes Recientes'),
        const SizedBox(height: 12),
        requestsAsync.when(
          loading: () => const _KpiSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (requests) {
            if (requests.isEmpty) {
              return GlassContainer(
                padding: const EdgeInsets.all(16),
                child: const Text('No tienes solicitudes enviadas aún.', style: TextStyle(color: PremiumGlass.slate500)),
              );
            }
            final recent = requests.take(3).toList();
            return Column(
              children: recent.map((r) {
                final isApproved = r.estado.name == 'aprobada';
                final isRejected = r.estado.name == 'rechazada';
                final color = isApproved
                    ? const Color(0xFF10B981)
                    : isRejected
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFF59E0B);

                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Material #${r.materialId} — ${r.cantidad} ud.',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: PremiumGlass.slate800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withAlpha(60)),
                        ),
                        child: Text(
                          r.estado.name.toUpperCase(),
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
        const _SectionHeader(title: 'Acciones Rápidas'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                label: 'Nueva Solicitud',
                icon: Icons.add_circle_outline_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  final labels = getLabelsForRole('DOCTOR');
                  final idx = labels.indexWhere((l) => l.toLowerCase() == 'solicitudes');
                  if (idx != -1) ref.read(navigationIndexProvider.notifier).state = idx;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                label: 'Ver Materiales',
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF3B82F6),
                onTap: () {
                  final labels = getLabelsForRole('DOCTOR');
                  final idx = labels.indexWhere((l) => l.toLowerCase() == 'materiales');
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: PremiumGlass.slate800,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String nombre;
  final String role;

  const _WelcomeHeader({required this.nombre, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      'SUPERADMIN': const Color(0xFF8B5CF6),
      'ADMIN': const Color(0xFF3B82F6),
      'INVENTARIO': const Color(0xFF0D9488),
      'DOCTOR': const Color(0xFF10B981),
    };
    final color = roleColors[role] ?? const Color(0xFF64748B);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buenos días,',
                  style: TextStyle(color: PremiumGlass.slate500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: PremiumGlass.slate800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
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
        Expanded(
          child: _SimpleKpiCard(
            value: resumen.totalMateriales.toString(),
            label: 'Materiales\nRegistrados',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SimpleKpiCard(
            value: resumen.stockTotalUnidades.toString(),
            label: 'Unidades\nEn Stock',
            icon: Icons.layers_outlined,
            color: AppTheme.clinicalTeal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SimpleKpiCard(
            value: resumen.materialesStockBajo.toString(),
            label: 'Stock\nBajo Mín.',
            icon: Icons.warning_amber_rounded,
            color: resumen.materialesStockBajo > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}

class _SimpleKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _SimpleKpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: PremiumGlass.slate500,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
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
      return GlassContainer(
        padding: const EdgeInsets.all(14),
        color: const Color(0xFF10B981).withAlpha(18),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sin alertas activas. Todo en orden.',
                style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alertas.take(6).map((a) {
        final isStockBajo = a.isStockBajo;
        final color = isStockBajo ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
        final icon = isStockBajo ? Icons.warning_amber_rounded : Icons.schedule_rounded;

        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          color: color.withAlpha(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.materialNombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: PremiumGlass.slate800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.detalle,
                      style: const TextStyle(fontSize: 11, color: PremiumGlass.slate500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('#${i + 1}  ', style: const TextStyle(fontWeight: FontWeight.bold, color: PremiumGlass.slate500)),
                        Expanded(
                          child: Text(
                            m.materialNombre,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: PremiumGlass.slate800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${m.totalSalida} uds.',
                    style: const TextStyle(color: AppTheme.clinicalTeal, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppTheme.clinicalTeal.withAlpha(25),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.clinicalTeal),
                ),
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
    return const SizedBox(
      height: 90,
      child: Center(child: CircularProgressIndicator(color: AppTheme.clinicalTeal)),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFFEF4444).withAlpha(15),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Reintentar', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final String text;
  const _EmptyInfo({required this.text});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: PremiumGlass.slate500, fontSize: 13),
        ),
      ),
    );
  }
}