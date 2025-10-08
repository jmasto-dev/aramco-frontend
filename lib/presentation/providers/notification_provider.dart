import 'package:flutter/foundation.dart';
import '../../core/models/notification.dart';
import '../../core/models/api_response.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';

class NotificationProvider with ChangeNotifier {
 final NotificationService _notificationService;
 final StorageService _storageService;

 NotificationProvider(this._notificationService, this._storageService);

 // État
 List<Notification> _notifications = [];
 List<Notification> _unreadNotifications = [];
 int _unreadCount = 0;
 NotificationPreferences? _preferences;
 bool _isLoading = false;
 String? _error;

 // Getters
 List<Notification> get notifications => _notifications;
 List<Notification> get unreadNotifications => _unreadNotifications;
 int get unreadCount => _unreadCount;
 NotificationPreferences? get preferences => _preferences;
 bool get isLoading => _isLoading;
 String? get error => _error;

 // Initialisation
 Future<void> initialize() {async {
 await loadNotifications();
 await loadUnreadCount();
 await loadPreferences();
 }

 // Charger toutes les notifications
 Future<void> loadNotifications({
 int page = 1,
 int limit = 20,
 bool unreadOnly = false,
 String? type,
 bool refresh = false,
 }) {async {
 if (refresh) {{
 _notifications.clear();
 notifyListeners();
}

 _setLoading(true);
 _clearError();

 try {
 final response = await _notificationService.getUserNotifications(
 page: page,
 limit: limit,
 unreadOnly: unreadOnly,
 type: type,
 );

 if (response.success && response.data != null) {{
 if (page == 1) {{
 _notifications = response.data!;
 } else {
 _notifications.addAll(response.data!);
 }

 // Mettre à jour les notifications non lues
 _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
 _unreadCount = _unreadNotifications.length;

 // Sauvegarder en cache
 await _storageService.saveNotifications(_notifications);

 notifyListeners();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des notifications');
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 
 // Charger depuis le cache en cas d'erreur
 if (refresh) {{
 await _loadNotificationsFromCache();
 }
} finally {
 _setLoading(false);
}
 }

 // Charger les notifications depuis le cache
 Future<void> _loadNotificationsFromCache() {async {
 try {
 final cachedNotifications = await _storageService.getNotifications();
 if (cachedNotifications.isNotEmpty) {{
 _notifications = cachedNotifications;
 _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
 _unreadCount = _unreadNotifications.length;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des notifications depuis le cache: $e');
}
 }

 // Charger le nombre de notifications non lues
 Future<void> loadUnreadCount() {async {
 try {
 final response = await _notificationService.getUnreadCount();
 if (response.success && response.data != null) {{
 _unreadCount = response.data!;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement du compte de notifications: $e');
}
 }

 // Charger les préférences de notification
 Future<void> loadPreferences() {async {
 try {
 final response = await _notificationService.getNotificationPreferences();
 if (response.success && response.data != null) {{
 _preferences = response.data;
 notifyListeners();
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des préférences: $e');
}
 }

 // Marquer une notification comme lue
 Future<bool> markAsRead(int notificationId) {async {
 try {
 final response = await _notificationService.markAsRead(notificationId);
 
 if (response.success) {{
 // Mettre à jour l'état local
 final index = _notifications.indexWhere((n) => n.id == notificationId);
 if (index != -1) {{
 _notifications[index] = _notifications[index].copyWith(
 isRead: true,
 readAt: DateTime.now(),
 );
 
 // Mettre à jour les notifications non lues
 _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
 _unreadCount = _unreadNotifications.length;
 
 // Sauvegarder en cache
 await _storageService.saveNotifications(_notifications);
 
 notifyListeners();
 }
 
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors du marquage comme lu');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Marquer toutes les notifications comme lues
 Future<bool> markAllAsRead() {async {
 try {
 final response = await _notificationService.markAllAsRead();
 
 if (response.success) {{
 // Mettre à jour l'état local
 _notifications = _notifications.map((n) => n.copyWith(
 isRead: true,
 readAt: DateTime.now(),
 )).toList();
 
 _unreadNotifications.clear();
 _unreadCount = 0;
 
 // Sauvegarder en cache
 await _storageService.saveNotifications(_notifications);
 
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors du marquage comme lu');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Supprimer une notification
 Future<bool> deleteNotification(int notificationId) {async {
 try {
 final response = await _notificationService.deleteNotification(notificationId);
 
 if (response.success) {{
 // Mettre à jour l'état local
 _notifications.removeWhere((n) => n.id == notificationId);
 _unreadNotifications.removeWhere((n) => n.id == notificationId);
 _unreadCount = _unreadNotifications.length;
 
 // Sauvegarder en cache
 await _storageService.saveNotifications(_notifications);
 
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Supprimer toutes les notifications
 Future<bool> deleteAllNotifications() {async {
 try {
 final response = await _notificationService.deleteAllNotifications();
 
 if (response.success) {{
 // Mettre à jour l'état local
 _notifications.clear();
 _unreadNotifications.clear();
 _unreadCount = 0;
 
 // Sauvegarder en cache
 await _storageService.saveNotifications(_notifications);
 
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Envoyer une notification (admin)
 Future<bool> sendNotification({
 required List<int> userIds,
 required String title,
 required String message,
 required String type,
 String? actionUrl,
 Map<String, dynamic>? metadata,
 }) {async {
 try {
 final response = await _notificationService.sendNotification(
 userIds: userIds,
 title: title,
 message: message,
 type: type,
 actionUrl: actionUrl,
 metadata: metadata,
 );
 
 if (response.success) {{
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'envoi de la notification');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Mettre à jour les préférences
 Future<bool> updatePreferences({
 bool? emailNotifications,
 bool? pushNotifications,
 bool? smsNotifications,
 List<String>? enabledTypes,
 Map<String, bool>? moduleNotifications,
 }) {async {
 try {
 final response = await _notificationService.updateNotificationPreferences(
 emailNotifications: emailNotifications,
 pushNotifications: pushNotifications,
 smsNotifications: smsNotifications,
 enabledTypes: enabledTypes,
 moduleNotifications: moduleNotifications,
 );
 
 if (response.success && response.data != null) {{
 _preferences = response.data;
 notifyListeners();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour des préférences');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // S'abonner aux notifications push
 Future<bool> subscribeToPushNotifications(String token) {async {
 try {
 final response = await _notificationService.subscribeToPushNotifications(token);
 
 if (response.success) {{
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'abonnement aux notifications push');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Se désabonner des notifications push
 Future<bool> unsubscribeFromPushNotifications(String token) {async {
 try {
 final response = await _notificationService.unsubscribeFromPushNotifications(token);
 
 if (response.success) {{
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors du désabonnement des notifications push');
 return false;
 }
} catch (e) {
 _setError('Erreur de connexion: ${e.toString()}');
 return false;
}
 }

 // Ajouter une nouvelle notification (pour les notifications push/real-time)
 void addNotification(Notification notification) {
 _notifications.insert(0, notification);
 
 if (!notification.isRead) {{
 _unreadNotifications.insert(0, notification);
 _unreadCount++;
}
 
 // Sauvegarder en cache
 _storageService.saveNotifications(_notifications);
 
 notifyListeners();
 }

 // Rafraîchir les notifications
 Future<void> refresh() {async {
 await loadNotifications(refresh: true);
 await loadUnreadCount();
 }

 // Vider les erreurs
 void clearError() {
 _error = null;
 notifyListeners();
 }

 // Méthodes privées
 void _setLoading(bool loading) {
 _isLoading = loading;
 notifyListeners();
 }

 void _setError(String error) {
 _error = error;
 notifyListeners();
 }

 void _clearError() {
 _error = null;
 }

 // Filtrer les notifications par type
 List<Notification> getNotificationsByType(String type) {
 return _notifications.where((n) => n.type == type).toList();
 }

 // Filtrer les notifications par date
 List<Notification> getNotificationsByDateRange(DateTime start, DateTime end) {
 return _notifications.where((n) {
 return n.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
 n.createdAt.isBefore(end.add(const Duration(days: 1)));
}).toList();
 }

 // Rechercher des notifications
 List<Notification> searchNotifications(String query) {
 if (query.isEmpty) r{eturn _notifications;
 
 final lowerQuery = query.toLowerCase();
 return _notifications.where((n) =>
 n.title.toLowerCase().contains(lowerQuery) ||
 n.message.toLowerCase().contains(lowerQuery)
 ).toList();
 }
}
