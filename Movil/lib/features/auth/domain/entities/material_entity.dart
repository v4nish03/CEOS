class MaterialEntity {
  final String id;
  final String nombre;
  final String categoria;
  final int stockMinimo;
  final int stockActual;
  final DateTime? fechaVencimiento;

  MaterialEntity({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.stockMinimo,
    required this.stockActual,
    this.fechaVencimiento,
  });

  // Regla de negocio UI: ¿Necesita reabastecimiento? [cite: 221]
  bool get bajoStock => stockActual <= stockMinimo;
}