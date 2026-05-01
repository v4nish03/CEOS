import '../../domain/entities/material_entity.dart';

class MaterialModel extends MaterialEntity {
  MaterialModel({
    required super.id,
    required super.nombre,
    required super.categoria,
    required super.stockMinimo,
    required super.stockActual,
    super.fechaVencimiento,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
    id: json['id'].toString(),
    nombre: json['nombre'],
    categoria: json['categoria'],
    stockMinimo: json['stock_minimo'] ?? 0,
    stockActual: json['stock_actual'] ?? 0,
    fechaVencimiento: json['fecha_vencimiento'] != null 
        ? DateTime.parse(json['fecha_vencimiento']) 
        : null,
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'categoria': categoria,
    'stock_minimo': stockMinimo,
    'stock_actual': stockActual, // Solo para creación [cite: 235]
    'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
  };
}