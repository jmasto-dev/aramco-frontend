# Guide de Démarrage Rapide - Aramco Frontend-Backend

## 🚀 Démarrage de l'Application

### Prérequis
- PHP 8.4+ installé
- Flutter installé
- Composer installé
- Base de données (MySQL/PostgreSQL)

### 1. Démarrer le Backend Laravel

```bash
# Naviguer vers le dossier backend
cd ../aramco-backend

# Installer les dépendances
composer install

# Configurer l'environnement
cp .env.example .env
php artisan key:generate

# Exécuter les migrations
php artisan migrate

# Démarrer le serveur
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Démarrer le Frontend Flutter

```bash
# Dans un nouveau terminal, naviguer vers le frontend
cd aramco-frontend

# Installer les dépendances
flutter pub get

# Générer les fichiers nécessaires
flutter packages pub run build_runner build

# Démarrer l'application
flutter run
```

### 3. Vérifier la Connexion

```bash
# Tester la connexion backend
curl http://localhost:8000

# Tester l'API
dart scripts/test_connection_final.dart
```

## 📋 Configuration

### Variables d'Environnement Backend

Dans `../aramco-backend/.env` :
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=aramco
DB_USERNAME=root
DB_PASSWORD=

APP_URL=http://localhost:8000
```

### Configuration Frontend

Le frontend est déjà configuré pour se connecter à :
- **URL Backend**: `http://localhost:8000`
- **API**: `http://localhost:8000/api/v1`

## 🔐 Accès par Défaut

### Compte Administrateur
- **Email**: admin@aramco.com
- **Mot de passe**: password

### Compte Employé
- **Email**: employee@aramco.com  
- **Mot de passe**: password

## 📊 Modules Disponibles

| Module | Description | Statut |
|--------|-------------|--------|
| 🔐 Authentification | Login, logout, inscription | ✅ |
| 👥 Employés | Gestion du personnel | ✅ |
| 📅 Congés | Demandes de congés | ✅ |
| 📈 Performance | Évaluations | ✅ |
| 📦 Commandes | Gestion des commandes | ✅ |
| 🛍️ Produits | Catalogue produits | ✅ |
| 🏭 Fournisseurs | Gestion fournisseurs | ✅ |
| 💰 Achats | Demandes d'achat | ✅ |
| 📄 Paie | Bulletins de paie | ✅ |
| 📈 Stocks | Gestion des stocks | ✅ |
| 🏛️ Fiscal | Déclarations fiscales | ✅ |
| 🏢 Entrepôts | Gestion des entrepôts | ✅ |
| 🔐 Permissions | Gestion des droits | ✅ |
| 📊 Rapports | Génération de rapports | ✅ |
| 🔔 Notifications | Système de notifications | ✅ |
| 💬 Messages | Messagerie interne | ✅ |
| ✅ Tâches | Gestion des tâches | ✅ |
| 📊 Dashboard | Tableau de bord | ✅ |

## 🛠️ Dépannage

### Problèmes Communs

#### Backend ne démarre pas
```bash
# Vérifier PHP
php --version

# Vérifier Composer
composer --version

# Réinstaller les dépendances
composer install --no-dev
```

#### Frontend ne se compile pas
```bash
# Nettoyer Flutter
flutter clean
flutter pub get

# Régénérer les fichiers
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Erreur de connexion
1. Vérifier que le backend est démarré
2. Vérifier l'URL dans `lib/core/constants/api_endpoints.dart`
3. Vérifier les CORS dans le backend

#### Base de données
```bash
# Réinitialiser la base de données
php artisan migrate:fresh --seed

# Vérifier la connexion
php artisan tinker
DB::connection()->getPdo();
```

### Logs

#### Logs Backend
```bash
# Logs Laravel
tail -f ../aramco-backend/storage/logs/laravel.log

# Logs PHP
php artisan serve --host=0.0.0.0 --port=8000 -vvv
```

#### Logs Frontend
```bash
# Logs Flutter
flutter logs

# Mode debug
flutter run --debug
```

## 📱 Déploiement

### Développement
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:3000` (web) ou application mobile

### Production
Voir `docs/DEPLOYMENT_PRODUCTION_COMPLETE.md`

## 🔧 Outils Utiles

### Scripts Disponibles
```bash
# Test de connexion
dart scripts/test_connection_final.dart

# Compilation complète
dart test_compilation.dart

# Validation
dart scripts/final_validation_and_testing.dart
```

### Documentation
- Guide technique: `docs/documentation_technique.md`
- Guide utilisateur: `docs/documentation_utilisateur.md`
- API Endpoints: `lib/core/constants/api_endpoints.dart`

## 📞 Support

En cas de problème :
1. Consulter les logs
2. Vérifier la documentation
3. Exécuter les scripts de test
4. Contacter le support technique

---

**Note**: Ce guide suppose que le backend Laravel a été déplacé dans `../aramco-backend` comme demandé.
