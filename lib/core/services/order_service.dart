import 'dart:convert';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import 'api_service.dart';

class OrderService {
 final ApiService _apiService;

 OrderService(this._apiService);

 // Récupérer la liste des commandes avec filtres avancés
 Future<ApiResponse<List<Order>>> getOrders({
 int page = 1,
 int limit = 20,
 String? search,
 OrderStatus? status,
 String? customerId,
 String? productId,
 DateTime? dateFrom,
 DateTime? dateTo,
 String? sortBy = 'createdAt',
 bool sortOrderDesc = true,
 double? minAmount,
 double? maxAmount,
 bool? isPaid,
 bool? isOverdue,
 List<String>? productCategories,
 String? deliveryMethod,
 String? paymentMethod,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'page': page,
 'limit': limit,
 'sort_by': sortBy,
 'sort_order': sortOrderDesc ? 'desc' : 'asc',
 };

 // Ajouter les filtres de recherche
 if (search != null && search.isNotEmpty) {
 queryParams['search'] = search;
 }

 // Filtre par statut
 if (status != null) {
 queryParams['status'] = status.apiValue;
 }

 // Filtre par client
 if (customerId != null && customerId.isNotEmpty) {
 queryParams['customer_id'] = customerId;
 }

 // Filtre par produit
 if (productId != null && productId.isNotEmpty) {
 queryParams['product_id'] = productId;
 }

 // Filtre par plage de dates
 if (dateFrom != null) {
 queryParams['date_from'] = dateFrom.toIso8601String();
 }
 if (dateTo != null) {
 queryParams['date_to'] = dateTo.toIso8601String();
 }

 // Filtre par montant
 if (minAmount != null) {
 queryParams['min_amount'] = minAmount;
 }
 if (maxAmount != null) {
 queryParams['max_amount'] = maxAmount;
 }

 // Filtre par paiement
 if (isPaid != null) {
 queryParams['is_paid'] = isPaid;
 }

 // Filtre par retard
 if (isOverdue != null) {
 queryParams['is_overdue'] = isOverdue;
 }

 // Filtre par catégories de produits
 if (productCategories != null && productCategories.isNotEmpty) {
 queryParams['product_categories'] = productCategories.join(',');
 }

 // Filtre par méthode de livraison
 if (deliveryMethod != null && deliveryMethod.isNotEmpty) {
 queryParams['delivery_method'] = deliveryMethod;
 }

 // Filtre par méthode de paiement
 if (paymentMethod != null && paymentMethod.isNotEmpty) {
 queryParams['payment_method'] = paymentMethod;
 }

 final ApiResponse<dynamic> response = await _apiService.get(
 '/api/orders',
 queryParameters: queryParams,
 );

 if (response.isSuccess && response.data != null) {
 final data = response.data!;
 final ordersData = data['orders'] as List<String>?;
 
 if (ordersData != null) {
 final orders = ordersData
 .map((json) => Order.fromJson(json))
 .toList();
 
 return ApiResponse<List<Order>>.success(
 data: orders,
 message: response.message,
 statusCode: response.statusCode,
 );
 }
 }

 return ApiResponse<List<Order>>.error(
 message: response.message ?? 'Erreur lors du chargement des commandes',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<List<Order>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Récupérer une commande par son ID
 Future<ApiResponse<Order>> getOrderById(String orderId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('/api/orders/$orderId');

 if (response.isSuccess && response.data != null) {
 final order = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: order,
 message: response.message,
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Commande non trouvée',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Créer une nouvelle commande
 Future<ApiResponse<Order>> createOrder(Order order) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/api/orders',
 data: order.toJson(),
 );

 if (response.isSuccess && response.data != null) {
 final newOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: newOrder,
 message: 'Commande créée avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de la création de la commande',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Mettre à jour une commande
 Future<ApiResponse<Order>> updateOrder(Order order) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put(
 '/api/orders/${order.id}',
 data: order.toJson(),
 );

 if (response.isSuccess && response.data != null) {
 final updatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: updatedOrder,
 message: 'Commande mise à jour avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de la mise à jour de la commande',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Supprimer une commande
 Future<ApiResponse<void>> deleteOrder(String orderId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('/api/orders/$orderId');

 if (response.isSuccess) {
 return ApiResponse<void>.success(
 data: null,
 message: 'Commande supprimée avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<void>.error(
 message: response.message ?? 'Erreur lors de la suppression de la commande',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<void>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Mettre à jour le statut d'une commande
 Future<ApiResponse<Order>> updateOrderStatus(
 String orderId,
 OrderStatus newStatus, {
 String? comment,
 String? internalNote,
 }) async {
 try {
 final data = {
 'status': newStatus.apiValue,
 if (comment != null) '{comment': comment,
 if (internalNote != null) '{internal_note': internalNote,
 };

 final ApiResponse<dynamic> response = await _apiService.put(
 '/api/orders/$orderId/status',
 data: data,
 );

 if (response.isSuccess && response.data != null) {
 final updatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: updatedOrder,
 message: 'Statut de la commande mis à jour avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de la mise à jour du statut',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Ajouter un produit à une commande
 Future<ApiResponse<Order>> addProductToOrder(
 String orderId,
 String productId,
 int quantity,
 double unitPrice,
 ) async {
 try {
 final data = {
 'product_id': productId,
 'quantity': quantity,
 'unit_price': unitPrice,
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 '/api/orders/$orderId/items',
 data: data,
 );

 if (response.isSuccess && response.data != null) {
 final updatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: updatedOrder,
 message: 'Produit ajouté à la commande',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de l\'ajout du produit',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Supprimer un produit d'une commande
 Future<ApiResponse<Order>> removeProductFromOrder(
 String orderId,
 String itemId,
 ) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('/api/orders/$orderId/items/$itemId');

 if (response.isSuccess && response.data != null) {
 final updatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: updatedOrder,
 message: 'Produit supprimé de la commande',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de la suppression du produit',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Appliquer une remise à une commande
 Future<ApiResponse<Order>> applyDiscount(
 String orderId,
 double discountAmount,
 String discountReason,
 ) async {
 try {
 final data = {
 'discount_amount': discountAmount,
 'discount_reason': discountReason,
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 '/api/orders/$orderId/discount',
 data: data,
 );

 if (response.isSuccess && response.data != null) {
 final updatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: updatedOrder,
 message: 'Remise appliquée avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de l\'application de la remise',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Marquer une commande comme payée
 Future<ApiResponse<Order>> markAsPaid(
 String orderId,
 String paymentMethod,
 String? transactionId,
 DateTime? paymentDate,
 ) async {
 try {
 final data = {
 'payment_method': paymentMethod,
 if (transactionId != null) '{transaction_id': transactionId,
 if (paymentDate != null) '{payment_date': paymentDate.toIso8601String(),
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 '/api/orders/$orderId/payment',
 data: data,
 );

 if (response.isSuccess && response.data != null) {
 final updatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: updatedOrder,
 message: 'Commande marquée comme payée',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors du marquage comme payée',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Envoyer une notification de commande
 Future<ApiResponse<void>> sendOrderNotification(
 String orderId,
 String notificationType, {
 String? recipientEmail,
 String? customMessage,
 }) async {
 try {
 final data = {
 'notification_type': notificationType,
 if (recipientEmail != null) '{recipient_email': recipientEmail,
 if (customMessage != null) '{custom_message': customMessage,
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 '/api/orders/$orderId/notify',
 data: data,
 );

 if (response.isSuccess) {
 return ApiResponse<void>.success(
 data: null,
 message: 'Notification envoyée avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<void>.error(
 message: response.message ?? 'Erreur lors de l\'envoi de la notification',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<void>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Obtenir les statistiques des commandes
 Future<ApiResponse<Map<String, dynamic>>> getOrderStatistics({
 DateTime? dateFrom,
 DateTime? dateTo,
 String? groupBy, // 'day', 'week', 'month', 'year'
 }) async {
 try {
 final queryParams = <String, dynamic>{};

 if (dateFrom != null) {
 queryParams['date_from'] = dateFrom.toIso8601String();
 }
 if (dateTo != null) {
 queryParams['date_to'] = dateTo.toIso8601String();
 }
 if (groupBy != null) {
 queryParams['group_by'] = groupBy;
 }

 final ApiResponse<dynamic> response = await _apiService.get(
 '/api/orders/statistics',
 queryParameters: queryParams,
 );

 if (response.isSuccess && response.data != null) {
 return ApiResponse<Map<String, dynamic>>.success(
 data: response.data!,
 message: response.message,
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Map<String, dynamic>>.error(
 message: response.message ?? 'Erreur lors du chargement des statistiques',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Exporter les commandes
 Future<ApiResponse<String>> exportOrders({
 String format = 'csv', // 'csv', 'excel', 'pdf'
 Map<String, dynamic>? filters,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'format': format,
 if (filters != null) .{..filters,
 };

 final ApiResponse<dynamic> response = await _apiService.get(
 '/api/orders/export',
 queryParameters: queryParams,
 );

 if (response.isSuccess && response.data != null) {
 final downloadUrl = response.data!['download_url'] as String?;
 if (downloadUrl != null) {
 return ApiResponse<String>.success(
 data: downloadUrl,
 message: 'Export prêt',
 statusCode: response.statusCode,
 );
 }
 }

 return ApiResponse<String>.error(
 message: response.message ?? 'Erreur lors de l\'export',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<String>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Dupliquer une commande
 Future<ApiResponse<Order>> duplicateOrder(
 String orderId, {
 Map<String, dynamic>? modifications,
 }) async {
 try {
 final data = {
 if (modifications != null) .{..modifications,
 };

 final ApiResponse<dynamic> response = await _apiService.post(
 '/api/orders/$orderId/duplicate',
 data: data,
 );

 if (response.isSuccess && response.data != null) {
 final duplicatedOrder = Order.fromJson(response.data!);
 return ApiResponse<Order>.success(
 data: duplicatedOrder,
 message: 'Commande dupliquée avec succès',
 statusCode: response.statusCode,
 );
 }

 return ApiResponse<Order>.error(
 message: response.message ?? 'Erreur lors de la duplication de la commande',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<Order>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }

 // Obtenir l'historique des changements d'une commande
 Future<ApiResponse<List<Map<String, dynamic>>>> getOrderHistory(String orderId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('/api/orders/$orderId/history');

 if (response.isSuccess && response.data != null) {
 final historyData = response.data!['history'] as List<String>?;
 if (historyData != null) {
 final history = historyData.cast<Map<String, dynamic>>();
 return ApiResponse<List<Map<String, dynamic>>>.success(
 data: history,
 message: response.message,
 statusCode: response.statusCode,
 );
 }
 }

 return ApiResponse<List<Map<String, dynamic>>>.error(
 message: response.message ?? 'Erreur lors du chargement de l\'historique',
 statusCode: response.statusCode,
 );
} catch (e) {
 return ApiResponse<List<Map<String, dynamic>>>.error(
 message: 'Erreur réseau: ${e.toString()}',
 statusCode: 0,
 );
}
 }
}
