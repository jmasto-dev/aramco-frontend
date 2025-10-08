import 'package:json_annotation/json_annotation.dart';

part 'payslip.g.dart';

@JsonSerializable()
class Payslip {
 final String id;
 final String employeeId;
 final String employeeName;
 final String employeeMatricule;
 final String department;
 final String position;
 final PayslipPeriod period;
 final DateTime issueDate;
 final DateTime paymentDate;
 final PayslipAmounts amounts;
 final List<PayslipEarning> earnings;
 final List<PayslipDeduction> deductions;
 final List<PayslipContribution> contributions;
 final PayslipSummary summary;
 final String currency;
 final String status;
 final String? pdfUrl;
 final List<String> attachments;
 final Map<String, dynamic>? metadata;
 final DateTime createdAt;
 final DateTime? updatedAt;

 const Payslip({
 required this.id,
 required this.employeeId,
 required this.employeeName,
 required this.employeeMatricule,
 required this.department,
 required this.position,
 required this.period,
 required this.issueDate,
 required this.paymentDate,
 required this.amounts,
 required this.earnings,
 required this.deductions,
 required this.contributions,
 required this.summary,
 this.currency = 'EUR',
 required this.status,
 this.pdfUrl,
 this.attachments = const [],
 this.metadata,
 required this.createdAt,
 this.updatedAt,
 });

 factory Payslip.fromJson(Map<String, dynamic> json) => _$PayslipFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipToJson(this);

 Payslip copyWith({
 String? id,
 String? employeeId,
 String? employeeName,
 String? employeeMatricule,
 String? department,
 String? position,
 PayslipPeriod? period,
 DateTime? issueDate,
 DateTime? paymentDate,
 PayslipAmounts? amounts,
 List<PayslipEarning>? earnings,
 List<PayslipDeduction>? deductions,
 List<PayslipContribution>? contributions,
 PayslipSummary? summary,
 String? currency,
 String? status,
 String? pdfUrl,
 List<String>? attachments,
 Map<String, dynamic>? metadata,
 DateTime? createdAt,
 DateTime? updatedAt,
 }) {
 return Payslip(
 id: id ?? this.id,
 employeeId: employeeId ?? this.employeeId,
 employeeName: employeeName ?? this.employeeName,
 employeeMatricule: employeeMatricule ?? this.employeeMatricule,
 department: department ?? this.department,
 position: position ?? this.position,
 period: period ?? this.period,
 issueDate: issueDate ?? this.issueDate,
 paymentDate: paymentDate ?? this.paymentDate,
 amounts: amounts ?? this.amounts,
 earnings: earnings ?? this.earnings,
 deductions: deductions ?? this.deductions,
 contributions: contributions ?? this.contributions,
 summary: summary ?? this.summary,
 currency: currency ?? this.currency,
 status: status ?? this.status,
 pdfUrl: pdfUrl ?? this.pdfUrl,
 attachments: attachments ?? this.attachments,
 metadata: metadata ?? this.metadata,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 );
 }

 // Getters calculés
 String get formattedIssueDate => _formatDate(issueDate);
 String get formattedPaymentDate => _formatDate(paymentDate);
 String get formattedPeriod => '${period.month}/${period.year}';
 String get formattedNetAmount => '${summary.netAmount.toStringAsFixed(2)} $currency';
 String get formattedGrossAmount => '${summary.grossAmount.toStringAsFixed(2)} $currency';
 
 bool get isPaid => status == 'paid';
 bool get isPending => status == 'pending';
 bool get isCancelled => status == 'cancelled';
 bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
 bool get hasAttachments => attachments.isNotEmpty;

 String get statusDisplay {
 switch (status) {
 case 'paid':
 return 'Payée';
 case 'pending':
 return 'En attente';
 case 'cancelled':
 return 'Annulée';
 default:
 return status;
}
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is Payslip && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'Payslip(id: $id, employeeName: $employeeName, period: $formattedPeriod, netAmount: $formattedNetAmount)';
 }
}

@JsonSerializable()
class PayslipPeriod {
 final int month;
 final int year;
 final DateTime startDate;
 final DateTime endDate;

 const PayslipPeriod({
 required this.month,
 required this.year,
 required this.startDate,
 required this.endDate,
 });

 factory PayslipPeriod.fromJson(Map<String, dynamic> json) => _$PayslipPeriodFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipPeriodToJson(this);

 String get monthName {
 const months = [
 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
 ];
 return months[month - 1];
 }

 String get display => '$monthName $year';

 @override
 String toString() => display;
}

@JsonSerializable()
class PayslipAmounts {
 final double baseSalary;
 final double overtimeHours;
 final double overtimeAmount;
 final double bonuses;
 final double allowances;
 final double commissions;
 final double otherEarnings;
 final double grossEarnings;
 final double socialSecurity;
 final double incomeTax;
 final double otherDeductions;
 final double totalDeductions;
 final double netAmount;

 const PayslipAmounts({
 required this.baseSalary,
 required this.overtimeHours,
 required this.overtimeAmount,
 required this.bonuses,
 required this.allowances,
 required this.commissions,
 required this.otherEarnings,
 required this.grossEarnings,
 required this.socialSecurity,
 required this.incomeTax,
 required this.otherDeductions,
 required this.totalDeductions,
 required this.netAmount,
 });

 factory PayslipAmounts.fromJson(Map<String, dynamic> json) => _$PayslipAmountsFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipAmountsToJson(this);

 String get formattedBaseSalary => '${baseSalary.toStringAsFixed(2)} €';
 String get formattedOvertimeAmount => '${overtimeAmount.toStringAsFixed(2)} €';
 String get formattedGrossEarnings => '${grossEarnings.toStringAsFixed(2)} €';
 String get formattedTotalDeductions => '${totalDeductions.toStringAsFixed(2)} €';
 String get formattedNetAmount => '${netAmount.toStringAsFixed(2)} €';

 @override
 String toString() => 'Net: $formattedNetAmount';
}

@JsonSerializable()
class PayslipEarning {
 final String id;
 final String type;
 final String description;
 final double amount;
 final double quantity;
 final double rate;
 final String? category;
 final bool isTaxable;
 final Map<String, dynamic>? metadata;

 const PayslipEarning({
 required this.id,
 required this.type,
 required this.description,
 required this.amount,
 required this.quantity,
 required this.rate,
 this.category,
 required this.isTaxable,
 this.metadata,
 });

 factory PayslipEarning.fromJson(Map<String, dynamic> json) => _$PayslipEarningFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipEarningToJson(this);

 String get formattedAmount => '${amount.toStringAsFixed(2)} €';
 String get formattedRate => '${rate.toStringAsFixed(2)} €';
 String get displayDescription => quantity > 1 ? '$description ($quantity)' : description;

 @override
 String toString() => '$description: $formattedAmount';
}

@JsonSerializable()
class PayslipDeduction {
 final String id;
 final String type;
 final String description;
 final double amount;
 final double percentage;
 final String? category;
 final bool isPreTax;
 final Map<String, dynamic>? metadata;

 const PayslipDeduction({
 required this.id,
 required this.type,
 required this.description,
 required this.amount,
 required this.percentage,
 this.category,
 required this.isPreTax,
 this.metadata,
 });

 factory PayslipDeduction.fromJson(Map<String, dynamic> json) => _$PayslipDeductionFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipDeductionToJson(this);

 String get formattedAmount => '${amount.toStringAsFixed(2)} €';
 String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

 @override
 String toString() => '$description: $formattedAmount';
}

@JsonSerializable()
class PayslipContribution {
 final String id;
 final String type;
 final String description;
 final double employeeContribution;
 final double employerContribution;
 final double totalContribution;
 final double percentage;
 final String? category;
 final bool isMandatory;
 final Map<String, dynamic>? metadata;

 const PayslipContribution({
 required this.id,
 required this.type,
 required this.description,
 required this.employeeContribution,
 required this.employerContribution,
 required this.totalContribution,
 required this.percentage,
 this.category,
 required this.isMandatory,
 this.metadata,
 });

 factory PayslipContribution.fromJson(Map<String, dynamic> json) => _$PayslipContributionFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipContributionToJson(this);

 String get formattedEmployeeContribution => '${employeeContribution.toStringAsFixed(2)} €';
 String get formattedEmployerContribution => '${employerContribution.toStringAsFixed(2)} €';
 String get formattedTotalContribution => '${totalContribution.toStringAsFixed(2)} €';
 String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

 @override
 String toString() => '$description: $formattedEmployeeContribution';
}

@JsonSerializable()
class PayslipSummary {
 final double grossAmount;
 final double taxableAmount;
 final double nonTaxableAmount;
 final double socialSecurityContributions;
 final double incomeTax;
 final double otherDeductions;
 final double totalDeductions;
 final double netAmount;
 final double yearToDateGross;
 final double yearToDateNet;
 final double yearToDateTax;

 const PayslipSummary({
 required this.grossAmount,
 required this.taxableAmount,
 required this.nonTaxableAmount,
 required this.socialSecurityContributions,
 required this.incomeTax,
 required this.otherDeductions,
 required this.totalDeductions,
 required this.netAmount,
 required this.yearToDateGross,
 required this.yearToDateNet,
 required this.yearToDateTax,
 });

 factory PayslipSummary.fromJson(Map<String, dynamic> json) => _$PayslipSummaryFromJson(json);
 Map<String, dynamic> toJson() => _$PayslipSummaryToJson(this);

 String get formattedGrossAmount => '${grossAmount.toStringAsFixed(2)} €';
 String get formattedTaxableAmount => '${taxableAmount.toStringAsFixed(2)} €';
 String get formattedNetAmount => '${netAmount.toStringAsFixed(2)} €';
 String get formattedYearToDateGross => '${yearToDateGross.toStringAsFixed(2)} €';
 String get formattedYearToDateNet => '${yearToDateNet.toStringAsFixed(2)} €';

 @override
 String toString() => 'Net: $formattedNetAmount';
}

enum PayslipStatus {
 draft('Brouillon'),
 pending('En attente'),
 approved('Approuvée'),
 paid('Payée'),
 cancelled('Annulée');

 const PayslipStatus(this.displayName);

 final String displayName;

 static PayslipStatus fromString(String value) {
 return PayslipStatus.values.firstWhere(
 (status) => status.displayName == value || status.name == value,
 orElse: () => PayslipStatus.draft,
 );
 }
}

enum PayslipEarningType {
 baseSalary('Salaire de base'),
 overtime('Heures supplémentaires'),
 bonus('Prime'),
 allowance('Indemnité'),
 commission('Commission'),
 holidayPay('Congés payés'),
 sickPay('Arrêt maladie'),
 other('Autre');

 const PayslipEarningType(this.displayName);

 final String displayName;

 static PayslipEarningType fromString(String value) {
 return PayslipEarningType.values.firstWhere(
 (type) => type.displayName == value || type.name == value,
 orElse: () => PayslipEarningType.other,
 );
 }
}

enum PayslipDeductionType {
 incomeTax('Impôt sur le revenu'),
 socialSecurity('Sécurité sociale'),
 unemployment('Assurance chômage'),
 retirement('Retraite'),
 healthInsurance('Assurance maladie'),
 loan('Prêt'),
 advance('Avance'),
 other('Autre');

 const PayslipDeductionType(this.displayName);

 final String displayName;

 static PayslipDeductionType fromString(String value) {
 return PayslipDeductionType.values.firstWhere(
 (type) => type.displayName == value || type.name == value,
 orElse: () => PayslipDeductionType.other,
 );
 }
}
