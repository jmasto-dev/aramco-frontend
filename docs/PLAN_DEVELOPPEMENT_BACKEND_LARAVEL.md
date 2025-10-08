# 🚀 PLAN DE DÉVELOPPEMENT BACKEND LARAVEL - PROJET ARAMCO

## 📋 **INTRODUCTION**

Ce document présente le plan de développement complet pour le backend Laravel qui supportera l'application frontend Flutter Aramco. Le frontend étant déjà 100% terminé avec 39 modules fonctionnels, ce plan se concentre sur la création d'une API RESTful robuste, sécurisée et performante.

---

## 🎯 **OBJECTIFS DU PROJET**

### **Objectifs Principaux**
- Développer une API RESTful complète avec Laravel 10.x
- Implémenter tous les endpoints nécessaires pour les 39 modules frontend
- Assurer la sécurité, la performance et la scalabilité
- Intégrer les technologies modernes (Redis, Elasticsearch, etc.)
- Garantir une qualité code irréprochable avec tests complets

### **Contraintes Techniques**
- **Laravel 10.x** : Framework principal
- **PostgreSQL 14.x** : Base de données principale
- **Redis 7.x** : Cache et sessions
- **Elasticsearch 8.x** : Moteur de recherche
- **PHP 8.2+** : Version minimale requise
- **API RESTful** : Architecture orientée services

---

## 📊 **ANALYSE DES BESOINS**

### **Modules Frontend à Connecter**
Basé sur l'analyse du frontend existant :

1. **🔐 Authentification & Sécurité**
   - Login, logout, refresh token
   - RBAC (Role-Based Access Control)
   - 2FA (Two-Factor Authentication)
   - Gestion des permissions

2. **👥 Ressources Humaines**
   - Gestion des employés
   - Congés et absences
   - Évaluations de performance
   - Paies et fiches de paie

3. **📦 Gestion des Stocks**
   - Articles et produits
   - Entrepôts et emplacements
   - Mouvements de stock
   - Inventaires

4. **🛒 Commandes & Achats**
   - Commandes clients
   - Gestion des produits
   - Fournisseurs
   - Demandes d'achat

5. **💰 Fiscalité**
   - Déclarations fiscales
   - Calcul des taxes
   - Suivi des paiements

6. **📈 Reporting & Dashboard**
   - KPIs et indicateurs
   - Graphiques et statistiques
   - Export de rapports

7. **🔔 Notifications**
   - Notifications push
   - Email et SMS
   - Préférences utilisateur

8. **🔍 Recherche Globale**
   - Recherche全文
   - Suggestions et auto-complétion
   - Filtrage avancé

9. **💬 Communication**
   - Messagerie interne
   - Gestion des tâches
   - Collaborations

---

## 🏗️ **ARCHITECTURE TECHNIQUE**

### **Structure du Projet**
```
aramco-backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── API/
│   │   │   │   ├── V1/
│   │   │   │   │   ├── Auth/
│   │   │   │   │   │   ├── AuthController.php
│   │   │   │   │   │   └── TwoFactorController.php
│   │   │   │   │   ├── HR/
│   │   │   │   │   │   ├── EmployeeController.php
│   │   │   │   │   │   ├── LeaveRequestController.php
│   │   │   │   │   │   ├── PerformanceReviewController.php
│   │   │   │   │   │   └── PayslipController.php
│   │   │   │   │   ├── Inventory/
│   │   │   │   │   │   ├── ProductController.php
│   │   │   │   │   │   ├── WarehouseController.php
│   │   │   │   │   │   ├── StockMovementController.php
│   │   │   │   │   │   └── InventoryController.php
│   │   │   │   │   ├── Orders/
│   │   │   │   │   │   ├── OrderController.php
│   │   │   │   │   │   ├── OrderItemController.php
│   │   │   │   │   │   ├── SupplierController.php
│   │   │   │   │   │   └── PurchaseRequestController.php
│   │   │   │   │   ├── Finance/
│   │   │   │   │   │   ├── TaxDeclarationController.php
│   │   │   │   │   │   ├── TaxPaymentController.php
│   │   │   │   │   │   └── FinancialReportController.php
│   │   │   │   │   ├── Reports/
│   │   │   │   │   │   ├── ReportController.php
│   │   │   │   │   │   ├── DashboardController.php
│   │   │   │   │   │   └── ExportController.php
│   │   │   │   │   ├── Notifications/
│   │   │   │   │   │   ├── NotificationController.php
│   │   │   │   │   │   ├── PushNotificationController.php
│   │   │   │   │   │   └── EmailNotificationController.php
│   │   │   │   │   ├── Search/
│   │   │   │   │   │   ├── SearchController.php
│   │   │   │   │   │   └── SuggestionController.php
│   │   │   │   │   ├── Messages/
│   │   │   │   │   │   ├── MessageController.php
│   │   │   │   │   │   └── TaskController.php
│   │   │   │   │   └── Admin/
│   │   │   │   │       ├── UserController.php
│   │   │   │   │       ├── RoleController.php
│   │   │   │   │       └── PermissionController.php
│   │   │   │   └── Middleware/
│   │   │   │       ├── AuthMiddleware.php
│   │   │   │       ├── PermissionMiddleware.php
│   │   │   │       ├── RateLimitMiddleware.php
│   │   │   │       └── CorsMiddleware.php
│   │   │   └── Controller.php
│   │   ├── Requests/
│   │   │   ├── API/
│   │   │   │   ├── Auth/
│   │   │   │   ├── HR/
│   │   │   │   ├── Inventory/
│   │   │   │   └── ...
│   │   │   └── Request.php
│   │   ├── Resources/
│   │   │   ├── API/
│   │   │   │   ├── V1/
│   │   │   │   │   ├── UserResource.php
│   │   │   │   │   ├── EmployeeResource.php
│   │   │   │   │   ├── ProductResource.php
│   │   │   │   │   └── ...
│   │   │   │   └── JsonResource.php
│   │   │   └── Resource.php
│   │   └── Kernel.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Role.php
│   │   ├── Permission.php
│   │   ├── Employee.php
│   │   ├── Department.php
│   │   ├── LeaveRequest.php
│   │   ├── PerformanceReview.php
│   │   ├── Payslip.php
│   │   ├── Product.php
│   │   ├── Category.php
│   │   ├── Warehouse.php
│   │   ├── StockMovement.php
│   │   ├── InventoryItem.php
│   │   ├── Order.php
│   │   ├── OrderItem.php
│   │   ├── Supplier.php
│   │   ├── PurchaseRequest.php
│   │   ├── TaxDeclaration.php
│   │   ├── TaxPayment.php
│   │   ├── Notification.php
│   │   ├── Message.php
│   │   ├── Task.php
│   │   └── ...
│   ├── Services/
│   │   ├── Auth/
│   │   │   ├── AuthService.php
│   │   │   ├── TwoFactorService.php
│   │   │   └── PermissionService.php
│   │   ├── HR/
│   │   │   ├── EmployeeService.php
│   │   │   ├── LeaveRequestService.php
│   │   │   ├── PerformanceReviewService.php
│   │   │   └── PayslipService.php
│   │   ├── Inventory/
│   │   │   ├── ProductService.php
│   │   │   ├── StockMovementService.php
│   │   │   └── InventoryService.php
│   │   ├── Orders/
│   │   │   ├── OrderService.php
│   │   │   ├── SupplierService.php
│   │   │   └── PurchaseRequestService.php
│   │   ├── Finance/
│   │   │   ├── TaxService.php
│   │   │   └── FinancialReportService.php
│   │   ├── Reports/
│   │   │   ├── ReportService.php
│   │   │   ├── DashboardService.php
│   │   │   └── ExportService.php
│   │   ├── Notifications/
│   │   │   ├── NotificationService.php
│   │   │   ├── EmailService.php
│   │   │   ├── SMSService.php
│   │   │   └── PushNotificationService.php
│   │   ├── Search/
│   │   │   ├── SearchService.php
│   │   │   └── ElasticsearchService.php
│   │   └── FileUpload/
│   │       ├── FileUploadService.php
│   │       └── ImageProcessingService.php
│   ├── Jobs/
│   │   ├── Notifications/
│   │   │   ├── SendEmailJob.php
│   │   │   ├── SendSMSJob.php
│   │   │   └── SendPushNotificationJob.php
│   │   ├── Reports/
│   │   │   ├── GenerateReportJob.php
│   │   │   └── ExportDataJob.php
│   │   └── Inventory/
│   │       ├── UpdateStockJob.php
│   │       └── ProcessInventoryJob.php
│   ├── Events/
│   │   ├── Auth/
│   │   │   ├── UserLoggedIn.php
│   │   │   ├── UserLoggedOut.php
│   │   │   └── TwoFactorEnabled.php
│   │   ├── HR/
│   │   │   ├── EmployeeCreated.php
│   │   │   ├── LeaveRequestSubmitted.php
│   │   │   └── PerformanceReviewCompleted.php
│   │   ├── Inventory/
│   │   │   ├── StockMovementCreated.php
│   │   │   └── LowStockAlert.php
│   │   └── Orders/
│   │       ├── OrderCreated.php
│   │       ├── OrderStatusChanged.php
│   │       └── PurchaseRequestApproved.php
│   ├── Listeners/
│   │   ├── Auth/
│   │   │   ├── LogUserActivity.php
│   │   │   └── SendWelcomeEmail.php
│   │   ├── HR/
│   │   │   ├── NotifyLeaveRequest.php
│   │   │   └── UpdateEmployeeRecords.php
│   │   └── Notifications/
│   │       ├── SendNotification.php
│   │       └── UpdateNotificationPreferences.php
│   ├── Observers/
│   │   ├── UserObserver.php
│   │   ├── EmployeeObserver.php
│   │   ├── ProductObserver.php
│   │   └── OrderObserver.php
│   ├── Policies/
│   │   ├── UserPolicy.php
│   │   ├── EmployeePolicy.php
│   │   ├── ProductPolicy.php
│   │   └── OrderPolicy.php
│   └── Providers/
│       ├── AppServiceProvider.php
│       ├── AuthServiceProvider.php
│       ├── RouteServiceProvider.php
│       ├── EventServiceProvider.php
│       └── NotificationServiceProvider.php
├── database/
│   ├── migrations/
│   │   ├── 2024_01_01_000000_create_users_table.php
│   │   ├── 2024_01_01_000001_create_roles_table.php
│   │   ├── 2024_01_01_000002_create_permissions_table.php
│   │   ├── 2024_01_01_000003_create_employees_table.php
│   │   ├── 2024_01_01_000004_create_departments_table.php
│   │   ├── 2024_01_01_000005_create_leave_requests_table.php
│   │   ├── 2024_01_01_000006_create_performance_reviews_table.php
│   │   ├── 2024_01_01_000007_create_payslips_table.php
│   │   ├── 2024_01_01_000008_create_products_table.php
│   │   ├── 2024_01_01_000009_create_categories_table.php
│   │   ├── 2024_01_01_000010_create_warehouses_table.php
│   │   ├── 2024_01_01_000011_create_stock_movements_table.php
│   │   ├── 2024_01_01_000012_create_inventory_items_table.php
│   │   ├── 2024_01_01_000013_create_orders_table.php
│   │   ├── 2024_01_01_000014_create_order_items_table.php
│   │   ├── 2024_01_01_000015_create_suppliers_table.php
│   │   ├── 2024_01_01_000016_create_purchase_requests_table.php
│   │   ├── 2024_01_01_000017_create_tax_declarations_table.php
│   │   ├── 2024_01_01_000018_create_tax_payments_table.php
│   │   ├── 2024_01_01_000019_create_notifications_table.php
│   │   ├── 2024_01_01_000020_create_messages_table.php
│   │   ├── 2024_01_01_000021_create_tasks_table.php
│   │   └── ...
│   ├── seeders/
│   │   ├── DatabaseSeeder.php
│   │   ├── RoleSeeder.php
│   │   ├── PermissionSeeder.php
│   │   ├── UserSeeder.php
│   │   ├── DepartmentSeeder.php
│   │   ├── CategorySeeder.php
│   │   └── ...
│   └── factories/
│       ├── UserFactory.php
│       ├── EmployeeFactory.php
│       ├── ProductFactory.php
│       ├── OrderFactory.php
│       └── ...
├── routes/
│   ├── api.php
│   ├── web.php
│   ├── console.php
│   └── channels.php
├── config/
│   ├── app.php
│   ├── database.php
│   ├── cache.php
│   ├── queue.php
│   ├── services.php
│   ├── sanctum.php
│   ├── permission.php
│   ├── elasticsearch.php
│   └── notification.php
├── tests/
│   ├── Feature/
│   │   ├── Auth/
│   │   │   ├── LoginTest.php
│   │   │   ├── LogoutTest.php
│   │   │   └── TwoFactorTest.php
│   │   ├── HR/
│   │   │   ├── EmployeeTest.php
│   │   │   ├── LeaveRequestTest.php
│   │   │   └── PerformanceReviewTest.php
│   │   ├── Inventory/
│   │   │   ├── ProductTest.php
│   │   │   ├── StockMovementTest.php
│   │   │   └── InventoryTest.php
│   │   ├── Orders/
│   │   │   ├── OrderTest.php
│   │   │   ├── SupplierTest.php
│   │   │   └── PurchaseRequestTest.php
│   │   └── ...
│   ├── Unit/
│   │   ├── Services/
│   │   │   ├── AuthServiceTest.php
│   │   │   ├── EmployeeServiceTest.php
│   │   │   └── ...
│   │   ├── Models/
│   │   │   ├── UserTest.php
│   │   │   ├── EmployeeTest.php
│   │   │   └── ...
│   │   └── ...
│   └── TestCase.php
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── nginx/
│   │   └── default.conf
│   └── php/
│       └── php.ini
├── storage/
│   ├── app/
│   ├── framework/
│   └── logs/
├── bootstrap/
│   └── app.php
├── public/
│   ├── index.php
│   └── .htaccess
├── resources/
│   ├── views/
│   └── lang/
├── .env.example
├── .gitignore
├── artisan
├── composer.json
├── package.json
├── README.md
└── CHANGELOG.md
```

### **Technologies et Packages**

#### **Core Laravel**
- **Laravel 10.x** : Framework principal
- **PHP 8.2+** : Version PHP requise
- **Composer** : Gestion des dépendances

#### **Authentification & Sécurité**
- **Laravel Sanctum** : Authentification API
- **Spatie Laravel Permission** : RBAC avancé
- **PragmaRX/Google2FA-Laravel** : 2FA
- **Laravel Passport** : Alternative OAuth2

#### **Base de Données & Cache**
- **PostgreSQL** : Base de données principale
- **Redis** : Cache et sessions
- **Elasticsearch** : Moteur de recherche
- **MeiliSearch** : Alternative légère

#### **Queue & Jobs**
- **Laravel Horizon** : Monitoring queues
- **Laravel Telescope** : Debug et monitoring
- **Redis Queue** : Gestion des tâches

#### **Notifications & Communication**
- **Laravel Notifications** : Système de notifications
- **Mailgun/SendGrid** : Email service
- **Twilio** : SMS service
- **Firebase** : Push notifications

#### **File Storage & Media**
- **Laravel Filesystem** : Gestion des fichiers
- **Intervention Image** : Traitement d'images
- **AWS S3** : Stockage cloud

#### **API & Documentation**
- **Laravel API Resources** : Transformation des données
- **L5-Swagger** : Documentation API
- **Laravel CORS** : Gestion CORS

#### **Testing & Quality**
- **PHPUnit** : Tests unitaires
- **Laravel Dusk** : Tests E2E
- **Faker** : Données de test
- **PHPStan** : Analyse statique

---

## 📋 **PLAN DE DÉVELOPPEMENT PAR PHASES**

### **PHASE 1 : INFRASTRUCTURE & AUTHENTIFICATION (2 semaines)**

#### **Semaine 1 : Setup de base**
**Objectifs :** Mettre en place l'infrastructure de base

**Tâches :**
- [ ] **Installation Laravel 10.x**
  ```bash
  composer create-project laravel/laravel aramco-backend
  cd aramco-backend
  ```

- [ ] **Configuration Docker**
  - Créer Dockerfile
  - Configurer docker-compose.yml
  - Setup Nginx et PostgreSQL

- [ ] **Configuration environnement**
  - Variables .env
  - Configuration base de données
  - Configuration Redis

- [ ] **Migrations de base**
  - Table users (Laravel)
  - Tables roles et permissions
  - Configuration Spatie Permission

- [ ] **Setup Sanctum**
  - Configuration authentification API
  - Migration tokens
  - Middleware Sanctum

**Livrables :**
- Projet Laravel fonctionnel
- Base de données configurée
- Authentification de base

#### **Semaine 2 : Authentification complète**
**Objectifs :** Implémenter un système d'authentification robuste

**Tâches :**
- [ ] **Controller Auth complet**
  ```php
  // app/Http/Controllers/API/V1/Auth/AuthController.php
  - login()
  - logout()
  - refresh()
  - me()
  - register()
  - forgotPassword()
  - resetPassword()
  ```

- [ ] **Système RBAC avec Spatie**
  - Configuration rôles par défaut
  - Création permissions granulaires
  - Middleware de vérification

- [ ] **2FA avec Google Authenticator**
  - Génération QR code
  - Vérification code
  - Backup codes
  - Récupération compte

- [ ] **Validation des emails**
  - Email de vérification
  - Token de validation
  - Expiration token

- [ ] **Reset de mot de passe sécurisé**
  - Token sécurisé
  - Expiration
  - Validation complexité

- [ ] **Tests unitaires authentification**
  - Tests login/logout
  - Tests permissions
  - Tests 2FA

**Livrables :**
- Système d'authentification complet
- Tests authentification
- Documentation API auth

---

### **PHASE 2 : RESSOURCES HUMAINES (3 semaines)**

#### **Semaine 3 : Gestion des employés**
**Objectifs :** Implémenter la gestion complète des employés

**Tâches :**
- [ ] **Model Employee**
  ```php
  // app/Models/Employee.php
  class Employee extends Model
  {
    protected $fillable = [
      'user_id', 'employee_id', 'first_name', 'last_name',
      'email', 'phone', 'department_id', 'position',
      'hire_date', 'salary', 'status', 'address',
      'emergency_contact', 'skills', 'certifications'
    ];
    
    public function user() { return $this->belongsTo(User::class); }
    public function department() { return $this->belongsTo(Department::class); }
    public function leaveRequests() { return $this->hasMany(LeaveRequest::class); }
    public function performanceReviews() { return $this->hasMany(PerformanceReview::class); }
    public function payslips() { return $this->hasMany(Payslip::class); }
  }
  ```

- [ ] **API CRUD employés**
  ```php
  // app/Http/Controllers/API/V1/HR/EmployeeController.php
  - index() // Liste avec filtres et pagination
  - store() // Création employé
  - show() // Détails employé
  - update() // Mise à jour employé
  - destroy() // Suppression employé
  - search() // Recherche employés
  - export() // Export liste employés
  ```

- [ ] **Upload photos et documents**
  - Service upload fichiers
  - Validation types MIME
  - Stockage S3/local
  - Redimensionnement images

- [ ] **Organigramme hiérarchique**
  - Relations manager/subordinates
  - API pour récupérer organigramme
  - Cache des hiérarchies

- [ ] **Historique des modifications**
  - Model EmployeeHistory
  - Tracking des changements
  - API pour historique

**Livrables :**
- Model Employee complet
- API CRUD employés
- Upload documents
- Organigramme fonctionnel

#### **Semaine 4 : Congés et absences**
**Objectifs :** Gérer les demandes de congés et absences

**Tâches :**
- [ ] **Model LeaveRequest**
  ```php
  // app/Models/LeaveRequest.php
  class LeaveRequest extends Model
  {
    protected $fillable = [
      'employee_id', 'leave_type', 'start_date', 'end_date',
      'reason', 'status', 'approved_by', 'approved_at',
      'rejected_reason', 'days_count'
    ];
    
    public function employee() { return $this->belongsTo(Employee::class); }
    public function approver() { return $this->belongsTo(User::class, 'approved_by'); }
  }
  ```

- [ ] **Workflow de validation multi-niveaux**
  - Configuration des niveaux d'approbation
  - Notifications automatiques
  - Historique des validations

- [ ] **Calendrier des congés**
  - API pour calendrier
  - Filtrage par département/date
  - Vue globale des absences

- [ ] **Solde de congés automatique**
  - Calcul automatique des soldes
  - Types de congés (annual, sick, personal)
  - Accumulation mensuelle/annuelle

- [ ] **Notifications automatiques**
  - Email de confirmation
  - Notifications approbation
  - Rappels de congés

**Livrables :**
- Système congés complet
- Workflow validation
- Calendrier fonctionnel
- Notifications congés

#### **Semaine 5 : Évaluations et paies**
**Objectifs :** Implémenter les évaluations de performance et la gestion des paies

**Tâches :**
- [ ] **Model PerformanceReview**
  ```php
  // app/Models/PerformanceReview.php
  class PerformanceReview extends Model
  {
    protected $fillable = [
      'employee_id', 'reviewer_id', 'review_period_start',
      'review_period_end', 'overall_rating', 'goals',
      'achievements', 'improvements', 'status',
      'review_date', 'next_review_date'
    ];
  }
  ```

- [ ] **Système d'évaluation 360°**
  - Auto-évaluation
  - Évaluation manager
  - Évaluation collègues
  - Compilation des résultats

- [ ] **Model Payslip**
  ```php
  // app/Models/Payslip.php
  class Payslip extends Model
  {
    protected $fillable = [
      'employee_id', 'pay_period', 'basic_salary',
      'allowances', 'deductions', 'overtime',
      'net_salary', 'pay_date', 'status'
    ];
  }
  ```

- [ ] **Génération des fiches de paie**
  - Calcul automatique salaire
  - Gestion des allowances/deductions
  - Impôts et cotisations

- [ ] **Export PDF sécurisé**
  - Génération PDF avec DomPDF
  - Watermark et sécurité
  - Stockage sécurisé

**Livrables :**
- Système évaluations complet
  - Gestion paie fonctionnelle
  - PDF payslips sécurisés
  - Calculs automatisés

---

### **PHASE 3 : GESTION DES STOCKS (3 semaines)**

#### **Semaine 6 : Articles et entrepôts**
**Objectifs :** Mettre en place la gestion des produits et entrepôts

**Tâches :**
- [ ] **Models Product et Warehouse**
  ```php
  // app/Models/Product.php
  class Product extends Model
  {
    protected $fillable = [
      'name', 'sku', 'description', 'category_id',
      'price', 'cost', 'barcode', 'status',
      'min_stock', 'max_stock', 'unit'
    ];
  }
  
  // app/Models/Warehouse.php
  class Warehouse extends Model
  {
    protected $fillable = [
      'name', 'code', 'address', 'manager_id',
      'capacity', 'status'
    ];
  }
  ```

- [ ] **Gestion des catégories**
  - Model Category hiérarchique
  - API CRUD catégories
  - Filtrage par catégorie

- [ ] **Codes-barres et QR codes**
  - Génération automatique
  - Validation unicité SKU
  - API scan codes-barres

- [ ] **Valorisation des stocks**
  - Méthodes FIFO, LIFO, coût moyen
  - Calcul automatique
  - Historique valorisation

- [ ] **Alertes de stock faible**
  - Configuration seuils
  - Notifications automatiques
  - Suggestions de réapprovisionnement

**Livrables :**
- Models produits/entrepôts
  - Gestion catégories
  - Codes-barres fonctionnels
  - Alertes stock

#### **Semaine 7 : Mouvements de stock**
**Objectifs :** Gérer les mouvements de stock et les inventaires

**Tâches :**
- [ ] **Model StockMovement**
  ```php
  // app/Models/StockMovement.php
  class StockMovement extends Model
  {
    protected $fillable = [
      'product_id', 'warehouse_id', 'movement_type',
      'quantity', 'reference', 'reason',
      'created_by', 'approved_by'
    ];
  }
  ```

- [ ] **Entrées/Sorties/Transferts**
  - Types de mouvements
  - Validation des quantités
  - Historique complet

- [ ] **Inventaire périodique**
  - Création campagnes inventaire
  - Saisie des quantités
  - Validation des écarts

- [ ] **Validation des mouvements**
  - Workflow approbation
  - Contrôle quantités
  - Journal des validations

- [ ] **Historique complet**
  - Traçabilité complète
  - API pour historique
  - Export mouvements

**Livrables :**
- Système mouvements complet
  - Gestion inventaire
  - Workflow validation
  - Historique détaillé

#### **Semaine 8 : Recherche et optimisation**
**Objectifs :** Implémenter la recherche avancée et optimiser les performances

**Tâches :**
- [ ] **Configuration Elasticsearch**
  - Installation et configuration
  - Indexation des produits
  - Mapping des champs

- [ ] **Indexation des produits**
  - Bulk indexing
  - Mise à jour automatique
  - Gestion des erreurs

- [ ] **Recherche avancée**
  ```php
  // app/Services/Search/ElasticsearchService.php
  public function searchProducts($query, $filters = [])
  {
    $params = [
      'index' => 'products',
      'body' => [
        'query' => [
          'bool' => [
            'must' => [
              ['multi_match' => [
                'query' => $query,
                'fields' => ['name^3', 'description^2', 'sku']
              ]]
            ],
            'filter' => $filters
          ]
        ]
      ]
    ];
    
    return $this->client->search($params);
  }
  ```

- [ ] **Suggestions et auto-complétion**
  - Completion suggester
  - API suggestions
  - Cache des suggestions

- [ ] **Performance optimisation**
  - Indexation optimisée
  - Cache des résultats
  - Monitoring performance

**Livrables :**
- Elasticsearch configuré
  - Recherche avancée fonctionnelle
  - Suggestions auto-complétion
  - Performance optimisée

---

### **PHASE 4 : COMMANDES & ACHATS (3 semaines)**

#### **Semaine 9 : Gestion des commandes**
**Objectifs :** Implémenter le système de gestion des commandes

**Tâches :**
- [ ] **Models Order et OrderItem**
  ```php
  // app/Models/Order.php
  class Order extends Model
  {
    protected $fillable = [
      'order_number', 'customer_id', 'status',
      'total_amount', 'tax_amount', 'discount_amount',
      'shipping_address', 'billing_address',
      'order_date', 'delivery_date', 'notes'
    ];
  }
  
  // app/Models/OrderItem.php
  class OrderItem extends Model
  {
    protected $fillable = [
      'order_id', 'product_id', 'quantity',
      'unit_price', 'total_price', 'discount'
    ];
  }
  ```

- [ ] **Workflow de validation**
  - États de commande
  - Transitions automatiques
  - Notifications changements

- [ ] **Calcul automatique des totaux**
  - Calcul taxes
  - Gestion remises
  - Frais de livraison

- [ ] **Gestion des statuts**
  ```php
  // app/Enums/OrderStatus.php
  enum OrderStatus: string
  {
    case PENDING = 'pending';
    case CONFIRMED = 'confirmed';
    case PROCESSING = 'processing';
    case SHIPPED = 'shipped';
    case DELIVERED = 'delivered';
    case CANCELLED = 'cancelled';
  }
  ```

- [ ] **Historique des modifications**
  - Tracking des changements
  - Journal des statuts
  - API pour historique

**Livrables :**
- Système commandes complet
  - Workflow validation
  - Calculs automatiques
  - Historique détaillé

#### **Semaine 10 : Fournisseurs et achats**
**Objectifs :** Gérer les fournisseurs et les demandes d'achat

**Tâches :**
- [ ] **Model Supplier**
  ```php
  // app/Models/Supplier.php
  class Supplier extends Model
  {
    protected $fillable = [
      'name', 'contact_person', 'email', 'phone',
      'address', 'tax_id', 'payment_terms',
      'rating', 'status', 'notes'
    ];
  }
  ```

- [ ] **Évaluation des fournisseurs**
  - Système de notation
  - Critères d'évaluation
  - Historique performance

- [ ] **Model PurchaseRequest**
  ```php
  // app/Models/PurchaseRequest.php
  class PurchaseRequest extends Model
  {
    protected $fillable = [
      'request_number', 'requested_by', 'department_id',
      'total_amount', 'status', 'urgency',
      'justification', 'approved_by'
    ];
  }
  ```

- [ ] **Workflow d'approbation**
  - Niveaux d'approbation
  - Notifications automatiques
  - Historique approbations

- [ ] **Comparaison automatique des devis**
  - Analyse des offres
  - Meilleur prix automatique
  - Rapport comparatif

**Livrables :**
- Gestion fournisseurs complète
  - Évaluation performance
  - Workflow achats
  - Comparaison devis

#### **Semaine 11 : Intégrations**
**Objectifs :** Intégrer les services externes et finaliser le module

**Tâches :**
- [ ] **API paiement (Stripe/PayPal)**
  ```php
  // app/Services/Payment/PaymentService.php
  public function processPayment($order, $paymentMethod)
  {
    // Intégration Stripe/PayPal
    // Gestion des webhooks
    // Mise à jour statut commande
  }
  ```

- [ ] **Notifications email/SMS**
  - Templates emails
  - Configuration SMS Twilio
  - Notifications automatiques

- [ ] **Export factures PDF**
  - Génération factures
  - Templates personnalisés
  - Stockage sécurisé

- [ ] **Synchronisation comptabilité**
  - Export données comptables
  - Format comptable
  - Rapprochement automatique

- [ ] **Dashboard commandes**
  - KPIs commandes
  - Graphiques statistiques
  - Données temps réel

**Livrables :**
- Intégrations paiement
  - Notifications avancées
  - Export PDF factures
  - Dashboard commandes

---

### **PHASE 5 : FISCALITÉ & REPORTING (3 semaines)**

#### **Semaine 12 : Fiscalité**
**Objectifs :** Implémenter le module de gestion fiscale

**Tâches :**
- [ ] **Model TaxDeclaration**
  ```php
  // app/Models/TaxDeclaration.php
  class TaxDeclaration extends Model
  {
    protected $fillable = [
      'declaration_number', 'declaration_type',
      'period_start', 'period_end', 'total_amount',
      'tax_amount', 'status', 'submitted_at',
      'validated_by', 'notes'
    ];
  }
  ```

- [ ] **Calcul automatique des taxes**
  ```php
  // app/Services/Finance/TaxService.php
  public function calculateVAT($amount, $rate)
  {
    return $amount * ($rate / 100);
  }
  
  public function generateTaxDeclaration($period, $type)
  {
    // Calcul automatique basé sur les transactions
    // Application des taux fiscaux
    // Génération déclaration
  }
  ```

- [ ] **Génération déclarations TVA**
  - Types de déclarations
  - Calcul automatique
  - Validation fiscale

- [ ] **Suivi des échéances**
  - Configuration échéances
  - Notifications rappels
  - Historique paiements

- [ ] **Archivage légal**
  - Archivage 10 ans
  - Stockage sécurisé
  - Accès contrôlé

**Livrables :**
- Système fiscal complet
  - Calculs automatiques
  - Déclarations TVA
  - Archivage légal

#### **Semaine 13 : Reporting avancé**
**Objectifs :** Créer un système de reporting flexible et puissant

**Tâches :**
- [ ] **Models Report et ReportTemplate**
  ```php
  // app/Models/Report.php
  class Report extends Model
  {
    protected $fillable = [
      'name', 'template_id', 'parameters',
      'generated_by', 'file_path', 'status',
      'generated_at', 'expires_at'
    ];
  }
  
  // app/Models/ReportTemplate.php
  class ReportTemplate extends Model
  {
    protected $fillable = [
      'name', 'description', 'query',
      'parameters', 'format', 'category'
    ];
  }
  ```

- [ ] **Générateur de rapports dynamiques**
  ```php
  // app/Services/Reports/ReportService.php
  public function generateReport($templateId, $parameters = [])
  {
    $template = ReportTemplate::find($templateId);
    $query = $this->buildQuery($template->query, $parameters);
    $data = DB::select($query);
    
    return $this->formatReport($data, $template->format);
  }
  ```

- [ ] **Export multi-formats**
  - Export PDF (DomPDF)
  - Export Excel (Laravel Excel)
  - Export CSV
  - Export JSON

- [ ] **Graphiques et KPIs**
  - API pour graphiques
  - Calcul KPIs
  - Données agrégées

- [ ] **Planification automatique**
  - Configuration planification
  - Jobs automatiques
  - Envoi par email

**Livrables :**
- Système reporting complet
  - Générateur dynamique
  - Exports multi-formats
  - Planification automatique

#### **Semaine 14 : Dashboard principal**
**Objectifs :** Créer un dashboard temps réel avec KPIs

**Tâches :**
- [ ] **API pour KPIs en temps réel**
  ```php
  // app/Http/Controllers/API/V1/Reports/DashboardController.php
  public function getKPIs()
  {
    return [
      'total_employees' => Employee::count(),
      'active_orders' => Order::where('status', 'processing')->count(),
      'low_stock_products' => Product::where('current_stock', '<', 'min_stock')->count(),
      'monthly_revenue' => Order::whereMonth('created_at', now()->month)->sum('total_amount'),
    ];
  }
  ```

- [ ] **Données agrégées performantes**
  - Vues matérialisées
  - Cache des agrégats
  - Index optimisés

- [ ] **Cache intelligent des données**
  - Configuration TTL
  - Invalidation automatique
  - Cache hiérarchique

- [ ] **Widgets personnalisables**
  - Configuration widgets
  - Positions modifiables
  - Sauvegarde préférences

- [ ] **Alertes et notifications**
  - Configuration alertes
  - Seuils personnalisés
  - Notifications temps réel

**Livrables :**
- Dashboard temps réel
  - KPIs performants
  - Cache intelligent
  - Widgets personnalisables

---

### **PHASE 6 : NOTIFICATIONS & COMMUNICATION (2 semaines)**

#### **Semaine 15 : Système de notifications**
**Objectifs :** Implémenter un système de notifications complet

**Tâches :**
- [ ] **Model Notification**
  ```php
  // app/Models/Notification.php
  class Notification extends Model
  {
    protected $fillable = [
      'title', 'message', 'type', 'notifiable_id',
      'notifiable_type', 'read_at', 'data'
    ];
  }
  ```

- [ ] **Notifications push (Firebase)**
  ```php
  // app/Services/Notifications/PushNotificationService.php
  public function sendPushNotification($user, $title, $message, $data = [])
  {
    $deviceToken = $user->device_token;
    
    $notification = [
      'title' => $title,
      'body' => $message,
      'data' => $data
    ];
    
    return $this->fcm->send([$deviceToken], $notification);
  }
  ```

- [ ] **Emails templatisés**
  - Templates Blade
  - Variables dynamiques
  - Inline CSS

- [ ] **SMS (Twilio)**
  - Configuration Twilio
  - Templates SMS
  - Validation numéros

- [ ] **Préférences utilisateur**
  ```php
  // app/Models/NotificationPreference.php
  class NotificationPreference extends Model
  {
    protected $fillable = [
      'user_id', 'type', 'email_enabled',
      'push_enabled', 'sms_enabled'
    ];
  }
  ```

**Livrables :**
- Système notifications complet
  - Push notifications
  - Emails templatisés
  - SMS intégration
  - Préférences utilisateur

#### **Semaine 16 : Messagerie et tâches**
**Objectifs :** Implémenter la messagerie interne et la gestion des tâches

**Tâches :**
- [ ] **Model Message**
  ```php
  // app/Models/Message.php
  class Message extends Model
  {
    protected $fillable = [
      'sender_id', 'receiver_id', 'subject',
      'content', 'read_at', 'parent_id'
    ];
  }
  ```

- [ ] **Messagerie interne**
  - Envoi messages
  - Conversation thread
  - Pièces jointes
  - Statut lecture

- [ ] **Model Task**
  ```php
  // app/Models/Task.php
  class Task extends Model
  {
    protected $fillable = [
      'title', 'description', 'assigned_to',
      'created_by', 'status', 'priority',
      'due_date', 'completed_at'
    ];
  }
  ```

- [ ] **Gestion des tâches**
  - Création tâches
  - Assignment utilisateurs
  - Suivi progression
  - Notifications rappels

- [ ] **Notifications automatiques**
  - Nouveau message
  - Tâche assignée
  - Échéance approche

**Livrables :**
- Messagerie interne complète
  - Gestion tâches fonctionnelle
  - Notifications automatiques
  - Interface conversation

---

### **PHASE 7 : TESTS & OPTIMISATION (2 semaines)**

#### **Semaine 17 : Tests complets**
**Objectifs :** Assurer la qualité du code avec une couverture de tests complète

**Tâches :**
- [ ] **Tests unitaires (PHPUnit)**
  ```php
  // tests/Unit/Services/AuthServiceTest.php
  class AuthServiceTest extends TestCase
  {
    public function test_user_can_login_with_valid_credentials()
    {
      $user = User::factory()->create([
        'password' => Hash::make('password123')
      ]);
      
      $response = $this->postJson('/api/auth/login', [
        'email' => $user->email,
        'password' => 'password123'
      ]);
      
      $response->assertStatus(200)
               ->assertJsonStructure(['access_token', 'user']);
    }
  }
  ```

- [ ] **Tests d'intégration**
  - Tests API endpoints
  - Tests workflows
  - Tests permissions

- [ ] **Tests de charge**
  ```php
  // tests/Feature/LoadTest.php
  class LoadTest extends TestCase
  {
    public function test_api_can_handle_100_concurrent_requests()
    {
      // Test de charge avec 100 requêtes simultanées
    }
  }
  ```

- [ ] **Tests de sécurité**
  - Tests injection SQL
  - Tests XSS
  - Tests CSRF
  - Tests permissions

- [ ] **Tests d'API**
  - Tests tous endpoints
  - Validation réponses
  - Tests erreurs

**Livrables :**
- Suite de tests complète
  - Couverture 80%+
  - Tests sécurité
  - Documentation tests

#### **Semaine 18 : Optimisation finale**
**Objectifs :** Optimiser les performances et préparer le déploiement

**Tâches :**
- [ ] **Optimisation des requêtes SQL**
  - Analyse requêtes lentes
  - Ajout indexes
  - Optimisation joins

- [ ] **Mise en cache avancée**
  ```php
  // app/Services/Cache/CacheService.php
  public function remember($key, $callback, $ttl = 3600)
  {
    return Cache::remember($key, $ttl, $callback);
  }
  
  public function forget($key)
  {
    Cache::forget($key);
  }
  ```

- [ ] **Monitoring et logging**
  - Configuration Laravel Telescope
  - Logs structurés
  - Alertes erreurs

- [ ] **Documentation API (Swagger)**
  ```yaml
  # swagger.yaml
  openapi: 3.0.0
  info:
    title: Aramco API
    version: 1.0.0
  paths:
    /api/auth/login:
      post:
        summary: User login
        tags:
          - Authentication
  ```

- [ ] **Déploiement staging**
  - Configuration environnement staging
  - Pipeline CI/CD
  - Tests automatisés

**Livrables :**
- Performances optimisées
  - Monitoring configuré
  - Documentation API complète
  - Environnement staging

---

## 🔧 **SPÉCIFICATIONS TECHNIQUES DÉTAILLÉES**

### **API RESTful Design**

#### **Structure des URLs**
```
https://api.aramco.com/v1/{resource}
```

#### **Endpoints par module**

**Authentification**
```
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
GET    /api/v1/auth/me
POST   /api/v1/auth/register
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/2fa/enable
POST   /api/v1/auth/2fa/verify
```

**Ressources Humaines**
```
GET    /api/v1/hr/employees
POST   /api/v1/hr/employees
GET    /api/v1/hr/employees/{id}
PUT    /api/v1/hr/employees/{id}
DELETE /api/v1/hr/employees/{id}
GET    /api/v1/hr/employees/{id}/history
POST   /api/v1/hr/employees/{id}/upload-photo

GET    /api/v1/hr/leave-requests
POST   /api/v1/hr/leave-requests
PUT    /api/v1/hr/leave-requests/{id}/approve
PUT    /api/v1/hr/leave-requests/{id}/reject

GET    /api/v1/hr/performance-reviews
POST   /api/v1/hr/performance-reviews
GET    /api/v1/hr/payslips
GET    /api/v1/hr/payslips/{id}/download
```

**Stocks**
```
GET    /api/v1/inventory/products
POST   /api/v1/inventory/products
GET    /api/v1/inventory/products/{id}
PUT    /api/v1/inventory/products/{id}
DELETE /api/v1/inventory/products/{id}

GET    /api/v1/inventory/warehouses
POST   /api/v1/inventory/stock-movements
GET    /api/v1/inventory/stock-movements
POST   /api/v1/inventory/inventory

GET    /api/v1/inventory/search
GET    /api/v1/inventory/suggestions
```

**Commandes**
```
GET    /api/v1/orders
POST   /api/v1/orders
GET    /api/v1/orders/{id}
PUT    /api/v1/orders/{id}
PUT    /api/v1/orders/{id}/status

GET    /api/v1/suppliers
POST   /api/v1/suppliers
GET    /api/v1/purchase-requests
POST   /api/v1/purchase-requests
```

### **Format des réponses**

#### **Succès**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_items": 200,
      "per_page": 20
    },
    "filters": {
      "status": "active",
      "department": "IT"
    }
  }
}
```

#### **Erreur**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  },
  "code": 422
}
```

### **Gestion des erreurs**

#### **Codes d'erreur HTTP**
- `200` : Succès
- `201` : Créé
- `400` : Requête invalide
- `401` : Non authentifié
- `403` : Non autorisé
- `404` : Non trouvé
- `422` : Erreur de validation
- `429` : Trop de requêtes
- `500` : Erreur serveur

#### **Gestion des exceptions**
```php
// app/Exceptions/Handler.php
public function render($request, Throwable $exception)
{
    if ($exception instanceof ValidationException) {
        return response()->json([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $exception->errors()
        ], 422);
    }
    
    if ($exception instanceof AuthenticationException) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401);
    }
    
    return parent::render($request, $exception);
}
```

---

## 🗄️ **DESIGN DE LA BASE DE DONNÉES**

### **Schema principal**

#### **Tables d'authentification**
```sql
-- Users table
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    two_factor_secret VARCHAR(255) NULL,
    two_factor_recovery_codes TEXT NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Roles table
CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) UNIQUE NOT NULL,
    guard_name VARCHAR(255) NOT NULL DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Permissions table
CREATE TABLE permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) UNIQUE NOT NULL,
    guard_name VARCHAR(255) NOT NULL DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Model has permissions
CREATE TABLE model_has_permissions (
    permission_id BIGINT NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT NOT NULL,
    FOREIGN KEY (permission_id) REFERENCES permissions(id),
    PRIMARY KEY (permission_id, model_id, model_type)
);

-- Model has roles
CREATE TABLE model_has_roles (
    role_id BIGINT NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    PRIMARY KEY (role_id, model_id, model_type)
);

-- Role has permissions
CREATE TABLE role_has_permissions (
    permission_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    FOREIGN KEY (permission_id) REFERENCES permissions(id),
    FOREIGN KEY (role_id) REFERENCES roles(id),
    PRIMARY KEY (permission_id, role_id)
);
```

#### **Tables Ressources Humaines**
```sql
-- Departments table
CREATE TABLE departments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    manager_id BIGINT NULL,
    parent_id BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES users(id),
    FOREIGN KEY (parent_id) REFERENCES departments(id)
);

-- Employees table
CREATE TABLE employees (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NULL,
    department_id BIGINT NULL,
    position VARCHAR(255) NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NULL,
    status ENUM('active', 'inactive', 'terminated') DEFAULT 'active',
    address TEXT NULL,
    emergency_contact JSON NULL,
    skills JSON NULL,
    certifications JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Leave requests table
CREATE TABLE leave_requests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT NOT NULL,
    leave_type ENUM('annual', 'sick', 'personal', 'maternity', 'paternity') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NULL,
    status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',
    approved_by BIGINT NULL,
    approved_at TIMESTAMP NULL,
    rejected_reason TEXT NULL,
    days_count INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Performance reviews table
CREATE TABLE performance_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    overall_rating DECIMAL(3,2) NULL,
    goals JSON NULL,
    achievements JSON NULL,
    improvements JSON NULL,
    status ENUM('draft', 'submitted', 'approved', 'rejected') DEFAULT 'draft',
    review_date DATE NULL,
    next_review_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (reviewer_id) REFERENCES users(id)
);

-- Payslips table
CREATE TABLE payslips (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT NOT NULL,
    pay_period VARCHAR(20) NOT NULL,
    basic_salary DECIMAL(10,2) NOT NULL,
    allowances JSON NULL,
    deductions JSON NULL,
    overtime DECIMAL(10,2) DEFAULT 0,
    net_salary DECIMAL(10,2) NOT NULL,
    pay_date DATE NOT NULL,
    status ENUM('draft', 'approved', 'paid') DEFAULT 'draft',
    file_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);
```

#### **Tables Stock**
```sql
-- Categories table
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    parent_id BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- Products table
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NULL,
    category_id BIGINT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    barcode VARCHAR(100) NULL,
    status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    min_stock INT DEFAULT 0,
    max_stock INT NULL,
    unit VARCHAR(50) DEFAULT 'units',
    current_stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Warehouses table
CREATE TABLE warehouses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT NULL,
    manager_id BIGINT NULL,
    capacity INT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES users(id)
);

-- Stock movements table
CREATE TABLE stock_movements (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    movement_type ENUM('in', 'out', 'transfer') NOT NULL,
    quantity INT NOT NULL,
    reference VARCHAR(255) NULL,
    reason TEXT NULL,
    created_by BIGINT NOT NULL,
    approved_by BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Inventory items table
CREATE TABLE inventory_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    location VARCHAR(255) NULL,
    batch_number VARCHAR(100) NULL,
    expiry_date DATE NULL,
    last_counted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE KEY unique_product_warehouse (product_id, warehouse_id)
);
```

#### **Tables Commandes**
```sql
-- Suppliers table
CREATE TABLE suppliers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    address TEXT NULL,
    tax_id VARCHAR(100) NULL,
    payment_terms VARCHAR(255) NULL,
    rating DECIMAL(3,2) DEFAULT 0,
    status ENUM('active', 'inactive') DEFAULT 'active',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    shipping_address JSON NULL,
    billing_address JSON NULL,
    order_date DATE NOT NULL,
    delivery_date DATE NULL,
    notes TEXT NULL,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Order items table
CREATE TABLE order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Purchase requests table
CREATE TABLE purchase_requests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    request_number VARCHAR(50) UNIQUE NOT NULL,
    requested_by BIGINT NOT NULL,
    department_id BIGINT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'processed') DEFAULT 'pending',
    urgency ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    justification TEXT NULL,
    approved_by BIGINT NULL,
    approved_at TIMESTAMP NULL,
    rejected_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (requested_by) REFERENCES users(id),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);
```

#### **Tables Notifications**
```sql
-- Notifications table
CREATE TABLE notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    id VARCHAR(255) UNIQUE NOT NULL,
    type VARCHAR(255) NOT NULL,
    notifiable_type VARCHAR(255) NOT NULL,
    notifiable_id BIGINT NOT NULL,
    data JSON NOT NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Notification preferences table
CREATE TABLE notification_preferences (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    type VARCHAR(255) NOT NULL,
    email_enabled BOOLEAN DEFAULT true,
    push_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_user_type (user_id, type)
);
```

### **Indexes et contraintes**

#### **Indexes principaux**
```sql
-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- Employees indexes
CREATE INDEX idx_employees_user_id ON employees(user_id);
CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);

-- Products indexes
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_name ON products(name);

-- Orders indexes
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Stock movements indexes
CREATE INDEX idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_warehouse_id ON stock_movements(warehouse_id);
CREATE INDEX idx_stock_movements_type ON stock_movements(movement_type);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at);
```

---

## 🔐 **SÉCURITÉ**

### **Mesures de sécurité implémentées**

#### **Authentification**
- **Laravel Sanctum** : Tokens sécurisés avec expiration
- **2FA obligatoire** : Google Authenticator
- **Validation emails** : Vérification obligatoire
- **Mots de passe forts** : Complexité requise
- **Rate limiting** : Protection brute force

#### **Autorisations**
- **RBAC granulaire** : Permissions par ressource
- **Middleware permissions** : Vérification automatique
- **Policies** : Autorisations par modèle
- **Scopes API** : Limitation accès API

#### **Protection des données**
- **HTTPS obligatoire** : TLS 1.3
- **Chiffrement données** : AES-256
- **Hashing passwords** : Bcrypt
- **Sanitization input** : Validation stricte
- **SQL injection** : Eloquent ORM

#### **Monitoring et audit**
- **Audit logs** : Traçabilité complète
- **Activity logging** : Journal des actions
- **Error tracking** : Sentry/Bugsnag
- **Security headers** : Protection XSS/CSRF

### **Tests de sécurité**

#### **Tests automatisés**
```php
// tests/Feature/SecurityTest.php
class SecurityTest extends TestCase
{
    public function test_sql_injection_protection()
    {
        $response = $this->getJson('/api/employees?search=' . "'; DROP TABLE users; --");
        $response->assertStatus(200);
        $this->assertDatabaseHas('users', ['id' => 1]);
    }
    
    public function test_xss_protection()
    {
        $maliciousInput = '<script>alert("xss")</script>';
        $response = $this->postJson('/api/employees', [
            'name' => $maliciousInput
        ]);
        $this->assertDatabaseMissing('employees', ['name' => $maliciousInput]);
    }
}
```

#### **Tests de pénétration**
- Tests d'injection SQL
- Tests XSS
- Tests CSRF
- Tests d'authentification
- Tests de permissions

---

## 📈 **PERFORMANCE & SCALABILITÉ**

### **Optimisations de performance**

#### **Base de données**
- **Indexes optimisés** : Sur les champs fréquemment recherchés
- **Query optimization** : Requêtes efficaces
- **Eager loading** : Réduction N+1 queries
- **Database pooling** : Connexions réutilisées

#### **Cache**
- **Redis cache** : Données fréquemment accédées
- **Query cache** : Résultats requêtes
- **View cache** : Pages compilées
- **API cache** : Réponses API

#### **Application**
- **Lazy loading** : Chargement à la demande
- **Pagination** : Grandes datasets
- **Compression** : Gzip responses
- **CDN** : Assets statiques

### **Monitoring**

#### **Laravel Telescope**
- Requêtes HTTP
- Commandes Artisan
- Jobs et queues
- Exceptions
- Cache

#### **Custom metrics**
```php
// app/Providers/AppServiceProvider.php
public function boot()
{
    // KPI monitoring
    if (app()->environment('production')) {
        $this->app->singleton('metrics', function () {
            return new MetricsService();
        });
    }
}
```

#### **Alertes**
- Erreurs critiques
- Performance dégradée
- Problèmes de connexion
- Échecs de synchronisation

---

## 🚀 **DÉPLOIEMENT**

### **Environnements**

#### **Local (Docker)**
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/var/www/html
    depends_on:
      - mysql
      - redis
  
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: aramco
      MYSQL_ROOT_PASSWORD: password
    ports:
      - "3306:3306"
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"
```

#### **Staging**
- Serveur de test
- Base de données staging
- Configuration staging
- Tests automatisés

#### **Production**
- Load balancer
- Multiple app servers
- Database cluster
- Redis cluster

### **CI/CD Pipeline**

#### **GitHub Actions**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: aramco_test
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

    steps:
    - uses: actions/checkout@v3
    
    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: '8.2'
        extensions: mbstring, xml, bcmath, pdo, sqlite
        
    - name: Install dependencies
      run: composer install --no-progress --no-suggest --prefer-dist --optimize-autoloader
    
    - name: Copy environment file
      run: cp .env.testing .env
    
    - name: Generate application key
      run: php artisan key:generate
    
    - name: Run migrations
      run: php artisan migrate --force
    
    - name: Run tests
      run: vendor/bin/phpunit --coverage-clover=coverage.xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Deploy to staging
      run: |
        # Script de déploiement
        ssh user@staging-server 'cd /var/www/aramco && git pull && composer install --no-dev && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache'
```

#### **Déploiement automatique**
- Tests automatiques
- Build optimisé
- Déploiement progressif
- Rollback automatique

---

## 📊 **ESTIMATION COÛT ET DÉLAI**

### **Durée totale estimée**
- **18 semaines** (~4.5 mois)
- **1 développeur senior** full-time
- **1 développeur junior** pour support (50%)
- **1 DevOps** pour infrastructure (25%)

### **Répartition par phase**
| Phase | Durée | Pourcentage | Complexité |
|-------|-------|-------------|------------|
| Phase 1 : Infrastructure & Auth | 2 semaines | 11% | Moyenne |
| Phase 2 : Ressources Humaines | 3 semaines | 17% | Élevée |
| Phase 3 : Gestion des Stocks | 3 semaines | 17% | Élevée |
| Phase 4 : Commandes & Achats | 3 semaines | 17% | Élevée |
| Phase 5 : Fiscalité & Reporting | 3 semaines | 17% | Très élevée |
| Phase 6 : Notifications & Com | 2 semaines | 11% | Moyenne |
| Phase 7 : Tests & Optimisation | 2 semaines | 11% | Moyenne |

### **Coût estimé (indicatif)**

#### **Développement**
- **Développeur senior** : 4.5 mois × taux local
- **Développeur junior** : 2.25 mois × taux local
- **DevOps** : 1.125 mois × taux local

#### **Infrastructure (mensuel)**
- **Serveur staging** : $50-100/mois
- **Serveur production** : $200-500/mois
- **Base de données** : $100-300/mois
- **Redis** : $50-150/mois
- **Elasticsearch** : $100-200/mois

#### **Services tiers (mensuel)**
- **Email service** : $20-100/mois
- **SMS service** : $10-50/mois
- **Push notifications** : $20-100/mois
- **Monitoring** : $20-100/mois
- **File storage** : $50-200/mois

#### **Total projet**
Selon les taux locaux et la complexité, le budget total peut varier significativement.

---

## 🎯 **CRITÈRES DE SUCCÈS**

### **Fonctionnels**
- ✅ **100% des endpoints API** implémentés
- ✅ **Frontend connecté** et fonctionnel
- ✅ **Tous les modules** opérationnels
- ✅ **Performance < 2s** par requête
- ✅ **Disponibilité 99.5%**

### **Techniques**
- ✅ **Code qualité** Laravel standards
- ✅ **Tests à 80%+** couverture
- ✅ **Sécurité renforcée**
- ✅ **Documentation complète**
- ✅ **Monitoring en place**

### **Qualité**
- ✅ **Code review** systématique
- ✅ **Tests automatisés** CI/CD
- ✅ **Performance monitoring**
- ✅ **Error tracking**
- ✅ **User feedback**

---

## 📝 **CONCLUSION**

Ce plan de développement backend Laravel est conçu pour :

1. **Supporter parfaitement** le frontend Flutter existant
2. **Respecter les exigences** du cahier des charges
3. **Assurer la sécurité** et la performance
4. **Faciliter la maintenance** et l'évolution
5. **Garantir la qualité** du code

Avec une approche structurée par phases et une attention particulière à la qualité, ce projet livrera une API robuste et complète pour l'application Aramco.

---

**📞 Pour toute question technique ou besoin d'ajustement du plan, n'hésitez pas à contacter l'équipe de développement.**

---

*Date de création : 3 Octobre 2025*  
*Statut : PLAN DE DÉVELOPPEMENT COMPLET - PRÊT POUR IMPLÉMENTATION*  
*Confiance : PLAN DÉTAILLÉ - COUVERTURE COMPLÈTE DES BESOINS*

**🚀 Ce plan constitue la feuille de route parfaite pour développer un backend Laravel qui supportera exceptionnellement l'application frontend Aramco ! 🚀**
