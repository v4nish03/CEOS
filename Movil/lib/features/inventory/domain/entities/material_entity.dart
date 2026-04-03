class MaterialEntity {
  const MaterialEntity({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.stockActual,
    required this.stockMinimo,
    this.fechaVencimiento,
  });

  final int id;
  final String nombre;
  final String categoria;
  final int stockActual;
  final int stockMinimo;
  final String? fechaVencimiento;
}
