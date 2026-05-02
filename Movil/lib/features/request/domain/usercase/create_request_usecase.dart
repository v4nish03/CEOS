import '../repositories/request_repository.dart';

class CreateRequestUseCase {
  final RequestRepository _repository;
  CreateRequestUseCase(this._repository);

  Future<void> execute(String materialId, int cantidad, {String? motivo}) async {
    if (cantidad <= 0) throw Exception('La cantidad debe ser mayor a 0');
    return await _repository.createRequest(
      materialId: materialId,
      cantidad: cantidad,
      motivo: motivo,
    );
  }
}