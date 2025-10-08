import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  // Initialisation du service
  Future<void> initialize({String? baseUrl}) async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Récupérer le token stocké automatiquement
    await _loadStoredToken();

    // Interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      requestHeader: kDebugMode,
      responseHeader: kDebugMode,
      error: kDebugMode,
      logPrint: (obj) {
        if (kDebugMode) {
          debugPrint(obj.toString());
        }
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Ajouter le token d'authentification
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        
        // Ajouter des headers communs
        options.headers['User-Agent'] = 'Aramco-Frontend/${AppConstants.appVersion}';
        options.headers['X-App-Version'] = AppConstants.appVersion;
        
        if (kDebugMode) {
          debugPrint('REQUEST: ${options.method} ${options.path}');
          debugPrint('HEADERS: ${options.headers}');
          if (options.data != null) {
            debugPrint('DATA: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('DATA: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          debugPrint('MESSAGE: ${error.message}');
          debugPrint('DATA: ${error.response?.data}');
        }
        
        // Gérer les erreurs d'authentification
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        
        handler.next(error);
      },
    ));
  }

  // Charger le token stocké automatiquement
  Future<void> _loadStoredToken() async {
    try {
      final storageService = StorageService();
      await storageService.initialize();
      _token = await storageService.getToken();
      
      if (kDebugMode && _token != null) {
        debugPrint('Token chargé automatiquement depuis le stockage sécurisé');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur lors du chargement du token: $e');
      }
    }
  }

  // Initialisation complète avec authentification automatique
  Future<void> initializeWithAuth({String? baseUrl}) async {
    await initialize(baseUrl: baseUrl);
    
    // Vérifier si l'utilisateur est authentifié
    if (_token != null) {
      if (kDebugMode) {
        debugPrint('Utilisateur déjà authentifié, token actif');
      }
    } else {
      if (kDebugMode) {
        debugPrint('Aucun token trouvé, utilisateur non authentifié');
      }
    }
  }

  // Définir le token d'authentification
  void setToken(String token) {
    _token = token;
  }

  // Supprimer le token d'authentification
  void clearToken() {
    _token = null;
  }

  // Gérer les erreurs 401 (non autorisé)
  void _handleUnauthorized() {
    clearToken();
    // TODO: Naviguer vers l'écran de connexion
    if (kDebugMode) {
      debugPrint('Token expiré ou invalide, redirection vers la connexion');
    }
  }

  // Méthode GET générique
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Méthode POST générique
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Méthode PUT générique
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Méthode DELETE générique
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Méthode PATCH générique
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Upload de fichier
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    File file, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      return _handleResponse<T>(response, fromJson: fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Download de fichier
  Future<ApiResponse<void>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<void>.success(data: null);
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e) {
      return ApiResponse<void>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: 0,
      );
    }
  }

  // Gérer les réponses réussies
  ApiResponse<T> _handleResponse<T>(
    Response response, {
    T Function(dynamic)? fromJson,
  }) {
    try {
      final statusCode = response.statusCode ?? 0;
      
      if (statusCode >= 200 && statusCode < 300) {
        dynamic data = response.data;
        
        // Si la réponse a une structure standard
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            data = data['data'];
          }
          if (data.containsKey('message')) {
            final message = data['message'] as String?;
            if (message != null) {
              return ApiResponse<T>.success(
                data: fromJson != null ? fromJson(data) : data,
                message: message,
                statusCode: statusCode,
              );
            }
          }
        }
        
        return ApiResponse<T>.success(
          data: fromJson != null ? fromJson(data) : data,
          statusCode: statusCode,
        );
      } else {
        return ApiResponse<T>.error(
          message: _extractErrorMessage(response.data),
          statusCode: statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>.error(
        message: AppConstants.serverErrorMessage,
        statusCode: response.statusCode ?? 0,
      );
    }
  }

  // Gérer les erreurs
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = AppConstants.serverErrorMessage;
    int statusCode = 0;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Délai d\'attente dépassé. Veuillez réessayer.';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode ?? 0;
        message = _extractErrorMessage(error.response?.data);
        break;
      case DioExceptionType.cancel:
        message = 'Requête annulée';
        break;
      case DioExceptionType.connectionError:
        message = AppConstants.networkErrorMessage;
        break;
      case DioExceptionType.badCertificate:
        message = 'Erreur de certificat SSL';
        break;
      case DioExceptionType.unknown:
        message = AppConstants.networkErrorMessage;
        break;
    }

    return ApiResponse<T>.error(
      message: message,
      statusCode: statusCode,
    );
  }

  // Extraire le message d'erreur de la réponse
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Essayer différents formats de message d'erreur
      if (data.containsKey('message')) {
        return data['message']?.toString() ?? AppConstants.serverErrorMessage;
      }
      if (data.containsKey('error')) {
        return data['error']?.toString() ?? AppConstants.serverErrorMessage;
      }
      if (data.containsKey('detail')) {
        return data['detail']?.toString() ?? AppConstants.serverErrorMessage;
      }
      
      // Si c'est un objet d'erreurs de validation
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });
          return errorMessages.join(', ');
        }
      }
    }
    
    return AppConstants.serverErrorMessage;
  }

  // Vérifier la connectivité
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les headers de la réponse
  Map<String, dynamic> getResponseHeaders(Response response) {
    return response.headers.map.map(
      (key, value) => MapEntry(key, value.first),
    );
  }
}
