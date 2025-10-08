import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/leave_request.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'dart:io';

class LeaveRequestService {
  static const String _baseUrl = '/leave-requests';
  
  final ApiService _apiService;

  LeaveRequestService(this._apiService);

  // Récupérer toutes les demandes de congé
  Future<ApiResponse<List<LeaveRequest>>> getLeaveRequests({
    LeaveRequestFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Ajouter les filtres
      if (filters != null && filters.hasFilters) {
        queryParams.addAll(filters.toApiParams());
      }

      final ApiResponse<dynamic> response = await _apiService.get<List<LeaveRequest>>(
        _baseUrl,
        queryParameters: queryParams,
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => LeaveRequest.fromJson(item)).toList();
          }
          return <LeaveRequest>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<LeaveRequest>>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Récupérer une demande de congé par ID
  Future<ApiResponse<LeaveRequest>> getLeaveRequestById(String id) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.get<LeaveRequest>(
        '$_baseUrl/$id',
        fromJson: (json) => LeaveRequest.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<LeaveRequest>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Créer une nouvelle demande de congé
  Future<ApiResponse<LeaveRequest>> createLeaveRequest(
    LeaveRequest leaveRequest,
  ) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post<LeaveRequest>(
        _baseUrl,
        data: leaveRequest.toJson(),
        fromJson: (json) => LeaveRequest.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<LeaveRequest>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Mettre à jour une demande de congé
  Future<ApiResponse<LeaveRequest>> updateLeaveRequest(
    String id,
    LeaveRequest leaveRequest,
  ) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.put<LeaveRequest>(
        '$_baseUrl/$id',
        data: leaveRequest.toJson(),
        fromJson: (json) => LeaveRequest.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<LeaveRequest>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Supprimer une demande de congé
  Future<ApiResponse<void>> deleteLeaveRequest(String id) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.delete<void>(
        '$_baseUrl/$id',
      );

      return response;
    } catch (e) {
      return ApiResponse<void>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Approuver une demande de congé
  Future<ApiResponse<LeaveRequest>> approveLeaveRequest(
    String id, {
    String? approverComments,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': 'approved',
      };
      
      if (approverComments != null) {
        body['approver_comments'] = approverComments;
      }

      final response = await _apiService.patch<LeaveRequest>(
        '$_baseUrl/$id/approve',
        data: body,
        fromJson: (json) => LeaveRequest.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<LeaveRequest>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Rejeter une demande de congé
  Future<ApiResponse<LeaveRequest>> rejectLeaveRequest(
    String id, {
    required String rejectionReason,
  }) async {
    try {
      final response = await _apiService.patch<LeaveRequest>(
        '$_baseUrl/$id/reject',
        data: {
          'status': 'rejected',
          'rejection_reason': rejectionReason,
        },
        fromJson: (json) => LeaveRequest.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<LeaveRequest>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Annuler une demande de congé
  Future<ApiResponse<LeaveRequest>> cancelLeaveRequest(String id) async {
    try {
      final response = await _apiService.patch<LeaveRequest>(
        '$_baseUrl/$id/cancel',
        data: {
          'status': 'cancelled',
        },
        fromJson: (json) => LeaveRequest.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<LeaveRequest>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Récupérer les demandes de congé d'un employé
  Future<ApiResponse<List<LeaveRequest>>> getEmployeeLeaveRequests(
    String employeeId, {
    LeaveRequestFilters? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'employee_id': employeeId,
      };

      // Ajouter les filtres
      if (filters != null && filters.hasFilters) {
        queryParams.addAll(filters.toApiParams());
      }

      final ApiResponse<dynamic> response = await _apiService.get<List<LeaveRequest>>(
        '$_baseUrl/employee/$employeeId',
        queryParameters: queryParams,
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => LeaveRequest.fromJson(item)).toList();
          }
          return <LeaveRequest>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<LeaveRequest>>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Vérifier les disponibilités de congé
  Future<ApiResponse<Map<String, dynamic>>> checkLeaveAvailability({
    required String employeeId,
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
        '$_baseUrl/check-availability',
        data: {
          'employee_id': employeeId,
          'leave_type': leaveType.name,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Télécharger un document pour une demande de congé
  Future<ApiResponse<String>> uploadAttachment(
    String leaveRequestId,
    File file,
  ) async {
    try {
      final response = await _apiService.uploadFile<String>(
        '$_baseUrl/$leaveRequestId/attachments',
        file,
        fromJson: (json) {
          if (json is Map<String, dynamic> && json.containsKey('file_url')) {
            return json['file_url'] as String;
          }
          return '';
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<String>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

  // Récupérer les statistiques des demandes de congé
  Future<ApiResponse<Map<String, dynamic>>> getLeaveStatistics({
    String? employeeId,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (employeeId != null) {
        queryParams['employee_id'] = employeeId;
      }
      if (year != null) {
        queryParams['year'] = year;
      }

      final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
        '$_baseUrl/statistics',
        queryParameters: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }
}
