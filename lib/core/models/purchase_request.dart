import 'package:json_annotation/json_annotation.dart';

part 'purchase_request.g.dart';

@JsonSerializable()
class PurchaseRequest {
 final String id;
 final String requestNumber;
 final String title;
 final String description;
 final PurchaseRequestType type;
 final PurchaseRequestStatus status;
 final PurchaseRequestPriority priority;
 final String requesterId;
 final String requesterName;
 final String requesterDepartment;
 final String? approverId;
 final String? approverName;
 final DateTime requestDate;
 final DateTime? requiredDate;
 final DateTime? approvalDate;
 final DateTime? rejectionDate;
 final String? rejectionReason;
 final List<PurchaseRequestItem> items;
 final List<PurchaseRequestAttachment> attachments;
 final List<ApprovalStep> approvalWorkflow;
 final ApprovalStep? currentApprovalStep;
 final double totalAmount;
 final String currency;
 final String? budgetCode;
 final String? projectCode;
 final String? costCenter;
 final DeliveryInfo deliveryInfo;
 final PaymentTerms paymentTerms;
 final List<String> preferredSuppliers;
 final Map<String, dynamic> metadata;
 final DateTime createdAt;
 final DateTime updatedAt;
 final String? createdBy;
 final String? updatedBy;
 final bool isActive;

 const PurchaseRequest({
 required this.id,
 required this.requestNumber,
 required this.title,
 required this.description,
 required this.type,
 required this.status,
 required this.priority,
 required this.requesterId,
 required this.requesterName,
 required this.requesterDepartment,
 this.approverId,
 this.approverName,
 required this.requestDate,
 this.requiredDate,
 this.approvalDate,
 this.rejectionDate,
 this.rejectionReason,
 required this.items,
 required this.attachments,
 required this.approvalWorkflow,
 this.currentApprovalStep,
 required this.totalAmount,
 required this.currency,
 this.budgetCode,
 this.projectCode,
 this.costCenter,
 required this.deliveryInfo,
 required this.paymentTerms,
 required this.preferredSuppliers,
 required this.metadata,
 required this.createdAt,
 required this.updatedAt,
 this.createdBy,
 this.updatedBy,
 required this.isActive,
 });

 factory PurchaseRequest.fromJson(Map<String, dynamic> json) =>
 _$PurchaseRequestFromJson(json);
 Map<String, dynamic> toJson() => _$PurchaseRequestToJson(this);

 PurchaseRequest copyWith({
 String? id,
 String? requestNumber,
 String? title,
 String? description,
 PurchaseRequestType? type,
 PurchaseRequestStatus? status,
 PurchaseRequestPriority? priority,
 String? requesterId,
 String? requesterName,
 String? requesterDepartment,
 String? approverId,
 String? approverName,
 DateTime? requestDate,
 DateTime? requiredDate,
 DateTime? approvalDate,
 DateTime? rejectionDate,
 String? rejectionReason,
 List<PurchaseRequestItem>? items,
 List<PurchaseRequestAttachment>? attachments,
 List<ApprovalStep>? approvalWorkflow,
 ApprovalStep? currentApprovalStep,
 double? totalAmount,
 String? currency,
 String? budgetCode,
 String? projectCode,
 String? costCenter,
 DeliveryInfo? deliveryInfo,
 PaymentTerms? paymentTerms,
 List<String>? preferredSuppliers,
 Map<String, dynamic>? metadata,
 DateTime? createdAt,
 DateTime? updatedAt,
 String? createdBy,
 String? updatedBy,
 bool? isActive,
 }) {
 return PurchaseRequest(
 id: id ?? this.id,
 requestNumber: requestNumber ?? this.requestNumber,
 title: title ?? this.title,
 description: description ?? this.description,
 type: type ?? this.type,
 status: status ?? this.status,
 priority: priority ?? this.priority,
 requesterId: requesterId ?? this.requesterId,
 requesterName: requesterName ?? this.requesterName,
 requesterDepartment: requesterDepartment ?? this.requesterDepartment,
 approverId: approverId ?? this.approverId,
 approverName: approverName ?? this.approverName,
 requestDate: requestDate ?? this.requestDate,
 requiredDate: requiredDate ?? this.requiredDate,
 approvalDate: approvalDate ?? this.approvalDate,
 rejectionDate: rejectionDate ?? this.rejectionDate,
 rejectionReason: rejectionReason ?? this.rejectionReason,
 items: items ?? this.items,
 attachments: attachments ?? this.attachments,
 approvalWorkflow: approvalWorkflow ?? this.approvalWorkflow,
 currentApprovalStep: currentApprovalStep ?? this.currentApprovalStep,
 totalAmount: totalAmount ?? this.totalAmount,
 currency: currency ?? this.currency,
 budgetCode: budgetCode ?? this.budgetCode,
 projectCode: projectCode ?? this.projectCode,
 costCenter: costCenter ?? this.costCenter,
 deliveryInfo: deliveryInfo ?? this.deliveryInfo,
 paymentTerms: paymentTerms ?? this.paymentTerms,
 preferredSuppliers: preferredSuppliers ?? this.preferredSuppliers,
 metadata: metadata ?? this.metadata,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 createdBy: createdBy ?? this.createdBy,
 updatedBy: updatedBy ?? this.updatedBy,
 isActive: isActive ?? this.isActive,
 );
 }

 @override
 bool operator ==(Object other) =>
 identical(this, other) ||
 other is PurchaseRequest &&
 runtimeType == other.runtimeType &&
 id == other.id;

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'PurchaseRequest{id: $id, requestNumber: $requestNumber, status: $status}';
 }

 // Getters utilitaires
 bool get isDraft => status == PurchaseRequestStatus.draft;
 bool get isPending => status == PurchaseRequestStatus.pendingApproval;
 bool get isApproved => status == PurchaseRequestStatus.approved;
 bool get isRejected => status == PurchaseRequestStatus.rejected;
 bool get isCompleted => status == PurchaseRequestStatus.completed;
 bool get isCancelled => status == PurchaseRequestStatus.cancelled;

 bool get isOverdue {
 if (requiredDate == null) r{eturn false;
 return DateTime.now().isAfter(requiredDate!) && !isCompleted;
 }

 bool get canEdit => isDraft;
 bool get canSubmit => isDraft && items.isNotEmpty;
 bool get canApprove => isPending;
 bool get canReject => isPending;
 bool get canCancel => !isCompleted && !isCancelled;
}

@JsonSerializable()
class PurchaseRequestItem {
 final String id;
 final String productId;
 final String productName;
 final String productCode;
 final String description;
 final String category;
 final double quantity;
 final String unit;
 final double unitPrice;
 final double totalPrice;
 final String? supplierId;
 final String? supplierName;
 final Map<String, dynamic> specifications;
 final DateTime? expectedDeliveryDate;
 final String? notes;

 const PurchaseRequestItem({
 required this.id,
 required this.productId,
 required this.productName,
 required this.productCode,
 required this.description,
 required this.category,
 required this.quantity,
 required this.unit,
 required this.unitPrice,
 required this.totalPrice,
 this.supplierId,
 this.supplierName,
 required this.specifications,
 this.expectedDeliveryDate,
 this.notes,
 });

 factory PurchaseRequestItem.fromJson(Map<String, dynamic> json) =>
 _$PurchaseRequestItemFromJson(json);
 Map<String, dynamic> toJson() => _$PurchaseRequestItemToJson(this);
}

@JsonSerializable()
class PurchaseRequestAttachment {
 final String id;
 final String name;
 final String type;
 final String url;
 final double fileSize;
 final String mimeType;
 final DateTime uploadDate;
 final String uploadedBy;
 final String description;
 final bool isRequired;

 const PurchaseRequestAttachment({
 required this.id,
 required this.name,
 required this.type,
 required this.url,
 required this.fileSize,
 required this.mimeType,
 required this.uploadDate,
 required this.uploadedBy,
 required this.description,
 required this.isRequired,
 });

 factory PurchaseRequestAttachment.fromJson(Map<String, dynamic> json) =>
 _$PurchaseRequestAttachmentFromJson(json);
 Map<String, dynamic> toJson() => _$PurchaseRequestAttachmentToJson(this);
}

@JsonSerializable()
class ApprovalStep {
 final String id;
 final String name;
 final String description;
 final ApprovalType type;
 final List<String> approverIds;
 final List<String> approverNames;
 final int order;
 final bool isRequired;
 final double? minApprovalAmount;
 final DateTime? deadline;
 final ApprovalStatus status;
 final String? approvedBy;
 final String? approvedByName;
 final DateTime? approvalDate;
 final String? comments;
 final Map<String, dynamic> conditions;

 const ApprovalStep({
 required this.id,
 required this.name,
 required this.description,
 required this.type,
 required this.approverIds,
 required this.approverNames,
 required this.order,
 required this.isRequired,
 this.minApprovalAmount,
 this.deadline,
 required this.status,
 this.approvedBy,
 this.approvedByName,
 this.approvalDate,
 this.comments,
 required this.conditions,
 });

 factory ApprovalStep.fromJson(Map<String, dynamic> json) =>
 _$ApprovalStepFromJson(json);
 Map<String, dynamic> toJson() => _$ApprovalStepToJson(this);

 bool get isPending => status == ApprovalStatus.pending;
 bool get isApproved => status == ApprovalStatus.approved;
 bool get isRejected => status == ApprovalStatus.rejected;
 bool get isSkipped => status == ApprovalStatus.skipped;

 bool get isOverdue {
 if (deadline == null) r{eturn false;
 return DateTime.now().isAfter(deadline!) && isPending;
 }
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
 final String? contactEmail;
 final DateTime? requestedDeliveryDate;
 final String? deliveryInstructions;
 final bool requiresAppointment;
 final List<String> availableDeliveryTimes;

 const DeliveryInfo({
 required this.id,
 required this.address,
 required this.city,
 required this.country,
 required this.postalCode,
 this.contactPerson,
 this.contactPhone,
 this.contactEmail,
 this.requestedDeliveryDate,
 this.deliveryInstructions,
 required this.requiresAppointment,
 required this.availableDeliveryTimes,
 });

 factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
 _$DeliveryInfoFromJson(json);
 Map<String, dynamic> toJson() => _$DeliveryInfoToJson(this);
}

@JsonSerializable()
class PaymentTerms {
 final String id;
 final String name;
 final int paymentDays;
 final PaymentMethod paymentMethod;
 final double? depositPercentage;
 final String? bankAccount;
 final String? bankName;
 final String? swiftCode;
 final String? iban;

 const PaymentTerms({
 required this.id,
 required this.name,
 required this.paymentDays,
 required this.paymentMethod,
 this.depositPercentage,
 this.bankAccount,
 this.bankName,
 this.swiftCode,
 this.iban,
 });

 factory PaymentTerms.fromJson(Map<String, dynamic> json) =>
 _$PaymentTermsFromJson(json);
 Map<String, dynamic> toJson() => _$PaymentTermsToJson(this);
}

enum PurchaseRequestType {
 @JsonValue('STANDARD')
 standard,
 @JsonValue('URGENT')
 urgent,
 @JsonValue('CONTRACT')
 contract,
 @JsonValue('SERVICE')
 service,
 @JsonValue('ASSET')
 asset,
}

enum PurchaseRequestStatus {
 @JsonValue('DRAFT')
 draft,
 @JsonValue('PENDING_APPROVAL')
 pendingApproval,
 @JsonValue('APPROVED')
 approved,
 @JsonValue('REJECTED')
 rejected,
 @JsonValue('COMPLETED')
 completed,
 @JsonValue('CANCELLED')
 cancelled,
 @JsonValue('ON_HOLD')
 onHold,
}

enum PurchaseRequestPriority {
 @JsonValue('LOW')
 low,
 @JsonValue('MEDIUM')
 medium,
 @JsonValue('HIGH')
 high,
 @JsonValue('CRITICAL')
 critical,
}

enum ApprovalType {
 @JsonValue('SINGLE')
 single,
 @JsonValue('MAJORITY')
 majority,
 @JsonValue('UNANIMOUS')
 unanimous,
 @JsonValue('SEQUENTIAL')
 sequential,
}

enum ApprovalStatus {
 @JsonValue('PENDING')
 pending,
 @JsonValue('APPROVED')
 approved,
 @JsonValue('REJECTED')
 rejected,
 @JsonValue('SKIPPED')
 skipped,
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
