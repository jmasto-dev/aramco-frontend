import 'dart:convert';
import 'dart:async';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'package:aramco_frontend/core/models/api_response.dart';
import 'package:aramco_frontend/core/services/cache_service.dart';
import 'package:aramco_frontend/core/services/api_service.dart';

class RequestConfig {
 final Duration timeout;
 final int maxRetries;
 final Duration retryDelay;
 final bool enableCache;
 final Duration cacheTtl;
 final bool enableCompression;

 const RequestConfig({
 this.timeout = const Duration(seconds: 30),
 this.maxRetries = 3,
 this.retryDelay = const Duration(seconds: 1),
 this.enableCache = true,
 this.cacheTtl = const Duration(minutes: 5),
 this.enableCompression = true,
 });
}

class RequestMetrics {
 final String url;
 final DateTime timestamp;
 final Duration duration;
 final int responseCode;
 final int responseSize;
 final bool fromCache;
 final int retryCount;

 RequestMetrics({
 required this.url,
 required this.timestamp,
 required this.duration,
 required this.responseCode,
 required this.responseSize,
 required this.fromCache,
 this.retryCount = 0,
 });

 @override
 String toString() {
 return 'RequestMetrics(url: $url, duration: ${duration.inMilliseconds}ms, '
 'status: $responseCode, size: ${responseSize}B, cached: $fromCache, '
 'retries: $retryCount)';
 }
}

class OptimizedApiService {
 static final OptimizedApiService _instance = OptimizedApiService._internal();
 factory OptimizedApiService() => _instance;
 OptimizedApiService._internal();

 final CacheService _cache = CacheService();
 final RequestConfig _defaultConfig = const RequestConfig();
 final List<RequestMetrics> _metrics = [];
 final Map<String, DateTime> _rateLimitTracker = {};
 final Map<String, Completer<http.Response>> _pendingRequests = {};

 Future<void> initialize() {async {
 await _cache.initialize();
 }

 Future<ApiResponse<T>> get<T>(
 String url, {
 Map<String, dynamic>? queryParameters,
 Map<String, String>? headers,
 RequestConfig? config,
 bool forceRefresh = false,
 }) async {
 final requestConfig = config ?? _defaultConfig;
 final fullUrl = _buildUrl(url, queryParameters);
 final cacheKey = _generateCacheKey(fullUrl, queryParameters);

 // Vérifier le cache d'abord
 if (requestConfig.enableCache && !forceRefresh) {
 final cachedResponse = await _cache.getCachedResponse<T>(fullUrl, params: queryParameters);
 if (cachedResponse != null) {
 _recordMetrics(fullUrl, Duration.zero, 200, 0, true, 0);
 return cachedResponse;
 }
}

 // Vérifier si une requête identique est en cours
 if (_pendingRequests.containsKey(cacheKey)){ {
 final response = await _pendingRequests[cacheKey]!.future;
 return _parseResponse<T>(response);
}

 // Appliquer le rate limiting
 await _applyRateLimiting(url);

 // Exécuter la requête avec retry
 final response = await _executeWithRetry<T>(
 () => _performGet(fullUrl, headers, requestConfig),
 requestConfig,
 url,
 );

 // Parser et mettre en cache la réponse
 final apiResponse = _parseResponse<T>(response);
 
 if (requestConfig.enableCache && apiResponse.success) {
 await _cache.setCachedResponse(
 fullUrl,
 apiResponse,
 ttl: requestConfig.cacheTtl,
 params: queryParameters,
 );
}

 return apiResponse;
 }

 Future<ApiResponse<T>> post<T>(
 String url, {
 Map<String, dynamic>? data,
 Map<String, String>? headers,
 RequestConfig? config,
 }) async {
 final requestConfig = config ?? _defaultConfig;
 
 // Les requêtes POST ne sont généralement pas mises en cache
 final response = await _executeWithRetry<T>(
 () => _performPost(url, data, headers, requestConfig),
 requestConfig,
 url,
 );

 return _parseResponse<T>(response);
 }

 Future<ApiResponse<T>> put<T>(
 String url, {
 Map<String, dynamic>? data,
 Map<String, String>? headers,
 RequestConfig? config,
 }) async {
 final requestConfig = config ?? _defaultConfig;
 
 // Invalider le cache lié à cette ressource
 await _cache.invalidatePattern(url);

 final response = await _executeWithRetry<T>(
 () => _performPut(url, data, headers, requestConfig),
 requestConfig,
 url,
 );

 return _parseResponse<T>(response);
 }

 Future<ApiResponse<T>> delete<T>(
 String url, {
 Map<String, String>? headers,
 RequestConfig? config,
 }) async {
 final requestConfig = config ?? _defaultConfig;
 
 // Invalider le cache lié à cette ressource
 await _cache.invalidatePattern(url);

 final response = await _executeWithRetry<T>(
 () => _performDelete(url, headers, requestConfig),
 requestConfig,
 url,
 );

 return _parseResponse<T>(response);
 }

 Future<http.Response> _performGet(
 String url,
 Map<String, String>? headers,
 RequestConfig config,
 ) async {
 final requestHeaders = {
 'Content-Type': 'application/json',
 'Accept': 'application/json',
 if (config.enableCompression) '{Accept-Encoding': 'gzip, deflate',
 ...?headers,
};

 return await http
 .get(Uri.parse(url), headers: requestHeaders)
 .timeout(config.timeout);
 }

 Future<http.Response> _performPost(
 String url,
 Map<String, dynamic>? data,
 Map<String, String>? headers,
 RequestConfig config,
 ) async {
 final requestHeaders = {
 'Content-Type': 'application/json',
 'Accept': 'application/json',
 if (config.enableCompression) '{Accept-Encoding': 'gzip, deflate',
 ...?headers,
};

 final body = data != null ? jsonEncode(data) : null;
 
 return await http
 .post(Uri.parse(url), headers: requestHeaders, body: body)
 .timeout(config.timeout);
 }

 Future<http.Response> _performPut(
 String url,
 Map<String, dynamic>? data,
 Map<String, String>? headers,
 RequestConfig config,
 ) async {
 final requestHeaders = {
 'Content-Type': 'application/json',
 'Accept': 'application/json',
 if (config.enableCompression) '{Accept-Encoding': 'gzip, deflate',
 ...?headers,
};

 final body = data != null ? jsonEncode(data) : null;
 
 return await http
 .put(Uri.parse(url), headers: requestHeaders, body: body)
 .timeout(config.timeout);
 }

 Future<http.Response> _performDelete(
 String url,
 Map<String, String>? headers,
 RequestConfig config,
 ) async {
 final requestHeaders = {
 'Content-Type': 'application/json',
 'Accept': 'application/json',
 if (config.enableCompression) '{Accept-Encoding': 'gzip, deflate',
 ...?headers,
};

 return await http
 .delete(Uri.parse(url), headers: requestHeaders)
 .timeout(config.timeout);
 }

 Future<http.Response> _executeWithRetry<T>(
 Future<http.Response> Function() requestFunction,
 RequestConfig config,
 String url,
 ) async {
 int retryCount = 0;
 http.Response? lastResponse;

 while (retryCount <= config.maxRetries) {
 try {
 final stopwatch = Stopwatch()..start();
 final response = await requestFunction();
 stopwatch.stop();

 // Enregistrer les métriques
 _recordMetrics(url, stopwatch.elapsed, response.statusCode, 
 response.contentLength ?? 0, false, retryCount);

 // Vérifier si c'est une erreur temporaire
 if (_isTemporaryError(response.statusCode) &{& retryCount < config.maxRetries) {
 retryCount++;
 lastResponse = response;
 await Future.delayed(config.retryDelay * retryCount);
 continue;
 }

 return response;
 } catch (e) {
 retryCount++;
 
 if (retryCount > config.maxRetries) {
 _recordMetrics(url, Duration.zero, 0, 0, false, retryCount - 1);
 rethrow;
 }

 await Future.delayed(config.retryDelay * retryCount);
 }
}

 return lastResponse!;
 }

 bool _isTemporaryError(int statusCode) {
 // Codes d'erreur qui peuvent être temporaires
 return statusCode == 429 || // Too Many Requests
 statusCode == 502 || // Bad Gateway
 statusCode == 503 || // Service Unavailable
 statusCode == 504; // Gateway Timeout
 ;

 ApiResponse<T> _parseResponse<T>(http.Response response) {
 try {
 final responseData = jsonDecode(response.body);
 
 if (response.statusCode >= 200 && response.statusCode < 300) {
 return ApiResponse<T>.success(
 data: responseData is Map ? responseData as T : responseData,
 message: responseData['message'] ?? 'Success',
 statusCode: response.statusCode,
 );
 } else {
 return ApiResponse<T>.error(
 message: responseData['message'] ?? 'Request failed',
 statusCode: response.statusCode,
 );
 }
} catch (e) {
 return ApiResponse<T>.error(
 message: 'Failed to parse response: $e',
 statusCode: response.statusCode,
 );
}
 }

 String _buildUrl(String baseUrl, Map<String, dynamic>? params) {
 if (params == null || params.isEmpty) r{eturn baseUrl;
 
 final queryString = params.entries
 .where((e) => e.value != null)
 .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
 .join('&');
 
 return queryString.isEmpty ? baseUrl : '$baseUrl?$queryString';
 }

 String _generateCacheKey(String url, Map<String, dynamic>? params) {
 final keyData = '$url${params?.toString() ?? ''}';
 return keyData.hashCode.toString();
 }

 Future<void> _applyRateLimiting(String url) {async {
 final domain = Uri.parse(url).host;
 final now = DateTime.now();
 final lastRequest = _rateLimitTracker[domain];
 
 if (lastRequest != null) {
 final timeSinceLastRequest = now.difference(lastRequest);
 const minInterval = Duration(milliseconds: 100); // 10 requêtes par seconde max
 
 if (timeSinceLastRequest < minInterval) {
 await Future.delayed(minInterval - timeSinceLastRequest);
 }
}
 
 _rateLimitTracker[domain] = DateTime.now();
 }

 void _recordMetrics(
 String url,
 Duration duration,
 int statusCode,
 int responseSize,
 bool fromCache,
 int retryCount,
 ) {
 final metrics = RequestMetrics(
 url: url,
 timestamp: DateTime.now(),
 duration: duration,
 responseCode: statusCode,
 responseSize: responseSize,
 fromCache: fromCache,
 retryCount: retryCount,
 );

 _metrics.add(metrics);
 
 // Garder seulement les 1000 dernières métriques
 if (_metrics.length > 1000) {
 _metrics.removeRange(0, _metrics.length - 1000);
}
 }

 Future<List<ApiResponse<T>>> batchRequest<T>(
 List<String> urls, {
 Map<String, dynamic>? queryParameters,
 Map<String, String>? headers,
 RequestConfig? config,
 int concurrency = 5,
 }) async {
 final semaphore = _Semaphore(concurrency);
 final futures = urls.map((url) async {
 await semaphore.acquire();
 try {
 return await get<T>(url, queryParameters: queryParameters, headers: headers, config: config);
 } finally {
 semaphore.release();
 }
});

 return await Future.wait(futures);
 }

 Future<void> preloadData<T>(
 List<String> urls,
 Map<String, dynamic>? queryParameters,
 Map<String, String>? headers,
 RequestConfig? config,
 ) async {
 await batchRequest<T>(urls, 
 queryParameters: queryParameters,
 headers: headers,
 config: config,
 concurrency: 3, // Moins de concurrence pour le préchargement
 );
 }

 PerformanceMetrics getPerformanceMetrics() {
 if (_metrics.isEmpty) {
 return PerformanceMetrics(
 totalRequests: 0,
 averageResponseTime: Duration.zero,
 cacheHitRate: 0.0,
 errorRate: 0.0,
 retryRate: 0.0,
 );
}

 final totalRequests = _metrics.length;
 final cachedRequests = _metrics.where((m) => m.fromCache).length;
 final errorRequests = _metrics.where((m) => m.responseCode >= 400).length;
 final retriedRequests = _metrics.where((m) => m.retryCount > 0).length;
 
 final totalDuration = _metrics
 .where((m) => !m.fromCache)
 .map((m) => m.duration)
 .fold(Duration.zero, (sum, d) => sum + d);
 
 final nonCachedRequests = totalRequests - cachedRequests;
 final averageResponseTime = nonCachedRequests > 0 
 ? Duration(milliseconds: totalDuration.inMilliseconds ~/ nonCachedRequests)
 : Duration.zero;

 return PerformanceMetrics(
 totalRequests: totalRequests,
 averageResponseTime: averageResponseTime,
 cacheHitRate: cachedRequests / totalRequests,
 errorRate: errorRequests / totalRequests,
 retryRate: retriedRequests / totalRequests,
 );
 }

 Future<void> clearCache() {async {
 await _cache.clear();
 }

 Future<CacheStats> getCacheStats() {async {
 return await _cache.getStats();
 }

 List<RequestMetrics> getRecentMetrics({int limit = 50}) {
 return _metrics.reversed.take(limit).toList();
 }
}

class PerformanceMetrics {
 final int totalRequests;
 final Duration averageResponseTime;
 final double cacheHitRate;
 final double errorRate;
 final double retryRate;

 const PerformanceMetrics({
 required this.totalRequests,
 required this.averageResponseTime,
 required this.cacheHitRate,
 required this.errorRate,
 required this.retryRate,
 });

 @override
 String toString() {
 return 'PerformanceMetrics('
 'requests: $totalRequests, '
 'avgTime: ${averageResponseTime.inMilliseconds}ms, '
 'cacheHit: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
 'errorRate: ${(errorRate * 100).toStringAsFixed(1)}%, '
 'retryRate: ${(retryRate * 100).toStringAsFixed(1)}%)';
 }
}

class _Semaphore {
 final int maxCount;
 int _currentCount;
 final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

 _Semaphore(this.maxCount) : _currentCount = maxCount;

 Future<void> acquire() {async {
 if (_currentCount > 0) {
 _currentCount--;
 return;
}

 final completer = Completer<void>();
 _waitQueue.add(completer);
 return completer.future;
 }

 void release() {
 if (_waitQueue.isNotEmpty) {
 final completer = _waitQueue.removeFirst();
 completer.complete();
} else {
 _currentCount++;
}
 }
}

// Extension pour faciliter l'utilisation avec les providers existants
extension OptimizedApiServiceExtension on OptimizedApiService {
 Future<ApiResponse<List<T>>> getPaginated<T>(
 String baseUrl, {
 int page = 1,
 int limit = 20,
 Map<String, dynamic>? additionalParams,
 RequestConfig? config,
 }) async {
 final params = {
 'page': page,
 'limit': limit,
 ...?additionalParams,
};

 return await get<List<T>>(baseUrl, queryParameters: params, config: config);
 }

 Future<ApiResponse<T>> getWithCache<T>(
 String url, {
 Map<String, dynamic>? queryParameters,
 Duration? cacheTtl,
 bool forceRefresh = false,
 }) async {
 final config = RequestConfig(
 enableCache: true,
 cacheTtl: cacheTtl ?? const Duration(minutes: 5),
 );

 return await get<T>(
 url,
 queryParameters: queryParameters,
 config: config,
 forceRefresh: forceRefresh,
 );
 }
}
