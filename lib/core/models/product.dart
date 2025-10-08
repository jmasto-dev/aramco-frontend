import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
 final String id;
 final String name;
 final String description;
 final double price;
 final int stock;
 final String category;
 final List<String> images;
 final bool isActive;
 final DateTime createdAt;
 final DateTime? updatedAt;
 final Map<String, dynamic>? attributes;
 final String? sku;
 final double? weight;
 final String? unit;
 final int? minOrderQuantity;
 final double? discountPrice;
 final List<String>? tags;

 const Product({
 required this.id,
 required this.name,
 required this.description,
 required this.price,
 required this.stock,
 required this.category,
 required this.images,
 required this.isActive,
 required this.createdAt,
 this.updatedAt,
 this.attributes,
 this.sku,
 this.weight,
 this.unit,
 this.minOrderQuantity,
 this.discountPrice,
 this.tags,
 });

 factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
 Map<String, dynamic> toJson() => _$ProductToJson(this);

 Product copyWith({
 String? id,
 String? name,
 String? description,
 double? price,
 int? stock,
 String? category,
 List<String>? images,
 bool? isActive,
 DateTime? createdAt,
 DateTime? updatedAt,
 Map<String, dynamic>? attributes,
 String? sku,
 double? weight,
 String? unit,
 int? minOrderQuantity,
 double? discountPrice,
 List<String>? tags,
 }) {
 return Product(
 id: id ?? this.id,
 name: name ?? this.name,
 description: description ?? this.description,
 price: price ?? this.price,
 stock: stock ?? this.stock,
 category: category ?? this.category,
 images: images ?? this.images,
 isActive: isActive ?? this.isActive,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 attributes: attributes ?? this.attributes,
 sku: sku ?? this.sku,
 weight: weight ?? this.weight,
 unit: unit ?? this.unit,
 minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
 discountPrice: discountPrice ?? this.discountPrice,
 tags: tags ?? this.tags,
 );
 }

 // Getters utilitaires
 bool get isInStock => stock > 0;
 bool get isLowStock => stock > 0 && stock <= 5;
 bool get hasDiscount => discountPrice != null && discountPrice! < price;
 double get effectivePrice => hasDiscount ? discountPrice! : price;
 String get displayName => name;
 String get displayPrice => '\$${effectivePrice.toStringAsFixed(2)}';
 String get displayStock => '$stock ${unit ?? 'units'}';

 // Validation
 bool get isValid => id.isNotEmpty && name.isNotEmpty && price >= 0 && stock >= 0;
 
 // Méthodes de vérification
 bool canOrderQuantity(int quantity) {
 final minQty = minOrderQuantity ?? 1;
 return quantity >= minQty && quantity <= stock;
 }

 int getMaxOrderableQuantity() {
 final minQty = minOrderQuantity ?? 1;
 return stock >= minQty ? stock : 0;
 }

 // Recherche
 bool matchesQuery(String query) {
 final lowerQuery = query.toLowerCase();
 return name.toLowerCase().contains(lowerQuery) ||
 description.toLowerCase().contains(lowerQuery) ||
 category.toLowerCase().contains(lowerQuery) ||
 (sku?.toLowerCase().contains(lowerQuery) ?? false) ||
 (tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false);
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is Product && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'Product(id: $id, name: $name, price: $price, stock: $stock)';
 }
}

@JsonSerializable()
class ProductVariant {
 final String id;
 final String productId;
 final String name;
 final double? priceAdjustment;
 final int? stock;
 final Map<String, dynamic>? attributes;
 final List<String>? images;

 const ProductVariant({
 required this.id,
 required this.productId,
 required this.name,
 this.priceAdjustment,
 this.stock,
 this.attributes,
 this.images,
 });

 factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
 Map<String, dynamic> toJson() => _$ProductVariantToJson(this);

 ProductVariant copyWith({
 String? id,
 String? productId,
 String? name,
 double? priceAdjustment,
 int? stock,
 Map<String, dynamic>? attributes,
 List<String>? images,
 }) {
 return ProductVariant(
 id: id ?? this.id,
 productId: productId ?? this.productId,
 name: name ?? this.name,
 priceAdjustment: priceAdjustment ?? this.priceAdjustment,
 stock: stock ?? this.stock,
 attributes: attributes ?? this.attributes,
 images: images ?? this.images,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is ProductVariant && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'ProductVariant(id: $id, name: $name, productId: $productId)';
 }
}

@JsonSerializable()
class ProductCategory {
 final String id;
 final String name;
 final String? description;
 final String? parentId;
 final List<String>? childrenIds;
 final String? image;
 final bool isActive;
 final int sortOrder;

 const ProductCategory({
 required this.id,
 required this.name,
 this.description,
 this.parentId,
 this.childrenIds,
 this.image,
 required this.isActive,
 required this.sortOrder,
 });

 factory ProductCategory.fromJson(Map<String, dynamic> json) => _$ProductCategoryFromJson(json);
 Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);

 ProductCategory copyWith({
 String? id,
 String? name,
 String? description,
 String? parentId,
 List<String>? childrenIds,
 String? image,
 bool? isActive,
 int? sortOrder,
 }) {
 return ProductCategory(
 id: id ?? this.id,
 name: name ?? this.name,
 description: description ?? this.description,
 parentId: parentId ?? this.parentId,
 childrenIds: childrenIds ?? this.childrenIds,
 image: image ?? this.image,
 isActive: isActive ?? this.isActive,
 sortOrder: sortOrder ?? this.sortOrder,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is ProductCategory && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'ProductCategory(id: $id, name: $name)';
 }
}
