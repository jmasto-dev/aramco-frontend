part 'apiresponse.g.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

/// Modèle de réponse API générique pour gérer les réponses du backend
class ApiResponse<T> extends Equatable {
  final T? data;
  final String? message;
  final bool success;
  final int statusCode;
  final List<String>? errors;

  const ApiResponse({
    this.data,
    this.message,
    required this.success,
    required this.statusCode,
    this.errors,
  });

  /// Constructeur pour une réponse réussie
  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }

  /// Constructeur pour une réponse d'erreur
  factory ApiResponse.error({
    required String message,
    int statusCode = 400,
    List<String>? errors,
  }) {
    return ApiResponse<T>(
      message: message,
      success: false,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Constructeur pour une réponse en cours de chargement
  factory ApiResponse.loading({String? message}) {
    return ApiResponse<T>(
      message: message ?? 'Chargement en cours...',
      success: false,
      statusCode: 0,
    );
  }

  /// Vérifier si la réponse est réussie
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;

  /// Vérifier si la réponse est une erreur client (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Vérifier si la réponse est une erreur serveur (5xx)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// Vérifier si la réponse est une erreur d'authentification
  bool get isUnauthorized => statusCode == 401;

  /// Vérifier si la réponse est une erreur d'autorisation
  bool get isForbidden => statusCode == 403;

  /// Vérifier si la réponse est une erreur de ressource non trouvée
  bool get isNotFound => statusCode == 404;

  /// Obtenir le message d'erreur principal
  String get errorMessage {
    if (message != null) return message!;
    if (errors != null && errors!.isNotEmpty) return errors!.first;
    return 'Erreur inconnue';
  }

  /// Obtenir tous les messages d'erreur
  List<String> get allErrors {
    final List<String> allErrorMessages = [];
    if (message != null) allErrorMessages.add(message!);
    if (errors != null) allErrorMessages.addAll(errors!);
    return allErrorMessages;
  }

  /// Convertir en Map pour le JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': message,
      'success': success,
      'statusCode': statusCode,
      'errors': errors,
    };
  }

  /// Créer depuis une Map (JSON)
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    final data = json['data'];
    final message = json['message'] as String?;
    final success = json['success'] as bool? ?? false;
    final statusCode = json['statusCode'] as int? ?? 0;
    final errors = (json['errors'] as List<dynamic>?)?.cast<String>();

    return ApiResponse<T>(
      data: fromJson != null && data != null ? fromJson(data) : data,
      message: message,
      success: success,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Copier avec modification
  ApiResponse<T> copyWith({
    T? data,
    String? message,
    bool? success,
    int? statusCode,
    List<String>? errors,
  }) {
    return ApiResponse<T>(
      data: data ?? this.data,
      message: message ?? this.message,
      success: success ?? this.success,
      statusCode: statusCode ?? this.statusCode,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        data,
        message,
        success,
        statusCode,
        errors,
      ];

  @override
  String toString() {
    return 'ApiResponse<T>('
        'data: $data, '
        'message: $message, '
        'success: $success, '
        'statusCode: $statusCode, '
        'errors: $errors'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponse<T> &&
        other.data == data &&
        other.message == message &&
        other.success == success &&
        other.statusCode == statusCode &&
        other.errors == errors;
  }

  @override
  int get hashCode {
    return Object.hash(
      data,
      message,
      success,
      statusCode,
      errors,
    );
  }
}

/// Extension pour faciliter la création de réponses
extension ApiResponseExtension<T> on ApiResponse<T> {
  /// Transformer les données
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return ApiResponse<R>.success(
        data: mapper(data!),
        message: message,
        statusCode: statusCode,
      );
    }
    return ApiResponse<R>.error(
      message: errorMessage,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Appliquer une fonction en cas de succès
  ApiResponse<T> onSuccess(void Function(T data) onSuccess) {
    if (isSuccess && data != null) {
      onSuccess(data!);
    }
    return this;
  }

  /// Appliquer une fonction en cas d'erreur
  ApiResponse<T> onError(void Function(String message) onError) {
    if (!isSuccess) {
      onError(errorMessage);
    }
    return this;
  }
}

/// Classe pour les réponses paginées
class PaginatedResponse<T> extends Equatable {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Constructeur depuis une Map (JSON)
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final data = (json['data'] as List<dynamic>?)
            ?.map((item) => fromJson(item))
            .toList() ??
        [];

    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse<T>(
      data: data,
      currentPage: pagination['currentPage'] as int? ?? 1,
      totalPages: pagination['totalPages'] as int? ?? 0,
      totalItems: pagination['totalItems'] as int? ?? 0,
      pageSize: pagination['pageSize'] as int? ?? 10,
      hasNextPage: pagination['hasNextPage'] as bool? ?? false,
      hasPreviousPage: pagination['hasPreviousPage'] as bool? ?? false,
    );
  }

  /// Vérifier s'il y a des données
  bool get hasData => data.isNotEmpty;

  /// Vérifier si c'est la première page
  bool get isFirstPage => currentPage == 1;

  /// Vérifier si c'est la dernière page
  bool get isLastPage => currentPage == totalPages;

  /// Obtenir le nombre d'éléments restants
  int get remainingItems => totalItems - (currentPage * pageSize);

  /// Obtenir le pourcentage de progression
  double get progressPercentage => totalPages > 0 ? currentPage / totalPages : 0.0;

  @override
  List<Object?> get props => [
        data,
        currentPage,
        totalPages,
        totalItems,
        pageSize,
        hasNextPage,
        hasPreviousPage,
      ];

  @override
  String toString() {
    return 'PaginatedResponse<T>('
        'data: ${data.length} items, '
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'totalItems: $totalItems, '
        'pageSize: $pageSize'
        ')';
  }
}

/// Extension pour les réponses paginées
extension PaginatedResponseExtension<T> on PaginatedResponse<T> {
  /// Transformer les données
  PaginatedResponse<R> map<R>(R Function(T data) mapper) {
    return PaginatedResponse<R>(
      data: data.map(mapper).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      pageSize: pageSize,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  /// Filtrer les données
  PaginatedResponse<T> where(bool Function(T item) predicate) {
    final filteredData = data.where(predicate).toList();
    return PaginatedResponse<T>(
      data: filteredData,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: filteredData.length,
      pageSize: pageSize,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }
}

/// Types de réponses API courants
typedef SuccessResponse<T> = ApiResponse<T>;
typedef ErrorResponse = ApiResponse<void>;
typedef LoadingResponse = ApiResponse<void>;

/// Codes d'erreur HTTP courants
@JsonSerializable()
class \1 {
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
}

/// Messages d'erreur courants
@JsonSerializable()
class \1 {
  static const String networkError = 'Erreur de connexion réseau';
  static const String serverError = 'Erreur interne du serveur';
  static const String unauthorized = 'Non autorisé';
  static const String forbidden = 'Accès interdit';
  static const String notFound = 'Ressource non trouvée';
  static const String timeout = 'Délai d\'attente dépassé';
  static const String unknownError = 'Erreur inconnue';
  static const String invalidData = 'Données invalides';
  static const String validationError = 'Erreur de validation';
}

/// Utilitaires pour les réponses API
@JsonSerializable()
class \1 {
  /// Créer une réponse de succès depuis une réponse HTTP
  static ApiResponse<T> createSuccessResponse<T>(
    T data, {
    String? message,
    int statusCode = HttpStatusCodes.ok,
  }) {
    return ApiResponse<T>.success(
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Créer une réponse d'erreur depuis une réponse HTTP
  static ApiResponse<T> createErrorResponse<T>(
    String message, {
    int statusCode = HttpStatusCodes.badRequest,
    List<String>? errors,
  }) {
    return ApiResponse<T>.error(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Créer une réponse de chargement
  static ApiResponse<T> createLoadingResponse<T>({
    String? message,
  }) {
    return ApiResponse<T>.loading(message: message);
  }

  /// Gérer les erreurs HTTP courantes
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case HttpStatusCodes.badRequest:
        return 'Requête invalide';
      case HttpStatusCodes.unauthorized:
        return ErrorMessages.unauthorized;
      case HttpStatusCodes.forbidden:
        return ErrorMessages.forbidden;
      case HttpStatusCodes.notFound:
        return ErrorMessages.notFound;
      case HttpStatusCodes.internalServerError:
        return ErrorMessages.serverError;
      case HttpStatusCodes.serviceUnavailable:
        return 'Service indisponible';
      default:
        return ErrorMessages.unknownError;
    }
  }
}
