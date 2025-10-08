import 'package:json_annotation/json_annotation.dart';

part 'supplier.g.dart';

@JsonSerializable()
class Supplier {
 final String id;
 final String name;
 final String contactPerson;
 final String email;
 final String phone;
 final String address;
 final String city;
 final String country;
 final String postalCode;
 final String taxId;
 final String registrationNumber;
 final SupplierCategory category;
 final SupplierStatus status;
 final List<String> productCategories;
 final List<SupplierDocument> documents;
 final List<SupplierContact> contacts;
 final PaymentTerms paymentTerms;
 final DeliveryInfo deliveryInfo;
 final List<SupplierRating> ratings;
 final double averageRating;
 final DateTime createdAt;
 final DateTime updatedAt;
 final String? createdBy;
 final String? updatedBy;
 final Map<String, dynamic> metadata;
 final bool isActive;
 final List<String> tags;

 const Supplier({
 required this.id,
 required this.name,
 required this.contactPerson,
 required this.email,
 required this.phone,
 required this.address,
 required this.city,
 required this.country,
 required this.postalCode,
 required this.taxId,
 required this.registrationNumber,
 required this.category,
 required this.status,
 required this.productCategories,
 required this.documents,
 required this.contacts,
 required this.paymentTerms,
 required this.deliveryInfo,
 required this.ratings,
 required this.averageRating,
 required this.createdAt,
 required this.updatedAt,
 this.createdBy,
 this.updatedBy,
 required this.metadata,
 required this.isActive,
 required this.tags,
 });

 factory Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);
 Map<String, dynamic> toJson() => _$SupplierToJson(this);

 Supplier copyWith({
 String? id,
 String? name,
 String? contactPerson,
 String? email,
 String? phone,
 String? address,
 String? city,
 String? country,
 String? postalCode,
 String? taxId,
 String? registrationNumber,
 SupplierCategory? category,
 SupplierStatus? status,
 List<String>? productCategories,
 List<SupplierDocument>? documents,
 List<SupplierContact>? contacts,
 PaymentTerms? paymentTerms,
 DeliveryInfo? deliveryInfo,
 List<SupplierRating>? ratings,
 double? averageRating,
 DateTime? createdAt,
 DateTime? updatedAt,
 String? createdBy,
 String? updatedBy,
 Map<String, dynamic>? metadata,
 bool? isActive,
 List<String>? tags,
 }) {
 return Supplier(
 id: id ?? this.id,
 name: name ?? this.name,
 contactPerson: contactPerson ?? this.contactPerson,
 email: email ?? this.email,
 phone: phone ?? this.phone,
 address: address ?? this.address,
 city: city ?? this.city,
 country: country ?? this.country,
 postalCode: postalCode ?? this.postalCode,
 taxId: taxId ?? this.taxId,
 registrationNumber: registrationNumber ?? this.registrationNumber,
 category: category ?? this.category,
 status: status ?? this.status,
 productCategories: productCategories ?? this.productCategories,
 documents: documents ?? this.documents,
 contacts: contacts ?? this.contacts,
 paymentTerms: paymentTerms ?? this.paymentTerms,
 deliveryInfo: deliveryInfo ?? this.deliveryInfo,
 ratings: ratings ?? this.ratings,
 averageRating: averageRating ?? this.averageRating,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 createdBy: createdBy ?? this.createdBy,
 updatedBy: updatedBy ?? this.updatedBy,
 metadata: metadata ?? this.metadata,
 isActive: isActive ?? this.isActive,
 tags: tags ?? this.tags,
 );
 }

 @override
 bool operator ==(Object other) =>
 identical(this, other) ||
 other is Supplier &&
 runtimeType == other.runtimeType &&
 id == other.id;

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'Supplier{id: $id, name: $name, status: $status}';
 }
}

@JsonSerializable()
class SupplierDocument {
 final String id;
 final String name;
 final String type;
 final String url;
 final DateTime uploadDate;
 final DateTime? expiryDate;
 final String uploadedBy;
 final bool isVerified;
 final DateTime? verifiedAt;
 final String? verifiedBy;
 final double fileSize;
 final String mimeType;

 const SupplierDocument({
 required this.id,
 required this.name,
 required this.type,
 required this.url,
 required this.uploadDate,
 this.expiryDate,
 required this.uploadedBy,
 required this.isVerified,
 this.verifiedAt,
 this.verifiedBy,
 required this.fileSize,
 required this.mimeType,
 });

 factory SupplierDocument.fromJson(Map<String, dynamic> json) =>
 _$SupplierDocumentFromJson(json);
 Map<String, dynamic> toJson() => _$SupplierDocumentToJson(this);

 bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
 bool get isExpiringSoon {
 if (expiryDate == null) r{eturn false;
 final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
 return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
 }
}

@JsonSerializable()
class SupplierContact {
 final String id;
 final String name;
 final String position;
 final String email;
 final String phone;
 final String? mobile;
 final bool isPrimary;
 final ContactType type;

 const SupplierContact({
 required this.id,
 required this.name,
 required this.position,
 required this.email,
 required this.phone,
 this.mobile,
 required this.isPrimary,
 required this.type,
 });

 factory SupplierContact.fromJson(Map<String, dynamic> json) =>
 _$SupplierContactFromJson(json);
 Map<String, dynamic> toJson() => _$SupplierContactToJson(this);
}

@JsonSerializable()
class PaymentTerms {
 final String id;
 final String name;
 final int paymentDays;
 final PaymentMethod paymentMethod;
 final String? bankAccount;
 final String? bankName;
 final String? swiftCode;
 final String? iban;
 final double? creditLimit;
 final String? currency;

 const PaymentTerms({
 required this.id,
 required this.name,
 required this.paymentDays,
 required this.paymentMethod,
 this.bankAccount,
 this.bankName,
 this.swiftCode,
 this.iban,
 this.creditLimit,
 this.currency,
 });

 factory PaymentTerms.fromJson(Map<String, dynamic> json) =>
 _$PaymentTermsFromJson(json);
 Map<String, dynamic> toJson() => _$PaymentTermsToJson(this);
}

@JsonSerializable()
class DeliveryInfo {
 final String id;
 final String address;
 final String city;
 final String country;
 final String postalCode;
 final String? contactPerson;
 final String? contactPhone;
 final List<String> deliveryDays;
 final int leadTimeDays;
 final String? specialInstructions;
 final bool requiresAppointment;

 const DeliveryInfo({
 required this.id,
 required this.address,
 required this.city,
 required this.country,
 required this.postalCode,
 this.contactPerson,
 this.contactPhone,
 required this.deliveryDays,
 required this.leadTimeDays,
 this.specialInstructions,
 required this.requiresAppointment,
 });

 factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
 _$DeliveryInfoFromJson(json);
 Map<String, dynamic> toJson() => _$DeliveryInfoToJson(this);
}

@JsonSerializable()
class SupplierRating {
 final String id;
 final String orderId;
 final double rating;
 final String? comment;
 final List<String> criteria;
 final Map<String, double> criteriaRatings;
 final DateTime createdAt;
 final String createdBy;

 const SupplierRating({
 required this.id,
 required this.orderId,
 required this.rating,
 this.comment,
 required this.criteria,
 required this.criteriaRatings,
 required this.createdAt,
 required this.createdBy,
 });

 factory SupplierRating.fromJson(Map<String, dynamic> json) =>
 _$SupplierRatingFromJson(json);
 Map<String, dynamic> toJson() => _$SupplierRatingToJson(this);
}

enum SupplierCategory {
 @JsonValue('RAW_MATERIALS')
 rawMaterials,
 @JsonValue('EQUIPMENT')
 equipment,
 @JsonValue('SERVICES')
 services,
 @JsonValue('CONSUMABLES')
 consumables,
 @JsonValue('TECHNOLOGY')
 technology,
 @JsonValue('LOGISTICS')
 logistics,
 @JsonValue('CONSULTING')
 consulting,
 @JsonValue('OTHER')
 other,
}

enum SupplierStatus {
 @JsonValue('ACTIVE')
 active,
 @JsonValue('INACTIVE')
 inactive,
 @JsonValue('PENDING_VERIFICATION')
 pendingVerification,
 @JsonValue('SUSPENDED')
 suspended,
 @JsonValue('BLACKLISTED')
 blacklisted,
 @JsonValue('UNDER_REVIEW')
 underReview,
}

enum ContactType {
 @JsonValue('SALES')
 sales,
 @JsonValue('TECHNICAL')
 technical,
 @JsonValue('FINANCIAL')
 financial,
 @JsonValue('LOGISTICS')
 logistics,
 @JsonValue('GENERAL')
 general,
}

enum PaymentMethod {
 @JsonValue('BANK_TRANSFER')
 bankTransfer,
 @JsonValue('CREDIT_CARD')
 creditCard,
 @JsonValue('CHECK')
 check,
 @JsonValue('CASH')
 cash,
 @JsonValue('ONLINE')
 online,
}
