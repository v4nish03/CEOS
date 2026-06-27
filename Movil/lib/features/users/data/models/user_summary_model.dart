import '../../domain/entities/user_summary_entity.dart';

class UserSummaryModel extends UserSummaryEntity {
  const UserSummaryModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['rol'] as String? ?? '',
    );
  }
}
