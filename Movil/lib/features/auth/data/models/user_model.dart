import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.token,
  });

  // Mapeo de la respuesta del backend (Punto 1.1 y 1.2 de tu plan) [cite: 39, 40]
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '0',
    name: json['nombre'] ?? '',
    email: json['email'] ?? '',
    role: json['rol'] ?? '',
    token: json['token'] ?? '',
  );
}