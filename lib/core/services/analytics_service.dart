import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnalyticsEvent {
 final String name;
 final Map<String, dynamic>? parameters;
 final DateTime timestamp;
 final String? userId;
 final String sessionId;

 AnalyticsEvent({
 required this.name,
 this.parameters,
 required this.timestamp,
 this.userId,
 required this.sessionId,
 });

 Map<String, dynamic> toJson() {
 return {
 'name': name,
 'parameters': parameters,
 'timestamp': timestamp.toIso8601String(),
 'userId': userId,
 'sessionId': sessionId,
};
 }
}

class UserProperties {
 final String? userId;
 final String? email;
 final String? role;
 final String? department;
 final Map<String, dynamic>? customProperties;

 UserProperties({
 this.userId,
 this.email,
 this.role,
 this.department,
 this.customProperties,
 });

 Map<String, dynamic> toJson() {
 return {
 'userId': userId,
 'email': email,
 'role': role,
 'department': department,
 'customProperties': customProperties,
};
 }
}

class AnalyticsService {
 static final AnalyticsService _instance = AnalyticsService._internal();
 factory AnalyticsService() => _instance;
 AnalyticsService._internal();

 static const String _sessionIdKey = 'analytics_session_id';
 static const String _userIdKey = 'analytics_user_id';
 static const String _eventsKey = 'analytics_events';
 static const String _userPropertiesKey = 'analytics_user_properties';
 static const int _maxEventsToStore = 1000;

 String? _sessionId;
 String? _userId;
 UserProperties? _userProperties;
 List<AnalyticsEvent> _pendingEvents = [];
 Timer? _flushTimer;
 bool _isInitialized = false;
 bool _analyticsEnabled = true;
 String? _appVersion;
 String? _deviceInfo;

 // Getters
 String? get sessionId => _sessionId;
 String? get userId => _userId;
 bool get isInitialized => _isInitialized;
 bool get analyticsEnabled => _analyticsEnabled;

 Future<void> initialize() {async {
 if (_isInitialized) r{eturn;

 try {
 // Get device info
 await _getDeviceInfo();
 
 // Initialize session
 await _initializeSession();
 
 // Load pending events
 await _loadPendingEvents();
 
 // Load user properties
 await _loadUserProperties();
 
 // Start flush timer
 _startFlushTimer();
 
 _isInitialized = true;
 
 // Track app start
 trackEvent('app_opened', {
 'app_version': _appVersion,
 'device_info': _deviceInfo,
 'session_id': _sessionId,
 });
 
 debugPrint('Analytics service initialized');
} catch (e) {
 debugPrint('Failed to initialize analytics: $e');
}
 }

 Future<void> _getDeviceInfo() {async {
 try {
 final packageInfo = await PackageInfo.fromPlatform();
 _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

 String deviceInfo = '';
 if (Platform.isIOS) {
 final iosInfo = await DeviceInfoPlugin().iosInfo;
 deviceInfo = 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
 } else if (Platform.isAndroid) {
 final androidInfo = await DeviceInfoPlugin().androidInfo;
 deviceInfo = 'Android ${androidInfo.version.release} - ${androidInfo.model}';
 } else if (Platform.isWindows) {
 final windowsInfo = await DeviceInfoPlugin().windowsInfo;
 deviceInfo = 'Windows ${windowsInfo.majorVersion}.${windowsInfo.minorVersion}';
 } else if (Platform.isMacOS) {
 final macOsInfo = await DeviceInfoPlugin().macOsInfo;
 deviceInfo = 'macOS ${macOsInfo.majorVersion}.${macOsInfo.minorVersion}';
 } else if (Platform.isLinux) {
 final linuxInfo = await DeviceInfoPlugin().linuxInfo;
 deviceInfo = 'Linux ${linuxInfo.version}';
 }
 
 _deviceInfo = deviceInfo;
} catch (e) {
 debugPrint('Failed to get device info: $e');
}
 }

 Future<void> _initializeSession() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 
 // Check if session already exists
 String? existingSessionId = prefs.getString(_sessionIdKey);
 
 // For simplicity, create new session each time app starts
 // In production, you might want to check if session is still valid
 _sessionId = const Uuid().v4();
 await prefs.setString(_sessionIdKey, _sessionId!);
 
 debugPrint('New analytics session created: $_sessionId');
} catch (e) {
 debugPrint('Failed to initialize session: $e');
 _sessionId = const Uuid().v4();
}
 }

 Future<void> _loadPendingEvents() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 final eventsJson = prefs.getStringList(_eventsKey) ?? [];
 
 _pendingEvents = eventsJson.map((eventJson) {
 final Map<String, dynamic> eventMap = {};
 // Simple JSON parsing - in production, use proper JSON decoder
 return AnalyticsEvent(
 name: eventMap['name'] ?? 'unknown',
 parameters: eventMap['parameters'],
 timestamp: DateTime.tryParse(eventMap['timestamp'] ?? '') ?? DateTime.now(),
 userId: eventMap['userId'],
 sessionId: eventMap['sessionId'] ?? _sessionId ?? '',
 );
 }).toList();
 
 debugPrint('Loaded ${_pendingEvents.length} pending events');
} catch (e) {
 debugPrint('Failed to load pending events: $e');
 _pendingEvents = [];
}
 }

 Future<void> _loadUserProperties() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 final userPropertiesJson = prefs.getString(_userPropertiesKey);
 
 if (userPropertiesJson != null) {
 // Simple JSON parsing - in production, use proper JSON decoder
 final Map<String, dynamic> propertiesMap = {};
 _userProperties = UserProperties(
 userId: propertiesMap['userId'],
 email: propertiesMap['email'],
 role: propertiesMap['role'],
 department: propertiesMap['department'],
 customProperties: propertiesMap['customProperties'],
 );
 }
} catch (e) {
 debugPrint('Failed to load user properties: $e');
}
 }

 void _startFlushTimer() {
 _flushTimer = Timer.periodic(const Duration(minutes: 5), (_) {
 flushEvents();
});
 }

 void setUserId(String userId) {
 _userId = userId;
 _saveUserId();
 
 // Update user properties
 if (_userProperties != null) {
 _userProperties = UserProperties(
 userId: userId,
 email: _userProperties!.email,
 role: _userProperties!.role,
 department: _userProperties!.department,
 customProperties: _userProperties!.customProperties,
 );
 _saveUserProperties();
}
 }

 void setUserProperties({
 String? email,
 String? role,
 String? department,
 Map<String, dynamic>? customProperties,
 }) {
 _userProperties = UserProperties(
 userId: _userId,
 email: email,
 role: role,
 department: department,
 customProperties: customProperties,
 );
 _saveUserProperties();
 }

 Future<void> _saveUserId() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 if (_userId != null) {
 await prefs.setString(_userIdKey, _userId!);
 }
} catch (e) {
 debugPrint('Failed to save user ID: $e');
}
 }

 Future<void> _saveUserProperties() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 if (_userProperties != null) {
 // Simple JSON string - in production, use proper JSON encoder
 await prefs.setString(_userPropertiesKey, _userProperties!.toString());
 }
} catch (e) {
 debugPrint('Failed to save user properties: $e');
}
 }

 void trackEvent(String name, [Map<String, dynamic>? parameters]) {
 if (!_analyticsEnabled || !_isInitialized) r{eturn;

 final event = AnalyticsEvent(
 name: name,
 parameters: parameters,
 timestamp: DateTime.now(),
 userId: _userId,
 sessionId: _sessionId!,
 );

 _pendingEvents.add(event);
 
 // Limit the number of stored events
 if (_pendingEvents.length > _maxEventsToStore) {
 _pendingEvents.removeAt(0);
}

 // Save to local storage
 _savePendingEvents();

 debugPrint('Analytics event tracked: $name');
 }

 void trackScreenView(String screenName, [Map<String, dynamic>? parameters]) {
 trackEvent('screen_view', {
 'screen_name': screenName,
 ...?parameters,
});
 }

 void trackUserAction(String action, [Map<String, dynamic>? parameters]) {
 trackEvent('user_action', {
 'action': action,
 ...?parameters,
});
 }

 void trackError(String error, [String? stackTrace]) {
 trackEvent('error', {
 'error_message': error,
 'stack_trace': stackTrace,
});
 }

 void trackPerformance(String operation, Duration duration, [Map<String, dynamic>? parameters]) {
 trackEvent('performance', {
 'operation': operation,
 'duration_ms': duration.inMilliseconds,
 ...?parameters,
});
 }

 void trackApiCall(String endpoint, String method, int statusCode, Duration duration) {
 trackEvent('api_call', {
 'endpoint': endpoint,
 'method': method,
 'status_code': statusCode,
 'duration_ms': duration.inMilliseconds,
});
 }

 Future<void> _savePendingEvents() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 
 // Simple JSON conversion - in production, use proper JSON encoder
 final eventsJson = _pendingEvents.map((event) => event.toString()).toList();
 await prefs.setStringList(_eventsKey, eventsJson);
} catch (e) {
 debugPrint('Failed to save pending events: $e');
}
 }

 Future<void> flushEvents() {async {
 if (!_analyticsEnabled || _pendingEvents.isEmpty) r{eturn;

 try {
 // In a real implementation, this would send events to your analytics backend
 // For now, we'll just clear the events and log them
 final eventsToSend = List<AnalyticsEvent>.from(_pendingEvents);
 
 for (final event in eventsToSend) {
 debugPrint('Sending analytics event: ${event.name}');
 // Here you would send to your analytics service
 // await _sendEventToBackend(event);
 }
 
 // Clear sent events
 _pendingEvents.clear();
 await _savePendingEvents();
 
 debugPrint('Flushed ${eventsToSend.length} analytics events');
} catch (e) {
 debugPrint('Failed to flush analytics events: $e');
}
 }

 void setAnalyticsEnabled(bool enabled) {
 _analyticsEnabled = enabled;
 
 if (!enabled) {
 // Clear all pending events
 _pendingEvents.clear();
 _savePendingEvents();
}
 }

 Future<List<AnalyticsEvent>> getPendingEvents() async {
 return List<AnalyticsEvent>.from(_pendingEvents);
 }

 Future<void> clearAllData() {async {
 try {
 final prefs = await SharedPreferences.getInstance();
 
 await prefs.remove(_sessionIdKey);
 await prefs.remove(_userIdKey);
 await prefs.remove(_eventsKey);
 await prefs.remove(_userPropertiesKey);
 
 _sessionId = null;
 _userId = null;
 _userProperties = null;
 _pendingEvents.clear();
 
 debugPrint('All analytics data cleared');
} catch (e) {
 debugPrint('Failed to clear analytics data: $e');
}
 }

 Future<Map<String, dynamic>> getAnalyticsSummary() async {
 return {
 'isInitialized': _isInitialized,
 'analyticsEnabled': _analyticsEnabled,
 'sessionId': _sessionId,
 'userId': _userId,
 'pendingEventsCount': _pendingEvents.length,
 'appVersion': _appVersion,
 'deviceInfo': _deviceInfo,
 'userProperties': _userProperties?.toJson(),
};
 }

 void dispose() {
 _flushTimer?.cancel();
 flushEvents();
 }
}

// Extension methods for easy tracking
extension AnalyticsExtensions on AnalyticsService {
 void trackLogin(String method, {String? userId}) {
 trackEvent('login', {
 'method': method,
 'user_id': userId,
});
 }

 void trackLogout() {
 trackEvent('logout');
 }

 void trackSignUp(String method) {
 trackEvent('sign_up', {
 'method': method,
});
 }

 void trackPurchase(String itemId, double amount, String currency) {
 trackEvent('purchase', {
 'item_id': itemId,
 'amount': amount,
 'currency': currency,
});
 }

 void trackSearch(String query, int resultCount) {
 trackEvent('search', {
 'query': query,
 'result_count': resultCount,
});
 }

 void trackShare(String contentType, String contentId) {
 trackEvent('share', {
 'content_type': contentType,
 'content_id': contentId,
});
 }

 void trackDownload(String fileType, double fileSize) {
 trackEvent('download', {
 'file_type': fileType,
 'file_size': fileSize,
});
 }

 void trackFormSubmission(String formName, Map<String, dynamic> formData) {
 trackEvent('form_submission', {
 'form_name': formName,
 'field_count': formData.length,
});
 }

 void trackFeatureUsage(String featureName, {Map<String, dynamic>? properties}) {
 trackEvent('feature_used', {
 'feature_name': featureName,
 ...?properties,
});
 }
}
