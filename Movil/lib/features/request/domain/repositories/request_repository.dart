import '../entities/request_entity.dart';

abstract class RequestRepository {
  Future<List<RequestEntity>> getRequests();
  Future<void> createRequest({
    required String materialId, 
    required int cantidad, 
    String? motivo,
  });
  Future<void> updateRequestStatus(String requestId, String estado);
}
