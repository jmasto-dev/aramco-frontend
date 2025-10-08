import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'stock_item.g.dart';

@JsonSerializable()
class StockItem {
 final String id;
 final String productId;
 final String warehouseId;
 final String location;
 final int quantity;
 final int minQuantity;
 final int maxQuantity;
 final double unitCost;
 final double totalValue;
 final String? batchNumber;
 final DateTime? expiryDate;
 final DateTime lastUpdated;
 final String? lastUpdatedBy;
 final StockStatus status;
 final Product? product;

 const StockItem({
 required this.id,
 required this.productId,
 required this.warehouseId,
 required this.location,
 required this.quantity,
 required this.minQuantity,
 required this.maxQuantity,
 required this.unitCost,
 required this.totalValue,
 this.batchNumber,
 this.expiryDate,
 required this.lastUpdated,
 this.lastUpdatedBy,
 required this.status,
 this.product,
 });

 factory StockItem.fromJson(Map<String, dynamic> json) =>
 _$StockItemFromJson(json);

 Map<String, dynamic> toJson() => _$StockItemToJson(this);

 StockItem copyWith({
 String? id,
 String? productId,
 String? warehouseId,
 String? location,
 int? quantity,
 int? minQuantity,
 int? maxQuantity,
 double? unitCost,
 double? totalValue,
 String? batchNumber,
 DateTime? expiryDate,
 DateTime? lastUpdated,
 String? lastUpdatedBy,
 StockStatus? status,
 Product? product,
 }) {
 return StockItem(
 id: id ?? this.id,
 productId: productId ?? this.productId,
 warehouseId: warehouseId ?? this.warehouseId,
 location: location ?? this.location,
 quantity: quantity ?? this.quantity,
 minQuantity: minQuantity ?? this.minQuantity,
 maxQuantity: maxQuantity ?? this.maxQuantity,
 unitCost: unitCost ?? this.unitCost,
 totalValue: totalValue ?? this.totalValue,
 batchNumber: batchNumber ?? this.batchNumber,
 expiryDate: expiryDate ?? this.expiryDate,
 lastUpdated: lastUpdated ?? this.lastUpdated,
 lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
 status: status ?? this.status,
 product: product ?? this.product,
 );
 }

 bool get isLowStock => quantity <= minQuantity;
 bool get isOverStock => quantity >= maxQuantity;
 bool get isExpiringSoon => expiryDate != null && 
 expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
 bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

 double get stockLevel => quantity / maxQuantity;
 String get stockStatusText {
 if (isExpired) r{eturn 'Expiré';
 if (isExpiringSoon) r{eturn 'Expire bientôt';
 if (isLowStock) r{eturn 'Stock faible';
 if (isOverStock) r{eturn 'Surstock';
 return 'Normal';
 }
}

enum StockStatus {
 @JsonValue('in_stock')
 inStock,
 @JsonValue('low_stock')
 lowStock,
 @JsonValue('out_of_stock')
 outOfStock,
 @JsonValue('expired')
 expired,
 @JsonValue('reserved')
 reserved,
 @JsonValue('in_transit')
 inTransit,
}

@JsonSerializable()
class StockMovement {
 final String id;
 final String stockItemId;
 final MovementType type;
 final int quantity;
 final String? reference;
 final String? reason;
 final DateTime movementDate;
 final String? userId;
 final String? fromLocation;
 final String? toLocation;

 const StockMovement({
 required this.id,
 required this.stockItemId,
 required this.type,
 required this.quantity,
 this.reference,
 this.reason,
 required this.movementDate,
 this.userId,
 this.fromLocation,
 this.toLocation,
 });

 factory StockMovement.fromJson(Map<String, dynamic> json) =>
 _$StockMovementFromJson(json);

 Map<String, dynamic> toJson() => _$StockMovementToJson(this);
}

enum MovementType {
 @JsonValue('in')
 in_,
 @JsonValue('out')
 out,
 @JsonValue('transfer')
 transfer,
 @JsonValue('adjustment')
 adjustment,
 @JsonValue('return')
 return_,
}

@JsonSerializable()
class StockAlert {
 final String id;
 final String stockItemId;
 final AlertType type;
 final String message;
 final AlertSeverity severity;
 final DateTime createdAt;
 final bool isAcknowledged;
 final String? acknowledgedBy;
 final DateTime? acknowledgedAt;

 const StockAlert({
 required this.id,
 required this.stockItemId,
 required this.type,
 required this.message,
 required this.severity,
 required this.createdAt,
 required this.isAcknowledged,
 this.acknowledgedBy,
 this.acknowledgedAt,
 });

 factory StockAlert.fromJson(Map<String, dynamic> json) =>
 _$StockAlertFromJson(json);

 Map<String, dynamic> toJson() => _$StockAlertToJson(this);
}

enum AlertType {
 @JsonValue('low_stock')
 lowStock,
 @JsonValue('out_of_stock')
 outOfStock,
 @JsonValue('expiring_soon')
 expiringSoon,
 @JsonValue('expired')
 expired,
 @JsonValue('overstock')
 overstock,
}

enum AlertSeverity {
 @JsonValue('low')
 low,
 @JsonValue('medium')
 medium,
 @JsonValue('high')
 high,
 @JsonValue('critical')
 critical,
}
