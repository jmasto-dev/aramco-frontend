# Guide Complet d'Exécution des Tests - Projet Aramco SA

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Configuration de l'Environnement](#configuration-de-lenvironnement)
3. [Types de Tests Disponibles](#types-de-tests-disponibles)
4. [Exécution des Tests](#exécution-des-tests)
5. [Analyse des Résultats](#analyse-des-résultats)
6. [Dépannage](#dépannage)
7. [Automatisation CI/CD](#automatisation-cicd)

## 🚀 Prérequis

### Système Requis
- **OS**: Windows 10/11, macOS 10.14+, Ubuntu 18.04+
- **RAM**: Minimum 8GB (16GB recommandé)
- **Stockage**: 10GB d'espace libre
- **Réseau**: Connexion internet stable

### Logiciels Installés
```bash
# Vérifier les versions requises
flutter --version  # >= 3.0.0
dart --version     # >= 2.17.0
php --version      # >= 8.1.0
composer --version # >= 2.0.0
docker --version   # >= 20.0.0
git --version      # >= 2.30.0
```

### Outils Supplémentaires
```bash
# Installation des dépendances de test
flutter pub get
cd aramco-backend && composer install
```

## ⚙️ Configuration de l'Environnement

### 1. Configuration du Backend

```bash
# Copier le fichier d'environnement
cd aramco-backend
cp .env.example .env

# Configurer les variables d'environnement
nano .env
```

Variables essentielles :
```env
APP_NAME="Aramco SA"
APP_ENV=testing
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=aramco_test
DB_USERNAME=postgres
DB_PASSWORD=password

# Configuration JWT
JWT_SECRET=votre_jwt_secret
JWT_TTL=60
```

### 2. Démarrage des Services

```bash
# Démarrer les services Docker
docker-compose up -d

# Exécuter les migrations
php artisan migrate --seed

# Démarrer le serveur de développement
php artisan serve --host=0.0.0.0 --port=8000
```

### 3. Configuration du Frontend

```bash
# Retourner au répertoire principal
cd ..

# Mettre à jour les dépendances
flutter pub get

# Configurer l'URL de l'API
# Vérifier lib/core/utils/constants.dart
const String API_BASE_URL = 'http://localhost:8000/api/v1';
```

## 🧪 Types de Tests Disponibles

### 1. Tests Unitaires
- **Objectif**: Tester les fonctions et méthodes isolées
- **Localisation**: `test/`
- **Exécution**: `flutter test`

### 2. Tests d'Intégration
- **Objectif**: Tester l'interaction entre les composants
- **Localisation**: `test/integration/`
- **Exécution**: `flutter test test/integration/`

### 3. Tests de Connexion Backend
- **Objectif**: Vérifier la communication frontend-backend
- **Localisation**: `test/integration/backend_connection_test.dart`
- **Exécution**: `dart scripts/test_backend_connection.dart`

### 4. Tests de Performance
- **Objectif**: Mesurer les performances sous charge
- **Localisation**: `scripts/performance_test.dart`
- **Exécution**: `dart scripts/performance_test.dart`

### 5. Tests End-to-End (E2E)
- **Objectif**: Simuler les scénarios utilisateur complets
- **Localisation**: `test_driver/app_test.dart`
- **Exécution**: `flutter drive --target=test_driver/app_test.dart`

### 6. Tests de Configuration
- **Objectif**: Valider l'environnement de test
- **Localisation**: Scripts intégrés
- **Exécution**: Automatique dans le script principal

## 🏃‍♂️ Exécution des Tests

### Exécution Complète (Recommandé)

```bash
# Exécuter tous les tests
dart scripts/run_all_tests.dart
```

Cette commande exécute :
1. ✅ Test de connexion backend
2. ✅ Tests d'intégration Flutter
3. ✅ Tests de performance
4. ✅ Tests E2E (si appareil disponible)
5. ✅ Validation de la configuration

### Exécution Individuelle

#### Tests Unitaires Seulement
```bash
flutter test
```

#### Tests d'Intégration Seulement
```bash
flutter test test/integration/
```

#### Tests de Performance Seulement
```bash
dart scripts/performance_test.dart
```

#### Tests E2E Seulement
```bash
# Démarrer un émulateur ou appareil
flutter devices

# Exécuter les tests E2E
flutter drive --target=test_driver/app_test.dart
```

#### Tests de Connexion Backend Seulement
```bash
dart scripts/test_backend_connection.dart
```

### Exécution avec Rapport Détaillé

```bash
# Générer un rapport de couverture
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Ouvrir le rapport
open coverage/html/index.html
```

## 📊 Analyse des Résultats

### Structure du Rapport

Le script génère un fichier JSON avec :
```json
{
  "timestamp": "2024-01-01T12:00:00.000Z",
  "summary": {
    "total_tests": 5,
    "passed_tests": 4,
    "failed_tests": 1,
    "success_rate": 80.0,
    "total_duration_ms": 45000
  },
  "results": [...]
}
```

### Interprétation des Métriques

#### Taux de Succès
- **> 95%**: Excellent ✅
- **90-95%**: Bon ⚠️
- **< 90%**: Nécessite une attention ❌

#### Temps de Réponse
- **< 500ms**: Excellent ✅
- **500-1000ms**: Acceptable ⚠️
- **> 1000ms**: À optimiser ❌

#### Requêtes par Seconde
- **> 50 RPS**: Excellent ✅
- **20-50 RPS**: Bon ⚠️
- **< 20 RPS**: À améliorer ❌

### Rapports de Performance

Le script de performance génère :
- **Test de charge**: 10 utilisateurs × 20 requêtes
- **Test de stress**: Augmentation progressive jusqu'à 50 utilisateurs
- **Test d'endurance**: 5 utilisateurs pendant 30 minutes
- **Test de pics**: Simulation de pics soudains

## 🔧 Dépannage

### Problèmes Courants

#### 1. Backend Non Accessible
```bash
# Vérifier si le backend tourne
curl http://localhost:8000/api/v1/health

# Redémarrer le backend
cd aramco-backend
php artisan serve --host=0.0.0.0 --port=8000
```

#### 2. Base de Données Non Connectée
```bash
# Vérifier la connexion PostgreSQL
docker ps | grep postgres

# Redémarrer la base de données
docker-compose restart postgres
```

#### 3. Tests E2E Échouent
```bash
# Vérifier les appareils disponibles
flutter devices

# Démarrer un émulateur
flutter emulators --launch <emulator_name>
```

#### 4. Dépendances Manquantes
```bash
# Mettre à jour les dépendances Flutter
flutter pub get

# Mettre à jour les dépendances Backend
cd aramco-backend && composer install
```

#### 5. Permissions CORS
```bash
# Vérifier la configuration CORS
cd aramco-backend
php artisan config:cache
php artisan route:cache
```

### Logs Utiles

#### Logs Backend
```bash
cd aramco-backend
tail -f storage/logs/laravel.log
```

#### Logs Docker
```bash
docker-compose logs -f
```

#### Logs Tests
```bash
# Logs détaillés des tests
flutter test --verbose
```

## 🔄 Automatisation CI/CD

### GitHub Actions

Le projet inclut une configuration CI/CD dans `.github/workflows/deploy.yml` :

```yaml
name: Tests and Deploy
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: dart scripts/run_all_tests.dart
```

### Intégration Locale

Pour exécuter les tests automatiquement avant chaque commit :

```bash
# Installer pre-commit
pip install pre-commit

# Configurer le hook
pre-commit install
```

Fichier `.pre-commit-config.yaml` :
```yaml
repos:
  - repo: local
    hooks:
      - id: flutter-test
        name: Flutter Tests
        entry: flutter test
        language: system
      - id: integration-tests
        name: Integration Tests
        entry: dart scripts/run_all_tests.dart
        language: system
```

## 📈 Bonnes Pratiques

### 1. Fréquence des Tests
- **Avant chaque commit**: Tests unitaires et d'intégration
- **Avant chaque PR**: Tests complets
- **Quotidien**: Tests de performance
- **Hebdomadaire**: Tests E2E complets

### 2. Environnement de Test
- Utiliser une base de données dédiée
- Isoler les environnements de test et de production
- Nettoyer les données après chaque test

### 3. Monitoring
- Surveiller les performances des tests
- Alertes en cas de régression
- Historique des résultats

### 4. Documentation
- Documenter les nouveaux tests
- Mettre à jour les cas de test
- Partager les résultats avec l'équipe

## 🎯 Objectifs de Qualité

### Critères de Succès
- **Taux de réussite**: > 95%
- **Couverture de code**: > 80%
- **Temps d'exécution**: < 5 minutes
- **Performance**: < 1s par requête

### Indicateurs Clés
- Nombre de tests passés/échoués
- Temps d'exécution moyen
- Couverture de code
- Performance sous charge

## 📞 Support

En cas de problème :
1. Consulter les logs d'erreur
2. Vérifier la configuration
3. Exécuter les tests individuellement
4. Contacter l'équipe de développement

---

**Note**: Ce guide est mis à jour régulièrement. Pour la dernière version, consultez le dépôt Git du projet.
