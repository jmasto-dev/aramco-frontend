import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
 final String id;
 final String productId;
 final String productName;
 final int quantity;
 final double unitPrice;
 final double totalPrice;
 final String? productImage;
 final String? productSku;
 final Map<String, dynamic>? customOptions;
 final String? notes;
 final String? variantId;
 final String? variantName;
 final double? discountAmount;
 final double? taxAmount;
 final double? weight;
 final String? unit;
 final DateTime? addedAt;

 const OrderItem({
 required this.id,
 required this.productId,
 required this.productName,
 required this.quantity,
 required this.unitPrice,
 required this.totalPrice,
 this.productImage,
 this.productSku,
 this.customOptions,
 this.notes,
 this.variantId,
 this.variantName,
 this.discountAmount,
 this.taxAmount,
 this.weight,
 this.unit,
 this.addedAt,
 });

 factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
 Map<String, dynamic> toJson() => _$OrderItemToJson(this);

 OrderItem copyWith({
 String? id,
 String? productId,
 String? productName,
 int? quantity,
 double? unitPrice,
 double? totalPrice,
 String? productImage,
 String? productSku,
 Map<String, dynamic>? customOptions,
 String? notes,
 String? variantId,
 String? variantName,
 double? discountAmount,
 double? taxAmount,
 double? weight,
 String? unit,
 DateTime? addedAt,
 }) {
 return OrderItem(
 id: id ?? this.id,
 productId: productId ?? this.productId,
 productName: productName ?? this.productName,
 quantity: quantity ?? this.quantity,
 unitPrice: unitPrice ?? this.unitPrice,
 totalPrice: totalPrice ?? this.totalPrice,
 productImage: productImage ?? this.productImage,
 productSku: productSku ?? this.productSku,
 customOptions: customOptions ?? this.customOptions,
 notes: notes ?? this.notes,
 variantId: variantId ?? this.variantId,
 variantName: variantName ?? this.variantName,
 discountAmount: discountAmount ?? this.discountAmount,
 taxAmount: taxAmount ?? this.taxAmount,
 weight: weight ?? this.weight,
 unit: unit ?? this.unit,
 addedAt: addedAt ?? this.addedAt,
 );
 }

 // Getters utilitaires
 bool get hasDiscount => discountAmount != null && discountAmount! > 0;
 bool get hasTax => taxAmount != null && taxAmount! > 0;
 bool get hasCustomOptions => customOptions != null && customOptions!.isNotEmpty;
 bool get hasNotes => notes != null && notes!.isNotEmpty;
 bool get hasVariant => variantId != null && variantId!.isNotEmpty;
 
 double get effectiveUnitPrice => unitPrice - (discountAmount ?? 0);
 double get effectiveTotalPrice => (effectiveUnitPrice * quantity) + (taxAmount ?? 0);
 
 String get displayName => hasVariant ? '$productName - $variantName' : productName;
 String get displayUnitPrice => '\$${effectiveUnitPrice.toStringAsFixed(2)}';
 String get displayTotalPrice => '\$${effectiveTotalPrice.toStringAsFixed(2)}';
 String get displayQuantity => '$quantity ${unit ?? 'units'}';
 
 String get displayDiscount => hasDiscount ? '-\$${discountAmount!.toStringAsFixed(2)}' : '';
 String get displayTax => hasTax ? '+\$${taxAmount!.toStringAsFixed(2)}' : '';

 // Validation
 bool get isValid => 
 id.isNotEmpty && 
 productId.isNotEmpty && 
 productName.isNotEmpty && 
 quantity > 0 && 
 unitPrice >= 0 && 
 totalPrice >= 0;

 // Méthodes de calcul
 static double calculateTotalPrice(int quantity, double unitPrice, {double? discountAmount, double? taxAmount}) {
 final effectivePrice = unitPrice - (discountAmount ?? 0);
 return (effectivePrice * quantity) + (taxAmount ?? 0);
 }

 static double calculateUnitPrice(double totalPrice, int quantity, {double? taxAmount}) {
 final priceWithoutTax = totalPrice - (taxAmount ?? 0);
 return quantity > 0 ? priceWithoutTax / quantity : 0.0;
 }

 // Création à partir d'un produit
 factory OrderItem.fromProduct({
 required String id,
 required Product product,
 required int quantity,
 String? variantId,
 String? variantName,
 double? priceAdjustment,
 Map<String, dynamic>? customOptions,
 String? notes,
 }) {
 final basePrice = product.effectivePrice;
 final adjustedPrice = priceAdjustment != null ? basePrice + priceAdjustment : basePrice;
 final totalPrice = calculateTotalPrice(quantity, adjustedPrice);

 return OrderItem(
 id: id,
 productId: product.id,
 productName: product.name,
 quantity: quantity,
 unitPrice: adjustedPrice,
 totalPrice: totalPrice,
 productImage: product.images.isNotEmpty ? product.images.first : null,
 productSku: product.sku,
 customOptions: customOptions,
 notes: notes,
 variantId: variantId,
 variantName: variantName,
 weight: product.weight,
 unit: product.unit,
 addedAt: DateTime.now(),
 );
 }

 // Mise à jour de la quantité
 OrderItem withUpdatedQuantity(int newQuantity) {
 if (newQuantity <= 0) {{
 throw ArgumentError('Quantity must be greater than 0');
}
 
 final newTotalPrice = calculateTotalPrice(newQuantity, unitPrice, discountAmount: discountAmount, taxAmount: taxAmount);
 
 return copyWith(
 quantity: newQuantity,
 totalPrice: newTotalPrice,
 );
 }

 // Application d'une remise
 OrderItem withDiscount(double discountAmount) {
 if (discountAmount < 0 || discountAmount > unitPrice) {{
 throw ArgumentError('Invalid discount amount');
}
 
 final newTotalPrice = calculateTotalPrice(quantity, unitPrice, discountAmount: discountAmount, taxAmount: taxAmount);
 
 return copyWith(
 discountAmount: discountAmount,
 totalPrice: newTotalPrice,
 );
 }

 // Application d'une taxe
 OrderItem withTax(double taxAmount) {
 if (taxAmount < 0) {{
 throw ArgumentError('Tax amount cannot be negative');
}
 
 final newTotalPrice = calculateTotalPrice(quantity, unitPrice, discountAmount: discountAmount, taxAmount: taxAmount);
 
 return copyWith(
 taxAmount: taxAmount,
 totalPrice: newTotalPrice,
 );
 }

 // Représentation textuelle pour les logs
 @override
 String toString() {
 return 'OrderItem(id: $id, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice)';
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is OrderItem && 
 other.id == id &&
 other.productId == productId &&
 other.variantId == variantId;
 }

 @override
 int get hashCode => Object.hash(id, productId, variantId);
}

// Classe pour les options personnalisées d'article
@JsonSerializable()
class OrderItemOption {
 final String id;
 final String name;
 final String value;
 final double? priceAdjustment;
 final String? type;

 const OrderItemOption({
 required this.id,
 required this.name,
 required this.value,
 this.priceAdjustment,
 this.type,
 });

 factory OrderItemOption.fromJson(Map<String, dynamic> json) => _$OrderItemOptionFromJson(json);
 Map<String, dynamic> toJson() => _$OrderItemOptionToJson(this);

 OrderItemOption copyWith({
 String? id,
 String? name,
 String? value,
 double? priceAdjustment,
 String? type,
 }) {
 return OrderItemOption(
 id: id ?? this.id,
 name: name ?? this.name,
 value: value ?? this.value,
 priceAdjustment: priceAdjustment ?? this.priceAdjustment,
 type: type ?? this.type,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is OrderItemOption && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'OrderItemOption(id: $id, name: $name, value: $value)';
 }
}

// Classe pour le résumé des articles de commande
class OrderItemSummary {
 final int totalItems;
 final int totalQuantity;
 final double subtotal;
 final double totalDiscount;
 final double totalTax;
 final double totalAmount;
 final double totalWeight;

 const OrderItemSummary({
 required this.totalItems,
 required this.totalQuantity,
 required this.subtotal,
 required this.totalDiscount,
 required this.totalTax,
 required this.totalAmount,
 required this.totalWeight,
 });

 factory OrderItemSummary.fromItems(List<OrderItem> items) {
 final totalItems = items.length;
 final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
 final subtotal = items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
 final totalDiscount = items.fold(0.0, (sum, item) => sum + (item.discountAmount ?? 0) * item.quantity);
 final totalTax = items.fold(0.0, (sum, item) => sum + (item.taxAmount ?? 0) * item.quantity);
 final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
 final totalWeight = items.fold(0.0, (sum, item) => sum + ((item.weight ?? 0) * item.quantity));

 return OrderItemSummary(
 totalItems: totalItems,
 totalQuantity: totalQuantity,
 subtotal: subtotal,
 totalDiscount: totalDiscount,
 totalTax: totalTax,
 totalAmount: totalAmount,
 totalWeight: totalWeight,
 );
 }

 String get displaySubtotal => '\$${subtotal.toStringAsFixed(2)}';
 String get displayTotalDiscount => totalDiscount > 0 ? '-\$${totalDiscount.toStringAsFixed(2)}' : '';
 String get displayTotalTax => totalTax > 0 ? '+\$${totalTax.toStringAsFixed(2)}' : '';
 String get displayTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';
 String get displayTotalWeight => totalWeight > 0 ? '${totalWeight.toStringAsFixed(2)} kg' : '';

 @override
 String toString() {
 return 'OrderItemSummary(totalItems: $totalItems, totalQuantity: $totalQuantity, totalAmount: $totalAmount)';
 }
}

