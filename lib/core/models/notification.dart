import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
 final int id;
 final String title;
 final String message;
 final String type; // info, warning, error, success
 final DateTime createdAt;
 final DateTime? readAt;
 final bool isRead;
 final String? actionUrl;
 final Map<String, dynamic>? metadata;
 final int? userId;

 Notification({
 required this.id,
 required this.title,
 required this.message,
 required this.type,
 required this.createdAt,
 this.readAt,
 required this.isRead,
 this.actionUrl,
 this.metadata,
 this.userId,
 });

 factory Notification.fromJson(Map<String, dynamic> json) =>
 _$NotificationFromJson(json);

 Map<String, dynamic> toJson() => _$NotificationToJson(this);

 Notification copyWith({
 int? id,
 String? title,
 String? message,
 String? type,
 DateTime? createdAt,
 DateTime? readAt,
 bool? isRead,
 String? actionUrl,
 Map<String, dynamic>? metadata,
 int? userId,
 }) {
 return Notification(
 id: id ?? this.id,
 title: title ?? this.title,
 message: message ?? this.message,
 type: type ?? this.type,
 createdAt: createdAt ?? this.createdAt,
 readAt: readAt ?? this.readAt,
 isRead: isRead ?? this.isRead,
 actionUrl: actionUrl ?? this.actionUrl,
 metadata: metadata ?? this.metadata,
 userId: userId ?? this.userId,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)){ return true;
 return other is Notification && other.id == id;
 }

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() {
 return 'Notification(id: $id, title: $title, type: $type, isRead: $isRead)';
 }
}

@JsonSerializable()
class NotificationPreferences {
 final bool emailNotifications;
 final bool pushNotifications;
 final bool smsNotifications;
 final List<String> enabledTypes;
 final Map<String, bool> moduleNotifications;

 NotificationPreferences({
 required this.emailNotifications,
 required this.pushNotifications,
 required this.smsNotifications,
 required this.enabledTypes,
 required this.moduleNotifications,
 });

 factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
 _$NotificationPreferencesFromJson(json);

 Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);
}

