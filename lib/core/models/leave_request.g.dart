// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) => LeaveRequest(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      leaveType: $enumDecode(_$LeaveTypeEnumMap, json['leave_type']),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String?,
      status: $enumDecode(_$LeaveStatusEnumMap, json['status']),
      priority: $enumDecode(_$LeavePriorityEnumMap, json['priority']),
      approverId: json['approver_id'] as String?,
      approverName: json['approver_name'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      rejectedAt: json['rejected_at'] == null
          ? null
          : DateTime.parse(json['rejected_at'] as String),
      totalDays: json['total_days'] as int,
      paidDays: (json['paid_days'] as num?)?.toDouble(),
      unpaidDays: (json['unpaid_days'] as num?)?.toDouble(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );

Map<String, dynamic> _$LeaveRequestToJson(LeaveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'leave_type': _$LeaveTypeEnumMap[instance.leaveType]!,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'reason': instance.reason,
      'status': _$LeaveStatusEnumMap[instance.status]!,
      'priority': _$LeavePriorityEnumMap[instance.priority]!,
      'approver_id': instance.approverId,
      'approver_name': instance.approverName,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'rejection_reason': instance.rejectionReason,
      'rejected_at': instance.rejectedAt?.toIso8601String(),
      'total_days': instance.totalDays,
      'paid_days': instance.paidDays,
      'unpaid_days': instance.unpaidDays,
      'attachments': instance.attachments,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
    };

const _$LeaveTypeEnumMap = {
  LeaveType.annual: 'annual',
  LeaveType.sick: 'sick',
  LeaveType.maternity: 'maternity',
  LeaveType.paternity: 'paternity',
  LeaveType.unpaid: 'unpaid',
  LeaveType.bereavement: 'bereavement',
  LeaveType.emergency: 'emergency',
  LeaveType.training: 'training',
  LeaveType.other: 'other',
};

const _$LeaveStatusEnumMap = {
  LeaveStatus.pending: 'pending',
  LeaveStatus.approved: 'approved',
  LeaveStatus.rejected: 'rejected',
  LeaveStatus.cancelled: 'cancelled',
  LeaveStatus.inProgress: 'in_progress',
};

const _$LeavePriorityEnumMap = {
  LeavePriority.low: 'low',
  LeavePriority.medium: 'medium',
  LeavePriority.high: 'high',
  LeavePriority.urgent: 'urgent',
};
