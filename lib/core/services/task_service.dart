import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/task.dart';
import 'api_service.dart';
import 'storage_service.dart';

class TaskService {
 final ApiService _apiService;
 final StorageService _storageService;
 final Dio _dio;

 TaskService(this._apiService, this._storageService) : _dio = Dio();

 // Tâches
 Future<ApiResponse<List<Task>>> getTasks({
 int page = 1,
 int limit = 20,
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? projectId,
 String? reporterId,
 String? searchQuery,
 DateTime? startDate,
 DateTime? endDate,
 List<String>? tagIds,
 bool? isOverdue,
 bool? hasAttachments,
 String? sortBy,
 String? sortOrder,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (status != null) q{ueryParams['status'] = status.name;
 if (priority != null) q{ueryParams['priority'] = priority.name;
 if (type != null) q{ueryParams['type'] = type.name;
 if (assigneeId != null) q{ueryParams['assignee_id'] = assigneeId;
 if (projectId != null) q{ueryParams['project_id'] = projectId;
 if (reporterId != null) q{ueryParams['reporter_id'] = reporterId;
 if (searchQuery != null && searchQuery.isNotEmpty) q{ueryParams['search'] = searchQuery;
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();
 if (tagIds != null && tagIds.isNotEmpty) q{ueryParams['tag_ids'] = tagIds.join(',');
 if (isOverdue != null) q{ueryParams['is_overdue'] = isOverdue;
 if (hasAttachments != null) q{ueryParams['has_attachments'] = hasAttachments;
 if (sortBy != null) q{ueryParams['sort_by'] = sortBy;
 if (sortOrder != null) q{ueryParams['sort_order'] = sortOrder;

 final response = await _dio.get('/tasks', queryParameters: queryParams);
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final tasks = data.map((json) => Task.fromJson(json)).toList();
 
 return ApiResponse<List<Task>>.success(
 data: tasks,
 message: response.data['message'] ?? 'Tâches récupérées avec succès',
 );
 } else {
 return ApiResponse<List<Task>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des tâches',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<Task>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<Task>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<Task>> getTaskById(String taskId) async {
 try {
 final response = await _dio.get('/tasks/$taskId');
 
 if (response.statusCode == 200) {
 final task = Task.fromJson(response.data['data']);
 
 return ApiResponse<Task>.success(
 data: task,
 message: response.data['message'] ?? 'Tâche récupérée avec succès',
 );
 } else {
 return ApiResponse<Task>.error(
 message: response.data['message'] ?? 'Tâche non trouvée',
 );
 }
} on DioException catch (e) {
 return ApiResponse<Task>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Task>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<Task>> createTask({
 required String title,
 required String description,
 required TaskType type,
 required String assigneeId,
 TaskPriority priority = TaskPriority.normal,
 String? projectId,
 String? parentTaskId,
 DateTime? dueDate,
 DateTime? startDate,
 int estimatedHours = 0,
 List<String>? tagIds,
 List<File>? attachments,
 Map<String, dynamic>? customFields,
 TaskDependencies? dependencies,
 }) async {
 try {
 final data = {
 'title': title,
 'description': description,
 'type': type.name,
 'assignee_id': assigneeId,
 'priority': priority.name,
 'estimated_hours': estimatedHours,
 if (projectId != null) '{project_id': projectId,
 if (parentTaskId != null) '{parent_task_id': parentTaskId,
 if (dueDate != null) '{due_date': dueDate.toIso8601String(),
 if (startDate != null) '{start_date': startDate.toIso8601String(),
 if (tagIds != null && tagIds.isNotEmpty) '{tag_ids': tagIds,
 if (customFields != null) '{custom_fields': customFields,
 if (dependencies != null) '{dependencies': dependencies.toJson(),
 };

 // Gérer les pièces jointes
 if (attachments != null && attachments.isNotEmpty) {
 final formData = FormData.fromMap({
 ...data,
 'attachments': attachments.map((file) => MultipartFile.fromFileSync(
 file.path,
 filename: file.path.split('/').last,
 )).toList(),
 });
 
 final response = await _dio.post('/tasks', data: formData);
 
 if (response.statusCode == 201) {
 final task = Task.fromJson(response.data['data']);
 
 return ApiResponse<Task>.success(
 data: task,
 message: response.data['message'] ?? 'Tâche créée avec succès',
 );
 } else {
 return ApiResponse<Task>.error(
 message: response.data['message'] ?? 'Erreur lors de la création de la tâche',
 );
 }
 } else {
 final response = await _dio.post('/tasks', data: data);
 
 if (response.statusCode == 201) {
 final task = Task.fromJson(response.data['data']);
 
 return ApiResponse<Task>.success(
 data: task,
 message: response.data['message'] ?? 'Tâche créée avec succès',
 );
 } else {
 return ApiResponse<Task>.error(
 message: response.data['message'] ?? 'Erreur lors de la création de la tâche',
 );
 }
 }
} on DioException catch (e) {
 return ApiResponse<Task>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Task>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<Task>> updateTask({
 required String taskId,
 String? title,
 String? description,
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? projectId,
 DateTime? dueDate,
 DateTime? startDate,
 DateTime? completedAt,
 int? estimatedHours,
 int? actualHours,
 double? progress,
 List<String>? tagIds,
 Map<String, dynamic>? customFields,
 TaskDependencies? dependencies,
 }) async {
 try {
 final data = <String, dynamic>{};
 
 if (title != null) d{ata['title'] = title;
 if (description != null) d{ata['description'] = description;
 if (status != null) d{ata['status'] = status.name;
 if (priority != null) d{ata['priority'] = priority.name;
 if (type != null) d{ata['type'] = type.name;
 if (assigneeId != null) d{ata['assignee_id'] = assigneeId;
 if (projectId != null) d{ata['project_id'] = projectId;
 if (dueDate != null) d{ata['due_date'] = dueDate.toIso8601String();
 if (startDate != null) d{ata['start_date'] = startDate.toIso8601String();
 if (completedAt != null) d{ata['completed_at'] = completedAt.toIso8601String();
 if (estimatedHours != null) d{ata['estimated_hours'] = estimatedHours;
 if (actualHours != null) d{ata['actual_hours'] = actualHours;
 if (progress != null) d{ata['progress'] = progress;
 if (tagIds != null) d{ata['tag_ids'] = tagIds;
 if (customFields != null) d{ata['custom_fields'] = customFields;
 if (dependencies != null) d{ata['dependencies'] = dependencies.toJson();

 final response = await _dio.put('/tasks/$taskId', data: data);
 
 if (response.statusCode == 200) {
 final task = Task.fromJson(response.data['data']);
 
 return ApiResponse<Task>.success(
 data: task,
 message: response.data['message'] ?? 'Tâche mise à jour avec succès',
 );
 } else {
 return ApiResponse<Task>.error(
 message: response.data['message'] ?? 'Erreur lors de la mise à jour de la tâche',
 );
 }
} on DioException catch (e) {
 return ApiResponse<Task>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Task>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<bool>> deleteTask(String taskId) async {
 try {
 final response = await _dio.delete('/tasks/$taskId');
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Tâche supprimée avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression de la tâche',
 );
 }
} on DioException catch (e) {
 return ApiResponse<bool>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<bool>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Sous-tâches
 Future<ApiResponse<List<Task>>> getSubtasks(String parentTaskId) async {
 try {
 final response = await _dio.get('/tasks/$parentTaskId/subtasks');
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final subtasks = data.map((json) => Task.fromJson(json)).toList();
 
 return ApiResponse<List<Task>>.success(
 data: subtasks,
 message: response.data['message'] ?? 'Sous-tâches récupérées avec succès',
 );
 } else {
 return ApiResponse<List<Task>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des sous-tâches',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<Task>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<Task>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Commentaires
 Future<ApiResponse<TaskComment>> addComment({
 required String taskId,
 required String content,
 String? parentId,
 List<File>? attachments,
 }) async {
 try {
 final data = {
 'content': content,
 if (parentId != null) '{parent_id': parentId,
 };

 if (attachments != null && attachments.isNotEmpty) {
 final formData = FormData.fromMap({
 ...data,
 'attachments': attachments.map((file) => MultipartFile.fromFileSync(
 file.path,
 filename: file.path.split('/').last,
 )).toList(),
 });
 
 final response = await _dio.post('/tasks/$taskId/comments', data: formData);
 
 if (response.statusCode == 201) {
 final comment = TaskComment.fromJson(response.data['data']);
 
 return ApiResponse<TaskComment>.success(
 data: comment,
 message: response.data['message'] ?? 'Commentaire ajouté avec succès',
 );
 } else {
 return ApiResponse<TaskComment>.error(
 message: response.data['message'] ?? 'Erreur lors de l\'ajout du commentaire',
 );
 }
 } else {
 final response = await _dio.post('/tasks/$taskId/comments', data: data);
 
 if (response.statusCode == 201) {
 final comment = TaskComment.fromJson(response.data['data']);
 
 return ApiResponse<TaskComment>.success(
 data: comment,
 message: response.data['message'] ?? 'Commentaire ajouté avec succès',
 );
 } else {
 return ApiResponse<TaskComment>.error(
 message: response.data['message'] ?? 'Erreur lors de l\'ajout du commentaire',
 );
 }
 }
} on DioException catch (e) {
 return ApiResponse<TaskComment>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<TaskComment>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<bool>> deleteComment(String taskId, String commentId) async {
 try {
 final response = await _dio.delete('/tasks/$taskId/comments/$commentId');
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Commentaire supprimé avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression du commentaire',
 );
 }
} on DioException catch (e) {
 return ApiResponse<bool>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<bool>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Historique
 Future<ApiResponse<List<TaskHistory>>> getTaskHistory(String taskId) async {
 try {
 final response = await _dio.get('/tasks/$taskId/history');
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final history = data.map((json) => TaskHistory.fromJson(json)).toList();
 
 return ApiResponse<List<TaskHistory>>.success(
 data: history,
 message: response.data['message'] ?? 'Historique récupéré avec succès',
 );
 } else {
 return ApiResponse<List<TaskHistory>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération de l\'historique',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<TaskHistory>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<TaskHistory>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Statistiques
 Future<ApiResponse<Map<String, dynamic>>> getTaskStatistics({
 String? projectId,
 String? assigneeId,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final queryParams = <String, dynamic>{};
 
 if (projectId != null) q{ueryParams['project_id'] = projectId;
 if (assigneeId != null) q{ueryParams['assignee_id'] = assigneeId;
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();

 final response = await _dio.get('/tasks/statistics', queryParameters: queryParams);
 
 if (response.statusCode == 200) {
 final statistics = response.data['data'] as Map<String, dynamic>;
 
 return ApiResponse<Map<String, dynamic>>.success(
 data: statistics,
 message: response.data['message'] ?? 'Statistiques récupérées avec succès',
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des statistiques',
 );
 }
} on DioException catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Recherche avancée
 Future<ApiResponse<List<Task>>> searchTasks({
 required String query,
 int page = 1,
 int limit = 20,
 List<String>? projectIds,
 List<String>? assigneeIds,
 List<TaskStatus>? statuses,
 List<TaskPriority>? priorities,
 List<TaskType>? types,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final data = {
 'query': query,
 'page': page,
 'limit': limit,
 if (projectIds != null && projectIds.isNotEmpty) '{project_ids': projectIds,
 if (assigneeIds != null && assigneeIds.isNotEmpty) '{assignee_ids': assigneeIds,
 if (statuses != null && statuses.isNotEmpty) '{statuses': statuses.map((s) => s.name).toList(),
 if (priorities != null && priorities.isNotEmpty) '{priorities': priorities.map((p) => p.name).toList(),
 if (types != null && types.isNotEmpty) '{types': types.map((t) => t.name).toList(),
 if (startDate != null) '{start_date': startDate.toIso8601String(),
 if (endDate != null) '{end_date': endDate.toIso8601String(),
 };

 final response = await _dio.post('/tasks/search', data: data);
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final tasks = data.map((json) => Task.fromJson(json)).toList();
 
 return ApiResponse<List<Task>>.success(
 data: tasks,
 message: response.data['message'] ?? 'Tâches trouvées avec succès',
 );
 } else {
 return ApiResponse<List<Task>>.error(
 message: response.data['message'] ?? 'Erreur lors de la recherche des tâches',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<Task>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<Task>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Actions en lot
 Future<ApiResponse<bool>> bulkUpdateTasks({
 required List<String> taskIds,
 TaskStatus? status,
 TaskPriority? priority,
 String? assigneeId,
 String? projectId,
 List<String>? tagIds,
 }) async {
 try {
 final data = {
 'task_ids': taskIds,
 if (status != null) '{status': status.name,
 if (priority != null) '{priority': priority.name,
 if (assigneeId != null) '{assignee_id': assigneeId,
 if (projectId != null) '{project_id': projectId,
 if (tagIds != null) '{tag_ids': tagIds,
 };

 final response = await _dio.patch('/tasks/bulk-update', data: data);
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Tâches mises à jour avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors de la mise à jour des tâches',
 );
 }
} on DioException catch (e) {
 return ApiResponse<bool>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<bool>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<bool>> bulkDeleteTasks(List<String> taskIds) async {
 try {
 final response = await _dio.delete('/tasks/bulk-delete', data: {
 'task_ids': taskIds,
 });
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Tâches supprimées avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression des tâches',
 );
 }
} on DioException catch (e) {
 return ApiResponse<bool>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<bool>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }
}
