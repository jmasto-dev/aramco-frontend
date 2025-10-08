import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/api_service.dart';
import 'package:aramco_frontend/core/utils/constants.dart';

class EmployeeService {
  final ApiService _apiService;

  EmployeeService(this._apiService);

  // Récupérer la liste des employés avec pagination et filtres
  Future<ApiResponse<PaginatedResponse<Employee>>> getEmployees({
    int page = 1,
    int limit = 20,
    EmployeeFilters? filters,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Ajouter les filtres
      if (filters != null) {
        queryParams.addAll(filters.toApiParams());
      }

      // Ajouter la recherche
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final ApiResponse<dynamic> response = await _apiService.get(
        AppConstants.employeesEndpoint,
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        final data = response.data;
        final employeesData = data['data'] as List<dynamic>? ?? [];
        final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};

        final employees = employeesData
            .map((json) => Employee.fromJson(json))
            .toList();

        final pagination = PaginatedResponse<Employee>(
          data: employees,
          currentPage: paginationData['current_page'] ?? 1,
          totalPages: paginationData['last_page'] ?? 1,
          totalItems: paginationData['total'] ?? employees.length,
          pageSize: paginationData['per_page'] ?? limit,
          hasNextPage: paginationData['current_page'] < paginationData['last_page'],
          hasPreviousPage: paginationData['current_page'] > 1,
        );

        return ApiResponse.success(data: pagination);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors du chargement des employés',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Récupérer un employé par son ID
  Future<ApiResponse<Employee>> getEmployeeById(String id) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('${AppConstants.employeesEndpoint}/$id');

      if (response.isSuccess) {
        final employee = Employee.fromJson(response.data['data']);
        return ApiResponse.success(data: employee);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Employé non trouvé',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Créer un nouvel employé
  Future<ApiResponse<Employee>> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post(
        AppConstants.employeesEndpoint,
        data: employeeData,
      );

      if (response.isSuccess) {
        final employee = Employee.fromJson(response.data['data']);
        return ApiResponse.success(data: employee);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de la création de l\'employé',
          statusCode: response.statusCode,
          errors: response.data['errors']?.cast<String>(),
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Mettre à jour un employé
  Future<ApiResponse<Employee>> updateEmployee(String id, Map<String, dynamic> employeeData) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.put(
        '${AppConstants.employeesEndpoint}/$id',
        data: employeeData,
      );

      if (response.isSuccess) {
        final employee = Employee.fromJson(response.data['data']);
        return ApiResponse.success(data: employee);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de la mise à jour de l\'employé',
          statusCode: response.statusCode,
          errors: response.data['errors']?.cast<String>(),
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Supprimer un employé
  Future<ApiResponse<void>> deleteEmployee(String id) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.delete('${AppConstants.employeesEndpoint}/$id');

      if (response.isSuccess) {
        return ApiResponse.success(data: null);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de la suppression de l\'employé',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Activer/Désactiver un employé
  Future<ApiResponse<Employee>> toggleEmployeeStatus(String id, bool isActive) async {
    try {
      final response = await _apiService.patch(
        '${AppConstants.employeesEndpoint}/$id/status',
        data: {'is_active': isActive},
      );

      if (response.isSuccess) {
        final employee = Employee.fromJson(response.data['data']);
        return ApiResponse.success(data: employee);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de la mise à jour du statut',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Exporter les employés
  Future<ApiResponse<String>> exportEmployees({
    String format = 'excel',
    EmployeeFilters? filters,
  }) async {
    try {
      final data = <String, dynamic>{
        'format': format,
      };

      if (filters != null) {
        data['filters'] = filters.toApiParams();
      }

      final ApiResponse<dynamic> response = await _apiService.post(
        '${AppConstants.employeesEndpoint}/export',
        data: data,
      );

      if (response.isSuccess) {
        final downloadUrl = response.data['download_url'] as String;
        return ApiResponse.success(data: downloadUrl);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de l\'export',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Importer des employés depuis un fichier
  Future<ApiResponse<List<Employee>>> importEmployees(String filePath) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post(
        '${AppConstants.employeesEndpoint}/import',
        data: {'file_path': filePath},
      );

      if (response.isSuccess) {
        final employeesData = response.data['data'] as List<dynamic>? ?? [];
        final employees = employeesData
            .map((json) => Employee.fromJson(json))
            .toList();
        return ApiResponse.success(data: employees);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de l\'import',
          statusCode: response.statusCode,
          errors: response.data['errors']?.cast<String>(),
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Récupérer les statistiques des employés
  Future<ApiResponse<Map<String, dynamic>>> getEmployeeStats() async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('${AppConstants.employeesEndpoint}/stats');

      if (response.isSuccess) {
        return ApiResponse.success(data: response.data['data']);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors du chargement des statistiques',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Récupérer les managers disponibles
  Future<ApiResponse<List<Employee>>> getAvailableManagers() async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('${AppConstants.employeesEndpoint}/managers');

      if (response.isSuccess) {
        final managersData = response.data['data'] as List<dynamic>? ?? [];
        final managers = managersData
            .map((json) => Employee.fromJson(json))
            .toList();
        return ApiResponse.success(data: managers);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors du chargement des managers',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Récupérer les employés par département
  Future<ApiResponse<Map<String, List<Employee>>>> getEmployeesByDepartment() async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('${AppConstants.employeesEndpoint}/by-department');

      if (response.isSuccess) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final employeesByDept = <String, List<Employee>>{};
        
        data.forEach((dept, employeesData) {
          final employees = (employeesData as List<dynamic>? ?? [])
              .map((json) => Employee.fromJson(json))
              .toList();
          employeesByDept[dept] = employees;
        });
        
        return ApiResponse.success(data: employeesByDept);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors du chargement par département',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Valider les données d'un employé avant création/mise à jour
  Future<ApiResponse<Map<String, List<String>>>> validateEmployeeData(Map<String, dynamic> employeeData) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post(
        '${AppConstants.employeesEndpoint}/validate',
        data: employeeData,
      );

      if (response.isSuccess) {
        final validationData = response.data['data'] as Map<String, dynamic>? ?? {};
        final errors = <String, List<String>>{};
        
        validationData.forEach((field, errorList) {
          errors[field] = (errorList as List<dynamic>).cast<String>();
        });
        
        return ApiResponse.success(data: errors);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors de la validation',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Récupérer l'historique des modifications d'un employé
  Future<ApiResponse<List<Map<String, dynamic>>>> getEmployeeHistory(String id) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get('${AppConstants.employeesEndpoint}/$id/history');

      if (response.isSuccess) {
        final historyData = response.data['data'] as List<dynamic>? ?? [];
        final history = historyData.cast<Map<String, dynamic>>();
        return ApiResponse.success(data: history);
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Erreur lors du chargement de l\'historique',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur réseau: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
