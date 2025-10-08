import 'package:json_annotation/json_annotation.dart';
/// Modèles pour la gestion des messages

enum MessageType {
  text,
  html,
  system,
  file,
  image,
  video,
  audio,
}

enum MessagePriority {
  low,
  normal,
  high,
  urgent,
}

enum MessageStatus {
  draft,
  sent,
  delivered,
  read,
  failed,
}

enum AttachmentType {
  image,
  document,
  video,
  audio,
  other,
}

enum MessageGroupType {
  private,
  public,
  project,
  department,
}

@JsonSerializable()
class \1 {
  final String id;
  final String senderId;
  final String receiverId;
  final String? groupId;
  final String subject;
  final String content;
  final MessageType type;
  final MessagePriority priority;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? repliedAt;
  final String? replyToId;
  final List<MessageAttachment>? attachments;
  final Map<String, dynamic>? metadata;
  final bool isDeleted;
  final DateTime? deletedAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.groupId,
    required this.subject,
    required this.content,
    required this.type,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.repliedAt,
    this.replyToId,
    this.attachments,
    this.metadata,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      groupId: json['group_id'] as String?,
      subject: json['subject'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      priority: MessagePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => MessagePriority.normal,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.draft,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      repliedAt: json['replied_at'] != null ? DateTime.parse(json['replied_at'] as String) : null,
      replyToId: json['reply_to_id'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((item) => MessageAttachment.fromJson(item as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'group_id': groupId,
      'subject': subject,
      'content': content,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'replied_at': repliedAt?.toIso8601String(),
      'reply_to_id': replyToId,
      'attachments': attachments?.map((item) => item.toJson()).toList(),
      'metadata': metadata,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? groupId,
    String? subject,
    String? content,
    MessageType? type,
    MessagePriority? priority,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? repliedAt,
    String? replyToId,
    List<MessageAttachment>? attachments,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      repliedAt: repliedAt ?? this.repliedAt,
      replyToId: replyToId ?? this.replyToId,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isRead => readAt != null;
  bool get isReplied => repliedAt != null;
  bool get isGroupMessage => groupId != null;
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
  bool get isHighPriority => priority == MessagePriority.high || priority == MessagePriority.urgent;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message{id: $id, subject: $subject, status: $status}';
  }
}

@JsonSerializable()
class \1 {
  final String id;
  final String fileName;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String url;
  final String? thumbnailUrl;
  final AttachmentType type;
  final DateTime uploadedAt;

  const MessageAttachment({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.url,
    this.thumbnailUrl,
    required this.type,
    required this.uploadedAt,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      originalName: json['original_name'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttachmentType.other,
      ),
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'original_name': originalName,
      'mime_type': mimeType,
      'file_size': fileSize,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'type': type.name,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  bool get isImage => type == AttachmentType.image;
  bool get isDocument => type == AttachmentType.document;
  bool get isVideo => type == AttachmentType.video;
  bool get isAudio => type == AttachmentType.audio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAttachment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageAttachment{id: $id, fileName: $fileName, type: $type}';
  }
}

@JsonSerializable()
class \1 {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final List<String> memberIds;
  final String adminId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final MessageGroupType type;
  final Map<String, dynamic>? settings;
  final bool isActive;

  const MessageGroup({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.memberIds,
    required this.adminId,
    required this.createdAt,
    this.lastMessageAt,
    required this.type,
    this.settings,
    this.isActive = true,
  });

  factory MessageGroup.fromJson(Map<String, dynamic> json) {
    return MessageGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      memberIds: List<String>.from(json['member_ids'] as List<dynamic>),
      adminId: json['admin_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at'] as String) 
          : null,
      type: MessageGroupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageGroupType.private,
      ),
      settings: json['settings'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'member_ids': memberIds,
      'admin_id': adminId,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'type': type.name,
      'settings': settings,
      'is_active': isActive,
    };
  }

  bool get isPrivateGroup => type == MessageGroupType.private;
  bool get isPublicGroup => type == MessageGroupType.public;
  bool get isProjectGroup => type == MessageGroupType.project;
  bool get isDepartmentGroup => type == MessageGroupType.department;
  int get memberCount => memberIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageGroup && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageGroup{id: $id, name: $name, type: $type}';
  }
}

/// Utilitaires pour les messages
@JsonSerializable()
class \1 {
  /// Formater la priorité
  static String formatPriority(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.low:
        return 'Basse';
      case MessagePriority.normal:
        return 'Normale';
      case MessagePriority.high:
        return 'Haute';
      case MessagePriority.urgent:
        return 'Urgente';
    }
  }

  /// Formater le statut
  static String formatStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.draft:
        return 'Brouillon';
      case MessageStatus.sent:
        return 'Envoyé';
      case MessageStatus.delivered:
        return 'Livré';
      case MessageStatus.read:
        return 'Lu';
      case MessageStatus.failed:
        return 'Échoué';
    }
  }

  /// Obtenir la couleur de la priorité
  static String getPriorityColor(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.low:
        return '#4CAF50';
      case MessagePriority.normal:
        return '#2196F3';
      case MessagePriority.high:
        return '#FF9800';
      case MessagePriority.urgent:
        return '#F44336';
    }
  }

  /// Obtenir la couleur du statut
  static String getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.draft:
        return '#9E9E9E';
      case MessageStatus.sent:
        return '#2196F3';
      case MessageStatus.delivered:
        return '#4CAF50';
      case MessageStatus.read:
        return '#8BC34A';
      case MessageStatus.failed:
        return '#F44336';
    }
  }

  /// Valider un message
  static bool isValidMessage(Message message) {
    return message.subject.isNotEmpty && 
           message.content.isNotEmpty && 
           message.senderId.isNotEmpty && 
           message.receiverId.isNotEmpty;
  }

  /// Créer un message par défaut
  static Message createDefaultMessage({
    required String senderId,
    required String receiverId,
    required String subject,
    required String content,
  }) {
    return Message(
      id: _generateMessageId(),
      senderId: senderId,
      receiverId: receiverId,
      subject: subject,
      content: content,
      type: MessageType.text,
      priority: MessagePriority.normal,
      status: MessageStatus.draft,
      createdAt: DateTime.now(),
    );
  }

  /// Générer un ID de message unique
  static String _generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'MSG_$timestamp';
  }

  /// Filtrer les messages par statut
  static List<Message> filterByStatus(List<Message> messages, MessageStatus status) {
    return messages.where((message) => message.status == status).toList();
  }

  /// Filtrer les messages par priorité
  static List<Message> filterByPriority(List<Message> messages, MessagePriority priority) {
    return messages.where((message) => message.priority == priority).toList();
  }

  /// Trier les messages par date
  static List<Message> sortByDate(List<Message> messages, {bool descending = true}) {
    final sorted = List<Message>.from(messages);
    sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return descending ? sorted.reversed.toList() : sorted;
  }
}
