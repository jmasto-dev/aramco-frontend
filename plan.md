

[ DÉBUT DU PLAN ]

PLAN DE DÉVELOPPEMENT - PROJET ARAMCO

Version : 1.0
Date : 26/09/2025
Architecte : IA Senior

Introduction

Ce document constitue la feuille de route exhaustive pour la construction de l'application de gestion Aramco. Il adopte une stratégie de Développement Parallèle par Fonctionnalités Verticales, garantissant une intégration continue et une validation fonctionnelle complète à chaque étape. Le plan est structuré en deux étapes distinctes pour permettre un développement parallèle optimal entre le backend (Laravel) et le frontend (Flutter).

SECTION 1 : FONDATIONS ARCHITECTURALES

Cette section définit les standards et contrats techniques permettant un développement parallèle efficace. Ces éléments doivent être validés avant toute implémentation.

1.1. Contrat d'API Immuable (RESTful)

Définition précise des endpoints API pour la communication entre backend et frontend :

| Méthode | URL | Rôle Requis | Payload | Réponse Succès | Réponse Erreur |
|---------|-----|-------------|---------|----------------|----------------|
| POST | /api/login | Aucun | {email: string, password: string} | {token: string, user: {id, name, email, role}} | 401: {error: "Identifiants invalides"} |
| POST | /api/logout | Authentifié | {} | {message: "Déconnexion réussie"} | 401: {error: "Non authentifié"} |
| GET | /api/users | Admin | {} | [{id, name, email, role, created_at}] | 403: {error: "Accès non autorisé"} |
| POST | /api/users | Admin | {name, email, password, role} | {id, name, email, role} | 422: {errors: {champ: ["message"]}} |
| PUT | /api/users/{id} | Admin | {name, email, role} | {id, name, email, role} | 404: {error: "Utilisateur non trouvé"} |
| DELETE | /api/users/{id} | Admin | {} | {message: "Utilisateur supprimé"} | 404: {error: "Utilisateur non trouvé"} |
| GET | /api/employees | RH, Admin | {} | [{id, user_id, position, department, hire_date}] | 403: {error: "Accès non autorisé"} |
| POST | /api/employees | RH, Admin | {user_id, position, department, hire_date} | {id, user_id, position, department, hire_date} | 422: {errors: {champ: ["message"]}} |
| GET | /api/orders | Tous rôles | {} | [{id, reference, customer_id, total, status, date}] | 401: {error: "Non authentifié"} |
| POST | /api/orders | Opérateur, Admin | {customer_id, items: [{product_id, quantity}]} | {id, reference, total, status} | 422: {errors: {champ: ["message"]}} |
| GET | /api/deliveries | Logistique, Admin | {} | [{id, order_id, status, delivery_date, tracking}] | 403: {error: "Accès non autorisé"} |
| PUT | /api/deliveries/{id} | Logistique, Admin | {status, delivery_date, tracking} | {id, order_id, status, delivery_date, tracking} | 404: {error: "Livraison non trouvée"} |
| GET | /api/accounting/transactions | Comptable, Admin | {} | [{id, reference, type, amount, date, category}] | 403: {error: "Accès non autorisé"} |
| POST | /api/accounting/transactions | Comptable, Admin | {reference, type, amount, date, category} | {id, reference, type, amount, date, category} | 422: {errors: {champ: ["message"]}} |
| GET | /api/tax/declarations | Comptable, Admin | {} | [{id, period, amount, status, due_date}] | 403: {error: "Accès non autorisé"} |
| POST | /api/tax/declarations | Comptable, Admin | {period, amount, due_date} | {id, period, amount, status, due_date} | 422: {errors: {champ: ["message"]}} |
| GET | /api/dashboard | Tous rôles | {} | {kpi1: value, kpi2: value, charts: [...]} | 401: {error: "Non authentifié"} |
| GET | /api/export/pdf | Tous rôles | {type: "report", filters: {...}} | {url: "signed_url"} | 422: {errors: {champ: ["message"]}} |
| GET | /api/export/excel | Tous rôles | {type: "report", filters: {...}} | {url: "signed_url"} | 422: {errors: {champ: ["message"]}} |

1.2. Schéma de la Base de Données (PostgreSQL)

Structure relationnelle optimisée pour l'intégrité des données :

```sql
-- Table des utilisateurs
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des rôles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Table d'association utilisateurs-rôles
CREATE TABLE role_user (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Table des employés
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    position VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    salary NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des clients
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des commandes
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    total NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Table des produits
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des détails de commande
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

-- Table des livraisons
CREATE TABLE deliveries (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    status VARCHAR(20) NOT NULL DEFAULT 'preparing',
    delivery_date DATE,
    tracking VARCHAR(100),
    delivered_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des transactions comptables
CREATE TABLE accounting_transactions (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'income', 'expense', 'transfer'
    amount NUMERIC(12,2) NOT NULL,
    date DATE NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des déclarations fiscales
CREATE TABLE tax_declarations (
    id SERIAL PRIMARY KEY,
    period VARCHAR(20) NOT NULL, -- '2025-Q1', '2025-01'
    type VARCHAR(20) NOT NULL, -- 'vat', 'income_tax'
    amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    due_date DATE NOT NULL,
    submitted_date DATE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour optimisation des performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_reference ON orders(reference);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_deliveries_status ON deliveries(status);
CREATE INDEX idx_transactions_date ON accounting_transactions(date);
CREATE INDEX idx_tax_period ON tax_declarations(period);
```

1.3. Structure des Projets et Standards de Code

Organisation standardisée des projets Laravel et Flutter :

**Backend (Laravel) :**
```
aramco-backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── AuthController.php
│   │   │   │   ├── UserController.php
│   │   │   │   ├── EmployeeController.php
│   │   │   │   ├── OrderController.php
│   │   │   │   ├── DeliveryController.php
│   │   │   │   ├── AccountingController.php
│   │   │   │   ├── TaxController.php
│   │   │   │   └── DashboardController.php
│   │   ├── Middleware/
│   │   │   ├── Authenticate.php
│   │   │   └── RoleMiddleware.php
│   │   └── Requests/
│   │       ├── UserRequest.php
│   │       ├── EmployeeRequest.php
│   │       └── OrderRequest.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Role.php
│   │   ├── Employee.php
│   │   ├── Order.php
│   │   └── ...
│   └── Services/
│       ├── AuthService.php
│       ├── ExportService.php
│       └── DashboardService.php
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── factories/
├── routes/
│   ├── api.php
│   └── web.php
└── tests/
    ├── Feature/
    ├── Unit/
    └── TestCase.php
```

**Frontend (Flutter) :**
```
aramco-frontend/
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_service.dart
│   │   │   └── endpoints.dart
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── order.dart
│   │   │   └── ...
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── storage_service.dart
│   │   │   └── notification_service.dart
│   │   ├── utils/
│   │   │   ├── constants.dart
│   │   │   ├── validators.dart
│   │   │   └── formatters.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── custom_input.dart
│   │       └── loading_overlay.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── login_view_model.dart
│   │   │   │   └── login_repository.dart
│   │   │   └── ...
│   │   ├── users/
│   │   │   ├── user_list/
│   │   │   │   ├── user_list_screen.dart
│   │   │   │   ├── user_list_view_model.dart
│   │   │   │   └── user_list_repository.dart
│   │   │   └── ...
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── dashboard_view_model.dart
│   │   │   └── dashboard_repository.dart
│   │   └── ...
│   ├── shared/
│   │   ├── main_layout.dart
│   │   ├── app_theme.dart
│   │   └── navigation_service.dart
│   └── main.dart
├── assets/
│   ├── images/
│   ├── fonts/
│   └── translations/
└── test/
```

SECTION 2 : ÉTAPE A - DÉVELOPPEMENT BACKEND (LARAVEL)

Cette section détaille l'ensemble des tâches à réaliser pour le backend Laravel, organisées par modules fonctionnels.

Module 0 : Initialisation et Authentification
- B-01 : Initialiser projet Laravel, configuration BDD, installation Sanctum et Spatie Permissions.
- B-02 : Créer migration et modèle User avec relations. Créer seeder pour l'administrateur par défaut.
- B-03 : Implémenter la route et le contrôleur pour l'authentification (/api/login).
- B-04 : Implémenter la logique de validation des identifiants et génération de token Sanctum.
- B-05 : Mettre en place le middleware d'authentification (auth:sanctum) et de rôles (Spatie).
- B-06 : Implémenter la route et le contrôleur pour la déconnexion (/api/logout).

Module 1 : Gestion des Utilisateurs (Admin)
- B-07 : Créer le CRUD complet pour les Users (routes, contrôleur, validation) protégé par rôle admin.
- B-08 : Implémenter la validation des requêtes (FormRequest) pour création et modification.
- B-09 : Implémenter la logique d'assignation/révocation de rôles via l'API.
- B-10 : Gérer la suppression logique des utilisateurs (soft delete) et restauration.

Module 2 : Gestion des Ressources Humaines (RH)
- B-11 : Créer migration et modèle Employee avec relation 1-1 vers User.
- B-12 : Créer le CRUD API pour les Employees (protégé par rôle RH/Admin).
- B-13 : Implémenter la logique de gestion des congés (modèle Vacation, API endpoints).
- B-14 : Créer l'API pour la gestion des évaluations de performance.
- B-15 : Implémenter la génération des fiches de paie (PDF via dompdf).

Module 3 : Gestion des Commandes
- B-16 : Créer migrations et modèles pour Order, Customer, Product et OrderItem.
- B-17 : Implémenter le CRUD pour les commandes avec calcul automatique du total.
- B-18 : Créer l'endpoint pour la création de commande avec validation des stocks.
- B-19 : Implémenter la logique de mise à jour des statuts de commande.
- B-20 : Créer l'endpoint pour la recherche avancée de commandes.

Module 4 : Gestion des Livraisons
- B-21 : Créer migration et modèle Delivery avec relation vers Order.
- B-22 : Implémenter le CRUD pour les livraisons (protégé par rôle Logistique/Admin).
- B-23 : Créer l'endpoint pour la mise à jour du statut de livraison.
- B-24 : Implémenter la génération d'étiquettes de livraison (PDF avec code-barres).
- B-25 : Créer l'endpoint pour l'historique des livraisons par commande.

Module 5 : Comptabilité
- B-26 : Créer migration et modèle AccountingTransaction avec catégories prédéfinies.
- B-27 : Implémenter le CRUD pour les transactions (protégé par rôle Comptable/Admin).
- B-28 : Créer l'endpoint pour le rapprochement bancaire.
- B-29 : Implémenter la génération des rapports financiers (bilan, compte de résultat).
- B-30 : Créer l'endpoint pour la clôture périodique des comptes.

Module 6 : DGI (Direction Générale des Impôts)
- B-31 : Créer migration et modèle TaxDeclaration avec types de taxes.
- B-32 : Implémenter le CRUD pour les déclarations (protégé par rôle Comptable/Admin).
- B-33 : Créer l'endpoint pour le calcul automatique des taxes (TVA, impôts).
- B-34 : Implémenter la génération des déclarations fiscales (PDF conforme).
- B-35 : Créer l'endpoint pour le suivi des paiements fiscaux.

Module 7 : Tableau de Bord
- B-36 : Créer le service DashboardService avec calcul des KPIs.
- B-37 : Implémenter l'endpoint /api/dashboard avec données agrégées.
- B-38 : Créer l'endpoint pour les données des graphiques (ventes, stocks, etc.).
- B-39 : Implémenter le système d'alertes configurables par utilisateur.
- B-40 : Créer l'endpoint pour les données comparatives (périodes, années).

Module 8 : Exports PDF/Excel
- B-41 : Créer le service ExportService avec génération PDF (dompdf) et Excel (PhpSpreadsheet).
- B-42 : Implémenter l'endpoint /api/export/pdf pour les rapports personnalisés.
- B-43 : Implémenter l'endpoint /api/export/excel pour les données brutes.
- B-44 : Créer la logique de stockage temporaire des fichiers générés.
- B-45 : Implémenter la génération de rapports programmés avec envoi par email.

SECTION 3 : ÉTAPE B - DÉVELOPPEMENT FRONTEND (FLUTTER)

Cette section détaille l'ensemble des tâches à réaliser pour le frontend Flutter, organisées par modules fonctionnels.

Module 0 : Initialisation et Authentification
- F-01 : Initialiser projet Flutter, configuration architecture MVVM, mise en place du gestionnaire d'état (Provider/Riverpod).
- F-02 : Mettre en place le service ApiService pour la communication HTTP avec gestion des erreurs.
- F-03 : Développer l'UI de l'écran de connexion (login_screen.dart) avec validation des champs.
- F-04 : Connecter le formulaire de connexion à l'endpoint /api/login avec gestion des états (chargement, succès, erreur).
- F-05 : Gérer le stockage sécurisé du token (flutter_secure_storage) et initialisation du client HTTP.
- F-06 : Développer le layout principal (main_layout.dart) avec navigation par tiroir et barre inférieure.

Module 1 : Gestion des Utilisateurs (Admin)
- F-07 : Développer l'UI de la page liste des utilisateurs avec recherche et pagination.
- F-08 : Connecter la liste à l'endpoint GET /api/users avec rafraîchissement pull-to-refresh.
- F-09 : Développer le formulaire d'ajout/modification d'utilisateur avec sélection de rôle.
- F-10 : Connecter le formulaire aux endpoints POST/PUT /api/users avec validation en temps réel.

Module 2 : Gestion des Ressources Humaines (RH)
- F-11 : Développer l'UI de la page liste des employés avec filtres par département.
- F-12 : Connecter la liste à l'endpoint GET /api/employees avec chargement progressif.
- F-13 : Développer le formulaire de demande de congé avec calendrier interactif.
- F-14 : Développer l'interface d'évaluation avec sections et notes personnalisables.
- F-15 : Développer la visualisation et téléchargement des fiches de paie avec filtre par mois.

Module 3 : Gestion des Commandes
- F-16 : Développer l'UI de la page liste des commandes avec statuts colorés et recherche.
- F-17 : Connecter la liste à l'endpoint GET /api/orders avec filtres par statut et période.
- F-18 : Développer le formulaire de création de commande avec ajout dynamique de produits.
- F-19 : Développer l'interface de mise à jour de statut avec historique des changements.
- F-20 : Implémenter la recherche avancée avec plusieurs critères et sauvegarde des filtres.

Module 4 : Gestion des Livraisons
- F-21 : Développer l'UI de la page liste des livraisons avec carte de statut.
- F-22 : Connecter la liste à l'endpoint GET /api/deliveries avec vue calendrier optionnelle.
- F-23 : Développer l'interface de suivi de livraison avec carte interactive.
- F-24 : Développer la fonction d'impression des étiquettes via Bluetooth/USB.
- F-25 : Développer l'affichage détaillé de l'historique avec timeline visuelle.

Module 5 : Comptabilité
- F-26 : Développer l'UI de la page liste des transactions avec graphique récapitulatif.
- F-27 : Connecter la liste à l'endpoint GET /api/accounting/transactions avec export rapide.
- F-28 : Développer l'interface de rapprochement avec glisser-déposer et suggestions.
- F-29 : Développer la visualisation des rapports avec graphiques interactifs et tableaux détaillés.
- F-30 : Développer l'assistant de clôture avec vérifications préalables et confirmation.

Module 6 : DGI (Direction Générale des Impôts)
- F-31 : Développer l'UI de la page liste des déclarations fiscales avec alertes d'échéance.
- F-32 : Connecter la liste à l'endpoint GET /api/tax/declarations avec filtres par statut.
- F-33 : Développer l'assistant de calcul avec paramètres configurables et prévisualisation.
- F-34 : Développer la prévisualisation et génération PDF avec signature numérique.
- F-35 : Développer l'interface de suivi avec historique et rappels automatiques.

Module 7 : Tableau de Bord
- F-36 : Développer l'UI du tableau de bord avec widgets personnalisables et glisser-déposer.
- F-37 : Connecter le dashboard à l'endpoint avec rafraîchissement périodique.
- F-38 : Développer les composants graphiques (courbes, barres, camemberts) avec animations.
- F-39 : Développer l'interface de configuration des alertes avec seuils et notifications.
- F-40 : Développer la vue comparative avec sélecteurs de période et indicateurs de tendance.

Module 8 : Exports PDF/Excel
- F-41 : Développer l'interface d'export avec sélection de format et paramètres.
- F-42 : Connecter l'export PDF à l'endpoint avec prévisualisation avant génération.
- F-43 : Connecter l'export Excel à l'endpoint avec sélection des colonnes et filtres.
- F-44 : Développer l'interface de téléchargement avec historique des exports.
- F-45 : Développer l'interface de planification avec fréquences et destinataires.

SECTION 4 : FINALISATION ET DÉPLOIEMENT

Tâches finales après développement complet des fonctionnalités :

Tâche I-01 : Effectuer les tests d'intégration de bout en bout pour chaque module fonctionnel en utilisant Postman pour l'API et Flutter Integration Tests pour le frontend.

Tâche I-02 : Optimiser les performances :
- Backend: Indexation BDD, mise en cache Redis, optimisation des requêtes Eloquent
- Frontend: Lazy loading, optimisation des images, code splitting

Tâche I-03 : Préparer les builds de production :
- Backend: Configuration environnement (.env), optimisation Composer, déploiement via Docker
- Frontend: Compilation AOT pour Web, builds signés pour mobile, configuration des assets

Tâche I-04 : Rédiger le guide de déploiement complet incluant :
- Configuration serveur (Nginx, PHP-FPM, PostgreSQL)
- Processus de migration des données existantes
- Procédures de sauvegarde et restauration
- Instructions de maintenance et monitoring

[ FIN DU PLAN ]