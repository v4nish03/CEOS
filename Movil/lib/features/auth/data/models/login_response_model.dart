import 'package:ceos/features/auth/domain/entities/auth_session.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.accessToken, required this.rol, required this.nombre});
  final String accessToken;
  final String rol;
  final String nombre;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'] as String,
      rol: json['rol'] as String,
      nombre: json['nombre'] as String,
    );
  }

  AuthSession toEntity() {
    return AuthSession(token: accessToken, name: nombre, role: _mapRole(rol));
  }

  UserRole _mapRole(String value) {
    switch (value.toUpperCase()) {
      case 'SUPERADMIN':
        return UserRole.superadmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'INVENTARIO':
        return UserRole.inventario;
      default:
        return UserRole.doctor;
    }
  }
}
