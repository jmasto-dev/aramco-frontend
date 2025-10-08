import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/utils/constants.dart';

// États du provider
enum EmployeeStatus {
 initial,
 loading,
 loaded,
 error,
 creating,
 updating,
 deleting,
}

class \1 extends ChangeNotifier {
 final EmployeeStatus status;
 final List<Employee> employees;
 final Employee? selectedEmployee;
 final EmployeeFilters filters;
 final int currentPage;
 final int totalPages;
 final bool hasMore;
 final String? error;
 final Map<String, String> errors;

 const EmployeeState({
 this.status = EmployeeStatus.initial,
 this.employees = const [],
 this.selectedEmployee,
 this.filters = const EmployeeFilters(),
 this.currentPage = 1,
 this.totalPages = 1,
 this.hasMore = true,
 this.error,
 this.errors = const {},
 });

 EmployeeState copyWith({
 EmployeeStatus? status,
 List<Employee>? employees,
 Employee? selectedEmployee,
 EmployeeFilters? filters,
 int? currentPage,
 int? totalPages,
 bool? hasMore,
 String? error,
 Map<String, String>? errors,
 bool clearError = false,
 bool clearErrors = false,
 }) {
 return EmployeeState(
 status: status ?? this.status,
 employees: employees ?? this.employees,
 selectedEmployee: selectedEmployee ?? this.selectedEmployee,
 filters: filters ?? this.filters,
 currentPage: currentPage ?? this.currentPage,
 totalPages: totalPages ?? this.totalPages,
 hasMore: hasMore ?? this.hasMore,
 error: clearError ? null : (error ?? this.error),
 errors: clearErrors ? {} : (errors ?? this.errors),
 );
 }

 bool get isLoading => status == EmployeeStatus.loading;
 bool get isCreating => status == EmployeeStatus.creating;
 bool get isUpdating => status == EmployeeStatus.updating;
 bool get isDeleting => status == EmployeeStatus.deleting;
 bool get hasError => error != null;
 bool get hasEmployees => employees.isNotEmpty;
 bool get canLoadMore => hasMore && !isLoading;

 // Getters pour les statistiques
 int get totalEmployees => employees.length;
 int get activeEmployees => employees.where((e) => e.isActive).length;
 int get inactiveEmployees => totalEmployees - activeEmployees;
 
 Map<String, int> get employeesByDepartment {
 final Map<String, int> departmentCount = {};
 for (final employee in employees) {
 departmentCount[employee.formattedDepartment] = 
 (departmentCount[employee.formattedDepartment] ?? 0) + 1;
}
 return departmentCount;
 }

 List<Employee> get filteredEmployees {
 if (!filters.hasFilters) r{eturn employees;
 
 return employees.where((employee) {
 // Filtre par recherche
 if (filters.searchQuery.isNotEmpty) {{
 final query = filters.searchQuery.toLowerCase();
 final matchesName = employee.fullName.toLowerCase().contains(query);
 final matchesEmail = employee.email.toLowerCase().contains(query);
 final matchesPosition = employee.position.toLowerCase().contains(query);
 final matchesDepartment = employee.department.toLowerCase().contains(query);
 
 if (!matchesName && !matchesEmail && !matchesPosition && !matchesDepartment) {{
 return false;
 }
 }
 
 // Filtre par département
 if (filters.department != Department.all) {{
 if (Department.fromString(employee.department) !{= filters.department) {
 return false;
 }
 }
 
 // Filtre par poste
 if (filters.position != Position.all) {{
 if (Position.fromString(employee.position) !{= filters.position) {
 return false;
 }
 }
 
 // Filtre par statut
 if (filters.isActive != null) {{
 if (employee.isActive != filters.isActive) {{
 return false;
 }
 }
 
 // Filtre par manager
 if (filters.managerId != null) {{
 if (employee.managerId != filters.managerId) {{
 return false;
 }
 }
 
 // Filtre par date d'embauche
 if (filters.hireDateFrom != null) {{
 if (employee.hireDate.isBefore(filters.hireDateFrom!)){ {
 return false;
 }
 }
 
 if (filters.hireDateTo != null) {{
 if (employee.hireDate.isAfter(filters.hireDateTo!)){ {
 return false;
 }
 }
 
 // Filtre par salaire
 if (filters.salaryMin != null && employee.salary != null) {{
 if (employee.salary! < filters.salaryMin!) {{
 return false;
 }
 }
 
 if (filters.salaryMax != null && employee.salary != null) {{
 if (employee.salary! > filters.salaryMax!) {{
 return false;
 }
 }
 
 return true;
}).toList();
 }
}

class EmployeeProvider extends StateNotifier<EmployeeState> {
 final ApiService _apiService;
 final Ref _ref;

 EmployeeProvider(this._apiService, this._ref) : super(const EmployeeState());

 // Charger la liste des employés
 Future<void> loadEmployees({bool refresh = false}) {async {
 if (refresh) {{
 state = state.copyWith(
 status: EmployeeStatus.loading,
 employees: [],
 currentPage: 1,
 hasMore: true,
 clearError: true,
 clearErrors: true,
 );
} else if (state.isLoading || !state.canLoadMore) {{
 return;
}

 try {
 state = state.copyWith(status: EmployeeStatus.loading);

 final response = await _apiService.get(
 '${AppConstants.employeesEndpoint}?page=${state.currentPage}',
 queryParameters: state.filters.toApiParams(),
 );

 if (response.isSuccess) {{
 final apiResponse = response.data;
 final List<String> employeesJson = apiResponse['data'] ?? [];
 final List<Employee> newEmployees = employeesJson
 .map((json) => Employee.fromJson(json))
 .toList();

 final List<Employee> allEmployees = refresh
 ? newEmployees
 : [...state.employees, ...newEmployees];

 final pagination = apiResponse.data['pagination'] ?? {};
 final currentPage = pagination['current_page'] ?? 1;
 final totalPages = pagination['last_page'] ?? 1;
 final hasMore = currentPage < totalPages;

 state = state.copyWith(
 status: EmployeeStatus.loaded,
 employees: allEmployees,
 currentPage: currentPage + 1,
 totalPages: totalPages,
 hasMore: hasMore,
 );
 } else {
 state = state.copyWith(
 status: EmployeeStatus.error,
 error: response.message ?? 'Erreur lors du chargement des employés',
 );
 }
} catch (e) {
 state = state.copyWith(
 status: EmployeeStatus.error,
 error: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Charger plus d'employés (pagination)
 Future<void> loadMoreEmployees() {async {
 if (state.canLoadMore) {{
 await loadEmployees();
}
 }

 // Rafraîchir la liste
 Future<void> refreshEmployees() {async {
 await loadEmployees(refresh: true);
 }

 // Appliquer des filtres
 Future<void> applyFilters(EmployeeFilters filters) {async {
 state = state.copyWith(filters: filters);
 await refreshEmployees();
 }

 // Réinitialiser les filtres
 Future<void> clearFilters() {async {
 await applyFilters(const EmployeeFilters());
 }

 // Rechercher des employés
 Future<void> searchEmployees(String query) {async {
 final newFilters = state.filters.copyWith(searchQuery: query);
 await applyFilters(newFilters);
 }

 // Sélectionner un employé
 void selectEmployee(Employee? employee) {
 state = state.copyWith(selectedEmployee: employee);
 }

 // Créer un employé
 Future<bool> createEmployee(Map<String, dynamic> employeeData) {async {
 try {
 state = state.copyWith(status: EmployeeStatus.creating, clearError: true);

 final response = await _apiService.post(
 AppConstants.employeesEndpoint,
 data: employeeData,
 );

 if (response.isSuccess) {{
 final newEmployee = Employee.fromJson(response.data['data']);
 state = state.copyWith(
 status: EmployeeStatus.loaded,
 employees: [newEmployee, ...state.employees],
 );
 return true;
 } else {
 final errors = <String, String>{};
 if (response.data['errors'] != null) {{
 final errorsMap = response.data['errors'] as Map<String, dynamic>;
 errorsMap.forEach((key, value) {
 if (value is List && value.isNotEmpty) {{
 errors[key] = value.first.toString();
}
});
 }

 state = state.copyWith(
 status: EmployeeStatus.error,
 error: response.message ?? 'Erreur lors de la création',
 errors: errors,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 status: EmployeeStatus.error,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Mettre à jour un employé
 Future<bool> updateEmployee(String employeeId, Map<String, dynamic> employeeData) {async {
 try {
 state = state.copyWith(status: EmployeeStatus.updating, clearError: true);

 final response = await _apiService.put(
 '${AppConstants.employeesEndpoint}/$employeeId',
 data: employeeData,
 );

 if (response.isSuccess) {{
 final updatedEmployee = Employee.fromJson(response.data['data']);
 final updatedEmployees = state.employees.map((e) {
 return e.id == employeeId ? updatedEmployee : e;
 }).toList();

 state = state.copyWith(
 status: EmployeeStatus.loaded,
 employees: updatedEmployees,
 selectedEmployee: state.selectedEmployee?.id == employeeId 
 ? updatedEmployee 
 : state.selectedEmployee,
 );
 return true;
 } else {
 final errors = <String, String>{};
 if (response.data['errors'] != null) {{
 final errorsMap = response.data['errors'] as Map<String, dynamic>;
 errorsMap.forEach((key, value) {
 if (value is List && value.isNotEmpty) {{
 errors[key] = value.first.toString();
}
});
 }

 state = state.copyWith(
 status: EmployeeStatus.error,
 error: response.message ?? 'Erreur lors de la mise à jour',
 errors: errors,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 status: EmployeeStatus.error,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Supprimer un employé
 Future<bool> deleteEmployee(String employeeId) {async {
 try {
 state = state.copyWith(status: EmployeeStatus.deleting, clearError: true);

 final response = await _apiService.delete(
 '${AppConstants.employeesEndpoint}/$employeeId',
 );

 if (response.isSuccess) {{
 final updatedEmployees = state.employees
 .where((e) => e.id != employeeId)
 .toList();

 state = state.copyWith(
 status: EmployeeStatus.loaded,
 employees: updatedEmployees,
 selectedEmployee: state.selectedEmployee?.id == employeeId 
 ? null 
 : state.selectedEmployee,
 );
 return true;
 } else {
 state = state.copyWith(
 status: EmployeeStatus.error,
 error: response.message ?? 'Erreur lors de la suppression',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 status: EmployeeStatus.error,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Activer/Désactiver un employé
 Future<bool> toggleEmployeeStatus(String employeeId) {async {
 final employee = state.employees.firstWhere((e) => e.id == employeeId);
 return await updateEmployee(employeeId, {'is_active': !employee.isActive});
 }

 // Exporter les employés
 Future<String?> exportEmployees({String format = 'excel'}) async {
 try {
 final response = await _apiService.post(
 '${AppConstants.employeesEndpoint}/export',
 data: {
 'format': format,
 'filters': state.filters.toApiParams(),
 },
 );

 if (response.isSuccess) {{
 return response.data['download_url'] as String?;
 } else {
 state = state.copyWith(
 error: response.message ?? 'Erreur lors de l\'export',
 );
 return null;
 }
} catch (e) {
 state = state.copyWith(
 error: 'Erreur réseau: ${e.toString()}',
 );
 return null;
}
 }

 // Effacer les erreurs
 void clearErrors() {
 state = state.copyWith(clearError: true, clearErrors: true);
 }

 // Réinitialiser l'état
 void reset() {
 state = const EmployeeState();
 }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) {
 return ApiService();
});

final employeeProvider = StateNotifierProvider<EmployeeProvider, EmployeeState>((ref) {
 final apiService = ref.watch(apiServiceProvider);
 return EmployeeProvider(apiService, ref);
});

// Provider pour les employés filtrés
final filteredEmployeesProvider = Provider<List<Employee>>((ref) {
 final employeeState = ref.watch(employeeProvider);
 return employeeState.filteredEmployees;
});

// Provider pour les statistiques
final employeeStatsProvider = Provider<Map<String, dynamic>>((ref) {
 final employeeState = ref.watch(employeeProvider);
 return {
 'total': employeeState.totalEmployees,
 'active': employeeState.activeEmployees,
 'inactive': employeeState.inactiveEmployees,
 'byDepartment': employeeState.employeesByDepartment,
 };
});
