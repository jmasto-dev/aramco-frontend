import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/api_response.dart';
import '../../core/utils/constants.dart';
import '../../core/providers/service_providers.dart';

// Modèle pour l'utilisateur
class User extends ChangeNotifier {
 final String id;
 final String email;
 final String firstName;
 final String lastName;
 final String role;
 final String? avatar;
 final bool isActive;
 final DateTime? lastLogin;
 final DateTime createdAt;
 final DateTime updatedAt;

 User({
 required this.id,
 required this.email,
 required this.firstName,
 required this.lastName,
 required this.role,
 this.avatar,
 required this.isActive,
 this.lastLogin,
 required this.createdAt,
 required this.updatedAt,
 });

 factory User.fromJson(Map<String, dynamic> json) {
 return User(
 id: json['id'] as String,
 email: json['email'] as String,
 firstName: json['firstName'] as String,
 lastName: json['lastName'] as String,
 role: json['role'] as String,
 avatar: json['avatar'] as String?,
 isActive: json['isActive'] as bool? ?? true,
 lastLogin: json['lastLogin'] != null 
 ? DateTime.parse(json['lastLogin'] as String) 
 : null,
 createdAt: DateTime.parse(json['createdAt'] as String),
 updatedAt: DateTime.parse(json['updatedAt'] as String),
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'id': id,
 'email': email,
 'firstName': firstName,
 'lastName': lastName,
 'role': role,
 'avatar': avatar,
 'isActive': isActive,
 'lastLogin': lastLogin?.toIso8601String(),
 'createdAt': createdAt.toIso8601String(),
 'updatedAt': updatedAt.toIso8601String(),
 };
 }

 String get fullName => '$firstName $lastName';
 String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

 User copyWith({
 String? id,
 String? email,
 String? firstName,
 String? lastName,
 String? role,
 String? avatar,
 bool? isActive,
 DateTime? lastLogin,
 DateTime? createdAt,
 DateTime? updatedAt,
 }) {
 return User(
 id: id ?? this.id,
 email: email ?? this.email,
 firstName: firstName ?? this.firstName,
 lastName: lastName ?? this.lastName,
 role: role ?? this.role,
 avatar: avatar ?? this.avatar,
 isActive: isActive ?? this.isActive,
 lastLogin: lastLogin ?? this.lastLogin,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 );
 }
}

// État d'authentification
class AuthState extends ChangeNotifier {
 final bool isAuthenticated;
 final User? user;
 final bool isLoading;
 final String? error;
 final bool isBiometricEnabled;

 const AuthState({
 this.isAuthenticated = false,
 this.user,
 this.isLoading = false,
 this.error,
 this.isBiometricEnabled = false,
 });

 AuthState copyWith({
 bool? isAuthenticated,
 User? user,
 bool? isLoading,
 String? error,
 bool? isBiometricEnabled,
 }) {
 return AuthState(
 isAuthenticated: isAuthenticated ?? this.isAuthenticated,
 user: user ?? this.user,
 isLoading: isLoading ?? this.isLoading,
 error: error ?? this.error,
 isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
 );
 }

 @override
 bool operator ==(Object other) {
 if (identical(this, other)) return true;
 return other is AuthState &&
 other.isAuthenticated == isAuthenticated &&
 other.user == user &&
 other.isLoading == isLoading &&
 other.error == error &&
 other.isBiometricEnabled == isBiometricEnabled;
 }

 @override
 int get hashCode {
 return Object.hash(
 isAuthenticated,
 user,
 isLoading,
 error,
 isBiometricEnabled,
 );
 }
}

// Provider pour l'état d'authentification
class AuthNotifier extends StateNotifier<AuthState> {
 final ApiService _apiService;
 final StorageService _storageService;

 AuthNotifier(this._apiService, this._storageService) : super(const AuthState()) {
 _initializeAuth();
 }

 // Initialiser l'authentification au démarrage
 Future<void> _initializeAuth() async {
 try {
 state = state.copyWith(isLoading: true);

 // Vérifier si un token existe
 final token = await _storageService.getToken();
 if (token == null) {
 state = state.copyWith(isLoading: false);
 return;
 }

 // Configurer le token dans le service API
 _apiService.setToken(token);

 // Récupérer les données utilisateur
 final userData = await _storageService.getUserData();
 if (userData != null) {
 final user = User.fromJson(userData);
 
 // Vérifier si l'authentification biométrique est activée
 final isBiometricEnabled = _storageService.isBiometricEnabled() ?? false;
 
 state = state.copyWith(
 isAuthenticated: true,
 user: user,
 isBiometricEnabled: isBiometricEnabled,
 isLoading: false,
 );
 } else {
 // Si pas de données utilisateur, essayer de les récupérer depuis l'API
 await _refreshUserData();
 }
 } catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de l\'initialisation de l\'authentification',
 );
 }
 }

 // Connexion
 Future<bool> login({
 required String email,
 required String password,
 bool rememberMe = false,
 }) async {
 try {
 state = state.copyWith(isLoading: true, error: null);

 final response = await _apiService.post<Map<String, dynamic>>(
 AppConstants.loginEndpoint,
 data: {
 'email': email,
 'password': password,
 'rememberMe': rememberMe,
 },
 );

 if (response.isSuccess && response.data != null) {
 final data = response.data!;
 final token = data['token'] as String;
 final refreshToken = data['refreshToken'] as String?;
 final userData = data['user'] as Map<String, dynamic>;

 // Sauvegarder les tokens
 await _storageService.saveToken(token);
 if (refreshToken != null) {
 await _storageService.saveRefreshToken(refreshToken);
 }

 // Sauvegarder les données utilisateur
 await _storageService.saveUserData(userData);

 // Configurer le token dans le service API
 _apiService.setToken(token);

 final user = User.fromJson(userData);

 state = state.copyWith(
 isAuthenticated: true,
 user: user,
 isLoading: false,
 );

 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
 } catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: AppConstants.networkErrorMessage,
 );
 return false;
 }
 }

 // Déconnexion
 Future<void> logout() async {
 try {
 // Appeler l'endpoint de déconnexion si disponible
 await _apiService.post(AppConstants.logoutEndpoint);
 } catch (e) {
 // Ignorer les erreurs lors de la déconnexion
 } finally {
 // Nettoyer les données locales
 await _clearAuthData();
 
 state = const AuthState();
 }
 }

 // Rafraîchir les données utilisateur
 Future<void> _refreshUserData() async {
 try {
 final response = await _apiService.get<Map<String, dynamic>>(
 '${AppConstants.usersEndpoint}/me',
 );

 if (response.isSuccess && response.data != null) {
 final userData = response.data!;
 await _storageService.saveUserData(userData);
 
 final user = User.fromJson(userData);
 
 state = state.copyWith(
 isAuthenticated: true,
 user: user,
 isLoading: false,
 );
 } else {
 // Si on ne peut pas récupérer les données, déconnecter
 await _clearAuthData();
 state = const AuthState();
 }
 } catch (e) {
 await _clearAuthData();
 state = const AuthState();
 }
 }

 // Mettre à jour le profil utilisateur
 Future<bool> updateProfile({
 String? firstName,
 String? lastName,
 String? avatar,
 }) async {
 try {
 state = state.copyWith(isLoading: true, error: null);

 final data = <String, dynamic>{};
 if (firstName != null) data['firstName'] = firstName;
 if (lastName != null) data['lastName'] = lastName;
 if (avatar != null) data['avatar'] = avatar;

 final response = await _apiService.put<Map<String, dynamic>>(
 '${AppConstants.usersEndpoint}/me',
 data: data,
 );

 if (response.isSuccess && response.data != null) {
 final userData = response.data!;
 await _storageService.saveUserData(userData);
 
 final user = User.fromJson(userData);
 
 state = state.copyWith(
 user: user,
 isLoading: false,
 );

 return true;
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.errorMessage,
 );
 return false;
 }
 } catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: AppConstants.networkErrorMessage,
 );
 return false;
 }
 }

 // Changer le mot de passe
 Future<bool> changePassword({
 required String currentPassword,
 required String newPassword,
 }) async {
 try {
 state = state.copyWith(isLoading: true, error: null);

 final response = await _apiService.post(
 '${AppConstants.usersEndpoint}/change-password',
 data: {
 'currentPassword': currentPassword,
 'newPassword': newPassword,
 },
 );

 state = state.copyWith(isLoading: false);

 if (response.isSuccess) {
 return true;
 } else {
 state = state.copyWith(error: response.errorMessage);
 return false;
 }
 } catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: AppConstants.networkErrorMessage,
 );
 return false;
 }
 }

 // Activer/désactiver l'authentification biométrique
 Future<void> toggleBiometric(bool enabled) async {
 await _storageService.saveBiometricEnabled(enabled);
 state = state.copyWith(isBiometricEnabled: enabled);
 }

 // Vérifier si l'utilisateur a une permission spécifique
 bool hasPermission(String permission) {
 if (!state.isAuthenticated || state.user == null) return false;
 
 final role = state.user!.role;
 final permissions = AppConstants.rolePermissions[role] ?? [];
 return permissions.contains(permission);
 }

 // Vérifier si l'utilisateur a un rôle spécifique
 bool hasRole(String role) {
 return state.user?.role == role;
 }

 // Nettoyer les données d'authentification
 Future<void> _clearAuthData() async {
 await _storageService.removeToken();
 await _storageService.removeRefreshToken();
 await _storageService.removeUserData();
 _apiService.clearToken();
 }

 // Réinitialiser l'erreur
 void clearError() {
 state = state.copyWith(error: null);
 }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
 return AuthNotifier(
 ref.read(apiServiceProvider),
 ref.read(storageServiceProvider),
 );
});

// Providers utilitaires
final currentUserProvider = Provider<User?>((ref) {
 return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
 return ref.watch(authProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
 return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
 return ref.watch(authProvider).error;
});

final biometricEnabledProvider = Provider<bool>((ref) {
 return ref.watch(authProvider).isBiometricEnabled;
});
