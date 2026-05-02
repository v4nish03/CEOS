enum RequestStatus { pendiente, aprobada, rechazada }

class RequestEntity {
  final String id;
  final String materialId;
  final String materialNombre;
  final int cantidad;
  final RequestStatus estado;
  final String solicitadoPor;
  final String? motivo;

  RequestEntity({
    required this.id,
    required this.materialId,
    required this.materialNombre,
    required this.cantidad,
    required this.estado,
    required this.solicitadoPor,
    this.motivo,
  });
}