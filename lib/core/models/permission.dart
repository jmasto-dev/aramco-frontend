import 'package:json_annotation/json_annotation.dart';

part 'permission.g.dart';

@JsonSerializable()
class Permission {
 final String id;
 final String name;
 final String code;
 final String description;
 final String module;
 final PermissionType type;
 final List<String> actions;
 final bool isActive;
 final DateTime createdAt;
 final DateTime updatedAt;

 const Permission({
 required this.id,
 required this.name,
 required this.code,
 required this.description,
 required this.module,
 required this.type,
 required this.actions,
 required this.isActive,
 required this.createdAt,
 required this.updatedAt,
 });

 factory Permission.fromJson(Map<String, dynamic> json) =>
 _$PermissionFromJson(json);

 Map<String, dynamic> toJson() => _$PermissionToJson(this);

 Permission copyWith({
 String? id,
 String? name,
 String? code,
 String? description,
 String? module,
 PermissionType? type,
 List<String>? actions,
 bool? isActive,
 DateTime? createdAt,
 DateTime? updatedAt,
 }) {
 return Permission(
 id: id ?? this.id,
 name: name ?? this.name,
 code: code ?? this.code,
 description: description ?? this.description,
 module: module ?? this.module,
 type: type ?? this.type,
 actions: actions ?? this.actions,
 isActive: isActive ?? this.isActive,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 );
 }

 String get typeText {
 switch (type) {
 case PermissionType.read:
 return 'Lecture';
 case PermissionType.write:
 return 'Écriture';
 case PermissionType.delete:
 return 'Suppression';
 case PermissionType.admin:
 return 'Administration';
}
 }
}

enum PermissionType {
 @JsonValue('read')
 read,
 @JsonValue('write')
 write,
 @JsonValue('delete')
 delete,
 @JsonValue('admin')
 admin,
}

@JsonSerializable()
class Role {
 final String id;
 final String name;
 final String code;
 final String description;
 final List<String> permissionIds;
 final List<Permission> permissions;
 final bool isSystem;
 final bool isActive;
 final int priority;
 final DateTime createdAt;
 final DateTime updatedAt;

 const Role({
 required this.id,
 required this.name,
 required this.code,
 required this.description,
 required this.permissionIds,
 required this.permissions,
 required this.isSystem,
 required this.isActive,
 required this.priority,
 required this.createdAt,
 required this.updatedAt,
 });

 factory Role.fromJson(Map<String, dynamic> json) =>
 _$RoleFromJson(json);

 Map<String, dynamic> toJson() => _$RoleToJson(this);

 bool hasPermission(String permissionCode) {
 return permissions.any((p) => p.code == permissionCode);
 }

 bool hasModulePermission(String module, PermissionType type) {
 return permissions.any((p) => p.module == module && p.type == type);
 }
}

@JsonSerializable()
class UserRole {
 final String id;
 final String userId;
 final String roleId;
 final Role? role;
 final DateTime assignedAt;
 final DateTime? expiresAt;
 final String? assignedBy;
 final bool isActive;

 const UserRole({
 required this.id,
 required this.userId,
 required this.roleId,
 this.role,
 required this.assignedAt,
 this.expiresAt,
 this.assignedBy,
 required this.isActive,
 });

 factory UserRole.fromJson(Map<String, dynamic> json) =>
 _$UserRoleFromJson(json);

 Map<String, dynamic> toJson() => _$UserRoleToJson(this);

 bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

@JsonSerializable()
class AuditLog {
 final String id;
 final String userId;
 final String? userName;
 final String action;
 final String module;
 final String? entityId;
 final String? entityType;
 final Map<String, dynamic>? oldValues;
 final Map<String, dynamic>? newValues;
 final String? ipAddress;
 final String? userAgent;
 final DateTime timestamp;
 final bool isSuccess;
 final String? errorMessage;

 const AuditLog({
 required this.id,
 required this.userId,
 this.userName,
 required this.action,
 required this.module,
 this.entityId,
 this.entityType,
 this.oldValues,
 this.newValues,
 this.ipAddress,
 this.userAgent,
 required this.timestamp,
 required this.isSuccess,
 this.errorMessage,
 });

 factory AuditLog.fromJson(Map<String, dynamic> json) =>
 _$AuditLogFromJson(json);

 Map<String, dynamic> toJson() => _$AuditLogToJson(this);

 String get actionText {
 switch (action.toLowerCase()) {
 case 'create':
 return 'Création';
 case 'update':
 return 'Modification';
 case 'delete':
 return 'Suppression';
 case 'login':
 return 'Connexion';
 case 'logout':
 return 'Déconnexion';
 case 'view':
 return 'Consultation';
 case 'export':
 return 'Export';
 case 'import':
 return 'Import';
 default:
 return action;
}
 }

 String get statusText => isSuccess ? 'Succès' : 'Échec';
}

@JsonSerializable()
class SystemSetting {
 final String id;
 final String key;
 final String value;
 final String description;
 final String category;
 final SettingType type;
 final bool isPublic;
 final bool isEditable;
 final String? validationRules;
 final DateTime createdAt;
 final DateTime updatedAt;

 const SystemSetting({
 required this.id,
 required this.key,
 required this.value,
 required this.description,
 required this.category,
 required this.type,
 required this.isPublic,
 required this.isEditable,
 this.validationRules,
 required this.createdAt,
 required this.updatedAt,
 });

 factory SystemSetting.fromJson(Map<String, dynamic> json) =>
 _$SystemSettingFromJson(json);

 Map<String, dynamic> toJson() => _$SystemSettingToJson(this);

 dynamic get typedValue {
 switch (type) {
 case SettingType.string:
 return value;
 case SettingType.number:
 return double.tryParse(value) ?? 0;
 case SettingType.boolean:
 return value.toLowerCase() == 'true';
 case SettingType.json:
 return value; // Would need json.decode in practice
 case SettingType.array:
 return value.split(',').map((e) => e.trim()).toList();
}
 }

 String get typeText {
 switch (type) {
 case SettingType.string:
 return 'Texte';
 case SettingType.number:
 return 'Nombre';
 case SettingType.boolean:
 return 'Booléen';
 case SettingType.json:
 return 'JSON';
 case SettingType.array:
 return 'Liste';
}
 }
}

enum SettingType {
 @JsonValue('string')
 string,
 @JsonValue('number')
 number,
 @JsonValue('boolean')
 boolean,
 @JsonValue('json')
 json,
 @JsonValue('array')
 array,
}

@JsonSerializable()
class Backup {
 final String id;
 final String name;
 final String description;
 final String filePath;
 final BackupType type;
 final BackupStatus status;
 final int fileSize;
 final DateTime createdAt;
 final DateTime? completedAt;
 final String? createdBy;
 final Map<String, dynamic>? metadata;
 final String? errorMessage;

 const Backup({
 required this.id,
 required this.name,
 required this.description,
 required this.filePath,
 required this.type,
 required this.status,
 required this.fileSize,
 required this.createdAt,
 this.completedAt,
 this.createdBy,
 this.metadata,
 this.errorMessage,
 });

 factory Backup.fromJson(Map<String, dynamic> json) =>
 _$BackupFromJson(json);

 Map<String, dynamic> toJson() => _$BackupToJson(this);

 String get formattedFileSize {
 if (fileSize < 1024) r{eturn '$fileSize B';
 if (fileSize < 1024 * 1024) r{eturn '${(fileSize / 1024).toStringAsFixed(1)} KB';
 if (fileSize < 1024 * 1024 * 1024) r{eturn '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
 return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
 }

 String get statusText {
 switch (status) {
 case BackupStatus.pending:
 return 'En attente';
 case BackupStatus.inProgress:
 return 'En cours';
 case BackupStatus.completed:
 return 'Terminé';
 case BackupStatus.failed:
 return 'Échoué';
}
 }

 String get typeText {
 switch (type) {
 case BackupType.full:
 return 'Complet';
 case BackupType.incremental:
 return 'Incrémentiel';
 case BackupType.differential:
 return 'Différentiel';
}
 }
}

enum BackupType {
 @JsonValue('full')
 full,
 @JsonValue('incremental')
 incremental,
 @JsonValue('differential')
 differential,
}

enum BackupStatus {
 @JsonValue('pending')
 pending,
 @JsonValue('in_progress')
 inProgress,
 @JsonValue('completed')
 completed,
 @JsonValue('failed')
 failed,
}
