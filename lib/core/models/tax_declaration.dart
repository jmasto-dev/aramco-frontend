import 'package:json_annotation/json_annotation.dart';

part 'tax_declaration.g.dart';

enum TaxDeclarationType {
 @JsonValue('vat')
 vat,
 @JsonValue('corporate_tax')
 corporateTax,
 @JsonValue('income_tax')
 incomeTax,
 @JsonValue('property_tax')
 propertyTax,
 @JsonValue('other')
 other,
}

enum TaxDeclarationStatus {
 @JsonValue('draft')
 draft,
 @JsonValue('submitted')
 submitted,
 @JsonValue('under_review')
 underReview,
 @JsonValue('approved')
 approved,
 @JsonValue('rejected')
 rejected,
 @JsonValue('paid')
 paid,
}

enum TaxPeriod {
 @JsonValue('monthly')
 monthly,
 @JsonValue('quarterly')
 quarterly,
 @JsonValue('semi_annual')
 semiAnnual,
 @JsonValue('annual')
 annual,
}

@JsonSerializable()
class TaxDeclaration {
 final String id;
 final String declarationNumber;
 final TaxDeclarationType type;
 final TaxDeclarationStatus status;
 final TaxPeriod period;
 final DateTime startDate;
 final DateTime endDate;
 final DateTime submissionDate;
 final DateTime? dueDate;
 final DateTime? paymentDate;
 final double totalAmount;
 final double taxAmount;
 final double baseAmount;
 final String currency;
 final String? description;
 final List<TaxDeclarationItem> items;
 final List<TaxDocument> documents;
 final String? submittedBy;
 final String? approvedBy;
 final String? notes;
 final DateTime createdAt;
 final DateTime updatedAt;

 const TaxDeclaration({
 required this.id,
 required this.declarationNumber,
 required this.type,
 required this.status,
 required this.period,
 required this.startDate,
 required this.endDate,
 required this.submissionDate,
 this.dueDate,
 this.paymentDate,
 required this.totalAmount,
 required this.taxAmount,
 required this.baseAmount,
 this.currency = 'EUR',
 this.description,
 this.items = const [],
 this.documents = const [],
 this.submittedBy,
 this.approvedBy,
 this.notes,
 required this.createdAt,
 required this.updatedAt,
 });

 factory TaxDeclaration.fromJson(Map<String, dynamic> json) =>
 _$TaxDeclarationFromJson(json);

 Map<String, dynamic> toJson() => _$TaxDeclarationToJson(this);

 TaxDeclaration copyWith({
 String? id,
 String? declarationNumber,
 TaxDeclarationType? type,
 TaxDeclarationStatus? status,
 TaxPeriod? period,
 DateTime? startDate,
 DateTime? endDate,
 DateTime? submissionDate,
 DateTime? dueDate,
 DateTime? paymentDate,
 double? totalAmount,
 double? taxAmount,
 double? baseAmount,
 String? currency,
 String? description,
 List<TaxDeclarationItem>? items,
 List<TaxDocument>? documents,
 String? submittedBy,
 String? approvedBy,
 String? notes,
 DateTime? createdAt,
 DateTime? updatedAt,
 }) {
 return TaxDeclaration(
 id: id ?? this.id,
 declarationNumber: declarationNumber ?? this.declarationNumber,
 type: type ?? this.type,
 status: status ?? this.status,
 period: period ?? this.period,
 startDate: startDate ?? this.startDate,
 endDate: endDate ?? this.endDate,
 submissionDate: submissionDate ?? this.submissionDate,
 dueDate: dueDate ?? this.dueDate,
 paymentDate: paymentDate ?? this.paymentDate,
 totalAmount: totalAmount ?? this.totalAmount,
 taxAmount: taxAmount ?? this.taxAmount,
 baseAmount: baseAmount ?? this.baseAmount,
 currency: currency ?? this.currency,
 description: description ?? this.description,
 items: items ?? this.items,
 documents: documents ?? this.documents,
 submittedBy: submittedBy ?? this.submittedBy,
 approvedBy: approvedBy ?? this.approvedBy,
 notes: notes ?? this.notes,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 );
 }

 // Getters
 String get typeText {
 switch (type) {
 case TaxDeclarationType.vat:
 return 'TVA';
 case TaxDeclarationType.corporateTax:
 return 'Impôt sur les sociétés';
 case TaxDeclarationType.incomeTax:
 return 'Impôt sur le revenu';
 case TaxDeclarationType.propertyTax:
 return 'Taxe foncière';
 case TaxDeclarationType.other:
 return 'Autre';
}
 }

 String get statusText {
 switch (status) {
 case TaxDeclarationStatus.draft:
 return 'Brouillon';
 case TaxDeclarationStatus.submitted:
 return 'Soumis';
 case TaxDeclarationStatus.underReview:
 return 'En cours de révision';
 case TaxDeclarationStatus.approved:
 return 'Approuvé';
 case TaxDeclarationStatus.rejected:
 return 'Rejeté';
 case TaxDeclarationStatus.paid:
 return 'Payé';
}
 }

 String get periodText {
 switch (period) {
 case TaxPeriod.monthly:
 return 'Mensuel';
 case TaxPeriod.quarterly:
 return 'Trimestriel';
 case TaxPeriod.semiAnnual:
 return 'Semestriel';
 case TaxPeriod.annual:
 return 'Annuel';
}
 }

 bool get isOverdue {
 if (dueDate == null) r{eturn false;
 return DateTime.now().isAfter(dueDate!) && 
 status != TaxDeclarationStatus.paid;
 }

 bool get isPendingPayment {
 return status == TaxDeclarationStatus.approved && paymentDate == null;
 }

 int get daysUntilDue {
 if (dueDate == null) r{eturn -1;
 return dueDate!.difference(DateTime.now()).inDays;
 }
}

@JsonSerializable()
class TaxDeclarationItem {
 final String id;
 final String description;
 final double amount;
 final double taxRate;
 final double taxAmount;
 final String category;
 final Map<String, dynamic>? metadata;

 const TaxDeclarationItem({
 required this.id,
 required this.description,
 required this.amount,
 required this.taxRate,
 required this.taxAmount,
 required this.category,
 this.metadata,
 });

 factory TaxDeclarationItem.fromJson(Map<String, dynamic> json) =>
 _$TaxDeclarationItemFromJson(json);

 Map<String, dynamic> toJson() => _$TaxDeclarationItemToJson(this);
}

@JsonSerializable()
class TaxDocument {
 final String id;
 final String name;
 final String type;
 final String url;
 final int size;
 final DateTime uploadedAt;
 final String? uploadedBy;

 const TaxDocument({
 required this.id,
 required this.name,
 required this.type,
 required this.url,
 required this.size,
 required this.uploadedAt,
 this.uploadedBy,
 });

 factory TaxDocument.fromJson(Map<String, dynamic> json) =>
 _$TaxDocumentFromJson(json);

 Map<String, dynamic> toJson() => _$TaxDocumentToJson(this);

 String get formattedSize {
 if (size < 1024) r{eturn '$size B';
 if (size < 1024 * 1024) r{eturn '${(size / 1024).toStringAsFixed(1)} KB';
 return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
 }
}

@JsonSerializable()
class TaxRate {
 final String id;
 final String name;
 final double rate;
 final String description;
 final bool isActive;
 final DateTime? validFrom;
 final DateTime? validTo;
 final DateTime createdAt;
 final DateTime updatedAt;

 const TaxRate({
 required this.id,
 required this.name,
 required this.rate,
 required this.description,
 required this.isActive,
 this.validFrom,
 this.validTo,
 required this.createdAt,
 required this.updatedAt,
 });

 factory TaxRate.fromJson(Map<String, dynamic> json) =>
 _$TaxRateFromJson(json);

 Map<String, dynamic> toJson() => _$TaxRateToJson(this);

 String get percentageText => '${(rate * 100).toStringAsFixed(2)}%';

 bool get isValid {
 final now = DateTime.now();
 if (validFrom != null && now.isBefore(validFrom!)){ return false;
 if (validTo != null && now.isAfter(validTo!)){ return false;
 return isActive;
 }
}

@JsonSerializable()
class TaxPayment {
 final String id;
 final String declarationId;
 final double amount;
 final DateTime paymentDate;
 final String paymentMethod;
 final String? transactionId;
 final String? reference;
 final String status;
 final String? notes;
 final DateTime createdAt;

 const TaxPayment({
 required this.id,
 required this.declarationId,
 required this.amount,
 required this.paymentDate,
 required this.paymentMethod,
 this.transactionId,
 this.reference,
 required this.status,
 this.notes,
 required this.createdAt,
 });

 factory TaxPayment.fromJson(Map<String, dynamic> json) =>
 _$TaxPaymentFromJson(json);

 Map<String, dynamic> toJson() => _$TaxPaymentToJson(this);
}

