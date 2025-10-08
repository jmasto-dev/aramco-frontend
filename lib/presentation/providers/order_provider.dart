import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import '../../core/models/order.dart';
import '../../core/models/order_status.dart';
import '../../core/services/order_service.dart';
import '../../core/services/api_service.dart';
import '../../core/models/api_response.dart';

// Classe pour représenter une plage de dates
class \1 extends ChangeNotifier {
 final DateTime start;
 final DateTime end;

 const DateTimeRange({
 required this.start,
 required this.end,
 });

 bool contains(DateTime date) {
 return date.isAfter(start.subtract(const Duration(days: 1))) && 
 date.isBefore(end.add(const Duration(days: 1)));
 }

 Duration get duration => end.difference(start);
}

// États du provider
@immutable
class \1 extends ChangeNotifier {
 final bool isLoading;
 final bool isCreating;
 final bool isUpdating;
 final bool isDeleting;
 final List<Order> orders;
 final Order? selectedOrder;
 final String? error;
 final String? successMessage;
 final int currentPage;
 final int totalPages;
 final int totalCount;
 final bool hasMore;
 final Map<String, dynamic> filters;
 final String searchQuery;
 final OrderStatus? statusFilter;
 final DateTimeRange? dateRange;
 final SortOption sortBy;
 final bool sortAscending;

 const OrderState({
 this.isLoading = false,
 this.isCreating = false,
 this.isUpdating = false,
 this.isDeleting = false,
 this.orders = const [],
 this.selectedOrder,
 this.error,
 this.successMessage,
 this.currentPage = 1,
 this.totalPages = 1,
 this.totalCount = 0,
 this.hasMore = false,
 this.filters = const {},
 this.searchQuery = '',
 this.statusFilter,
 this.dateRange,
 this.sortBy = SortOption.createdAt,
 this.sortAscending = false,
 });

 OrderState copyWith({
 bool? isLoading,
 bool? isCreating,
 bool? isUpdating,
 bool? isDeleting,
 List<Order>? orders,
 Order? selectedOrder,
 String? error,
 String? successMessage,
 int? currentPage,
 int? totalPages,
 int? totalCount,
 bool? hasMore,
 Map<String, dynamic>? filters,
 String? searchQuery,
 OrderStatus? statusFilter,
 DateTimeRange? dateRange,
 SortOption? sortBy,
 bool? sortAscending,
 }) {
 return OrderState(
 isLoading: isLoading ?? this.isLoading,
 isCreating: isCreating ?? this.isCreating,
 isUpdating: isUpdating ?? this.isUpdating,
 isDeleting: isDeleting ?? this.isDeleting,
 orders: orders ?? this.orders,
 selectedOrder: selectedOrder ?? this.selectedOrder,
 error: error,
 successMessage: successMessage,
 currentPage: currentPage ?? this.currentPage,
 totalPages: totalPages ?? this.totalPages,
 totalCount: totalCount ?? this.totalCount,
 hasMore: hasMore ?? this.hasMore,
 filters: filters ?? this.filters,
 searchQuery: searchQuery ?? this.searchQuery,
 statusFilter: statusFilter ?? this.statusFilter,
 dateRange: dateRange ?? this.dateRange,
 sortBy: sortBy ?? this.sortBy,
 sortAscending: sortAscending ?? this.sortAscending,
 );
 }

 bool get hasError => error != null;
 bool get hasSuccessMessage => successMessage != null;
 bool get isBusy => isLoading || isCreating || isUpdating || isDeleting;
 bool get hasFilters => searchQuery.isNotEmpty || 
 statusFilter != null || 
 dateRange != null ||
 filters.isNotEmpty;
}

enum SortOption {
 createdAt('Date de création'),
 updatedAt('Date de modification'),
 totalAmount('Montant total'),
 customerName('Nom du client'),
 status('Statut'),
 deliveryDate('Date de livraison');

 const SortOption(this.displayName);

 final String displayName;
}

class OrderNotifier extends StateNotifier<OrderState> {
 final OrderService _orderService;

 OrderNotifier(this._orderService) : super(const OrderState());

 // Charger la liste des commandes
 Future<void> loadOrders({
 int page = 1,
 bool refresh = false,
 Map<String, dynamic>? additionalFilters,
 }) {async {
 if (state.isBusy && !refresh) r{eturn;

 try {
 state = state.copyWith(
 isLoading: true,
 error: null,
 currentPage: refresh ? 1 : page,
 );

 final filters = {
 ...state.filters,
 if (additionalFilters != null) .{..additionalFilters,
 if (state.searchQuery.isNotEmpty) '{search': state.searchQuery,
 if (state.statusFilter != null) '{status': state.statusFilter!.apiValue,
 if (state.dateRange != null) .{..{
 'date_from': state.dateRange!.start.toIso8601String(),
 'date_to': state.dateRange!.end.toIso8601String(),
 },
 'page': state.currentPage,
 'limit': 20,
 'sort_by': state.sortBy.name,
 'sort_order': state.sortAscending ? 'asc' : 'desc',
 };

 final response = await _orderService.getOrders(
 page: state.currentPage,
 limit: 20,
 search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
 status: state.statusFilter,
 dateFrom: state.dateRange?.start,
 dateTo: state.dateRange?.end,
 sortBy: state.sortBy.name,
 sortOrderDesc: !state.sortAscending,
 );

 if (response.isSuccess && response.data != null) {{
 final orders = response.data!;
 
 state = state.copyWith(
 isLoading: false,
 orders: refresh ? orders : [...state.orders, ...orders],
 currentPage: state.currentPage,
 totalCount: orders.length,
 hasMore: orders.length >= 20,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.message ?? 'Erreur lors du chargement des commandes',
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
}
 }

 // Charger plus de commandes (pagination infinie)
 Future<void> loadMoreOrders() {async {
 if (state.hasMore && !state.isBusy) {{
 await loadOrders(page: state.currentPage + 1);
}
 }

 // Rafraîchir la liste
 Future<void> refreshOrders() {async {
 await loadOrders(refresh: true);
 }

 // Créer une nouvelle commande
 Future<bool> createOrder(Order order) {async {
 try {
 state = state.copyWith(isCreating: true, error: null);

 final response = await _orderService.createOrder(order);

 if (response.isSuccess && response.data != null) {{
 final newOrder = response.data!;
 state = state.copyWith(
 isCreating: false,
 orders: [newOrder, ...state.orders],
 successMessage: response.message ?? 'Commande créée avec succès',
 totalCount: state.totalCount + 1,
 );
 return true;
 } else {
 state = state.copyWith(
 isCreating: false,
 error: response.message ?? 'Erreur lors de la création de la commande',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isCreating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Mettre à jour une commande
 Future<bool> updateOrder(Order order) {async {
 try {
 state = state.copyWith(isUpdating: true, error: null);

 final response = await _orderService.updateOrder(order);

 if (response.isSuccess && response.data != null) {{
 final updatedOrder = response.data!;
 final updatedOrders = state.orders.map((o) {
 return o.id == updatedOrder.id ? updatedOrder : o;
 }).toList();

 state = state.copyWith(
 isUpdating: false,
 orders: updatedOrders,
 selectedOrder: state.selectedOrder?.id == updatedOrder.id 
 ? updatedOrder 
 : state.selectedOrder,
 successMessage: response.message ?? 'Commande mise à jour avec succès',
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message ?? 'Erreur lors de la mise à jour de la commande',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Supprimer une commande
 Future<bool> deleteOrder(String orderId) {async {
 try {
 state = state.copyWith(isDeleting: true, error: null);

 final response = await _orderService.deleteOrder(orderId);

 if (response.isSuccess) {{
 final updatedOrders = state.orders.where((o) => o.id != orderId).toList();

 state = state.copyWith(
 isDeleting: false,
 orders: updatedOrders,
 selectedOrder: state.selectedOrder?.id == orderId ? null : state.selectedOrder,
 successMessage: response.message ?? 'Commande supprimée avec succès',
 totalCount: state.totalCount - 1,
 );
 return true;
 } else {
 state = state.copyWith(
 isDeleting: false,
 error: response.message ?? 'Erreur lors de la suppression de la commande',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isDeleting: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Mettre à jour le statut d'une commande
 Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {String? comment}) {async {
 try {
 state = state.copyWith(isUpdating: true, error: null);

 final response = await _orderService.updateOrderStatus(orderId, newStatus, comment: comment);

 if (response.isSuccess && response.data != null) {{
 final updatedOrder = response.data!;
 final updatedOrders = state.orders.map((o) {
 return o.id == updatedOrder.id ? updatedOrder : o;
 }).toList();

 state = state.copyWith(
 isUpdating: false,
 orders: updatedOrders,
 selectedOrder: state.selectedOrder?.id == updatedOrder.id 
 ? updatedOrder 
 : state.selectedOrder,
 successMessage: response.message ?? 'Statut de la commande mis à jour avec succès',
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message ?? 'Erreur lors de la mise à jour du statut',
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur réseau: ${e.toString()}',
 );
 return false;
}
 }

 // Sélectionner une commande
 void selectOrder(Order? order) {
 state = state.copyWith(selectedOrder: order);
 }

 // Appliquer des filtres
 void applyFilters({
 String? searchQuery,
 OrderStatus? statusFilter,
 DateTimeRange? dateRange,
 Map<String, dynamic>? additionalFilters,
 }) {
 state = state.copyWith(
 searchQuery: searchQuery ?? '',
 statusFilter: statusFilter,
 dateRange: dateRange,
 filters: additionalFilters ?? {},
 );
 refreshOrders();
 }

 // Effacer les filtres
 void clearFilters() {
 state = state.copyWith(
 searchQuery: '',
 statusFilter: null,
 dateRange: null,
 filters: {},
 );
 refreshOrders();
 }

 // Changer le tri
 void changeSorting(SortOption sortBy, {bool? ascending}) {
 state = state.copyWith(
 sortBy: sortBy,
 sortAscending: ascending ?? (sortBy == state.sortBy ? !state.sortAscending : false),
 );
 refreshOrders();
 }

 // Effacer les messages
 void clearMessages() {
 state = state.copyWith(error: null, successMessage: null);
 }

 // Effacer l'erreur
 void clearError() {
 state = state.copyWith(error: null);
 }

 // Effacer le message de succès
 void clearSuccessMessage() {
 state = state.copyWith(successMessage: null);
 }

 // Réinitialiser l'état
 void reset() {
 state = const OrderState();
 }
}

// Provider pour l'OrderService
final orderServiceProvider = Provider<OrderService>((ref) {
 final apiService = ApiService();
 return OrderService(apiService);
});

// Providers
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
 final orderService = ref.read(orderServiceProvider);
 return OrderNotifier(orderService);
});

// Providers spécialisés
final filteredOrdersProvider = Provider<List<Order>>((ref) {
 final state = ref.watch(orderProvider);
 return state.orders;
});

final selectedOrderProvider = Provider<Order?>((ref) {
 final state = ref.watch(orderProvider);
 return state.selectedOrder;
});

final ordersCountProvider = Provider<int>((ref) {
 final state = ref.watch(orderProvider);
 return state.totalCount;
});

final ordersByStatusProvider = Provider<Map<OrderStatus, int>>((ref) {
 final state = ref.watch(orderProvider);
 final Map<OrderStatus, int> counts = {};
 
 for (final status in OrderStatus.values) {
 counts[status] = state.orders.where((order) => order.status == status).length;
 }
 
 return counts;
});

final pendingOrdersProvider = Provider<List<Order>>((ref) {
 final orders = ref.watch(filteredOrdersProvider);
 return orders.where((order) => order.status.isPending).toList();
});

final activeOrdersProvider = Provider<List<Order>>((ref) {
 final orders = ref.watch(filteredOrdersProvider);
 return orders.where((order) => order.status.isActive).toList();
});

final completedOrdersProvider = Provider<List<Order>>((ref) {
 final orders = ref.watch(filteredOrdersProvider);
 return orders.where((order) => order.status.isCompleted).toList();
});

final overdueOrdersProvider = Provider<List<Order>>((ref) {
 final orders = ref.watch(filteredOrdersProvider);
 return orders.where((order) => order.isOverdue).toList();
});

final unpaidOrdersProvider = Provider<List<Order>>((ref) {
 final orders = ref.watch(filteredOrdersProvider);
 return orders.where((order) => !order.isPaid).toList();
});

// Provider pour les statistiques
final orderStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
 final state = ref.watch(orderProvider);
 final orders = state.orders;
 
 if (orders.isEmpty) {{
 return {
 'totalOrders': 0,
 'totalRevenue': 0.0,
 'averageOrderValue': 0.0,
 'pendingOrders': 0,
 'completedOrders': 0,
 'cancelledOrders': 0,
 'overdueOrders': 0,
};
 }

 final totalRevenue = orders.fold<double>(
 0.0, 
 (sum, order) => sum + order.totalAmount,
 );
 
 final averageOrderValue = totalRevenue / orders.length;
 
 return {
 'totalOrders': orders.length,
 'totalRevenue': totalRevenue,
 'averageOrderValue': averageOrderValue,
 'pendingOrders': orders.where((o) => o.status.isPending).length,
 'completedOrders': orders.where((o) => o.status.isCompleted).length,
 'cancelledOrders': orders.where((o) => o.status.isCancelled).length,
 'overdueOrders': orders.where((o) => o.isOverdue).length,
 };
});
