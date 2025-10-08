import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SharedPreferences? _prefs;

  // Initialisation du service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Vérifier si le service est initialisé
  void _checkInitialized() {
    if (_prefs == null) {
      throw Exception('StorageService n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
  }

  // ===== Stockage sécurisé (sensible) =====

  // Sauvegarder une valeur sécurisée
  Future<void> setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde sécurisée: $e');
    }
  }

  // Lire une valeur sécurisée
  Future<String?> getSecureString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture sécurisée: $e');
    }
  }

  // Supprimer une valeur sécurisée
  Future<void> removeSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la suppression sécurisée: $e');
    }
  }

  // Vider tout le stockage sécurisé
  Future<void> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception('Erreur lors du vidage du stockage sécurisé: $e');
    }
  }

  // Vérifier si une clé sécurisée existe
  Future<bool> containsSecureKey(String key) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      throw Exception('Erreur lors de la vérification de la clé sécurisée: $e');
    }
  }

  // ===== Stockage local (non sensible) =====

  // Sauvegarder une chaîne de caractères
  Future<bool> setString(String key, String value) async {
    _checkInitialized();
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la chaîne: $e');
    }
  }

  // Lire une chaîne de caractères
  String? getString(String key) {
    _checkInitialized();
    try {
      return _prefs!.getString(key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture de la chaîne: $e');
    }
  }

  // Sauvegarder un entier
  Future<bool> setInt(String key, int value) async {
    _checkInitialized();
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'entier: $e');
    }
  }

  // Lire un entier
  int? getInt(String key) {
    _checkInitialized();
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture de l\'entier: $e');
    }
  }

  // Sauvegarder un booléen
  Future<bool> setBool(String key, bool value) async {
    _checkInitialized();
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du booléen: $e');
    }
  }

  // Lire un booléen
  bool? getBool(String key) {
    _checkInitialized();
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture du booléen: $e');
    }
  }

  // Sauvegarder un double
  Future<bool> setDouble(String key, double value) async {
    _checkInitialized();
    try {
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du double: $e');
    }
  }

  // Lire un double
  double? getDouble(String key) {
    _checkInitialized();
    try {
      return _prefs!.getDouble(key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture du double: $e');
    }
  }

  // Sauvegarder une liste de chaînes
  Future<bool> setStringList(String key, List<String> value) async {
    _checkInitialized();
    try {
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la liste: $e');
    }
  }

  // Lire une liste de chaînes
  List<String>? getStringList(String key) {
    _checkInitialized();
    try {
      return _prefs!.getStringList(key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture de la liste: $e');
    }
  }

  // Supprimer une clé
  Future<bool> remove(String key) async {
    _checkInitialized();
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // Vider tout le stockage local
  Future<bool> clear() async {
    _checkInitialized();
    try {
      return await _prefs!.clear();
    } catch (e) {
      throw Exception('Erreur lors du vidage du stockage: $e');
    }
  }

  // Vérifier si une clé existe
  bool containsKey(String key) {
    _checkInitialized();
    try {
      return _prefs!.containsKey(key);
    } catch (e) {
      throw Exception('Erreur lors de la vérification de la clé: $e');
    }
  }

  // Obtenir toutes les clés
  Set<String> getKeys() {
    _checkInitialized();
    try {
      return _prefs!.getKeys();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des clés: $e');
    }
  }

  // ===== Méthodes utilitaires pour les objets JSON =====

  // Sauvegarder un objet JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      return await setString(key, jsonEncode(value));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'objet JSON: $e');
    }
  }

  // Lire un objet JSON
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors de la lecture de l\'objet JSON: $e');
    }
  }

  // Sauvegarder un objet JSON sécurisé
  Future<void> setSecureJson(String key, Map<String, dynamic> value) async {
    try {
      await setSecureString(key, jsonEncode(value));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde sécurisée de l\'objet JSON: $e');
    }
  }

  // Lire un objet JSON sécurisé
  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    try {
      final jsonString = await getSecureString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors de la lecture sécurisée de l\'objet JSON: $e');
    }
  }

  // ===== Méthodes spécifiques à l'application =====

  // Gestion du token d'authentification
  Future<void> saveToken(String token) async {
    await setSecureString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return await getSecureString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await removeSecure(AppConstants.tokenKey);
  }

  // Gestion du refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await setSecureString(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await getSecureString(AppConstants.refreshTokenKey);
  }

  Future<void> removeRefreshToken() async {
    await removeSecure(AppConstants.refreshTokenKey);
  }

  // Gestion des données utilisateur
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setSecureJson(AppConstants.userKey, userData);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await getSecureJson(AppConstants.userKey);
  }

  Future<void> removeUserData() async {
    await removeSecure(AppConstants.userKey);
  }

  // Gestion de la langue
  Future<void> saveLanguage(String language) async {
    await setString(AppConstants.languageKey, language);
  }

  String? getLanguage() {
    return getString(AppConstants.languageKey);
  }

  // Gestion du thème
  Future<void> saveTheme(String theme) async {
    await setString(AppConstants.themeKey, theme);
  }

  String? getTheme() {
    return getString(AppConstants.themeKey);
  }

  // Gestion de l'authentification biométrique
  Future<void> saveBiometricEnabled(bool enabled) async {
    await setBool(AppConstants.biometricKey, enabled);
  }

  bool? isBiometricEnabled() {
    return getBool(AppConstants.biometricKey);
  }

  // Gestion du premier lancement
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await setBool(AppConstants.firstLaunchKey, isFirstLaunch);
  }

  bool? isFirstLaunch() {
    return getBool(AppConstants.firstLaunchKey);
  }

  // Gestion du mode hors ligne
  Future<void> setOfflineMode(bool enabled) async {
    await setBool(AppConstants.offlineModeKey, enabled);
  }

  bool? isOfflineMode() {
    return getBool(AppConstants.offlineModeKey);
  }

  // Gestion de la sauvegarde automatique
  Future<void> setAutoBackup(bool enabled) async {
    await setBool(AppConstants.autoBackupKey, enabled);
  }

  bool? isAutoBackup() {
    return getBool(AppConstants.autoBackupKey);
  }

  // Gestion de la dernière synchronisation
  Future<void> setLastSync(DateTime lastSync) async {
    await setString(AppConstants.lastSyncKey, lastSync.toIso8601String());
  }

  DateTime? getLastSync() {
    final lastSyncString = getString(AppConstants.lastSyncKey);
    if (lastSyncString == null) return null;
    try {
      return DateTime.parse(lastSyncString);
    } catch (e) {
      return null;
    }
  }

  // ===== Nettoyage et maintenance =====

  // Nettoyer les données expirées
  Future<void> cleanupExpiredData() async {
    _checkInitialized();
    
    try {
      final keys = getKeys();
      final now = DateTime.now();
      
      for (final key in keys) {
        if (key.endsWith('_expiry')) {
          final expiryString = getString(key);
          if (expiryString != null) {
            final expiry = DateTime.parse(expiryString);
            if (now.isAfter(expiry)) {
              final dataKey = key.replaceAll('_expiry', '');
              await remove(dataKey);
              await remove(key);
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Erreur lors du nettoyage des données expirées: $e');
    }
  }

  // Sauvegarder des données avec expiration
  Future<bool> setWithExpiry(String key, String value, Duration expiry) async {
    _checkInitialized();
    
    try {
      await setString(key, value);
      final expiryTime = DateTime.now().add(expiry);
      await setString('${key}_expiry', expiryTime.toIso8601String());
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde avec expiration: $e');
    }
  }

  // Lire des données avec vérification d'expiration
  String? getWithExpiry(String key) {
    _checkInitialized();
    
    try {
      final expiryString = getString('${key}_expiry');
      if (expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isAfter(expiry)) {
          // Données expirées, les supprimer
          remove(key);
          remove('${key}_expiry');
          return null;
        }
      }
      return getString(key);
    } catch (e) {
      throw Exception('Erreur lors de la lecture avec expiration: $e');
    }
  }

  // Exporter toutes les données (pour le debug)
  Map<String, dynamic> exportAllData() {
    _checkInitialized();
    
    final data = <String, dynamic>{};
    final keys = getKeys();
    
    for (final key in keys) {
      final value = getString(key);
      if (value != null) {
        data[key] = value;
      }
    }
    
    return data;
  }

  // Obtenir des informations sur le stockage
  Future<Map<String, dynamic>> getStorageInfo() async {
    _checkInitialized();
    
    final keys = getKeys();
    final secureKeys = await _secureStorage.readAll();
    
    return {
      'localKeys': keys.length,
      'secureKeys': secureKeys.length,
      'totalKeys': keys.length + secureKeys.length,
      'localStorageKeys': keys.toList(),
      'secureStorageKeys': secureKeys.keys.toList(),
    };
  }

  // ===== Méthodes pour les notifications =====
  
  // Sauvegarder les notifications
  Future<void> saveNotifications(dynamic notifications) async {
    try {
      List<Map<String, dynamic>> notificationMaps = [];
      if (notifications is List) {
        for (var notification in notifications) {
          if (notification is Map<String, dynamic>) {
            notificationMaps.add(notification);
          } else {
            // Convertir l'objet en Map si c'est un objet Notification
            notificationMaps.add(notification.toJson());
          }
        }
      }
      await setJson('notifications', {'data': notificationMaps});
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des notifications: $e');
    }
  }

  // Récupérer les notifications
  Future<List<String>> getNotifications() async {
    try {
      final data = getJson('notifications');
      if (data == null || data['data'] == null) return [];
      return List<String>.from(data['data']);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }
}
