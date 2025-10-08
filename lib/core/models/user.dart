import 'package:json_annotation/json_annotation.dart';

/// Modèle de données pour un utilisateur
@JsonSerializable()
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phone;
  final String? avatar;
  final String? avatarOriginal;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final bool isActive;
  final DateTime? lastLoginAt;
  final String? lastLoginIp;
  final String? language;
  final String? timezone;
  final String? departmentId;
  final String? position;
  final String? employeeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final List<Role>? roles;
  final List<String>? permissions;
  final EmployeeInfo? employee;
  
  // Computed properties
  final bool? isAdmin;
  final bool? isVerified;
  final bool? isPhoneVerified;
  final UserPreferences? preferences;
  final UserStatus? status;
  final UserMeta? meta;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phone,
    this.avatar,
    this.avatarOriginal,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.isActive,
    this.lastLoginAt,
    this.lastLoginIp,
    this.language,
    this.timezone,
    this.departmentId,
    this.position,
    this.employeeId,
    required this.createdAt,
    required this.updatedAt,
    this.roles,
    this.permissions,
    this.employee,
    this.isAdmin,
    this.isVerified,
    this.isPhoneVerified,
    this.preferences,
    this.status,
    this.meta,
  });

  /// Créer un utilisateur à partir d'un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName: json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 
        '${json['first_name'] as String? ?? ''} ${json['last_name'] as String? ?? ''}',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      avatarOriginal: json['avatar_original'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null 
        ? DateTime.parse(json['email_verified_at'] as String) 
        : null,
      phoneVerifiedAt: json['phone_verified_at'] != null 
        ? DateTime.parse(json['phone_verified_at'] as String) 
        : null,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      lastLoginAt: json['last_login_at'] != null 
        ? DateTime.parse(json['last_login_at'] as String) 
        : null,
      lastLoginIp: json['last_login_ip'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      departmentId: json['department_id'] as String?,
      position: json['position'] as String?,
      employeeId: json['employee_id'] as String?,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
      updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
      roles: json['roles'] != null 
        ? (json['roles'] as List).map((e) => Role.fromJson(e as Map<String, dynamic>)).toList()
        : null,
      permissions: json['permissions'] != null 
        ? (json['permissions'] as List).map((e) => e.toString()).toList()
        : null,
      employee: json['employee'] != null 
        ? EmployeeInfo.fromJson(json['employee'] as Map<String, dynamic>)
        : null,
      isAdmin: json['is_admin'] as bool?,
      isVerified: json['is_verified'] as bool?,
      isPhoneVerified: json['is_phone_verified'] as bool?,
      preferences: json['preferences'] != null 
        ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
        : null,
      status: json['status'] != null 
        ? UserStatus.fromJson(json['status'] as Map<String, dynamic>)
        : null,
      meta: json['meta'] != null 
        ? UserMeta.fromJson(json['meta'] as Map<String, dynamic>)
        : null,
    );
  }

  /// Convertir l'utilisateur en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'avatar_original': avatarOriginal,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_login_ip': lastLoginIp,
      'language': language,
      'timezone': timezone,
      'department_id': departmentId,
      'position': position,
      'employee_id': employeeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles?.map((e) => e.toJson()).toList(),
      'permissions': permissions,
      'employee': employee?.toJson(),
      'is_admin': isAdmin,
      'is_verified': isVerified,
      'is_phone_verified': isPhoneVerified,
      'preferences': preferences?.toJson(),
      'status': status?.toJson(),
      'meta': meta?.toJson(),
    };
  }

  /// Obtenir les initiales de l'utilisateur
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

  /// Obtenir le rôle principal
  String get primaryRole => roles?.isNotEmpty == true ? roles!.first.name : 'user';

  /// Créer une copie de l'utilisateur avec des champs modifiés
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? avatar,
    String? avatarOriginal,
    DateTime? emailVerifiedAt,
    DateTime? phoneVerifiedAt,
    bool? isActive,
    DateTime? lastLoginAt,
    String? lastLoginIp,
    String? language,
    String? timezone,
    String? departmentId,
    String? position,
    String? employeeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Role>? roles,
    List<String>? permissions,
    EmployeeInfo? employee,
    bool? isAdmin,
    bool? isVerified,
    bool? isPhoneVerified,
    UserPreferences? preferences,
    UserStatus? status,
    UserMeta? meta,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      avatarOriginal: avatarOriginal ?? this.avatarOriginal,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      departmentId: departmentId ?? this.departmentId,
      position: position ?? this.position,
      employeeId: employeeId ?? this.employeeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      employee: employee ?? this.employee,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      meta: meta ?? this.meta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $primaryRole)';
  }
}

/// Modèle pour les rôles utilisateur
@JsonSerializable()
class Role {
  final String id;
  final String name;
  final String displayName;
  final String? description;

  const Role({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
    };
  }
}

/// Modèle pour les informations employé associées
@JsonSerializable()
class EmployeeInfo {
  final String id;
  final String employeeNumber;
  final DateTime? hireDate;
  final String? jobTitle;
  final String? department;
  final String? manager;

  const EmployeeInfo({
    required this.id,
    required this.employeeNumber,
    this.hireDate,
    this.jobTitle,
    this.department,
    this.manager,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      id: json['id'] as String,
      employeeNumber: json['employee_number'] as String,
      hireDate: json['hire_date'] != null 
        ? DateTime.parse(json['hire_date'] as String) 
        : null,
      jobTitle: json['job_title'] as String?,
      department: json['department'] as String?,
      manager: json['manager'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_number': employeeNumber,
      'hire_date': hireDate?.toIso8601String(),
      'job_title': jobTitle,
      'department': department,
      'manager': manager,
    };
  }
}

/// Modèle pour les préférences utilisateur
@JsonSerializable()
class UserPreferences {
  final String? language;
  final String? timezone;

  const UserPreferences({
    this.language,
    this.timezone,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'timezone': timezone,
    };
  }
}

/// Modèle pour le statut utilisateur
@JsonSerializable()
class UserStatus {
  final bool active;
  final bool verified;
  final bool phoneVerified;
  final DateTime? lastSeen;
  final String? lastSeenFrom;

  const UserStatus({
    required this.active,
    required this.verified,
    required this.phoneVerified,
    this.lastSeen,
    this.lastSeenFrom,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      active: json['active'] as bool,
      verified: json['verified'] as bool,
      phoneVerified: json['phone_verified'] as bool,
      lastSeen: json['last_seen'] != null 
        ? DateTime.parse(json['last_seen'] as String) 
        : null,
      lastSeenFrom: json['last_seen_from'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'verified': verified,
      'phone_verified': phoneVerified,
      'last_seen': lastSeen?.toIso8601String(),
      'last_seen_from': lastSeenFrom,
    };
  }
}

/// Modèle pour les métadonnées utilisateur
@JsonSerializable()
class UserMeta {
  final String createdAtHuman;
  final String updatedAtHuman;
  final String? lastLoginHuman;
  final int accountAgeDays;

  const UserMeta({
    required this.createdAtHuman,
    required this.updatedAtHuman,
    this.lastLoginHuman,
    required this.accountAgeDays,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      createdAtHuman: json['created_at_human'] as String,
      updatedAtHuman: json['updated_at_human'] as String,
      lastLoginHuman: json['last_login_human'] as String?,
      accountAgeDays: json['account_age_days'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at_human': createdAtHuman,
      'updated_at_human': updatedAtHuman,
      'last_login_human': lastLoginHuman,
      'account_age_days': accountAgeDays,
    };
  }
}

/// Extension pour les utilitaires sur les utilisateurs
extension UserExtensions on User {
  /// Vérifier si l'utilisateur est un administrateur
  bool get isAdminUser => isAdmin == true || primaryRole == 'admin';

  /// Vérifier si l'utilisateur est un manager
  bool get isManagerUser => primaryRole == 'manager';

  /// Vérifier si l'utilisateur est un opérateur
  bool get isOperatorUser => primaryRole == 'operator';

  /// Vérifier si l'utilisateur est dans les RH
  bool get isHRUser => primaryRole == 'hr' || primaryRole == 'rh';

  /// Vérifier si l'utilisateur est un comptable
  bool get isAccountantUser => primaryRole == 'accountant' || primaryRole == 'comptable';

  /// Vérifier si l'utilisateur est dans la logistique
  bool get isLogisticsUser => primaryRole == 'logistics' || primaryRole == 'logistique';

  /// Obtenir le nom d'affichage du rôle
  String get roleDisplayName {
    switch (primaryRole) {
      case 'admin':
        return 'Administrateur';
      case 'manager':
        return 'Manager';
      case 'operator':
        return 'Opérateur';
      case 'hr':
      case 'rh':
        return 'Ressources Humaines';
      case 'accountant':
      case 'comptable':
        return 'Comptable';
      case 'logistics':
      case 'logistique':
        return 'Logistique';
      default:
        return primaryRole.toUpperCase();
    }
  }

  /// Vérifier si l'utilisateur a accès à une ressource spécifique
  bool hasPermission(String permission) {
    if (isAdminUser) return true;
    return permissions?.contains(permission) ?? false;
  }

  /// Obtenir une version simplifiée pour l'affichage
  User get displayUser {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      avatar: avatar,
      phone: phone,
      position: position,
      departmentId: employee?.department != null ? departmentId : null,
    );
  }

  /// Getter pour la compatibilité avec l'ancien code
  String get role => primaryRole;
  
  /// Getter pour la compatibilité avec l'ancien code 
  DateTime? get lastLogin => lastLoginAt;
}
