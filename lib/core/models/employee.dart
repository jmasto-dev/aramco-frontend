import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

/// Modèle pour les employés de l'entreprise
@JsonSerializable()
class Employee {
  final String id;
  final String userId;
  final String position;
  final String department;
  final DateTime hireDate;
  final double? salary;
  final String? managerId;
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  const Employee({
    required this.id,
    required this.userId,
    required this.position,
    required this.department,
    required this.hireDate,
    this.salary,
    this.managerId,
    this.phone,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      hireDate: DateTime.parse(json['hire_date'] as String),
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      managerId: json['manager_id'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'position': position,
      'department': department,
      'hire_date': hireDate.toIso8601String(),
      'salary': salary,
      'manager_id': managerId,
      'phone': phone,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  Employee copyWith({
    String? id,
    String? userId,
    String? position,
    String? department,
    DateTime? hireDate,
    double? salary,
    String? managerId,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return Employee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      department: department ?? this.department,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      managerId: managerId ?? this.managerId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  // Getters calculés
  String get fullName => user?.fullName ?? 'N/A';
  String get email => user?.email ?? 'N/A';
  
  String get initials {
    final name = fullName;
    if (name.isEmpty) return 'N/A';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  // Calcul de l'ancienneté
  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - hireDate.year;
    if (now.month < hireDate.month || 
        (now.month == hireDate.month && now.day < hireDate.day)) {
      years--;
    }
    return years;
  }

  // Statut de l'employé
  String get statusText => isActive ? 'Actif' : 'Inactif';
  
  // Département formaté
  String get formattedDepartment {
    switch (department.toLowerCase()) {
      case 'hr':
      case 'rh':
        return 'Ressources Humaines';
      case 'it':
        return 'Informatique';
      case 'sales':
      case 'ventes':
        return 'Ventes';
      case 'marketing':
        return 'Marketing';
      case 'finance':
      case 'comptabilité':
        return 'Finance';
      case 'operations':
        return 'Opérations';
      default:
        return department;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Employee{id: $id, fullName: $fullName, position: $position, department: $department}';
  }
}

// Énumération des départements
enum Department {
  all('Tous'),
  hr('Ressources Humaines'),
  it('Informatique'),
  sales('Ventes'),
  marketing('Marketing'),
  finance('Finance'),
  operations('Opérations');

  const Department(this.displayName);
  final String displayName;

  static Department fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hr':
      case 'rh':
      case 'ressources humaines':
        return Department.hr;
      case 'it':
      case 'informatique':
        return Department.it;
      case 'sales':
      case 'ventes':
        return Department.sales;
      case 'marketing':
        return Department.marketing;
      case 'finance':
      case 'comptabilité':
        return Department.finance;
      case 'operations':
        return Department.operations;
      default:
        return Department.all;
    }
  }
}

// Énumération des postes
enum Position {
  all('Tous'),
  ceo('PDG'),
  cto('Directeur Technique'),
  cfo('Directeur Financier'),
  hrManager('Manager RH'),
  itManager('Manager IT'),
  salesManager('Manager Ventes'),
  marketingManager('Manager Marketing'),
  operationsManager('Manager Opérations'),
  developer('Développeur'),
  designer('Designer'),
  accountant('Comptable'),
  salesperson('Commercial'),
  marketingSpecialist('Spécialiste Marketing'),
  operationsSpecialist('Spécialiste Opérations'),
  hrSpecialist('Spécialiste RH'),
  itSupport('Support IT'),
  intern('Stagiaire');

  const Position(this.displayName);
  final String displayName;

  static Position fromString(String value) {
    switch (value.toLowerCase()) {
      case 'ceo':
      case 'pdg':
        return Position.ceo;
      case 'cto':
      case 'directeur technique':
        return Position.cto;
      case 'cfo':
      case 'directeur financier':
        return Position.cfo;
      case 'hr manager':
      case 'manager rh':
        return Position.hrManager;
      case 'it manager':
      case 'manager it':
        return Position.itManager;
      case 'sales manager':
      case 'manager ventes':
        return Position.salesManager;
      case 'marketing manager':
      case 'manager marketing':
        return Position.marketingManager;
      case 'operations manager':
      case 'manager opérations':
        return Position.operationsManager;
      case 'developer':
      case 'développeur':
        return Position.developer;
      case 'designer':
        return Position.designer;
      case 'accountant':
      case 'comptable':
        return Position.accountant;
      case 'salesperson':
      case 'commercial':
        return Position.salesperson;
      case 'marketing specialist':
      case 'spécialiste marketing':
        return Position.marketingSpecialist;
      case 'operations specialist':
      case 'spécialiste opérations':
        return Position.operationsSpecialist;
      case 'hr specialist':
      case 'spécialiste rh':
        return Position.hrSpecialist;
      case 'it support':
      case 'support it':
        return Position.itSupport;
      case 'intern':
      case 'stagiaire':
        return Position.intern;
      default:
        return Position.all;
    }
  }
}

// Filtres pour la recherche d'employés
@JsonSerializable()
class EmployeeFilters {
  final String searchQuery;
  final Department department;
  final Position position;
  final bool? isActive;
  final String? managerId;
  final DateTime? hireDateFrom;
  final DateTime? hireDateTo;
  final double? salaryMin;
  final double? salaryMax;

  const EmployeeFilters({
    this.searchQuery = '',
    this.department = Department.all,
    this.position = Position.all,
    this.isActive,
    this.managerId,
    this.hireDateFrom,
    this.hireDateTo,
    this.salaryMin,
    this.salaryMax,
  });

  EmployeeFilters copyWith({
    String? searchQuery,
    Department? department,
    Position? position,
    bool? isActive,
    String? managerId,
    DateTime? hireDateFrom,
    DateTime? hireDateTo,
    double? salaryMin,
    double? salaryMax,
  }) {
    return EmployeeFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      department: department ?? this.department,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      managerId: managerId ?? this.managerId,
      hireDateFrom: hireDateFrom ?? this.hireDateFrom,
      hireDateTo: hireDateTo ?? this.hireDateTo,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
    );
  }

  bool get hasFilters =>
      searchQuery.isNotEmpty ||
      department != Department.all ||
      position != Position.all ||
      isActive != null ||
      managerId != null ||
      hireDateFrom != null ||
      hireDateTo != null ||
      salaryMin != null ||
      salaryMax != null;

  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{};
    
    if (searchQuery.isNotEmpty) params['search'] = searchQuery;
    if (department != Department.all) params['department'] = department.name;
    if (position != Position.all) params['position'] = position.name;
    if (isActive != null) params['is_active'] = isActive;
    if (managerId != null) params['manager_id'] = managerId;
    if (hireDateFrom != null) params['hire_date_from'] = hireDateFrom!.toIso8601String();
    if (hireDateTo != null) params['hire_date_to'] = hireDateTo!.toIso8601String();
    if (salaryMin != null) params['salary_min'] = salaryMin;
    if (salaryMax != null) params['salary_max'] = salaryMax;
    
    return params;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeFilters &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          department == other.department &&
          position == other.position &&
          isActive == other.isActive &&
          managerId == other.managerId &&
          hireDateFrom == other.hireDateFrom &&
          hireDateTo == other.hireDateTo &&
          salaryMin == other.salaryMin &&
          salaryMax == other.salaryMax;

  @override
  int get hashCode {
    return searchQuery.hashCode ^
        department.hashCode ^
        position.hashCode ^
        isActive.hashCode ^
        managerId.hashCode ^
        hireDateFrom.hashCode ^
        hireDateTo.hashCode ^
        salaryMin.hashCode ^
        salaryMax.hashCode;
  }
}

/// Utilitaires pour les employés
class EmployeeUtils {
  /// Calculer l'ancienneté en années et mois
  static String getFormattedYearsOfService(DateTime hireDate) {
    final now = DateTime.now();
    int years = now.year - hireDate.year;
    int months = now.month - hireDate.month;
    
    if (now.day < hireDate.day) {
      months--;
    }
    
    if (months < 0) {
      years--;
      months += 12;
    }
    
    if (years > 0) {
      return '$years an${years > 1 ? 's' : ''}${months > 0 ? ' $months mois' : ''}';
    } else {
      return '$months mois';
    }
  }

  /// Formatter le salaire
  static String formatSalary(double? salary) {
    if (salary == null) return 'N/A';
    return '${salary.toStringAsFixed(2)} €';
  }

  /// Obtenir la couleur du statut
  static String getStatusColor(bool isActive) {
    return isActive ? '#4CAF50' : '#F44336';
  }

  /// Valider un email d'employé
  static bool isValidEmployeeEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  /// Générer un ID d'employé unique
  static String generateEmployeeId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'EMP_$timestamp';
  }

  /// Calculer le bonus annuel
  static double calculateAnnualBonus(double salary, int yearsOfService) {
    double bonusPercentage = 0.0;
    
    if (yearsOfService >= 1) bonusPercentage = 0.05;
    if (yearsOfService >= 3) bonusPercentage = 0.10;
    if (yearsOfService >= 5) bonusPercentage = 0.15;
    if (yearsOfService >= 10) bonusPercentage = 0.20;
    
    return salary * bonusPercentage;
  }

  /// Obtenir les informations de contact complètes
  static Map<String, String> getContactInfo(Employee employee) {
    return {
      'email': employee.email,
      'phone': employee.phone ?? 'N/A',
      'address': employee.address ?? 'N/A',
      'department': employee.formattedDepartment,
      'position': employee.position,
    };
  }
}
