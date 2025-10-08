import 'package:json_annotation/json_annotation.dart';
enum OrderStatus {
 pending('En attente', 'pending'),
 confirmed('Confirmée', 'confirmed'),
 processing('En traitement', 'processing'),
 shipped('Expédiée', 'shipped'),
 delivered('Livrée', 'delivered'),
 cancelled('Annulée', 'cancelled'),
 refunded('Remboursée', 'refunded'),
 returned('Retournée', 'returned');

 const OrderStatus(this.displayName, this.apiValue);

 final String displayName;
 final String apiValue;

 static OrderStatus fromApiValue(String value) {
 return OrderStatus.values.firstWhere(
 (status) => status.apiValue == value,
 orElse: () => OrderStatus.pending,
 );
 }

 static OrderStatus fromDisplayName(String value) {
 return OrderStatus.values.firstWhere(
 (status) => status.displayName == value,
 orElse: () => OrderStatus.pending,
 );
 }

 bool get isPending => this == OrderStatus.pending;
 bool get isConfirmed => this == OrderStatus.confirmed;
 bool get isProcessing => this == OrderStatus.processing;
 bool get isShipped => this == OrderStatus.shipped;
 bool get isDelivered => this == OrderStatus.delivered;
 bool get isCancelled => this == OrderStatus.cancelled;
 bool get isRefunded => this == OrderStatus.refunded;
 bool get isReturned => this == OrderStatus.returned;

 bool get isActive => !isCancelled && !isRefunded && !isReturned;
 bool get isCompleted => isDelivered || isReturned;
 bool get canBeCancelled => isPending || isConfirmed;
 bool get canBeRefunded => isDelivered && !isRefunded;
 bool get canBeReturned => isDelivered && !isReturned;

 List<OrderStatus> get nextPossibleStatuses {
 switch (this) {
 case OrderStatus.pending:
 return [OrderStatus.confirmed, OrderStatus.cancelled];
 case OrderStatus.confirmed:
 return [OrderStatus.processing, OrderStatus.cancelled];
 case OrderStatus.processing:
 return [OrderStatus.shipped, OrderStatus.cancelled];
 case OrderStatus.shipped:
 return [OrderStatus.delivered];
 case OrderStatus.delivered:
 return [OrderStatus.returned];
 case OrderStatus.cancelled:
 return [OrderStatus.refunded];
 case OrderStatus.refunded:
 return [];
 case OrderStatus.returned:
 return [OrderStatus.refunded];
}
 }
}

extension OrderStatusExtension on OrderStatus {
 String get color {
 switch (this) {
 case OrderStatus.pending:
 return '#FFA726'; // Orange
 case OrderStatus.confirmed:
 return '#42A5F5'; // Blue
 case OrderStatus.processing:
 return '#AB47BC'; // Purple
 case OrderStatus.shipped:
 return '#26C6DA'; // Cyan
 case OrderStatus.delivered:
 return '#66BB6A'; // Green
 case OrderStatus.cancelled:
 return '#EF5350'; // Red
 case OrderStatus.refunded:
 return '#FF7043'; // Deep Orange
 case OrderStatus.returned:
 return '#8D6E63'; // Brown
;
 }

 String get icon {
 switch (this) {
 case OrderStatus.pending:
 return '⏳';
 case OrderStatus.confirmed:
 return '✅';
 case OrderStatus.processing:
 return '🔄';
 case OrderStatus.shipped:
 return '🚚';
 case OrderStatus.delivered:
 return '📦';
 case OrderStatus.cancelled:
 return '❌';
 case OrderStatus.refunded:
 return '💰';
 case OrderStatus.returned:
 return '🔄';
}
 }

 String get description {
 switch (this) {
 case OrderStatus.pending:
 return 'La commande est en attente de validation';
 case OrderStatus.confirmed:
 return 'La commande a été confirmée et sera préparée';
 case OrderStatus.processing:
 return 'La commande est en cours de préparation';
 case OrderStatus.shipped:
 return 'La commande a été expédiée';
 case OrderStatus.delivered:
 return 'La commande a été livrée avec succès';
 case OrderStatus.cancelled:
 return 'La commande a été annulée';
 case OrderStatus.refunded:
 return 'La commande a été remboursée';
 case OrderStatus.returned:
 return 'La commande a été retournée';
}
 }
}
