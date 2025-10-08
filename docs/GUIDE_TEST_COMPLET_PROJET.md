# Guide Complet de Test du Projet Aramco SA

## Table des Matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Tests de Connexion Frontend-Backend](#tests-de-connexion-frontend-backend)
4. [Tests d'Intégration](#tests-dintégration)
5. [Tests de Performance](#tests-de-performance)
6. [Tests End-to-End (E2E)]#tests-end-to-end-e2e)
7. [Dépannage](#dépannage)
8. [Rapport de Tests](#rapport-de-tests)

## Introduction

Ce guide fournit une procédure complète pour tester l'intégration entre le frontend Flutter et le backend Laravel du projet Aramco SA.

## Prérequis

### 1. Environnement de Développement

- **Backend Laravel**: Démarré sur `http://localhost:8000`
- **Frontend Flutter**: Configuré pour pointer vers le backend
- **Base de données**: PostgreSQL configurée et peuplée
- **Dependencies**: Toutes les packages installées

### 2. Vérification de l'Environnement

```bash
# Vérifier que le backend est démarré
curl http://localhost:8000/api/v1/health

# Vérifier les dépendances Flutter
flutter doctor

# Vérifier les dépendances backend
cd aramco-backend && composer install && npm install
```

## Tests de Connexion Frontend-Backend

### 1. Script de Test Automatisé

Exécutez le script de test de connexion :

```bash
# Exécuter le script de test
dart scripts/test_backend_connection.dart
```

Ce script teste :
- ✅ Connectivité de base au backend
- ✅ Authentification JWT
- ✅ Accès aux endpoints protégés
- ✅ Validation des modèles de données
- ✅ Configuration des constantes

### 2. Tests Manuels

#### Test 1: Health Check

```bash
curl -X GET http://localhost:8000/api/v1/health \
  -H "Accept: application/json" \
  -H "User-Agent: Aramco-Frontend-Test/1.0.0"
```

**Résultat attendu :**
```json
{
  "status": "success",
  "message": "API is running",
  "data": {
    "environment": "local",
    "version": "1.0.0",
    "database": "connected",
    "cache": "connected"
  }
}
```

#### Test 2: Authentification

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@aramco-sa.com",
    "password": "password123"
  }'
```

**Résultat attendu :**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "1",
      "email": "admin@aramco-sa.com",
      "full_name": "Admin User",
      "roles": ["admin"],
      "permissions": ["users.create", "users.read", ...]
    }
  }
}
```

#### Test 3: Accès aux Endpoints Protégés

```bash
# Remplacer TOKEN par le token obtenu précédemment
curl -X GET http://localhost:8000/api/v1/users \
  -H "Accept: application/json" \
  -H "Authorization: Bearer TOKEN"
```

## Tests d'Intégration

### 1. Exécuter les Tests d'Intégration Flutter

```bash
# Exécuter tous les tests d'intégration
flutter test test/integration/

# Exécuter uniquement les tests de backend
flutter test test/integration/backend_integration_test.dart
```

### 2. Tests des Modèles de Données

Les tests valident que les structures de données du backend correspondent aux modèles du frontend :

- ✅ **User Model**: ID, email, nom, rôles, permissions
- ✅ **Employee Model**: Informations employé, département, salaire
- ✅ **Order Model**: Commandes, articles, statuts
- ✅ **Product Model**: Produits, prix, stocks
- ✅ **Dashboard Model**: Widgets, KPIs, graphiques

### 3. Tests des Endpoints API

| Endpoint | Méthode | Test | Statut |
|----------|---------|------|--------|
| `/health` | GET | ✅ Connectivité | Pass |
| `/auth/login` | POST | ✅ Authentification | Pass |
| `/users` | GET | ✅ Liste utilisateurs | Pass |
| `/employees` | GET | ✅ Liste employés | Pass |
| `/orders` | GET | ✅ Liste commandes | Pass |
| `/dashboard` | GET | ✅ Tableau de bord | Pass |
| `/products` | GET | ✅ Liste produits | Pass |
| `/suppliers` | GET | ✅ Liste fournisseurs | Pass |

## Tests de Performance

### 1. Temps de Réponse

```bash
# Test de temps de réponse avec curl
time curl -s http://localhost:8000/api/v1/health
```

**Objectifs :**
- Health check: < 200ms
- Authentification: < 500ms
- Listes de données: < 1000ms

### 2. Tests de Charge

```bash
# Test de charge avec Apache Bench
ab -n 100 -c 10 http://localhost:8000/api/v1/health

# Test avec curl en parallèle
for i in {1..10}; do
  curl -s http://localhost:8000/api/v1/health &
done
wait
```

### 3. Tests Concurrents

Les tests d'intégration incluent des tests de requêtes concurrentes :

```dart
test('Concurrent Requests - Handle multiple requests', () async {
  const int requestCount = 10;
  final futures = <Future<http.Response>>[];
  
  for (int i = 0; i < requestCount; i++) {
    futures.add(http.get(Uri.parse('$baseUrl/health')));
  }
  
  final responses = await Future.wait(futures);
  
  for (final response in responses) {
    expect(response.statusCode, 200);
  }
});
```

## Tests End-to-End (E2E)

### 1. Configuration des Tests E2E

```bash
# Installer les dépendances E2E
flutter pub add integration_test
flutter pub add driver

# Démarrer l'émulateur ou appareil physique
flutter devices
```

### 2. Exécuter les Tests E2E

```bash
# Exécuter les tests E2E
flutter drive --target=test_driver/app_test.dart

# Exécuter sur un appareil spécifique
flutter drive -d <device_id> --target=test_driver/app_test.dart
```

### 3. Scénarios de Test E2E

#### Scénario 1: Connexion Complète
1. Lancement de l'application
2. Navigation vers l'écran de login
3. Saisie des identifiants
4. Validation de la connexion
5. Accès au tableau de bord

#### Scénario 2: Gestion des Employés
1. Connexion à l'application
2. Navigation vers la section employés
3. Création d'un nouvel employé
4. Modification des informations
5. Suppression de l'employé

#### Scénario 3: Gestion des Commandes
1. Connexion à l'application
2. Navigation vers les commandes
3. Création d'une nouvelle commande
4. Ajout de produits
5. Validation de la commande

## Dépannage

### 1. Problèmes Courants

#### Erreur: Connexion Refusée
```
❌ Impossible de se connecter au serveur
```

**Solution:**
- Vérifier que le backend Laravel est démarré
- Vérifier le port (8000 par défaut)
- Vérifier la configuration CORS

```bash
# Démarrer le backend
cd aramco-backend
php artisan serve --host=0.0.0.0 --port=8000
```

#### Erreur: Timeout
```
❌ Timeout de connexion
```

**Solution:**
- Vérifier la performance du backend
- Vérifier la connexion réseau
- Augmenter le timeout dans les tests

#### Erreur: 401 Non Autorisé
```
❌ Token invalide ou expiré
```

**Solution:**
- Vérifier les identifiants de test
- Régénérer le token
- Vérifier la configuration JWT

### 2. Logs et Debugging

#### Logs Backend
```bash
# Logs Laravel
cd aramco-backend
php artisan log:clear
tail -f storage/logs/laravel.log

# Logs de performance
php artisan tinker
# Vérifier les requêtes lentes
```

#### Logs Frontend
```bash
# Logs Flutter
flutter logs

# Logs de test
flutter test --verbose
```

### 3. Validation de Configuration

#### Backend Configuration
```bash
# Vérifier la configuration
cd aramco-backend
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Vérifier la base de données
php artisan tinker
>>> DB::connection()->getPdo();
>>> \App\Models\User::count();
```

#### Frontend Configuration
```bash
# Vérifier la configuration API
flutter test test/integration/backend_connection_test.dart

# Vérifier les modèles
flutter test test/models/
```

## Rapport de Tests

### 1. Template de Rapport

```markdown
# Rapport de Test - [Date]

## Résumé
- Tests exécutés: [Nombre]
- Tests réussis: [Nombre]
- Tests échoués: [Nombre]
- Taux de réussite: [Pourcentage]%

## Tests de Connexion
- Health Check: ✅/❌
- Authentification: ✅/❌
- Endpoints protégés: ✅/❌

## Tests d'Intégration
- Modèles de données: ✅/❌
- API endpoints: ✅/❌
- Validation: ✅/❌

## Tests de Performance
- Temps de réponse: ✅/❌
- Tests de charge: ✅/❌
- Concurrence: ✅/❌

## Issues Identifiées
1. [Description de l'issue]
2. [Description de l'issue]

## Recommandations
1. [Recommandation 1]
2. [Recommandation 2]
```

### 2. Automatisation du Rapport

```bash
# Script de génération de rapport
#!/bin/bash
echo "# Rapport de Test - $(date)" > test_report.md
echo "" >> test_report.md
echo "## Tests de Connexion" >> test_report.md
dart scripts/test_backend_connection.dart >> test_report.md
echo "" >> test_report.md
echo "## Tests d'Intégration" >> test_report.md
flutter test test/integration/ >> test_report.md
```

## Prochaines Étapes

1. **Exécuter tous les tests** avant chaque déploiement
2. **Automatiser les tests** dans la CI/CD
3. **Surveiller la performance** en production
4. **Mettre à jour les tests** avec les nouvelles fonctionnalités

---

## Contact Support

Pour toute question ou problème lors des tests :

- **Documentation**: [docs/](./)
- **Issues**: Créer une issue sur le repository
- **Support**: Contacter l'équipe de développement

---

*Ce guide est maintenu par l'équipe de développement Aramco SA*
*Dernière mise à jour: $(date)*
