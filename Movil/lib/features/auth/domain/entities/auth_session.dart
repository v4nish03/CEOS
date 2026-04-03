enum UserRole { superadmin, admin, inventario, doctor }

class AuthSession {
  const AuthSession({required this.token, required this.name, required this.role});
  final String token;
  final String name;
  final UserRole role;
}
