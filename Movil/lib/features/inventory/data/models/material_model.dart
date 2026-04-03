import 'package:ceos/features/inventory/domain/entities/material_entity.dart';

class MaterialModel {
  const MaterialModel({
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

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      stockActual: json['stock_actual'] as int,
      stockMinimo: json['stock_minimo'] as int,
      fechaVencimiento: json['fecha_vencimiento']?.toString(),
    );
  }

  MaterialEntity toEntity() => MaterialEntity(
        id: id,
        nombre: nombre,
        categoria: categoria,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
        fechaVencimiento: fechaVencimiento,
      );
}
