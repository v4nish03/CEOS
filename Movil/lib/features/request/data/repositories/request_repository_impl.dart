import 'package:dio/dio.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final Dio _dio;

  RequestRepositoryImpl(this._dio);

  @override
  Future<List<RequestEntity>> getRequests() async {
    final response = await _dio.get('/solicitudes');
    final List data = response.data;
    return data.map((json) => RequestModel.fromJson(json)).toList();
  }

  @override
  Future<void> createRequest({
    required String materialId,
    required int cantidad,
    String? motivo,
  }) async {
    await _dio.post('/solicitudes', data: {
      'material_id': int.tryParse(materialId) ?? 0,
      'cantidad': cantidad,
      'motivo': motivo,
    });
  }

  @override
  Future<void> updateRequestStatus(String requestId, String estado) async {
    await _dio.patch('/solicitudes/$requestId/estado', data: {
      'estado': estado.toLowerCase(), // e.g., 'aprobada' or 'rechazada'
    });
  }
}
