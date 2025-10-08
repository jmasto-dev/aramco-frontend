import 'package:json_annotation/json_annotation.dart';
import 'order_status.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
 final String id;
 final String customerId;
 final String customerName;
 final String customerEmail;
 final String customerPhone;
 final List<OrderItem> items;
 final OrderStatus status;
 final DateTime createdAt;
 final DateTime? updatedAt;
 final DateTime? expectedDeliveryDate;
 final DateTime? deliveredAt;
 final double totalAmount;
 final double taxAmount;
 final double shippingAmount;
 final String currency;
 final String? notes;
 final List<String> attachments;
 final ShippingAddress shippingAddress;
 final BillingAddress? billingAddress;
 final PaymentInfo paymentInfo;
 final List<OrderStatusHistory> statusHistory;
 final Map<String, dynamic>? metadata;

 const Order({
 required this.id,
 required this.customerId,
 required this.customerName,
 required this.customerEmail,
 required this.customerPhone,
 required this.items,
 required this.status,
 required this.createdAt,
 this.updatedAt,
 this.expectedDeliveryDate,
 this.deliveredAt,
 required this.totalAmount,
 required this.taxAmount,
 required this.shippingAmount,
 this.currency = 'EUR',
 this.notes,
 this.attachments = const [],
 required this.shippingAddress,
 this.billingAddress,
 required this.paymentInfo,
 this.statusHistory = const [],
 this.metadata,
 });

 factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
 Map<String, dynamic> toJson() => _$OrderToJson(this);

 Order copyWith({
 String? id,
 String? customerId,
 String? customerName,
 String? customerEmail,
 String? customerPhone,
 List<OrderItem>? items,
 OrderStatus? status,
 DateTime? createdAt,
 DateTime? updatedAt,
 DateTime? expectedDeliveryDate,
 DateTime? deliveredAt,
 double? totalAmount,
 double? taxAmount,
 double? shippingAmount,
 String? currency,
 String? notes,
 List<String>? attachments,
 ShippingAddress? shippingAddress,
 BillingAddress? billingAddress,
 PaymentInfo? paymentInfo,
 List<OrderStatusHistory>? statusHistory,
 Map<String, dynamic>? metadata,
 }) {
 return Order(
 id: id ?? this.id,
 customerId: customerId ?? this.customerId,
 customerName: customerName ?? this.customerName,
 customerEmail: customerEmail ?? this.customerEmail,
 customerPhone: customerPhone ?? this.customerPhone,
 items: items ?? this.items,
 status: status ?? this.status,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
 deliveredAt: deliveredAt ?? this.deliveredAt,
 totalAmount: totalAmount ?? this.totalAmount,
 taxAmount: taxAmount ?? this.taxAmount,
 shippingAmount: shippingAmount ?? this.shippingAmount,
 currency: currency ?? this.currency,
 notes: notes ?? this.notes,
 attachments: attachments ?? this.attachments,
 shippingAddress: shippingAddress ?? this.shippingAddress,
 billingAddress: billingAddress ?? this.billingAddress,
 paymentInfo: paymentInfo ?? this.paymentInfo,
 statusHistory: statusHistory ?? this.statusHistory,
 metadata: metadata ?? this.metadata,
 );
 }

 // Getters calculés
 int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
 double get subtotalAmount => totalAmount - taxAmount - shippingAmount;
 String get formattedTotalAmount => '${totalAmount.toStringAsFixed(2)} $currency';
 String get formattedSubtotalAmount => '${subtotalAmount.toStringAsFixed(2)} $currency';
 String get formattedTaxAmount => '${taxAmount.toStringAsFixed(2)} $currency';
 String get formattedShippingAmount => '${shippingAmount.toStringAsFixed(2)} $currency';

 bool get isPaid => paymentInfo.status == PaymentStatus.paid;
 bool get isPendingPayment => paymentInfo.status == PaymentStatus.pending;
 bool get hasAttachments => attachments.isNotEmpty;
 bool get hasNotes => notes != null && notes!.isNotEmpty;
 bool get isOverdue => expectedDeliveryDate != null && 
 DateTime.now().isAfter(expectedDeliveryDate!) && 
 !status.isCompleted;

 Duration? get timeToDelivery {
 if (expectedDeliveryDate == null) r{eturn null;
 return expectedDeliveryDate!.difference(DateTime.now());
 }

 String get deliveryStatus {
 if (deliveredAt != null) r{eturn 'Livré le ${_formatDate(deliveredAt!)}';
 if (expectedDeliveryDate == null) r{eturn 'Date non définie';
 if (DateTime.now().{isAfter(expectedDeliveryDate!)) return 'En retard';
 return 'Prévu le ${_formatDate(expectedDeliveryDate!)}';
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is Order && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'Order(id: $id, customerName: $customerName, status: $status, totalAmount: $formattedTotalAmount)';
 }
}

@JsonSerializable()
class OrderItem {
 final String productId;
 final String productName;
 final String productSku;
 final String? productImage;
 final int quantity;
 final double unitPrice;
 final double totalPrice;
 final String? productCategory;
 final Map<String, dynamic>? productAttributes;
 final Map<String, dynamic>? customOptions;

 const OrderItem({
 required this.productId,
 required this.productName,
 required this.productSku,
 this.productImage,
 required this.quantity,
 required this.unitPrice,
 required this.totalPrice,
 this.productCategory,
 this.productAttributes,
 this.customOptions,
 });

 factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
 Map<String, dynamic> toJson() => _$OrderItemToJson(this);

 OrderItem copyWith({
 String? productId,
 String? productName,
 String? productSku,
 String? productImage,
 int? quantity,
 double? unitPrice,
 double? totalPrice,
 String? productCategory,
 Map<String, dynamic>? productAttributes,
 Map<String, dynamic>? customOptions,
 }) {
 return OrderItem(
 productId: productId ?? this.productId,
 productName: productName ?? this.productName,
 productSku: productSku ?? this.productSku,
 productImage: productImage ?? this.productImage,
 quantity: quantity ?? this.quantity,
 unitPrice: unitPrice ?? this.unitPrice,
 totalPrice: totalPrice ?? this.totalPrice,
 productCategory: productCategory ?? this.productCategory,
 productAttributes: productAttributes ?? this.productAttributes,
 customOptions: customOptions ?? this.customOptions,
 );
 }

 String get formattedUnitPrice => '${unitPrice.toStringAsFixed(2)} €';
 String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} €';
 bool get hasCustomOptions => customOptions != null && customOptions!.isNotEmpty;
 bool get hasProductAttributes => productAttributes != null && productAttributes!.isNotEmpty;

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is OrderItem && 
 other.productId == productId && 
 other.productSku == productSku;
 }

 @override
 int get hashCode => productId.hashCode ^ productSku.hashCode;

 @override
 String toString() {
 return 'OrderItem(productId: $productId, productName: $productName, quantity: $quantity, totalPrice: $formattedTotalPrice)';
 }
}

@JsonSerializable()
class ShippingAddress {
 final String street;
 final String city;
 final String postalCode;
 final String country;
 final String? state;
 final String? company;
 final String? firstName;
 final String? lastName;
 final String? phone;

 const ShippingAddress({
 required this.street,
 required this.city,
 required this.postalCode,
 required this.country,
 this.state,
 this.company,
 this.firstName,
 this.lastName,
 this.phone,
 });

 factory ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);
 Map<String, dynamic> toJson() => _$ShippingAddressToJson(this);

 String get fullAddress {
 final parts = <String>[];
 if (company != null && company!.isNotEmpty) p{arts.add(company!);
 if (firstName != null && lastName != null) {{
 parts.add('$firstName $lastName');
}
 parts.add(street);
 parts.add('$postalCode $city');
 if (state != null && state!.isNotEmpty) p{arts.add(state!);
 parts.add(country);
 return parts.join(', ');
 }

 @override
 String toString() => fullAddress;
}

@JsonSerializable()
class BillingAddress {
 final String street;
 final String city;
 final String postalCode;
 final String country;
 final String? state;
 final String? company;
 final String? firstName;
 final String? lastName;
 final String? phone;
 final String? vatNumber;

 const BillingAddress({
 required this.street,
 required this.city,
 required this.postalCode,
 required this.country,
 this.state,
 this.company,
 this.firstName,
 this.lastName,
 this.phone,
 this.vatNumber,
 });

 factory BillingAddress.fromJson(Map<String, dynamic> json) => _$BillingAddressFromJson(json);
 Map<String, dynamic> toJson() => _$BillingAddressToJson(this);

 String get fullAddress {
 final parts = <String>[];
 if (company != null && company!.isNotEmpty) p{arts.add(company!);
 if (firstName != null && lastName != null) {{
 parts.add('$firstName $lastName');
}
 parts.add(street);
 parts.add('$postalCode $city');
 if (state != null && state!.isNotEmpty) p{arts.add(state!);
 parts.add(country);
 return parts.join(', ');
 }

 @override
 String toString() => fullAddress;
}

@JsonSerializable()
class PaymentInfo {
 final String id;
 final PaymentMethod method;
 final PaymentStatus status;
 final double amount;
 final String currency;
 final DateTime? paidAt;
 final String? transactionId;
 final String? gateway;
 final Map<String, dynamic>? metadata;

 const PaymentInfo({
 required this.id,
 required this.method,
 required this.status,
 required this.amount,
 required this.currency,
 this.paidAt,
 this.transactionId,
 this.gateway,
 this.metadata,
 });

 factory PaymentInfo.fromJson(Map<String, dynamic> json) => _$PaymentInfoFromJson(json);
 Map<String, dynamic> toJson() => _$PaymentInfoToJson(this);

 String get formattedAmount => '${amount.toStringAsFixed(2)} $currency';
 bool get isPaid => status == PaymentStatus.paid;
 bool get isPending => status == PaymentStatus.pending;
 bool get isFailed => status == PaymentStatus.failed;

 @override
 String toString() {
 return 'PaymentInfo(method: $method, status: $status, amount: $formattedAmount)';
 }
}

@JsonSerializable()
class OrderStatusHistory {
 final OrderStatus status;
 final DateTime timestamp;
 final String? comment;
 final String? updatedBy;
 final Map<String, dynamic>? metadata;

 const OrderStatusHistory({
 required this.status,
 required this.timestamp,
 this.comment,
 this.updatedBy,
 this.metadata,
 });

 factory OrderStatusHistory.fromJson(Map<String, dynamic> json) => _$OrderStatusHistoryFromJson(json);
 Map<String, dynamic> toJson() => _$OrderStatusHistoryToJson(this);

 String get formattedTimestamp {
 return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
 }

 @override
 String toString() {
 return 'OrderStatusHistory(status: $status, timestamp: $formattedTimestamp)';
 }
}

enum PaymentMethod {
 creditCard('Carte de crédit'),
 debitCard('Carte de débit'),
 paypal('PayPal'),
 bankTransfer('Virement bancaire'),
 cashOnDelivery('Paiement à la livraison'),
 crypto('Cryptomonnaie'),
 check('Chèque'),
 other('Autre');

 const PaymentMethod(this.displayName);

 final String displayName;

 static PaymentMethod fromString(String value) {
 return PaymentMethod.values.firstWhere(
 (method) => method.displayName == value || method.name == value,
 orElse: () => PaymentMethod.other,
 );
 }
}

enum PaymentStatus {
 pending('En attente'),
 processing('En traitement'),
 paid('Payé'),
 failed('Échoué'),
 refunded('Remboursé'),
 partiallyRefunded('Partiellement remboursé');

 const PaymentStatus(this.displayName);

 final String displayName;

 static PaymentStatus fromString(String value) {
 return PaymentStatus.values.firstWhere(
 (status) => status.displayName == value || status.name == value,
 orElse: () => PaymentStatus.pending,
 );
 }
}
