/// Permission helper for checking user permissions
/// 
/// Permission levels:
/// - 0: Owner (擁有者) - Can do everything
/// - 1: Admin (管理員) - Can manage accounts and templates
/// - 2: Employee (一般員工) - Can only edit reports
class PermissionHelper {
  /// Check if user can access admin features (owner or admin)
  static bool canAccessAdmin(int permission) {
    return permission == 0 || permission == 1;
  }

  /// Check if user can delete accounts (only owner)
  static bool canDeleteAccount(int permission) {
    return permission == 0;
  }

  /// Check if user can edit reports (owner, admin, or employee)
  static bool canEditReport(int permission) {
    return permission == 0 || permission == 1 || permission == 2;
  }

  /// Check if user has permission level or higher
  /// Returns true if user permission is <= requiredPermission
  static bool hasPermissionOrHigher(int userPermission, int requiredPermission) {
    return userPermission <= requiredPermission;
  }
}

