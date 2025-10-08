import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/models/message.dart';
import '../../core/models/api_response.dart';
import '../../core/services/message_service.dart';

class MessageProvider with ChangeNotifier {
 final MessageService _messageService;

 MessageProvider(this._messageService);

 // État des messages
 List<Message> _messages = [];
 List<Message> _sentMessages = [];
 List<Message> _receivedMessages = [];
 List<Message> _unreadMessages = [];
 List<MessageGroup> _messageGroups = [];
 Map<String, List<Message>> _groupMessages = {};
 Map<String, dynamic> _statistics = {};
 
 // État de chargement
 bool _isLoading = false;
 bool _isLoadingGroups = false;
 bool _isLoadingStatistics = false;
 bool _isSending = false;
 
 // État des filtres
 String _searchQuery = '';
 MessageStatus? _statusFilter;
 MessageType? _typeFilter;
 MessagePriority? _priorityFilter;
 DateTime? _startDate;
 DateTime? _endDate;
 
 // État de pagination
 int _currentPage = 1;
 int _totalPages = 1;
 int _totalItems = 0;
 bool _hasMore = true;
 
 // État des erreurs
 String? _error;
 String? _groupsError;
 String? _statisticsError;
 
 // Compteurs
 int _unreadCount = 0;

 // Getters
 List<Message> get messages => _messages;
 List<Message> get sentMessages => _sentMessages;
 List<Message> get receivedMessages => _receivedMessages;
 List<Message> get unreadMessages => _unreadMessages;
 List<MessageGroup> get messageGroups => _messageGroups;
 Map<String, dynamic> get statistics => _statistics;
 
 bool get isLoading => _isLoading;
 bool get isLoadingGroups => _isLoadingGroups;
 bool get isLoadingStatistics => _isLoadingStatistics;
 bool get isSending => _isSending;
 
 String get searchQuery => _searchQuery;
 MessageStatus? get statusFilter => _statusFilter;
 MessageType? get typeFilter => _typeFilter;
 MessagePriority? get priorityFilter => _priorityFilter;
 DateTime? get startDate => _startDate;
 DateTime? get endDate => _endDate;
 
 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 int get totalItems => _totalItems;
 bool get hasMore => _hasMore;
 
 String? get error => _error;
 String? get groupsError => _groupsError;
 String? get statisticsError => _statisticsError;
 
 int get unreadCount => _unreadCount;
 
 bool get hasError => _error != null;
 bool get hasGroupsError => _groupsError != null;
 bool get hasStatisticsError => _statisticsError != null;

 // Charger les messages
 Future<void> loadMessages({
 bool refresh = false,
 String? userId,
 MessageStatus? status,
 MessageType? type,
 MessagePriority? priority,
 String? search,
 DateTime? startDate,
 DateTime? endDate,
 }) {async {
 if (refresh) {{
 _currentPage = 1;
 _hasMore = true;
 _messages.clear();
}

 if (!_hasMore || _isLoading) r{eturn;

 _isLoading = true;
 _error = null;
 notifyListeners();

 try {
 final response = await _messageService.getMessages(
 userId: userId,
 page: _currentPage,
 status: status ?? _statusFilter,
 type: type ?? _typeFilter,
 priority: priority ?? _priorityFilter,
 search: search ?? _searchQuery,
 startDate: startDate ?? _startDate,
 endDate: endDate ?? _endDate,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _messages = response.data!;
 } else {
 _messages.addAll(response.data!);
 }

 // Mettre à jour la pagination
 if (response.pagination != null) {{
 _currentPage = response.pagination!['current_page'] ?? _currentPage;
 _totalPages = response.pagination!['total_pages'] ?? 1;
 _totalItems = response.pagination!['total_items'] ?? 0;
 _hasMore = _currentPage < _totalPages;
 }

 // Séparer les messages
 _sentMessages = _messages.where((m) => m.senderId == userId).toList();
 _receivedMessages = _messages.where((m) => m.receiverId == userId).toList();
 _unreadMessages = _receivedMessages.where((m) => !m.isRead).toList();
 _unreadCount = _unreadMessages.length;
 } else {
 _error = response.message;
 }
} catch (e) {
 _error = 'Erreur lors du chargement des messages: $e';
} finally {
 _isLoading = false;
 notifyListeners();
}
 }

 // Charger plus de messages
 Future<void> loadMoreMessages() {async {
 if (_hasMore && !_isLoading) {{
 _currentPage++;
 await loadMessages();
}
 }

 // Rafraîchir les messages
 Future<void> refreshMessages() {async {
 await loadMessages(refresh: true);
 }

 // Envoyer un message
 Future<bool> sendMessage({
 required String receiverId,
 required String subject,
 required String content,
 MessageType type = MessageType.text,
 MessagePriority priority = MessagePriority.normal,
 String? groupId,
 List<String>? attachments,
 String? replyToId,
 Map<String, dynamic>? metadata,
 }) {async {
 _isSending = true;
 notifyListeners();

 try {
 final response = await _messageService.sendMessage(
 receiverId: receiverId,
 subject: subject,
 content: content,
 type: type,
 priority: priority,
 groupId: groupId,
 attachments: attachments != null ? [] : null, // TODO: Convertir les fichiers
 replyToId: replyToId,
 metadata: metadata,
 );

 if (response.success && response.data != null) {{
 // Ajouter le message à la liste
 _messages.insert(0, response.data!);
 
 // Mettre à jour les listes
 _sentMessages.insert(0, response.data!);
 _totalItems++;
 
 _isSending = false;
 notifyListeners();
 return true;
 } else {
 _error = response.message;
 _isSending = false;
 notifyListeners();
 return false;
 }
} catch (e) {
 _error = 'Erreur lors de l\'envoi du message: $e';
 _isSending = false;
 notifyListeners();
 return false;
}
 }

 // Marquer un message comme lu
 Future<bool> markAsRead(String messageId) {async {
 try {
 final response = await _messageService.markMessageAsRead(messageId);
 
 if (response.success) {{
 // Mettre à jour le message dans la liste
 final messageIndex = _messages.indexWhere((m) => m.id == messageId);
 if (messageIndex != -1) {{
 final updatedMessage = _messages[messageIndex].copyWith(
 readAt: DateTime.now(),
 status: MessageStatus.read,
 );
 _messages[messageIndex] = updatedMessage;
 
 // Mettre à jour les listes
 _unreadMessages.removeWhere((m) => m.id == messageId);
 _unreadCount = _unreadMessages.length;
 
 notifyListeners();
 }
 return true;
 } else {
 _error = response.message;
 notifyListeners();
 return false;
 }
} catch (e) {
 _error = 'Erreur lors du marquage du message: $e';
 notifyListeners();
 return false;
}
 }

 // Marquer plusieurs messages comme lus
 Future<bool> markMultipleAsRead(List<String> messageIds) {async {
 try {
 final response = await _messageService.markMultipleMessagesAsRead(messageIds);
 
 if (response.success) {{
 // Mettre à jour les messages dans la liste
 for (final messageId in messageIds) {
 final messageIndex = _messages.indexWhere((m) => m.id == messageId);
 if (messageIndex != -1 && !_messages[messageIndex].isRead) {{
 final updatedMessage = _messages[messageIndex].copyWith(
 readAt: DateTime.now(),
 status: MessageStatus.read,
 );
 _messages[messageIndex] = updatedMessage;
}
 }
 
 // Mettre à jour les listes
 _unreadMessages.removeWhere((m) => messageIds.contains(m.id));
 _unreadCount = _unreadMessages.length;
 
 notifyListeners();
 return true;
 } else {
 _error = response.message;
 notifyListeners();
 return false;
 }
} catch (e) {
 _error = 'Erreur lors du marquage des messages: $e';
 notifyListeners();
 return false;
}
 }

 // Supprimer un message
 Future<bool> deleteMessage(String messageId) {async {
 try {
 final response = await _messageService.deleteMessage(messageId);
 
 if (response.success) {{
 // Supprimer le message de la liste
 _messages.removeWhere((m) => m.id == messageId);
 _sentMessages.removeWhere((m) => m.id == messageId);
 _receivedMessages.removeWhere((m) => m.id == messageId);
 _unreadMessages.removeWhere((m) => m.id == messageId);
 
 _totalItems--;
 _unreadCount = _unreadMessages.length;
 
 notifyListeners();
 return true;
 } else {
 _error = response.message;
 notifyListeners();
 return false;
 }
} catch (e) {
 _error = 'Erreur lors de la suppression du message: $e';
 notifyListeners();
 return false;
}
 }

 // Charger les groupes de messages
 Future<void> loadMessageGroups({
 MessageGroupType? type,
 String? search,
 }) {async {
 _isLoadingGroups = true;
 _groupsError = null;
 notifyListeners();

 try {
 final response = await _messageService.getMessageGroups(
 type: type,
 search: search,
 );

 if (response.success && response.data != null) {{
 _messageGroups = response.data!;
 } else {
 _groupsError = response.message;
 }
} catch (e) {
 _groupsError = 'Erreur lors du chargement des groupes: $e';
} finally {
 _isLoadingGroups = false;
 notifyListeners();
}
 }

 // Créer un groupe de messages
 Future<bool> createMessageGroup({
 required String name,
 String? description,
 required List<String> memberIds,
 MessageGroupType type = MessageGroupType.private,
 String? avatar,
 Map<String, dynamic>? settings,
 }) {async {
 try {
 final response = await _messageService.createMessageGroup(
 name: name,
 description: description,
 memberIds: memberIds,
 type: type,
 avatar: avatar != null ? File(avatar) : null, // TODO: Convertir le fichier
 settings: settings,
 );

 if (response.success && response.data != null) {{
 _messageGroups.insert(0, response.data!);
 notifyListeners();
 return true;
 } else {
 _groupsError = response.message;
 notifyListeners();
 return false;
 }
} catch (e) {
 _groupsError = 'Erreur lors de la création du groupe: $e';
 notifyListeners();
 return false;
}
 }

 // Charger les messages d'un groupe
 Future<void> loadGroupMessages(
 String groupId, {
 bool refresh = false,
 String? search,
 }) {async {
 if (refresh) {{
 _groupMessages[groupId] = [];
}

 try {
 final response = await _messageService.getGroupMessages(
 groupId: groupId,
 search: search,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _groupMessages[groupId] = response.data!;
 } else {
 final existingMessages = _groupMessages[groupId] ?? [];
 _groupMessages[groupId] = [...existingMessages, ...response.data!];
 }
 notifyListeners();
 } else {
 _error = response.message;
 notifyListeners();
 }
} catch (e) {
 _error = 'Erreur lors du chargement des messages du groupe: $e';
 notifyListeners();
}
 }

 // Envoyer un message de groupe
 Future<bool> sendGroupMessage({
 required String groupId,
 required String content,
 MessageType type = MessageType.text,
 MessagePriority priority = MessagePriority.normal,
 List<String>? attachments,
 String? replyToId,
 Map<String, dynamic>? metadata,
 }) {async {
 _isSending = true;
 notifyListeners();

 try {
 final response = await _messageService.sendGroupMessage(
 groupId: groupId,
 content: content,
 type: type,
 priority: priority,
 attachments: attachments != null ? [] : null, // TODO: Convertir les fichiers
 replyToId: replyToId,
 metadata: metadata,
 );

 if (response.success && response.data != null) {{
 // Ajouter le message à la liste du groupe
 final groupMessages = _groupMessages[groupId] ?? [];
 groupMessages.insert(0, response.data!);
 _groupMessages[groupId] = groupMessages;
 
 _isSending = false;
 notifyListeners();
 return true;
 } else {
 _error = response.message;
 _isSending = false;
 notifyListeners();
 return false;
 }
} catch (e) {
 _error = 'Erreur lors de l\'envoi du message de groupe: $e';
 _isSending = false;
 notifyListeners();
 return false;
}
 }

 // Charger les statistiques
 Future<void> loadStatistics({
 DateTime? startDate,
 DateTime? endDate,
 }) {async {
 _isLoadingStatistics = true;
 _statisticsError = null;
 notifyListeners();

 try {
 final response = await _messageService.getMessageStatistics(
 startDate: startDate,
 endDate: endDate,
 );

 if (response.success && response.data != null) {{
 _statistics = response.data!;
 } else {
 _statisticsError = response.message;
 }
} catch (e) {
 _statisticsError = 'Erreur lors du chargement des statistiques: $e';
} finally {
 _isLoadingStatistics = false;
 notifyListeners();
}
 }

 // Rechercher des messages
 Future<void> searchMessages(String query) {async {
 _searchQuery = query;
 _currentPage = 1;
 _hasMore = true;
 await loadMessages(refresh: true);
 }

 // Appliquer des filtres
 void applyFilters({
 MessageStatus? status,
 MessageType? type,
 MessagePriority? priority,
 DateTime? startDate,
 DateTime? endDate,
 }) {
 _statusFilter = status;
 _typeFilter = type;
 _priorityFilter = priority;
 _startDate = startDate;
 _endDate = endDate;
 refreshMessages();
 }

 // Effacer les filtres
 void clearFilters() {
 _statusFilter = null;
 _typeFilter = null;
 _priorityFilter = null;
 _startDate = null;
 _endDate = null;
 _searchQuery = '';
 refreshMessages();
 }

 // Effacer les erreurs
 void clearError() {
 _error = null;
 notifyListeners();
 }

 void clearGroupsError() {
 _groupsError = null;
 notifyListeners();
 }

 void clearStatisticsError() {
 _statisticsError = null;
 notifyListeners();
 }

 // Obtenir les messages d'un groupe
 List<Message> getGroupMessages(String groupId) {
 return _groupMessages[groupId] ?? [];
 }
}
