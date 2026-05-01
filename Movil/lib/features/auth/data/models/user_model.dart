import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.name, required super.role});

  // Mapeo de la respuesta del backend (Punto 1.1 y 1.2 de tu plan) [cite: 39, 40]
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['nombre'] ?? '',
    role: json['rol'] ?? '',
  );
}