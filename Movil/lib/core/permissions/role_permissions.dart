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

  bool get isInventoryReadOnly => canViewInventory && !canModifyInventory;
}

RolePermissions permissionsForRole(String? role) {
  switch (role) {
    case 'SUPERADMIN':
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
    case 'ADMIN':
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
    case 'INVENTARIO':
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
    case 'DOCTOR':
    default:
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
