import '../../domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  RequestModel({
    required super.id,
    required super.materialId,
    required super.materialNombre,
    required super.cantidad,
    required super.estado,
    required super.solicitadoPor,
    super.motivo,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    RequestStatus mapStatus(String val) {
      switch (val.toUpperCase()) {
        case 'APROBADA': return RequestStatus.aprobada;
        case 'RECHAZADA': return RequestStatus.rechazada;
        default: return RequestStatus.pendiente;
      }
    }

    // El backend devuelve material_id y tal vez material_nombre?
    // Backend: material_id, cantidad, motivo, estado, solicitante_id, fecha_creacion
    // El backend (FastAPI) usa response_model=SolicitudOut
    // SolicitudOut incluye id, material_id, cantidad, motivo, estado, fecha_creacion, solicitante_id, y tal vez relaciones?
    // Si no incluye el nombre del material, lo mapearemos temporalmente.
    
    return RequestModel(
      id: json['id'].toString(),
      materialId: json['material_id'].toString(),
      materialNombre: json['material_nombre'] ?? 'Material #${json['material_id']}',
      cantidad: json['cantidad'] ?? 0,
      estado: mapStatus(json['estado'] ?? 'PENDIENTE'),
      solicitadoPor: json['solicitante_nombre'] ?? 'Usuario #${json['solicitante_id']}',
      motivo: json['motivo'],
    );
  }
}
