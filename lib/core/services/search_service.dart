import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import 'package:logger/logger.dart';
import 'api_service.dart';

class SearchResult {
 final String type;
 final String id;
 final String title;
 final String? subtitle;
 final String? description;
 final Map<String, dynamic>? metadata;
 final DateTime createdAt;
 final String? actionUrl;

 SearchResult({
 required this.type,
 required this.id,
 required this.title,
 this.subtitle,
 this.description,
 this.metadata,
 required this.createdAt,
 this.actionUrl,
 });

 factory SearchResult.fromJson(Map<String, dynamic> json) {
 return SearchResult(
 type: json['type'] as String,
 id: json['id'] as String,
 title: json['title'] as String,
 subtitle: json['subtitle'] as String?,
 description: json['description'] as String?,
 metadata: json['metadata'] as Map<String, dynamic>?,
 createdAt: DateTime.parse(json['created_at'] as String),
 actionUrl: json['action_url'] as String?,
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'type': type,
 'id': id,
 'title': title,
 'subtitle': subtitle,
 'description': description,
 'metadata': metadata,
 'created_at': createdAt.toIso8601String(),
 'action_url': actionUrl,
};
 }
}

class SearchFilters {
 final List<String> types;
 final String? dateRange;
 final DateTime? startDate;
 final DateTime? endDate;
 final Map<String, dynamic>? customFilters;

 SearchFilters({
 this.types = const [],
 this.dateRange,
 this.startDate,
 this.endDate,
 this.customFilters,
 });

 Map<String, dynamic> toJson() {
 final data = <String, dynamic>{};
 
 if (types.isNotEmpty) {
 data['types'] = types;
}
 
 if (dateRange != null) {
 data['date_range'] = dateRange;
}
 
 if (startDate != null) {
 data['start_date'] = startDate!.toIso8601String();
}
 
 if (endDate != null) {
 data['end_date'] = endDate!.toIso8601String();
}
 
 if (customFilters != null) {
 data.addAll(customFilters!);
}
 
 return data;
 }
}

class SearchService {
 final ApiService _apiService;

 SearchService(this._apiService);

 // Recherche globale
 Future<ApiResponse<List<SearchResult>>> globalSearch({
 required String query,
 SearchFilters? filters,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'q': query,
 'page': page,
 'limit': limit,
 };

 if (filters != null) {
 queryParams.addAll(filters.toJson());
 }

 final ApiResponse<dynamic> response = await _apiService.get(
 '/search',
 queryParameters: queryParams,
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final results = (data['data']['results'] as List)
 .map((json) => SearchResult.fromJson(json))
 .toList();

 return ApiResponse<List<SearchResult>>.success(
 data: results,
 message: 'Recherche effectuée avec succès',
 pagination: data['data']['pagination'],
 );
 } else {
 return ApiResponse<List<SearchResult>>.error(
 'Erreur lors de la recherche',
 );
 }
} catch (e) {
 return ApiResponse<List<SearchResult>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Recherche par type spécifique
 Future<ApiResponse<List<SearchResult>>> searchByType({
 required String type,
 required String query,
 Map<String, dynamic>? filters,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'q': query,
 'page': page,
 'limit': limit,
 };

 if (filters != null) {
 queryParams.addAll(filters);
 }

 final ApiResponse<dynamic> response = await _apiService.get(
 '/search/$type',
 queryParameters: queryParams,
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final results = (data['data']['results'] as List)
 .map((json) => SearchResult.fromJson(json))
 .toList();

 return ApiResponse<List<SearchResult>>.success(
 data: results,
 message: 'Recherche effectuée avec succès',
 pagination: data['data']['pagination'],
 );
 } else {
 return ApiResponse<List<SearchResult>>.error(
 'Erreur lors de la recherche',
 );
 }
} catch (e) {
 return ApiResponse<List<SearchResult>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Suggestions de recherche
 Future<ApiResponse<List<String>>> getSearchSuggestions(String query) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get(
 '/search/suggestions',
 queryParameters: {'q': query},
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final suggestions = (data['data'] as List).cast<String>();

 return ApiResponse<List<String>>.success(
 data: suggestions,
 message: 'Suggestions récupérées avec succès',
 );
 } else {
 return ApiResponse<List<String>>.error(
 'Erreur lors de la récupération des suggestions',
 );
 }
} catch (e) {
 return ApiResponse<List<String>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Historique de recherche
 Future<ApiResponse<List<String>>> getSearchHistory() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('/search/history');

 if (response.statusCode == 200) {
 final data = response.data;
 final history = (data['data'] as List).cast<String>();

 return ApiResponse<List<String>>.success(
 data: history,
 message: 'Historique récupéré avec succès',
 );
 } else {
 return ApiResponse<List<String>>.error(
 'Erreur lors de la récupération de l\'historique',
 );
 }
} catch (e) {
 return ApiResponse<List<String>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Ajouter une recherche à l'historique
 Future<ApiResponse<bool>> addToSearchHistory(String query) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/search/history',
 data: {'query': query},
 );

 if (response.statusCode == 201) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Recherche ajoutée à l\'historique',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors de l\'ajout à l\'historique',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Vider l'historique de recherche
 Future<ApiResponse<bool>> clearSearchHistory() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete('/search/history');

 if (response.statusCode == 200) {
 return ApiResponse<bool>.success(
 data: true,
 message: 'Historique vidé avec succès',
 );
 } else {
 return ApiResponse<bool>.error(
 'Erreur lors du vidage de l\'historique',
 );
 }
} catch (e) {
 return ApiResponse<bool>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Recherches populaires
 Future<ApiResponse<List<String>>> getPopularSearches() async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get('/search/popular');

 if (response.statusCode == 200) {
 final data = response.data;
 final popular = (data['data'] as List).cast<String>();

 return ApiResponse<List<String>>.success(
 data: popular,
 message: 'Recherches populaires récupérées avec succès',
 );
 } else {
 return ApiResponse<List<String>>.error(
 'Erreur lors de la récupération des recherches populaires',
 );
 }
} catch (e) {
 return ApiResponse<List<String>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Recherche rapide (employés, commandes, etc.)
 Future<ApiResponse<Map<String, List<SearchResult>>>> quickSearch(String query) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get(
 '/search/quick',
 queryParameters: {'q': query},
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final results = <String, List<SearchResult>>{};

 for (final entry in (data['data'] as Map).entries) {
 results[entry.key] = (entry.value as List)
 .map((json) => SearchResult.fromJson(json))
 .toList();
 }

 return ApiResponse<Map<String, List<SearchResult>>>.success(
 data: results,
 message: 'Recherche rapide effectuée avec succès',
 );
 } else {
 return ApiResponse<Map<String, List<SearchResult>>>.error(
 'Erreur lors de la recherche rapide',
 );
 }
} catch (e) {
 return ApiResponse<Map<String, List<SearchResult>>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Recherche avancée avec filtres multiples
 Future<ApiResponse<List<SearchResult>>> advancedSearch({
 required String query,
 required Map<String, dynamic> filters,
 List<String>? sortBy,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, dynamic>{
 'q': query,
 'page': page,
 'limit': limit,
 ...filters,
 };

 if (sortBy != null && sortBy.isNotEmpty) {
 queryParams['sort_by'] = sortBy.join(',');
 }

 final ApiResponse<dynamic> response = await _apiService.post(
 '/search/advanced',
 data: queryParams,
 );

 if (response.statusCode == 200) {
 final data = response.data;
 final results = (data['data']['results'] as List)
 .map((json) => SearchResult.fromJson(json))
 .toList();

 return ApiResponse<List<SearchResult>>.success(
 data: results,
 message: 'Recherche avancée effectuée avec succès',
 pagination: data['data']['pagination'],
 );
 } else {
 return ApiResponse<List<SearchResult>>.error(
 'Erreur lors de la recherche avancée',
 );
 }
} catch (e) {
 return ApiResponse<List<SearchResult>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }

 // Analyser une requête de recherche
 Future<ApiResponse<Map<String, dynamic>>> analyzeQuery(String query) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post(
 '/search/analyze',
 data: {'query': query},
 );

 if (response.statusCode == 200) {
 final data = response.data;

 return ApiResponse<Map<String, dynamic>>.success(
 data: data['data'],
 message: 'Analyse de la requête effectuée avec succès',
 );
 } else {
 return ApiResponse<Map<String, dynamic>>.error(
 'Erreur lors de l\'analyse de la requête',
 );
 }
} catch (e) {
 return ApiResponse<Map<String, dynamic>>.error(
 'Erreur de connexion: ${e.toString()}',
 );
}
 }
}
