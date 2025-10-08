import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leave_request.g.dart';

enum LeaveType {
  @JsonValue('annual')
  annual,
  @JsonValue('sick')
  sick,
  @JsonValue('maternity')
  maternity,
  @JsonValue('paternity')
  paternity,
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('bereavement')
  bereavement,
  @JsonValue('emergency')
  emergency,
  @JsonValue('training')
  training,
  @JsonValue('other')
  other,
}

enum LeaveStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('in_progress')
  inProgress,
}

enum LeavePriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

@JsonSerializable()
class LeaveRequest extends Equatable {
  final String id;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final LeaveStatus status;
  final LeavePriority priority;
  final String? approverId;
  final String? approverName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? rejectedAt;
  final int totalDays;
  final double? paidDays;
  final double? unpaidDays;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.status,
    required this.priority,
    this.approverId,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
    this.rejectedAt,
    required this.totalDays,
    this.paidDays,
    this.unpaidDays,
    this.attachments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRequestToJson(this);

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    LeavePriority? priority,
    String? approverId,
    String? approverName,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? rejectedAt,
    int? totalDays,
    double? paidDays,
    double? unpaidDays,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      totalDays: totalDays ?? this.totalDays,
      paidDays: paidDays ?? this.paidDays,
      unpaidDays: unpaidDays ?? this.unpaidDays,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  // Getters pour les informations formatées
  String get leaveTypeDisplayName {
    switch (leaveType) {
      case LeaveType.annual:
        return 'Congé annuel';
      case LeaveType.sick:
        return 'Congé maladie';
      case LeaveType.maternity:
        return 'Congé maternité';
      case LeaveType.paternity:
        return 'Congé paternité';
      case LeaveType.unpaid:
        return 'Congé sans solde';
      case LeaveType.bereavement:
        return 'Congé décès';
      case LeaveType.emergency:
        return 'Congé d\'urgence';
      case LeaveType.training:
        return 'Congé formation';
      case LeaveType.other:
        return 'Autre';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case LeaveStatus.pending:
        return 'En attente';
      case LeaveStatus.approved:
        return 'Approuvé';
      case LeaveStatus.rejected:
        return 'Rejeté';
      case LeaveStatus.cancelled:
        return 'Annulé';
      case LeaveStatus.inProgress:
        return 'En cours';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case LeavePriority.low:
        return 'Faible';
      case LeavePriority.medium:
        return 'Moyenne';
      case LeavePriority.high:
        return 'Élevée';
      case LeavePriority.urgent:
        return 'Urgente';
    }
  }

  String get formattedStartDate {
    return '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
  }

  String get formattedEndDate {
    return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }

  String get formattedDateRange {
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return 'Du ${startDate.day} au ${endDate.day} ${_getMonthName(startDate.month)} ${startDate.year}';
    } else if (startDate.year == endDate.year) {
      return 'Du ${startDate.day} ${_getMonthName(startDate.month)} au ${endDate.day} ${_getMonthName(endDate.month)} ${startDate.year}';
    } else {
      return 'Du ${formattedStartDate} au ${formattedEndDate}';
    }
  }

  String get formattedDuration {
    if (totalDays == 1) {
      return '1 jour';
    } else {
      return '$totalDays jours';
    }
  }

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;
  bool get isCancelled => status == LeaveStatus.cancelled;
  bool get isInProgress => status == LeaveStatus.inProgress;

  bool get isOverdue {
    final now = DateTime.now();
    return endDate.isBefore(now) && isApproved;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return startDate.isAfter(now) && isApproved;
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && isApproved;
  }

  // Validation
  bool get isValidDateRange {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }

  bool get isReasonRequired {
    switch (leaveType) {
      case LeaveType.sick:
      case LeaveType.bereavement:
      case LeaveType.emergency:
      case LeaveType.other:
        return true;
      case LeaveType.annual:
      case LeaveType.maternity:
      case LeaveType.paternity:
      case LeaveType.unpaid:
      case LeaveType.training:
        return false;
    }
  }

  // Calculs
  static int calculateTotalDays(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) return 0;
    
    final difference = endDate.difference(startDate);
    return difference.inDays + 1; // Inclure le jour de début
  }

  static double calculatePaidDays(LeaveType leaveType, int totalDays) {
    switch (leaveType) {
      case LeaveType.annual:
      case LeaveType.sick:
      case LeaveType.maternity:
      case LeaveType.paternity:
      case LeaveType.bereavement:
      case LeaveType.emergency:
      case LeaveType.training:
        return totalDays.toDouble();
      case LeaveType.unpaid:
      case LeaveType.other:
        return 0.0;
    }
  }

  static double calculateUnpaidDays(LeaveType leaveType, int totalDays) {
    final paidDays = calculatePaidDays(leaveType, totalDays);
    return totalDays.toDouble() - paidDays;
  }

  String _getMonthName(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        leaveType,
        startDate,
        endDate,
        reason,
        status,
        priority,
        approverId,
        approverName,
        approvedAt,
        rejectionReason,
        rejectedAt,
        totalDays,
        paidDays,
        unpaidDays,
        attachments,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  @override
  String toString() {
    return 'LeaveRequest('
        'id: $id, '
        'leaveType: $leaveType, '
        'status: $status, '
        'startDate: $formattedStartDate, '
        'endDate: $formattedEndDate, '
        'totalDays: $totalDays'
        ')';
  }
}

// Filtres pour les demandes de congé
class LeaveRequestFilters extends Equatable {
  final LeaveType? leaveType;
  final LeaveStatus? status;
  final LeavePriority? priority;
  final String? employeeId;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final DateTime? endDateFrom;
  final DateTime? endDateTo;
  final String? searchQuery;

  const LeaveRequestFilters({
    this.leaveType,
    this.status,
    this.priority,
    this.employeeId,
    this.startDateFrom,
    this.startDateTo,
    this.endDateFrom,
    this.endDateTo,
    this.searchQuery,
  });

  LeaveRequestFilters copyWith({
    LeaveType? leaveType,
    LeaveStatus? status,
    LeavePriority? priority,
    String? employeeId,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    String? searchQuery,
    bool clearSearchQuery = false,
  }) {
    return LeaveRequestFilters(
      leaveType: leaveType ?? this.leaveType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      employeeId: employeeId ?? this.employeeId,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      endDateFrom: endDateFrom ?? this.endDateFrom,
      endDateTo: endDateTo ?? this.endDateTo,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasFilters =>
      leaveType != null ||
      status != null ||
      priority != null ||
      employeeId != null ||
      startDateFrom != null ||
      startDateTo != null ||
      endDateFrom != null ||
      endDateTo != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{};
    
    if (leaveType != null) {
      params['leave_type'] = leaveType!.name;
    }
    if (status != null) {
      params['status'] = status!.name;
    }
    if (priority != null) {
      params['priority'] = priority!.name;
    }
    if (employeeId != null) {
      params['employee_id'] = employeeId;
    }
    if (startDateFrom != null) {
      params['start_date_from'] = startDateFrom!.toIso8601String().split('T')[0];
    }
    if (startDateTo != null) {
      params['start_date_to'] = startDateTo!.toIso8601String().split('T')[0];
    }
    if (endDateFrom != null) {
      params['end_date_from'] = endDateFrom!.toIso8601String().split('T')[0];
    }
    if (endDateTo != null) {
      params['end_date_to'] = endDateTo!.toIso8601String().split('T')[0];
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    
    return params;
  }

  @override
  List<Object?> get props => [
        leaveType,
        status,
        priority,
        employeeId,
        startDateFrom,
        startDateTo,
        endDateFrom,
        endDateTo,
        searchQuery,
      ];
}

// Extensions pour les enums
extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.annual:
        return 'Congé annuel';
      case LeaveType.sick:
        return 'Congé maladie';
      case LeaveType.maternity:
        return 'Congé maternité';
      case LeaveType.paternity:
        return 'Congé paternité';
      case LeaveType.unpaid:
        return 'Congé sans solde';
      case LeaveType.bereavement:
        return 'Congé décès';
      case LeaveType.emergency:
        return 'Congé d\'urgence';
      case LeaveType.training:
        return 'Congé formation';
      case LeaveType.other:
        return 'Autre';
    }
  }

  String get description {
    switch (this) {
      case LeaveType.annual:
        return 'Congés payés annuels';
      case LeaveType.sick:
        return 'Congé pour raison médicale';
      case LeaveType.maternity:
        return 'Congé maternité légal';
      case LeaveType.paternity:
        return 'Congé paternité légal';
      case LeaveType.unpaid:
        return 'Congé sans rémunération';
      case LeaveType.bereavement:
        return 'Congé pour décès d\'un proche';
      case LeaveType.emergency:
        return 'Congé pour urgence familiale';
      case LeaveType.training:
        return 'Congé pour formation professionnelle';
      case LeaveType.other:
        return 'Autre type de congé';
    }
  }

  bool get requiresDocument {
    switch (this) {
      case LeaveType.sick:
      case LeaveType.maternity:
      case LeaveType.paternity:
      case LeaveType.bereavement:
        return true;
      case LeaveType.annual:
      case LeaveType.unpaid:
      case LeaveType.emergency:
      case LeaveType.training:
      case LeaveType.other:
        return false;
    }
  }

  int get maxDays {
    switch (this) {
      case LeaveType.annual:
        return 30; // 30 jours par an
      case LeaveType.sick:
        return 90; // 3 mois maximum
      case LeaveType.maternity:
        return 98; // 14 semaines
      case LeaveType.paternity:
        return 14; // 2 semaines
      case LeaveType.bereavement:
        return 7; // 1 semaine
      case LeaveType.emergency:
        return 3; // 3 jours
      case LeaveType.training:
        return 30; // 1 mois
      case LeaveType.unpaid:
      case LeaveType.other:
        return 365; // 1 an maximum
    }
  }
}

extension LeaveStatusExtension on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'En attente';
      case LeaveStatus.approved:
        return 'Approuvé';
      case LeaveStatus.rejected:
        return 'Rejeté';
      case LeaveStatus.cancelled:
        return 'Annulé';
      case LeaveStatus.inProgress:
        return 'En cours';
    }
  }

  String get description {
    switch (this) {
      case LeaveStatus.pending:
        return 'En attente d\'approbation';
      case LeaveStatus.approved:
        return 'Demande approuvée';
      case LeaveStatus.rejected:
        return 'Demande rejetée';
      case LeaveStatus.cancelled:
        return 'Demande annulée';
      case LeaveStatus.inProgress:
        return 'Congé en cours';
    }
  }

  bool get canBeEdited {
    switch (this) {
      case LeaveStatus.pending:
        return true;
      case LeaveStatus.approved:
      case LeaveStatus.rejected:
      case LeaveStatus.cancelled:
      case LeaveStatus.inProgress:
        return false;
    }
  }

  bool get canBeCancelled {
    switch (this) {
      case LeaveStatus.pending:
      case LeaveStatus.approved:
        return true;
      case LeaveStatus.rejected:
      case LeaveStatus.cancelled:
      case LeaveStatus.inProgress:
        return false;
    }
  }
}

extension LeavePriorityExtension on LeavePriority {
  String get displayName {
    switch (this) {
      case LeavePriority.low:
        return 'Faible';
      case LeavePriority.medium:
        return 'Moyenne';
      case LeavePriority.high:
        return 'Élevée';
      case LeavePriority.urgent:
        return 'Urgente';
    }
  }

  String get description {
    switch (this) {
      case LeavePriority.low:
        return 'Priorité faible';
      case LeavePriority.medium:
        return 'Priorité moyenne';
      case LeavePriority.high:
        return 'Priorité élevée';
      case LeavePriority.urgent:
        return 'Priorité urgente';
    }
  }

  String get color {
    switch (this) {
      case LeavePriority.low:
        return '#4CAF50'; // Vert
      case LeavePriority.medium:
        return '#FF9800'; // Orange
      case LeavePriority.high:
        return '#F44336'; // Rouge
      case LeavePriority.urgent:
        return '#9C27B0'; // Violet
    }
  }
}
