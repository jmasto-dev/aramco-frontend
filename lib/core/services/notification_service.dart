import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/notification.dart';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import 'api_service.dart';
import 'storage_service.dart';

class NotificationService {
 final ApiService _apiService;
 final StorageService _storageService;

 NotificationService(this._apiService, this._storageService);

 // Récupérer toutes les notifications de l'utilisateur
 Future<ApiResponse<List<Notification>>> getUserNotifications({
 int? page = 1,
 int? limit = 20,
 bool? unreadOnly = false,
 String? type,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 };

 if (unreadOnly != null) {
 queryParams['unread_only'] = unreadOnly;
 }

 if (type != null) {
 queryParams['type'] = type;
 }

 final ApiResponse<dynamic> response = await _apiService.get(
 '/notifications',
 queryParameters: queryParams,
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final notifications = (data['data'] as List)
 .map((json) => Notification.fromJson(json))
 .toList();

 return ApiResponse<List<Notification>>.success(
 data: notifications,
 message: data['message'] ?? 'Notifications récupérées avec succès',
 pagination: data['pagination'],
 );
 } else {
 return ApiResponse<List<Notification>>.error(
 'Erreur lors de la récupération des notifications',
 );
 }
} catch (e) {
 return ApiResponse<List<Notification>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Marquer une notification comme lue
 Future<ApiResponse<bool>> markAsRead(int notificationId) async {
 try {
 final response = await _apiService.patch(
 '/notifications/$notificationId/read',
 );

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Notification marquée comme lue',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors du marquage de la notification comme lue',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Marquer toutes les notifications comme lues
 Future<ApiResponse<bool>> markAllAsRead() async {
 try {
 final response = await _apiService.patch(
 '/notifications/read-all',
 );

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Toutes les notifications marquées comme lues',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors du marquage des notifications comme lues',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Supprimer une notification
 Future<ApiResponse<bool>> deleteNotification(int notificationId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete(
 '/notifications/$notificationId',
 );

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Notification supprimée avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors de la suppression de la notification',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Supprimer toutes les notifications
 Future<ApiResponse<bool>> deleteAllNotifications() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete(
 '/notifications',
 );

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Toutes les notifications supprimées avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors de la suppression des notifications',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Envoyer une notification (pour les admins)
 Future<ApiResponse<Notification>> sendNotification({
 required List<int> userIds,
 required String title,
 required String message,
 required String type,
 String? actionUrl,
 Map<String, dynamic>? metadata,
 }) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/notifications',
 data: {
 'user_ids': userIds,
 'title': title,
 'message': message,
 'type': type,
 'action_url': actionUrl,
 'metadata': metadata,
 },
 );

 if (response.statusCode == 201) {
 final data = response.data;
 final notification = Notification.fromJson(data['data']);

 return ApiResponse<Notification>.success(
 data: notification,
 message: data['message'] ?? 'Notification envoyée avec succès',
 );
 } else {
 return ApiResponse<Notification>.error(
 'Erreur lors de l\'envoi de la notification',
 );
 }
} catch (e) {
 return ApiResponse<Notification>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Récupérer les préférences de notification
 Future<ApiResponse<NotificationPreferences>> getNotificationPreferences() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get(
 '/notifications/preferences',
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final preferences = NotificationPreferences.fromJson(data['data']);

 return ApiResponse<NotificationPreferences>.success(
 data: preferences,
 message: 'Préférences récupérées avec succès',
 );
 } else {
 return ApiResponse<NotificationPreferences>.error(
 'Erreur lors de la récupération des préférences',
 );
 }
} catch (e) {
 return ApiResponse<NotificationPreferences>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Mettre à jour les préférences de notification
 Future<ApiResponse<NotificationPreferences>> updateNotificationPreferences({
 bool? emailNotifications,
 bool? pushNotifications,
 bool? smsNotifications,
 List<String>? enabledTypes,
 Map<String, bool>? moduleNotifications,
 }) async {
 try {
 final data = <String, dynamic>{};

 if (emailNotifications != null) {
 data['email_notifications'] = emailNotifications;
 }
 if (pushNotifications != null) {
 data['push_notifications'] = pushNotifications;
 }
 if (smsNotifications != null) {
 data['sms_notifications'] = smsNotifications;
 }
 if (enabledTypes != null) {
 data['enabled_types'] = enabledTypes;
 }
 if (moduleNotifications != null) {
 data['module_notifications'] = moduleNotifications;
 }

 final ApiResponse<dynamic> response = await _apiService.put(
 '/notifications/preferences',
 data: data,
 );

 if (response.statusCode == 200) {
 final responseData = response.data;
 final preferences = NotificationPreferences.fromJson(responseData['data']);

 return ApiResponse<NotificationPreferences>.success(
 data: preferences,
 message: responseData['message'] ?? 'Préférences mises à jour avec succès',
 );
 } else {
 return ApiResponse<NotificationPreferences>.error(
 'Erreur lors de la mise à jour des préférences',
 );
 }
} catch (e) {
 return ApiResponse<NotificationPreferences>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Compter les notifications non lues
 Future<ApiResponse<int>> getUnreadCount() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get(
 '/notifications/unread-count',
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final count = data['data']['count'] as int;

 return ApiResponse<int>.success(
 data: count,
 message: 'Compte récupéré avec succès',
 );
 } else {
 return ApiResponse<int>.error(
 'Erreur lors de la récupération du compte',
 );
 }
} catch (e) {
 return ApiResponse<int>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // S'abonner aux notifications push (WebSocket/FCM)
 Future<ApiResponse<bool>> subscribeToPushNotifications(String token) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/notifications/subscribe',
 data: {
 'token': token,
 'platform': 'flutter', // ou 'ios', 'android'
 },
 );

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Abonnement aux notifications push réussi',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors de l\'abonnement aux notifications push',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Se désabonner des notifications push
 Future<ApiResponse<bool>> unsubscribeFromPushNotifications(String token) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/notifications/unsubscribe',
 data: {
 'token': token,
 },
 );

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Désabonnement des notifications push réussi',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors du désabonnement des notifications push',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }
}
