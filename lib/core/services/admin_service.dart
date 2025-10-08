import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/permission.dart';
import 'api_service.dart';

class AdminService {
 final ApiService _apiService = ApiService();
 static const String _baseUrl = '/admin';

 // Permissions Management
 Future<ApiResponse<List<Permission>>> getPermissions({
 String? module,
 PermissionType? type,
 bool? isActive,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (module != null) q{ueryParams['module'] = module;
 if (type != null) q{ueryParams['type'] = type.name;
 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/permissions',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['permissions'];
 final permissions = data.map((json) => Permission.fromJson(json)).toList();
 return ApiResponse.success(
 data: permissions,
 message: response.message ?? 'Permissions retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve permissions',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving permissions: $e');
}
 }

 Future<ApiResponse<Permission>> createPermission(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/permissions',
 data: data,
 );
 
 if (response.success) {
 final permission = Permission.fromJson(response.data!);
 return ApiResponse.success(
 data: permission,
 message: response.message ?? 'Permission created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create permission',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating permission: $e');
}
 }

 Future<ApiResponse<Permission>> updatePermission(String id, Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put<Map<String, dynamic>>(
 '$_baseUrl/permissions/$id',
 data: data,
 );
 
 if (response.success) {
 final permission = Permission.fromJson(response.data!);
 return ApiResponse.success(
 data: permission,
 message: response.message ?? 'Permission updated successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to update permission',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error updating permission: $e');
}
 }

 // Roles Management
 Future<ApiResponse<List<Role>>> getRoles({
 bool? isActive,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/roles',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['roles'];
 final roles = data.map((json) => Role.fromJson(json)).toList();
 return ApiResponse.success(
 data: roles,
 message: response.message ?? 'Roles retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve roles',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving roles: $e');
}
 }

 Future<ApiResponse<Role>> createRole(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/roles',
 data: data,
 );
 
 if (response.success) {
 final role = Role.fromJson(response.data!);
 return ApiResponse.success(
 data: role,
 message: response.message ?? 'Role created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create role',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating role: $e');
}
 }

 Future<ApiResponse<Role>> updateRole(String id, Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put<Map<String, dynamic>>(
 '$_baseUrl/roles/$id',
 data: data,
 );
 
 if (response.success) {
 final role = Role.fromJson(response.data!);
 return ApiResponse.success(
 data: role,
 message: response.message ?? 'Role updated successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to update role',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error updating role: $e');
}
 }

 // User Roles Management
 Future<ApiResponse<List<UserRole>>> getUserRoles(String userId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/users/$userId/roles',
 );
 
 if (response.success) {
 final List<String> data = response.data!['user_roles'];
 final userRoles = data.map((json) => UserRole.fromJson(json)).toList();
 return ApiResponse.success(
 data: userRoles,
 message: response.message ?? 'User roles retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve user roles',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving user roles: $e');
}
 }

 Future<ApiResponse<UserRole>> assignRole(String userId, String roleId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/users/$userId/roles',
 data: {'role_id': roleId},
 );
 
 if (response.success) {
 final userRole = UserRole.fromJson(response.data!);
 return ApiResponse.success(
 data: userRole,
 message: response.message ?? 'Role assigned successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to assign role',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error assigning role: $e');
}
 }

 Future<ApiResponse<bool>> revokeRole(String userId, String roleId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete<Map<String, dynamic>>(
 '$_baseUrl/users/$userId/roles/$roleId',
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: true,
 message: response.message ?? 'Role revoked successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to revoke role',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error revoking role: $e');
}
 }

 // Audit Logs
 Future<ApiResponse<List<AuditLog>>> getAuditLogs({
 String? userId,
 String? module,
 String? action,
 DateTime? startDate,
 DateTime? endDate,
 bool? isSuccess,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (userId != null) q{ueryParams['user_id'] = userId;
 if (module != null) q{ueryParams['module'] = module;
 if (action != null) q{ueryParams['action'] = action;
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();
 if (isSuccess != null) q{ueryParams['is_success'] = isSuccess.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/audit-logs',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['audit_logs'];
 final auditLogs = data.map((json) => AuditLog.fromJson(json)).toList();
 return ApiResponse.success(
 data: auditLogs,
 message: response.message ?? 'Audit logs retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve audit logs',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving audit logs: $e');
}
 }

 // System Settings
 Future<ApiResponse<List<SystemSetting>>> getSystemSettings({
 String? category,
 bool? isPublic,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (category != null) q{ueryParams['category'] = category;
 if (isPublic != null) q{ueryParams['is_public'] = isPublic.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/settings',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['settings'];
 final settings = data.map((json) => SystemSetting.fromJson(json)).toList();
 return ApiResponse.success(
 data: settings,
 message: response.message ?? 'System settings retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve system settings',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving system settings: $e');
}
 }

 Future<ApiResponse<SystemSetting>> updateSetting(String id, String value) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put<Map<String, dynamic>>(
 '$_baseUrl/settings/$id',
 data: {'value': value},
 );
 
 if (response.success) {
 final setting = SystemSetting.fromJson(response.data!);
 return ApiResponse.success(
 data: setting,
 message: response.message ?? 'Setting updated successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to update setting',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error updating setting: $e');
}
 }

 // Backup Management
 Future<ApiResponse<List<Backup>>> getBackups({
 BackupType? type,
 BackupStatus? status,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (type != null) q{ueryParams['type'] = type.name;
 if (status != null) q{ueryParams['status'] = status.name;

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/backups',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['backups'];
 final backups = data.map((json) => Backup.fromJson(json)).toList();
 return ApiResponse.success(
 data: backups,
 message: response.message ?? 'Backups retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve backups',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving backups: $e');
}
 }

 Future<ApiResponse<Backup>> createBackup(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/backups',
 data: data,
 );
 
 if (response.success) {
 final backup = Backup.fromJson(response.data!);
 return ApiResponse.success(
 data: backup,
 message: response.message ?? 'Backup created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create backup',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating backup: $e');
}
 }

 Future<ApiResponse<bool>> restoreBackup(String backupId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/backups/$backupId/restore',
 data: {},
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: true,
 message: response.message ?? 'Backup restored successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to restore backup',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error restoring backup: $e');
}
 }

 Future<ApiResponse<bool>> deleteBackup(String backupId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete<Map<String, dynamic>>(
 '$_baseUrl/backups/$backupId',
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: true,
 message: response.message ?? 'Backup deleted successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to delete backup',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error deleting backup: $e');
}
 }

 // System Statistics
 Future<ApiResponse<Map<String, dynamic>>> getSystemStatistics() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/statistics',
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!,
 message: response.message ?? 'System statistics retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve system statistics',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving system statistics: $e');
}
 }

 // Security Monitoring
 Future<ApiResponse<Map<String, dynamic>>> getSecurityReport() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/security/report',
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!,
 message: response.message ?? 'Security report retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve security report',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving security report: $e');
}
 }
}
