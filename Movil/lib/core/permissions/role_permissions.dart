import 'package:flutter/foundation.dart';

/// Tipos de roles definidos en la aplicación CEOS
enum UserRole {
  superadmin,
  admin,
  inventario,
  doctor;

  static UserRole fromString(String? role) {
    switch (role?.toUpperCase()) {
      case 'SUPERADMIN':
        return UserRole.superadmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'INVENTARIO':
        return UserRole.inventario;
      case 'DOCTOR':
      default:
        return UserRole.doctor;
    }
  }
}

@immutable
class RolePermissions {
  const RolePermissions({
    required this.canViewInventory,
    required this.canModifyInventory,
    required this.canViewUsers,
    required this.canManageUsers,
    required this.canViewReports,
    required this.canReviewRequests,
    required this.canCreateRequests,
    required this.canViewExpenses,
    required this.canCreateExpenses,
    required this.canCreateBackups,
  });

  final bool canViewInventory;
  final bool canModifyInventory;
  final bool canViewUsers;
  final bool canManageUsers;
  final bool canViewReports;
  final bool canReviewRequests;
  final bool canCreateRequests;
  final bool canViewExpenses;
  final bool canCreateExpenses;
  final bool canCreateBackups;

  /// Helper para determinar si el rol tiene acceso de solo lectura al inventario
  bool get isInventoryReadOnly => canViewInventory && !canModifyInventory;

  /// Permite crear copias modificadas manteniendo la inmutabilidad
  RolePermissions copyWith({
    bool? canViewInventory,
    bool? canModifyInventory,
    bool? canViewUsers,
    bool? canManageUsers,
    bool? canViewReports,
    bool? canReviewRequests,
    bool? canCreateRequests,
    bool? canViewExpenses,
    bool? canCreateExpenses,
    bool? canCreateBackups,
  }) {
    return RolePermissions(
      canViewInventory: canViewInventory ?? this.canViewInventory,
      canModifyInventory: canModifyInventory ?? this.canModifyInventory,
      canViewUsers: canViewUsers ?? this.canViewUsers,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canViewReports: canViewReports ?? this.canViewReports,
      canReviewRequests: canReviewRequests ?? this.canReviewRequests,
      canCreateRequests: canCreateRequests ?? this.canCreateRequests,
      canViewExpenses: canViewExpenses ?? this.canViewExpenses,
      canCreateExpenses: canCreateExpenses ?? this.canCreateExpenses,
      canCreateBackups: canCreateBackups ?? this.canCreateBackups,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolePermissions &&
        other.canViewInventory == canViewInventory &&
        other.canModifyInventory == canModifyInventory &&
        other.canViewUsers == canViewUsers &&
        other.canManageUsers == canManageUsers &&
        other.canViewReports == canViewReports &&
        other.canReviewRequests == canReviewRequests &&
        other.canCreateRequests == canCreateRequests &&
        other.canViewExpenses == canViewExpenses &&
        other.canCreateExpenses == canCreateExpenses &&
        other.canCreateBackups == canCreateBackups;
  }

  @override
  int get hashCode => Object.hash(
        canViewInventory,
        canModifyInventory,
        canViewUsers,
        canManageUsers,
        canViewReports,
        canReviewRequests,
        canCreateRequests,
        canViewExpenses,
        canCreateExpenses,
        canCreateBackups,
      );

  @override
  String toString() {
    return 'RolePermissions(viewInv: $canViewInventory, modifyInv: $canModifyInventory, manageUsers: $canManageUsers)';
  }
}

/// Mapeo de permisos globales según el rol asignado
RolePermissions permissionsForRole(String? role) {
  final userRole = UserRole.fromString(role);

  switch (userRole) {
    case UserRole.superadmin:
      return const RolePermissions(
        canViewInventory: true,
        canModifyInventory: true,
        canViewUsers: true,
        canManageUsers: true,
        canViewReports: true,
        canReviewRequests: true,
        canCreateRequests: false,
        canViewExpenses: true,
        canCreateExpenses: true,
        canCreateBackups: true,
      );

    case UserRole.admin:
      return const RolePermissions(
        canViewInventory: true,
        canModifyInventory: false,
        canViewUsers: true,
        canManageUsers: true,
        canViewReports: true,
        canReviewRequests: true,
        canCreateRequests: false,
        canViewExpenses: true,
        canCreateExpenses: false,
        canCreateBackups: true,
      );

    case UserRole.inventario:
      return const RolePermissions(
        canViewInventory: true,
        canModifyInventory: true,
        canViewUsers: false,
        canManageUsers: false,
        canViewReports: true,
        canReviewRequests: true,
        canCreateRequests: false,
        canViewExpenses: true,
        canCreateExpenses: true,
        canCreateBackups: false,
      );

    case UserRole.doctor:
      return const RolePermissions(
        canViewInventory: true,
        canModifyInventory: false,
        canViewUsers: false,
        canManageUsers: false,
        canViewReports: false,
        canReviewRequests: false,
        canCreateRequests: true,
        canViewExpenses: false,
        canCreateExpenses: false,
        canCreateBackups: false,
      );
  }
}