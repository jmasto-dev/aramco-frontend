import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/message.dart';
import 'api_service.dart';
import 'storage_service.dart';

class MessageService {
 final ApiService _apiService;
 final StorageService _storageService;
 final Dio _dio;

 MessageService(this._apiService, this._storageService) : _dio = Dio();

 // Messages privés
 Future<ApiResponse<List<Message>>> getMessages({
 String? userId,
 int page = 1,
 int limit = 20,
 MessageStatus? status,
 MessageType? type,
 MessagePriority? priority,
 String? search,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (userId != null) q{ueryParams['user_id'] = userId;
 if (status != null) q{ueryParams['status'] = status.name;
 if (type != null) q{ueryParams['type'] = type.name;
 if (priority != null) q{ueryParams['priority'] = priority.name;
 if (search != null && search.isNotEmpty) q{ueryParams['search'] = search;
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();

 final response = await _dio.get('/messages', queryParameters: queryParams);
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final messages = data.map((json) => Message.fromJson(json)).toList();
 
 return ApiResponse<List<Message>>.success(
 data: messages,
 message: response.data['message'] ?? 'Messages récupérés avec succès',
 pagination: response.data['pagination'],
 );
 } else {
 return ApiResponse<List<Message>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des messages',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<Message>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<Message>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<Message>> getMessageById(String messageId) async {
 try {
 final response = await _dio.get('/messages/$messageId');
 
 if (response.statusCode == 200) {
 final message = Message.fromJson(response.data['data']);
 
 return ApiResponse<Message>.success(
 data: message,
 message: response.data['message'] ?? 'Message récupéré avec succès',
 );
 } else {
 return ApiResponse<Message>.error(
 message: response.data['message'] ?? 'Message non trouvé',
 );
 }
} on DioException catch (e) {
 return ApiResponse<Message>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Message>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<Message>> sendMessage({
 required String receiverId,
 required String subject,
 required String content,
 MessageType type = MessageType.text,
 MessagePriority priority = MessagePriority.normal,
 String? groupId,
 List<File>? attachments,
 String? replyToId,
 Map<String, dynamic>? metadata,
 }) async {
 try {
 final data = {
 'receiver_id': receiverId,
 'subject': subject,
 'content': content,
 'type': type.name,
 'priority': priority.name,
 if (groupId != null) '{group_id': groupId,
 if (replyToId != null) '{reply_to_id': replyToId,
 if (metadata != null) '{metadata': metadata,
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
 
 final response = await _dio.post('/messages', data: formData);
 
 if (response.statusCode == 201) {
 final message = Message.fromJson(response.data['data']);
 
 return ApiResponse<Message>.success(
 data: message,
 message: response.data['message'] ?? 'Message envoyé avec succès',
 );
 } else {
 return ApiResponse<Message>.error(
 message: response.data['message'] ?? 'Erreur lors de l\'envoi du message',
 );
 }
 } else {
 final response = await _dio.post('/messages', data: data);
 
 if (response.statusCode == 201) {
 final message = Message.fromJson(response.data['data']);
 
 return ApiResponse<Message>.success(
 data: message,
 message: response.data['message'] ?? 'Message envoyé avec succès',
 );
 } else {
 return ApiResponse<Message>.error(
 message: response.data['message'] ?? 'Erreur lors de l\'envoi du message',
 );
 }
 }
} on DioException catch (e) {
 return ApiResponse<Message>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Message>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<bool>> markMessageAsRead(String messageId) async {
 try {
 final response = await _dio.patch('/messages/$messageId/read');
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Message marqué comme lu',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors du marquage du message',
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

 Future<ApiResponse<bool>> markMultipleMessagesAsRead(List<String> messageIds) async {
 try {
 final response = await _dio.patch('/messages/mark-read', data: {
 'message_ids': messageIds,
 });
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Messages marqués comme lus',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors du marquage des messages',
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

 Future<ApiResponse<bool>> deleteMessage(String messageId) async {
 try {
 final response = await _dio.delete('/messages/$messageId');
 
 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: response.data['message'] ?? 'Message supprimé avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 message: response.data['message'] ?? 'Erreur lors de la suppression du message',
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

 Future<ApiResponse<int>> getUnreadMessagesCount() async {
 try {
 final response = await _dio.get('/messages/unread-count');
 
 if (response.statusCode == 200) {
 final count = response.data['data'] as int;
 
 return ApiResponse<int>.success(
 data: count,
 message: response.data['message'] ?? 'Compte récupéré avec succès',
 );
 } else {
 return ApiResponse<int>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération du compte',
 );
 }
} on DioException catch (e) {
 return ApiResponse<int>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<int>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Groupes de messages
 Future<ApiResponse<List<MessageGroup>>> getMessageGroups({
 int page = 1,
 int limit = 20,
 MessageGroupType? type,
 String? search,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (type != null) q{ueryParams['type'] = type.name;
 if (search != null && search.isNotEmpty) q{ueryParams['search'] = search;

 final response = await _dio.get('/message-groups', queryParameters: queryParams);
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final groups = data.map((json) => MessageGroup.fromJson(json)).toList();
 
 return ApiResponse<List<MessageGroup>>.success(
 data: groups,
 message: response.data['message'] ?? 'Groupes récupérés avec succès',
 pagination: response.data['pagination'],
 );
 } else {
 return ApiResponse<List<MessageGroup>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des groupes',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<MessageGroup>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<MessageGroup>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<MessageGroup>> createMessageGroup({
 required String name,
 String? description,
 required List<String> memberIds,
 MessageGroupType type = MessageGroupType.private,
 File? avatar,
 Map<String, dynamic>? settings,
 }) async {
 try {
 final data = {
 'name': name,
 'member_ids': memberIds,
 'type': type.name,
 if (description != null) '{description': description,
 if (settings != null) '{settings': settings,
 };

 if (avatar != null) {
 final formData = FormData.fromMap({
 ...data,
 'avatar': await MultipartFile.fromFileSync(
 avatar.path,
 filename: avatar.path.split('/').last,
 ),
 });
 
 final response = await _dio.post('/message-groups', data: formData);
 
 if (response.statusCode == 201) {
 final group = MessageGroup.fromJson(response.data['data']);
 
 return ApiResponse<MessageGroup>.success(
 data: group,
 message: response.data['message'] ?? 'Groupe créé avec succès',
 );
 } else {
 return ApiResponse<MessageGroup>.error(
 message: response.data['message'] ?? 'Erreur lors de la création du groupe',
 );
 }
 } else {
 final response = await _dio.post('/message-groups', data: data);
 
 if (response.statusCode == 201) {
 final group = MessageGroup.fromJson(response.data['data']);
 
 return ApiResponse<MessageGroup>.success(
 data: group,
 message: response.data['message'] ?? 'Groupe créé avec succès',
 );
 } else {
 return ApiResponse<MessageGroup>.error(
 message: response.data['message'] ?? 'Erreur lors de la création du groupe',
 );
 }
 }
} on DioException catch (e) {
 return ApiResponse<MessageGroup>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<MessageGroup>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<List<Message>>> getGroupMessages({
 required String groupId,
 int page = 1,
 int limit = 20,
 String? search,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (search != null && search.isNotEmpty) q{ueryParams['search'] = search;

 final response = await _dio.get('/message-groups/$groupId/messages', queryParameters: queryParams);
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final messages = data.map((json) => Message.fromJson(json)).toList();
 
 return ApiResponse<List<Message>>.success(
 data: messages,
 message: response.data['message'] ?? 'Messages du groupe récupérés avec succès',
 pagination: response.data['pagination'],
 );
 } else {
 return ApiResponse<List<Message>>.error(
 message: response.data['message'] ?? 'Erreur lors de la récupération des messages du groupe',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<Message>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<Message>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 Future<ApiResponse<Message>> sendGroupMessage({
 required String groupId,
 required String content,
 MessageType type = MessageType.text,
 MessagePriority priority = MessagePriority.normal,
 List<File>? attachments,
 String? replyToId,
 Map<String, dynamic>? metadata,
 }) async {
 try {
 final data = {
 'content': content,
 'type': type.name,
 'priority': priority.name,
 if (replyToId != null) '{reply_to_id': replyToId,
 if (metadata != null) '{metadata': metadata,
 };

 if (attachments != null && attachments.isNotEmpty) {
 final formData = FormData.fromMap({
 ...data,
 'attachments': attachments.map((file) => MultipartFile.fromFileSync(
 file.path,
 filename: file.path.split('/').last,
 )).toList(),
 });
 
 final response = await _dio.post('/message-groups/$groupId/messages', data: formData);
 
 if (response.statusCode == 201) {
 final message = Message.fromJson(response.data['data']);
 
 return ApiResponse<Message>.success(
 data: message,
 message: response.data['message'] ?? 'Message envoyé avec succès',
 );
 } else {
 return ApiResponse<Message>.error(
 message: response.data['message'] ?? 'Erreur lors de l\'envoi du message',
 );
 }
 } else {
 final response = await _dio.post('/message-groups/$groupId/messages', data: data);
 
 if (response.statusCode == 201) {
 final message = Message.fromJson(response.data['data']);
 
 return ApiResponse<Message>.success(
 data: message,
 message: response.data['message'] ?? 'Message envoyé avec succès',
 );
 } else {
 return ApiResponse<Message>.error(
 message: response.data['message'] ?? 'Erreur lors de l\'envoi du message',
 );
 }
 }
} on DioException catch (e) {
 return ApiResponse<Message>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<Message>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }

 // Statistiques et rapports
 Future<ApiResponse<Map<String, dynamic>>> getMessageStatistics({
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final queryParams = <String, dynamic>{};
 
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();

 final response = await _dio.get('/messages/statistics', queryParameters: queryParams);
 
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
 Future<ApiResponse<List<Message>>> searchMessages({
 required String query,
 int page = 1,
 int limit = 20,
 List<String>? userIds,
 List<MessageType>? types,
 List<MessagePriority>? priorities,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final data = {
 'query': query,
 'page': page,
 'limit': limit,
 if (userIds != null && userIds.isNotEmpty) '{user_ids': userIds,
 if (types != null && types.isNotEmpty) '{types': types.map((t) => t.name).toList(),
 if (priorities != null && priorities.isNotEmpty) '{priorities': priorities.map((p) => p.name).toList(),
 if (startDate != null) '{start_date': startDate.toIso8601String(),
 if (endDate != null) '{end_date': endDate.toIso8601String(),
 };

 final response = await _dio.post('/messages/search', data: data);
 
 if (response.statusCode == 200) {
 final List<String> data = response.data['data'];
 final messages = data.map((json) => Message.fromJson(json)).toList();
 
 return ApiResponse<List<Message>>.success(
 data: messages,
 message: response.data['message'] ?? 'Messages trouvés avec succès',
 pagination: response.data['pagination'],
 );
 } else {
 return ApiResponse<List<Message>>.error(
 message: response.data['message'] ?? 'Erreur lors de la recherche des messages',
 );
 }
} on DioException catch (e) {
 return ApiResponse<List<Message>>.error(
 message: e.response?.data['message'] ?? 'Erreur réseau: ${e.message}',
 );
} catch (e) {
 return ApiResponse<List<Message>>.error(
 message: 'Erreur inattendue: $e',
 );
}
 }
}
