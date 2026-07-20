import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ceos/core/network/dio_client.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/utils/file_saver.dart';
import '../providers/reports_provider.dart';
import '../../data/models/report_models.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _exportarPdf(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Generando y descargando PDF...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/reportes/diario.pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes != null) {
        saveFile(bytes, 'reporte_diario.pdf');
        messenger.clearSnackBars();
        messenger.showSnackBar(SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Reporte PDF descargado con éxito'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(SnackBar(
        content: Text('Error al exportar PDF: $e'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Reportes e Métricas',
          style: TextStyle(
            color: PremiumGlass.slate800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: PremiumGlass.slate800),
            tooltip: 'Exportar PDF',
            onPressed: () => _exportarPdf(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: PremiumGlass.slate800),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.invalidate(resumenInventarioProvider);
              ref.invalidate(materialesMasUsadosProvider);
              ref.invalidate(movimientosReporteProvider);
              ref.invalidate(alertasInventarioProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PremiumBackground(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // TabBar Flotante de Cristal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(4),
                  borderRadius: 20,
                  color: Colors.white.withAlpha(140),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppTheme.clinicalTeal,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.clinicalTeal.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: PremiumGlass.slate500,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dashboard_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Resumen'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Top'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Historial'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: TabBarView(
                  children: [
                    _ResumenTab(ref: ref),
                    _TopMaterialesTab(ref: ref),
                    _MovimientosTab(ref: ref),
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

// ──────── Tab 1: Resumen ────────

class _ResumenTab extends StatelessWidget {
  final WidgetRef ref;
  const _ResumenTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final resumenAsync = ref.watch(resumenInventarioProvider);
    final alertasAsync = ref.watch(alertasInventarioProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(resumenInventarioProvider);
        ref.invalidate(alertasInventarioProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          const _SectionHeader(
            title: 'Resumen Global',
            subtitle: 'Estado actual del inventario general',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 12),
          resumenAsync.when(
            loading: () => const _LoadingKpiView(),
            error: (e, _) => _ErrorCard(onRetry: () => ref.invalidate(resumenInventarioProvider)),
            data: (r) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        value: '${r.totalMateriales}',
                        label: 'Total Materiales',
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFF3B82F6),
                        gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        value: '${r.stockTotalUnidades}',
                        label: 'Unidades en Stock',
                        icon: Icons.layers_outlined,
                        color: const Color(0xFF0D9488),
                        gradientColors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _KpiTileHorizontal(
                  value: '${r.materialesStockBajo}',
                  label: 'Materiales con Stock Bajo o Mínimo',
                  icon: Icons.warning_amber_rounded,
                  isWarning: r.materialesStockBajo > 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(
            title: 'Alertas Activas',
            subtitle: 'Notificaciones sobre stock y caducidad',
            icon: Icons.notifications_active_outlined,
          ),
          const SizedBox(height: 12),
          alertasAsync.when(
            loading: () => const _LoadingAlertsView(),
            error: (_, __) => const SizedBox.shrink(),
            data: (alertas) {
              if (alertas.isEmpty) {
                return GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  borderRadius: 16,
                  color: Colors.white.withAlpha(160),
                  child: const Row(
                    children: [
                      ContainerBadge(
                        icon: Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        bg: Color(0xFFD1FAE5),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sin alertas pendientes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: PremiumGlass.slate800,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Todos los materiales están con niveles adecuados.',
                              style: TextStyle(
                                color: PremiumGlass.slate500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: alertas.map((a) => _AlertaTile(alerta: a)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ──────── Tab 2: Top Materiales ────────

class _TopMaterialesTab extends StatelessWidget {
  final WidgetRef ref;
  const _TopMaterialesTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final topAsync = ref.watch(materialesMasUsadosProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(materialesMasUsadosProvider),
      child: topAsync.when(
        loading: () => const _LoadingListView(),
        error: (e, _) => Center(child: _ErrorCard(onRetry: () => ref.invalidate(materialesMasUsadosProvider))),
        data: (materiales) {
          if (materiales.isEmpty) {
            return _buildEmptyView(
              icon: Icons.bar_chart_rounded,
              title: 'Sin estadísticas',
              subtitle: 'No hay egresos registrados para calcular el top de materiales.',
            );
          }
          final maxVal = materiales.first.totalSalida;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: materiales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final m = materiales[i];
              final progress = maxVal > 0 ? m.totalSalida / maxVal : 0.0;

              final palette = [
                const Color(0xFFF59E0B), // Top 1: Amber
                const Color(0xFF0D9488), // Top 2: Teal
                const Color(0xFF3B82F6), // Top 3: Blue
                const Color(0xFF8B5CF6), // Others
                const Color(0xFFEC4899),
              ];
              final barColor = palette[i % palette.length];

              return GlassContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                color: Colors.white.withAlpha(180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: barColor.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(color: barColor.withAlpha(80), width: 1),
                          ),
                          child: Text(
                            '#${i + 1}',
                            style: TextStyle(
                              color: barColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m.materialNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: PremiumGlass.slate800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: barColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${m.totalSalida} uds.',
                            style: TextStyle(
                              color: barColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: barColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.01, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: barColor.withAlpha(80),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ──────── Tab 3: Historial de Movimientos ────────

class _MovimientosTab extends StatelessWidget {
  final WidgetRef ref;
  const _MovimientosTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final movAsync = ref.watch(movimientosReporteProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(movimientosReporteProvider),
      child: movAsync.when(
        loading: () => const _LoadingListView(),
        error: (e, _) => Center(child: _ErrorCard(onRetry: () => ref.invalidate(movimientosReporteProvider))),
        data: (movimientos) {
          if (movimientos.isEmpty) {
            return _buildEmptyView(
              icon: Icons.history_toggle_off_rounded,
              title: 'Sin movimientos',
              subtitle: 'Aún no se han registrado entradas ni salidas en el sistema.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: movimientos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final m = movimientos[i];
              final isEntrada = m.tipo.toLowerCase() == 'entrada';
              final isAjuste = m.tipo.toLowerCase() == 'ajuste';

              final Color color = isEntrada
                  ? const Color(0xFF059669)
                  : (isAjuste ? const Color(0xFFD97706) : const Color(0xFFDC2626));

              final IconData icon = isEntrada
                  ? Icons.arrow_downward_rounded
                  : (isAjuste ? Icons.tune_rounded : Icons.arrow_upward_rounded);

              final fecha = '${m.fecha.day.toString().padLeft(2, '0')}/'
                  '${m.fecha.month.toString().padLeft(2, '0')}/'
                  '${m.fecha.year} • '
                  '${m.fecha.hour.toString().padLeft(2, '0')}:${m.fecha.minute.toString().padLeft(2, '0')}';

              return GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                borderRadius: 16,
                color: Colors.white.withAlpha(180),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withAlpha(50), width: 1),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Material #${m.materialId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: PremiumGlass.slate800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fecha,
                            style: const TextStyle(fontSize: 11, color: PremiumGlass.slate500),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isEntrada ? '+' : '-'}${m.cantidad}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: color,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.tipo.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: color,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ──────── Componentes visuales y Tiles ────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.clinicalTeal),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: PremiumGlass.slate800,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: PremiumGlass.slate500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final List<Color>? gradientColors;

  const _KpiTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [color, color];

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      color: Colors.white.withAlpha(180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withAlpha(60),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: PremiumGlass.slate800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: PremiumGlass.slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTileHorizontal extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isWarning;

  const _KpiTileHorizontal({
    required this.value,
    required this.label,
    required this.icon,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final bg = isWarning ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      color: Colors.white.withAlpha(180),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PremiumGlass.slate500,
                    fontWeight: FontWeight.w600,
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

class _AlertaTile extends StatelessWidget {
  final AlertaInventario alerta;
  const _AlertaTile({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final isDanger = alerta.isStockBajo;
    final color = isDanger ? const Color(0xFFDC2626) : const Color(0xFFD97706);
    final bg = isDanger ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    final icon = isDanger ? Icons.warning_amber_rounded : Icons.schedule_rounded;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      color: Colors.white.withAlpha(170),
      child: Row(
        children: [
          ContainerBadge(icon: icon, color: color, bg: bg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.materialNombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: PremiumGlass.slate800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alerta.detalle,
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
  }
}

class ContainerBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;

  const ContainerBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ──────── Estados de Carga (Skeletons) y Vacío ────────

class _LoadingKpiView extends StatelessWidget {
  const _LoadingKpiView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _skeletonBox(height: 110)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox(height: 110)),
          ],
        ),
        const SizedBox(height: 12),
        _skeletonBox(height: 70),
      ],
    );
  }
}

class _LoadingAlertsView extends StatelessWidget {
  const _LoadingAlertsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _skeletonBox(height: 60),
      )),
    );
  }
}

class _LoadingListView extends StatelessWidget {
  const _LoadingListView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _skeletonBox(height: 70),
      ),
    );
  }
}

Widget _skeletonBox({required double height}) {
  return SizedBox(
    height: height,
    child: GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      color: Colors.white.withAlpha(120),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: PremiumGlass.slate500.withAlpha(100),
          ),
        ),
      ),
    ),
  );
}

Widget _buildEmptyView({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: 24,
        color: Colors.white.withAlpha(160),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: PremiumGlass.slate500.withAlpha(120)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: PremiumGlass.slate800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: PremiumGlass.slate500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorCard({required this.onRetry});

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
            'No se pudieron cargar los datos',
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