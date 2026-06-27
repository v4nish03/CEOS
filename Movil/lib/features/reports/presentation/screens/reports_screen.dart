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
    messenger.showSnackBar(const SnackBar(content: Text('Generando y descargando PDF...')));
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/reportes/diario.pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes != null) {
        saveFile(bytes, 'reporte_diario.pdf');
        messenger.showSnackBar(const SnackBar(
          content: Text('Reporte PDF descargado con éxito'),
          backgroundColor: AppTheme.success,
        ));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Error al exportar PDF: $e'),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: () => _exportarPdf(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.invalidate(resumenInventarioProvider);
              ref.invalidate(materialesMasUsadosProvider);
              ref.invalidate(movimientosReporteProvider);
            },
          )
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined), text: 'Resumen'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Top Materiales'),
                Tab(icon: Icon(Icons.history), text: 'Movimientos'),
              ],
            ),
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
        padding: const EdgeInsets.all(16),
        children: [
          Text('Resumen Global del Inventario', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          resumenAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            error: (e, _) => _ErrorCard(onRetry: () => ref.invalidate(resumenInventarioProvider)),
            data: (r) => Column(
              children: [
                Row(children: [
                  Expanded(child: _KpiTile(value: r.totalMateriales.toString(), label: 'Materiales', icon: Icons.inventory_2_outlined, color: Colors.blueAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _KpiTile(value: r.stockTotalUnidades.toString(), label: 'Unidades Totales', icon: Icons.layers_outlined, color: Colors.teal)),
                ]),
                const SizedBox(height: 12),
                _KpiTile(
                  value: r.materialesStockBajo.toString(),
                  label: 'Materiales con Stock Bajo o en Mínimo',
                  icon: Icons.warning_amber_rounded,
                  color: r.materialesStockBajo > 0 ? Colors.redAccent : Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Alertas Activas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          alertasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (alertas) {
              if (alertas.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withAlpha(60)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(child: Text('Sin alertas activas en este momento.', style: TextStyle(color: Colors.green))),
                  ]),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: _ErrorCard(onRetry: () => ref.invalidate(materialesMasUsadosProvider))),
        data: (materiales) {
          if (materiales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey.withAlpha(80)),
                  const SizedBox(height: 16),
                  const Text('Sin movimientos registrados aún.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final maxVal = materiales.first.totalSalida;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: materiales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final m = materiales[i];
              final progress = maxVal > 0 ? m.totalSalida / maxVal : 0.0;
              final colors = [Colors.amber, Colors.blueGrey, Colors.brown, Colors.blueAccent, Colors.teal, Colors.deepPurple, Colors.orange, Colors.cyan];
              final barColor = colors[i % colors.length];

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          CircleAvatar(radius: 12, backgroundColor: barColor.withAlpha(30),
                            child: Text('${i + 1}', style: TextStyle(color: barColor, fontWeight: FontWeight.bold, fontSize: 11))),
                          const SizedBox(width: 10),
                          Flexible(child: Text(m.materialNombre, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                        ]),
                        Text('${m.totalSalida} uds.', style: TextStyle(color: barColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress, minHeight: 7,
                        backgroundColor: barColor.withAlpha(25),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: _ErrorCard(onRetry: () => ref.invalidate(movimientosReporteProvider))),
        data: (movimientos) {
          if (movimientos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.withAlpha(80)),
                  const SizedBox(height: 16),
                  const Text('Sin movimientos registrados.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: movimientos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final m = movimientos[i];
              final isEntrada = m.tipo == 'entrada';
              final isAjuste = m.tipo == 'ajuste';
              final color = isEntrada ? Colors.green : (isAjuste ? Colors.orange : Colors.redAccent);
              final icon = isEntrada ? Icons.add_circle : (isAjuste ? Icons.tune : Icons.remove_circle);

              final fecha = '${m.fecha.day.toString().padLeft(2, '0')}/'
                  '${m.fecha.month.toString().padLeft(2, '0')}/'
                  '${m.fecha.year} '
                  '${m.fecha.hour.toString().padLeft(2, '0')}:${m.fecha.minute.toString().padLeft(2, '0')}';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Material #${m.materialId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(fecha, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${isEntrada ? '+' : '-'}${m.cantidad}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                        Text(m.tipo.toUpperCase(), style: TextStyle(fontSize: 10, color: color)),
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

// ──────── Tiles compartidos ────────

class _KpiTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _KpiTile({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
    final color = alerta.isStockBajo ? Colors.redAccent : Colors.orange;
    final icon = alerta.isStockBajo ? Icons.warning_amber_rounded : Icons.schedule;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
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
                Text(alerta.materialNombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(alerta.detalle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
        const SizedBox(height: 8),
        const Text('No se pudo cargar los datos', style: TextStyle(color: Colors.grey)),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
