class ResumenInventario {
  final int totalMateriales;
  final int stockTotalUnidades;
  final int materialesStockBajo;

  ResumenInventario({
    required this.totalMateriales,
    required this.stockTotalUnidades,
    required this.materialesStockBajo,
  });

  factory ResumenInventario.fromJson(Map<String, dynamic> json) {
    return ResumenInventario(
      totalMateriales: json['total_materiales'] ?? 0,
      stockTotalUnidades: json['stock_total_unidades'] ?? 0,
      materialesStockBajo: json['materiales_stock_bajo'] ?? 0,
    );
  }
}

class MaterialMasUsado {
  final int materialId;
  final String materialNombre;
  final int totalSalida;

  MaterialMasUsado({
    required this.materialId,
    required this.materialNombre,
    required this.totalSalida,
  });

  factory MaterialMasUsado.fromJson(Map<String, dynamic> json) {
    return MaterialMasUsado(
      materialId: json['material_id'] ?? 0,
      materialNombre: json['material_nombre'] ?? '',
      totalSalida: json['total_salida'] ?? 0,
    );
  }
}

class AlertaInventario {
  final String tipo;
  final int materialId;
  final String materialNombre;
  final String detalle;

  AlertaInventario({
    required this.tipo,
    required this.materialId,
    required this.materialNombre,
    required this.detalle,
  });

  factory AlertaInventario.fromJson(Map<String, dynamic> json) {
    return AlertaInventario(
      tipo: json['tipo'] ?? '',
      materialId: json['material_id'] ?? 0,
      materialNombre: json['material_nombre'] ?? '',
      detalle: json['detalle'] ?? '',
    );
  }

  bool get isStockBajo => tipo == 'stock_bajo';
}

class MovimientoReporte {
  final int id;
  final int materialId;
  final String tipo;
  final int cantidad;
  final DateTime fecha;
  final int usuarioId;

  MovimientoReporte({
    required this.id,
    required this.materialId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    required this.usuarioId,
  });

  factory MovimientoReporte.fromJson(Map<String, dynamic> json) {
    return MovimientoReporte(
      id: json['id'] ?? 0,
      materialId: json['material_id'] ?? 0,
      tipo: json['tipo'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      usuarioId: json['usuario_id'] ?? 0,
    );
  }
}
