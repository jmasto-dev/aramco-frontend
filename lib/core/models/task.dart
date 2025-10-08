import 'package:json_annotation/json_annotation.dart';
enum TaskStatus {
 todo,
 inProgress,
 inReview,
 completed,
 cancelled,
 onHold,
}

enum TaskPriority {
 low,
 normal,
 high,
 urgent,
}

enum TaskType {
 task,
 bug,
 feature,
 improvement,
 documentation,
 meeting,
 review,
}

@JsonSerializable()
class \1 {
 final String id;
 final String title;
 final String description;
 final TaskStatus status;
 final TaskPriority priority;
 final TaskType type;
 final String assigneeId;
 final String? reporterId;
 final String? projectId;
 final String? parentTaskId;
 final List<String> subtaskIds;
 final List<String> tagIds;
 final List<String> attachmentIds;
 final DateTime createdAt;
 final DateTime? updatedAt;
 final DateTime? dueDate;
 final DateTime? startDate;
 final DateTime? completedAt;
 final int estimatedHours;
 final int actualHours;
 final double progress;
 final Map<String, dynamic> customFields;
 final List<TaskComment> comments;
 final List<TaskHistory> history;
 final TaskDependencies? dependencies;

 Task({
 required this.id,
 required this.title,
 required this.description,
 required this.status,
 required this.priority,
 required this.type,
 required this.assigneeId,
 this.reporterId,
 this.projectId,
 this.parentTaskId,
 this.subtaskIds = const [],
 this.tagIds = const [],
 this.attachmentIds = const [],
 required this.createdAt,
 this.updatedAt,
 this.dueDate,
 this.startDate,
 this.completedAt,
 this.estimatedHours = 0,
 this.actualHours = 0,
 this.progress = 0.0,
 this.customFields = const {},
 this.comments = const [],
 this.history = const [],
 this.dependencies,
 });

 factory Task.fromJson(Map<String, dynamic> json) {
 return Task(
 id: json['id'] as String,
 title: json['title'] as String,
 description: json['description'] as String,
 status: TaskStatus.values.firstWhere(
 (e) => e.name == json['status'],
 orElse: () => TaskStatus.todo,
 ),
 priority: TaskPriority.values.firstWhere(
 (e) => e.name == json['priority'],
 orElse: () => TaskPriority.normal,
 ),
 type: TaskType.values.firstWhere(
 (e) => e.name == json['type'],
 orElse: () => TaskType.task,
 ),
 assigneeId: json['assignee_id'] as String,
 reporterId: json['reporter_id'] as String?,
 projectId: json['project_id'] as String?,
 parentTaskId: json['parent_task_id'] as String?,
 subtaskIds: List<String>.from(json['subtask_ids'] ?? []),
 tagIds: List<String>.from(json['tag_ids'] ?? []),
 attachmentIds: List<String>.from(json['attachment_ids'] ?? []),
 createdAt: DateTime.parse(json['created_at'] as String),
 updatedAt: json['updated_at'] != null 
 ? DateTime.parse(json['updated_at'] as String) 
 : null,
 dueDate: json['due_date'] != null 
 ? DateTime.parse(json['due_date'] as String) 
 : null,
 startDate: json['start_date'] != null 
 ? DateTime.parse(json['start_date'] as String) 
 : null,
 completedAt: json['completed_at'] != null 
 ? DateTime.parse(json['completed_at'] as String) 
 : null,
 estimatedHours: json['estimated_hours'] as int? ?? 0,
 actualHours: json['actual_hours'] as int? ?? 0,
 progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
 customFields: Map<String, dynamic>.from(json['custom_fields'] ?? {}),
 comments: (json['comments'] as List<String>?)
 ?.map((e) => TaskComment.fromJson(e as Map<String, dynamic>))
 .toList() ?? [],
 history: (json['history'] as List<String>?)
 ?.map((e) => TaskHistory.fromJson(e as Map<String, dynamic>))
 .toList() ?? [],
 dependencies: json['dependencies'] != null
 ? TaskDependencies.fromJson(json['dependencies'] as Map<String, dynamic>)
 : null,
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'id': id,
 'title': title,
 'description': description,
 'status': status.name,
 'priority': priority.name,
 'type': type.name,
 'assignee_id': assigneeId,
 'reporter_id': reporterId,
 'project_id': projectId,
 'parent_task_id': parentTaskId,
 'subtask_ids': subtaskIds,
 'tag_ids': tagIds,
 'attachment_ids': attachmentIds,
 'created_at': createdAt.toIso8601String(),
 'updated_at': updatedAt?.toIso8601String(),
 'due_date': dueDate?.toIso8601String(),
 'start_date': startDate?.toIso8601String(),
 'completed_at': completedAt?.toIso8601String(),
 'estimated_hours': estimatedHours,
 'actual_hours': actualHours,
 'progress': progress,
 'custom_fields': customFields,
 'comments': comments.map((e) => e.toJson()).toList(),
 'history': history.map((e) => e.toJson()).toList(),
 'dependencies': dependencies?.toJson(),
};
 }

 Task copyWith({
 String? id,
 String? title,
 String? description,
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? reporterId,
 String? projectId,
 String? parentTaskId,
 List<String>? subtaskIds,
 List<String>? tagIds,
 List<String>? attachmentIds,
 DateTime? createdAt,
 DateTime? updatedAt,
 DateTime? dueDate,
 DateTime? startDate,
 DateTime? completedAt,
 int? estimatedHours,
 int? actualHours,
 double? progress,
 Map<String, dynamic>? customFields,
 List<TaskComment>? comments,
 List<TaskHistory>? history,
 TaskDependencies? dependencies,
 }) {
 return Task(
 id: id ?? this.id,
 title: title ?? this.title,
 description: description ?? this.description,
 status: status ?? this.status,
 priority: priority ?? this.priority,
 type: type ?? this.type,
 assigneeId: assigneeId ?? this.assigneeId,
 reporterId: reporterId ?? this.reporterId,
 projectId: projectId ?? this.projectId,
 parentTaskId: parentTaskId ?? this.parentTaskId,
 subtaskIds: subtaskIds ?? this.subtaskIds,
 tagIds: tagIds ?? this.tagIds,
 attachmentIds: attachmentIds ?? this.attachmentIds,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 dueDate: dueDate ?? this.dueDate,
 startDate: startDate ?? this.startDate,
 completedAt: completedAt ?? this.completedAt,
 estimatedHours: estimatedHours ?? this.estimatedHours,
 actualHours: actualHours ?? this.actualHours,
 progress: progress ?? this.progress,
 customFields: customFields ?? this.customFields,
 comments: comments ?? this.comments,
 history: history ?? this.history,
 dependencies: dependencies ?? this.dependencies,
 );
 }

 // Getters
 bool get isOverdue {
 if (dueDate == null) r{eturn false;
 return DateTime.now().isAfter(dueDate!) && status != TaskStatus.completed;
 }

 bool get isCompleted => status == TaskStatus.completed;
 bool get isInProgress => status == TaskStatus.inProgress;
 bool get isTodo => status == TaskStatus.todo;
 bool get isOnHold => status == TaskStatus.onHold;
 bool get isCancelled => status == TaskStatus.cancelled;
 bool get isInReview => status == TaskStatus.inReview;

 bool get isHighPriority => priority == TaskPriority.high || priority == TaskPriority.urgent;
 bool get isUrgent => priority == TaskPriority.urgent;

 String get statusLabel {
 switch (status) {
 case TaskStatus.todo:
 return 'À faire';
 case TaskStatus.inProgress:
 return 'En cours';
 case TaskStatus.inReview:
 return 'En révision';
 case TaskStatus.completed:
 return 'Terminé';
 case TaskStatus.cancelled:
 return 'Annulé';
 case TaskStatus.onHold:
 return 'En pause';
}
 }

 String get priorityLabel {
 switch (priority) {
 case TaskPriority.low:
 return 'Basse';
 case TaskPriority.normal:
 return 'Normale';
 case TaskPriority.high:
 return 'Haute';
 case TaskPriority.urgent:
 return 'Urgente';
}
 }

 String get typeLabel {
 switch (type) {
 case TaskType.task:
 return 'Tâche';
 case TaskType.bug:
 return 'Bogue';
 case TaskType.feature:
 return 'Fonctionnalité';
 case TaskType.improvement:
 return 'Amélioration';
 case TaskType.documentation:
 return 'Documentation';
 case TaskType.meeting:
 return 'Réunion';
 case TaskType.review:
 return 'Révision';
}
 }

 String get formattedDueDate {
 if (dueDate == null) r{eturn '';
 return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
 }

 int get daysUntilDue {
 if (dueDate == null) r{eturn -1;
 final now = DateTime.now();
 final difference = dueDate!.difference(now).inDays;
 return difference;
 }
}

@JsonSerializable()
class \1 {
 final String id;
 final String taskId;
 final String userId;
 final String content;
 final DateTime createdAt;
 final DateTime? updatedAt;
 final List<String> attachmentIds;
 final String? parentId;
 final List<TaskComment> replies;

 TaskComment({
 required this.id,
 required this.taskId,
 required this.userId,
 required this.content,
 required this.createdAt,
 this.updatedAt,
 this.attachmentIds = const [],
 this.parentId,
 this.replies = const [],
 });

 factory TaskComment.fromJson(Map<String, dynamic> json) {
 return TaskComment(
 id: json['id'] as String,
 taskId: json['task_id'] as String,
 userId: json['user_id'] as String,
 content: json['content'] as String,
 createdAt: DateTime.parse(json['created_at'] as String),
 updatedAt: json['updated_at'] != null 
 ? DateTime.parse(json['updated_at'] as String) 
 : null,
 attachmentIds: List<String>.from(json['attachment_ids'] ?? []),
 parentId: json['parent_id'] as String?,
 replies: (json['replies'] as List<String>?)
 ?.map((e) => TaskComment.fromJson(e as Map<String, dynamic>))
 .toList() ?? [],
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'id': id,
 'task_id': taskId,
 'user_id': userId,
 'content': content,
 'created_at': createdAt.toIso8601String(),
 'updated_at': updatedAt?.toIso8601String(),
 'attachment_ids': attachmentIds,
 'parent_id': parentId,
 'replies': replies.map((e) => e.toJson()).toList(),
};
 }
}

@JsonSerializable()
class \1 {
 final String id;
 final String taskId;
 final String userId;
 final String action;
 final Map<String, dynamic> oldValue;
 final Map<String, dynamic> newValue;
 final DateTime createdAt;

 TaskHistory({
 required this.id,
 required this.taskId,
 required this.userId,
 required this.action,
 required this.oldValue,
 required this.newValue,
 required this.createdAt,
 });

 factory TaskHistory.fromJson(Map<String, dynamic> json) {
 return TaskHistory(
 id: json['id'] as String,
 taskId: json['task_id'] as String,
 userId: json['user_id'] as String,
 action: json['action'] as String,
 oldValue: Map<String, dynamic>.from(json['old_value'] ?? {}),
 newValue: Map<String, dynamic>.from(json['new_value'] ?? {}),
 createdAt: DateTime.parse(json['created_at'] as String),
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'id': id,
 'task_id': taskId,
 'user_id': userId,
 'action': action,
 'old_value': oldValue,
 'new_value': newValue,
 'created_at': createdAt.toIso8601String(),
};
 }
}

@JsonSerializable()
class \1 {
 final List<String> dependsOn;
 final List<String> blocks;

 TaskDependencies({
 this.dependsOn = const [],
 this.blocks = const [],
 });

 factory TaskDependencies.fromJson(Map<String, dynamic> json) {
 return TaskDependencies(
 dependsOn: List<String>.from(json['depends_on'] ?? []),
 blocks: List<String>.from(json['blocks'] ?? []),
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'depends_on': dependsOn,
 'blocks': blocks,
};
 }
}

@JsonSerializable()
class \1 {
 final TaskStatus? status;
 final TaskPriority? priority;
 final TaskType? type;
 final String? assigneeId;
 final String? projectId;
 final String? reporterId;
 final String? searchQuery;
 final DateTime? startDate;
 final DateTime? endDate;
 final List<String> tagIds;
 final bool? isOverdue;
 final bool? hasAttachments;

 TaskFilter({
 this.status,
 this.priority,
 this.type,
 this.assigneeId,
 this.projectId,
 this.reporterId,
 this.searchQuery,
 this.startDate,
 this.endDate,
 this.tagIds = const [],
 this.isOverdue,
 this.hasAttachments,
 });

 Map<String, dynamic> toJson() {
 return {
 'status': status?.name,
 'priority': priority?.name,
 'type': type?.name,
 'assignee_id': assigneeId,
 'project_id': projectId,
 'reporter_id': reporterId,
 'search_query': searchQuery,
 'start_date': startDate?.toIso8601String(),
 'end_date': endDate?.toIso8601String(),
 'tag_ids': tagIds,
 'is_overdue': isOverdue,
 'has_attachments': hasAttachments,
};
 }
}
