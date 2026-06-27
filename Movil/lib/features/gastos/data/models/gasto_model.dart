class GastoModel {
  final int id;
  final String concepto;
  final double monto;
  final String? descripcion;
  final DateTime fecha;
  final int registradoPorId;

  GastoModel({
    required this.id,
    required this.concepto,
    required this.monto,
    this.descripcion,
    required this.fecha,
    required this.registradoPorId,
  });

  factory GastoModel.fromJson(Map<String, dynamic> json) {
    return GastoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      concepto: json['concepto'] as String? ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] as String?,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      registradoPorId: (json['registrado_por_id'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concepto': concepto,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'registrado_por_id': registradoPorId,
    };
  }
}
