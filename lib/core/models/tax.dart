import 'package:json_annotation/json_annotation.dart';

part 'tax.g.dart';

@JsonSerializable()
class TaxDeclaration {
 final String id;
 final String companyId;
 final String declarationType;
 final String taxPeriod;
 final DateTime startDate;
 final DateTime endDate;
 final DateTime submissionDate;
 final DateTime? dueDate;
 final TaxStatus status;
 final double totalTaxAmount;
 final double totalRevenue;
 final double totalDeductibleExpenses;
 final double totalVATCollected;
 final double totalVATPaid;
 final double totalCorporateTax;
 final double totalWithholdingTax;
 final List<TaxItem> taxItems;
 final List<TaxDocument> documents;
 final String? submittedBy;
 final String? approvedBy;
 final DateTime? approvedAt;
 final String? notes;
 final DateTime createdAt;
 final DateTime updatedAt;

 const TaxDeclaration({
 required this.id,
 required this.companyId,
 required this.declarationType,
 required this.taxPeriod,
 required this.startDate,
 required this.endDate,
 required this.submissionDate,
 this.dueDate,
 required this.status,
 required this.totalTaxAmount,
 required this.totalRevenue,
 required this.totalDeductibleExpenses,
 required this.totalVATCollected,
 required this.totalVATPaid,
 required this.totalCorporateTax,
 required this.totalWithholdingTax,
 required this.taxItems,
 required this.documents,
 this.submittedBy,
 this.approvedBy,
 this.approvedAt,
 this.notes,
 required this.createdAt,
 required this.updatedAt,
 });

 factory TaxDeclaration.fromJson(Map<String, dynamic> json) =>
 _$TaxDeclarationFromJson(json);

 Map<String, dynamic> toJson() => _$TaxDeclarationToJson(this);

 TaxDeclaration copyWith({
 String? id,
 String? companyId,
 String? declarationType,
 String? taxPeriod,
 DateTime? startDate,
 DateTime? endDate,
 DateTime? submissionDate,
 DateTime? dueDate,
 TaxStatus? status,
 double? totalTaxAmount,
 double? totalRevenue,
 double? totalDeductibleExpenses,
 double? totalVATCollected,
 double? totalVATPaid,
 double? totalCorporateTax,
 double? totalWithholdingTax,
 List<TaxItem>? taxItems,
 List<TaxDocument>? documents,
 String? submittedBy,
 String? approvedBy,
 DateTime? approvedAt,
 String? notes,
 DateTime? createdAt,
 DateTime? updatedAt,
 }) {
 return TaxDeclaration(
 id: id ?? this.id,
 companyId: companyId ?? this.companyId,
 declarationType: declarationType ?? this.declarationType,
 taxPeriod: taxPeriod ?? this.taxPeriod,
 startDate: startDate ?? this.startDate,
 endDate: endDate ?? this.endDate,
 submissionDate: submissionDate ?? this.submissionDate,
 dueDate: dueDate ?? this.dueDate,
 status: status ?? this.status,
 totalTaxAmount: totalTaxAmount ?? this.totalTaxAmount,
 totalRevenue: totalRevenue ?? this.totalRevenue,
 totalDeductibleExpenses: totalDeductibleExpenses ?? this.totalDeductibleExpenses,
 totalVATCollected: totalVATCollected ?? this.totalVATCollected,
 totalVATPaid: totalVATPaid ?? this.totalVATPaid,
 totalCorporateTax: totalCorporateTax ?? this.totalCorporateTax,
 totalWithholdingTax: totalWithholdingTax ?? this.totalWithholdingTax,
 taxItems: taxItems ?? this.taxItems,
 documents: documents ?? this.documents,
 submittedBy: submittedBy ?? this.submittedBy,
 approvedBy: approvedBy ?? this.approvedBy,
 approvedAt: approvedAt ?? this.approvedAt,
 notes: notes ?? this.notes,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 );
 }

 bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);
 bool get isSubmitted => status == TaxStatus.submitted || status == TaxStatus.approved || status == TaxStatus.rejected;
 bool get isApproved => status == TaxStatus.approved;
 int get daysUntilDue {
 if (dueDate == null) r{eturn -1;
 return dueDate!.difference(DateTime.now()).inDays;
 }

 String get statusText {
 switch (status) {
 case TaxStatus.draft:
 return 'Brouillon';
 case TaxStatus.pending:
 return 'En attente';
 case TaxStatus.submitted:
 return 'Soumis';
 case TaxStatus.underReview:
 return 'En révision';
 case TaxStatus.approved:
 return 'Approuvé';
 case TaxStatus.rejected:
 return 'Rejeté';
 case TaxStatus.paid:
 return 'Payé';
}
 }
}

enum TaxStatus {
 @JsonValue('draft')
 draft,
 @JsonValue('pending')
 pending,
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

@JsonSerializable()
class TaxItem {
 final String id;
 final String declarationId;
 final String category;
 final String description;
 final double amount;
 final double taxRate;
 final double taxAmount;
 final TaxItemType type;
 final DateTime date;
 final String? reference;

 const TaxItem({
 required this.id,
 required this.declarationId,
 required this.category,
 required this.description,
 required this.amount,
 required this.taxRate,
 required this.taxAmount,
 required this.type,
 required this.date,
 this.reference,
 });

 factory TaxItem.fromJson(Map<String, dynamic> json) =>
 _$TaxItemFromJson(json);

 Map<String, dynamic> toJson() => _$TaxItemToJson(this);

 String get typeText {
 switch (type) {
 case TaxItemType.revenue:
 return 'Revenu';
 case TaxItemType.expense:
 return 'Dépense';
 case TaxItemType.deductible:
 return 'Déductible';
 case TaxItemType.nonDeductible:
 return 'Non déductible';
 case TaxItemType.vatCollected:
 return 'TVA collectée';
 case TaxItemType.vatPaid:
 return 'TVA payée';
 case TaxItemType.withholdingTax:
 return 'Retenue à la source';
 case TaxItemType.corporateTax:
 return 'Impôt sur les sociétés';
}
 }
}

enum TaxItemType {
 @JsonValue('revenue')
 revenue,
 @JsonValue('expense')
 expense,
 @JsonValue('deductible')
 deductible,
 @JsonValue('non_deductible')
 nonDeductible,
 @JsonValue('vat_collected')
 vatCollected,
 @JsonValue('vat_paid')
 vatPaid,
 @JsonValue('withholding_tax')
 withholdingTax,
 @JsonValue('corporate_tax')
 corporateTax,
}

@JsonSerializable()
class TaxDocument {
 final String id;
 final String declarationId;
 final String name;
 final String type;
 final String url;
 final int size;
 final DateTime uploadedAt;
 final String? uploadedBy;

 const TaxDocument({
 required this.id,
 required this.declarationId,
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
 if (size < 1024) r{eturn '${size}B';
 if (size < 1024 * 1024) r{eturn '${(size / 1024).toStringAsFixed(1)}KB';
 return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
 }
}
