class InventoryReport {
  final int totalMateriales;
  final int stockTotalUnidades;
  final int materialesBajoStock;
  final List<MaterialMasUsado> topMateriales;

  InventoryReport({
    required this.totalMateriales,
    required this.stockTotalUnidades,
    required this.materialesBajoStock,
    required this.topMateriales,
  });
}

class MaterialMasUsado {
  final String nombre;
  final int cantidad;

  MaterialMasUsado({required this.nombre, required this.cantidad});
}