

### Liste de Prompts pour le Développeur Frontend (Flutter)

---

#### **Module 0 : Initialisation et Authentification**

**Prompt F-01**  
*Tâche* : Initialiser projet Flutter, configuration architecture MVVM, mise en place du gestionnaire d'état (Provider/Riverpod).  
**Instructions** :  
1. Créer un nouveau projet Flutter avec `flutter create aramco_frontend`.  
2. Configurer l'architecture MVVM :  
   - Créer les dossiers `lib/core/`, `lib/features/`, `lib/shared/`.  
   - Implémenter le gestionnaire d'état avec **Riverpod** (ajouter `flutter_riverpod` dans `pubspec.yaml`).  
3. Structurer les fichiers :  
   - `lib/main.dart` : Point d'entrée avec `ProviderScope`.  
   - `lib/core/app_theme.dart` : Thème de l'application (couleurs, typographie).  
**Fichiers** :  
- `FICHIER : aramco_frontend/pubspec.yaml`  
- `FICHIER : aramco_frontend/lib/main.dart`  
- `FICHIER : aramco_frontend/lib/core/app_theme.dart`  
**Validation** : L'application démarre sans erreur, le thème est appliqué, Riverpod est fonctionnel.

---

**Prompt F-02**  
*Tâche* : Mettre en place le service ApiService pour la communication HTTP avec gestion des erreurs.  
**Instructions** :  
1. Créer `lib/core/api/api_service.dart` avec :  
   - Client HTTP (package `http`).  
   - Gestion des headers (Authorization Bearer).  
   - Méthodes génériques `get()`, `post()`, `put()`, `delete()`.  
2. Ajouter la gestion centralisée des erreurs :  
   - Interception des codes 401, 403, 422, 500.  
   - Messages d'erreur localisés (fr/en/ar).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/core/api/api_service.dart`  
- `FICHIER : aramco_frontend/lib/core/api/endpoints.dart` (URLs de l'API)  
**Validation** : Les appels HTTP retournent des réponses structurées ou des erreurs typées.

---

**Prompt F-03**  
*Tâche* : Développer l'UI de l'écran de connexion (login_screen.dart) avec validation des champs.  
**Instructions** :  
1. Créer `lib/features/auth/login/login_screen.dart` :  
   - Formulaire avec champs email/mot de passe.  
   - Validation en temps réel (email valide, mot de passe > 6 caractères).  
   - Bouton de connexion désactivé si formulaire invalide.  
2. Utiliser des widgets personnalisés :  
   - `CustomInputField` (dans `lib/core/widgets/`).  
   - `CustomButton` avec état de chargement.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/auth/login/login_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/custom_input_field.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/custom_button.dart`  
**Validation** : Le formulaire valide les entrées, l'UI est responsive (mobile/web).

---

**Prompt F-04**  
*Tâche* : Connecter le formulaire de connexion à l'endpoint /api/login avec gestion des états (chargement, succès, erreur).  
**Instructions** :  
1. Créer `lib/features/auth/login/login_view_model.dart` :  
   - Utiliser `StateNotifier` (Riverpod) pour gérer les états : `initial`, `loading`, `success`, `error`.  
   - Méthode `login()` appelant `ApiService.post('/api/login')`.  
2. Lier le ViewModel à l'UI :  
   - Afficher un loader pendant la requête.  
   - Rediriger vers le dashboard en cas de succès.  
   - Afficher les erreurs (snackbar).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/auth/login/login_view_model.dart`  
- `FICHIER : aramco_frontend/lib/features/auth/login/login_screen.dart` (mise à jour)  
**Validation** : La connexion réussit avec des identifiants valides, les erreurs sont affichées.

---

**Prompt F-05**  
*Tâche* : Gérer le stockage sécurisé du token (flutter_secure_storage) et initialisation du client HTTP.  
**Instructions** :  
1. Ajouter `flutter_secure_storage` dans `pubspec.yaml`.  
2. Créer `lib/core/services/storage_service.dart` :  
   - Méthodes `saveToken()`, `getToken()`, `deleteToken()`.  
3. Modifier `ApiService` :  
   - Injecter le token dans les headers via `StorageService`.  
   - Gérer le rafraîchissement du token (si applicable).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/core/services/storage_service.dart`  
- `FICHIER : aramco_frontend/lib/core/api/api_service.dart` (mise à jour)  
**Validation** : Le token est stocké/chiffré, les requêtes authentifiées incluent le header.

---

**Prompt F-06**  
*Tâche* : Développer le layout principal (main_layout.dart) avec navigation par tiroir et barre inférieure.  
**Instructions** :  
1. Créer `lib/shared/main_layout.dart` :  
   - Tiroir de navigation (Drawer) avec liens vers les modules.  
   - Barre inférieure (BottomNavigationBar) pour les écrans principaux.  
2. Implémenter la logique de navigation :  
   - Utiliser `GoRouter` ou `Navigator 2.0`.  
   - Gestion des rôles (afficher/masquer les items selon le rôle utilisateur).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/shared/main_layout.dart`  
- `FICHIER : aramco_frontend/lib/shared/navigation_service.dart`  
**Validation** : La navigation est fluide, les rôles sont respectés, l'UI est cohérente sur mobile/web.

---

#### **Module 1 : Gestion des Utilisateurs (Admin)**

**Prompt F-07**  
*Tâche* : Développer l'UI de la page liste des utilisateurs avec recherche et pagination.  
**Instructions** :  
1. Créer `lib/features/users/user_list/user_list_screen.dart` :  
   - Tableau responsive avec colonnes (Nom, Email, Rôle, Actions).  
   - Barre de recherche avec filtrage en temps réel.  
   - Pagination (chargement progressif ou boutons "Suivant/Précédent").  
2. Utiliser `DataTable2` (package `data_table_2`) pour les tables avancées.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/users/user_list/user_list_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/search_field.dart`  
**Validation** : La liste s'affiche, la recherche filtre les résultats, la pagination fonctionne.

---

**Prompt F-08**  
*Tâche* : Connecter la liste à l'endpoint GET /api/users avec rafraîchissement pull-to-refresh.  
**Instructions** :  
1. Créer `lib/features/users/user_list/user_list_view_model.dart` :  
   - Appeler `ApiService.get('/api/users')` avec paramètres (page, recherche).  
   - Gérer les états : `loading`, `data`, `error`.  
2. Ajouter `RefreshIndicator` dans l'UI pour le rafraîchissement manuel.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/users/user_list/user_list_view_model.dart`  
- `FICHIER : aramco_frontend/lib/features/users/user_list/user_list_screen.dart` (mise à jour)  
**Validation** : Les données se chargent, le pull-to-refresh met à jour la liste.

---

**Prompt F-09**  
*Tâche* : Développer le formulaire d'ajout/modification d'utilisateur avec sélection de rôle.  
**Instructions** :  
1. Créer `lib/features/users/user_form/user_form_screen.dart` :  
   - Formulaire avec champs : Nom, Email, Mot de passe (optionnel en modification), Rôle (dropdown).  
   - Validation des champs (email unique, mot de passe fort).  
2. Utiliser `DropdownButton` pour la sélection des rôles (récupérés depuis l'API).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/users/user_form/user_form_screen.dart`  
- `FICHIER : aramco_frontend/lib/features/users/user_form/user_form_view_model.dart`  
**Validation** : Le formulaire valide les entrées, le dropdown affiche les rôles.

---

**Prompt F-10**  
*Tâche* : Connecter le formulaire aux endpoints POST/PUT /api/users avec validation en temps réel.  
**Instructions** :  
1. Dans `user_form_view_model.dart` :  
   - Méthode `submitUser()` appelant `POST /api/users` (création) ou `PUT /api/users/{id}` (modification).  
   - Gérer les erreurs 422 (afficher les messages par champ).  
2. Lier le ViewModel à l'UI :  
   - Afficher les erreurs sous les champs concernés.  
   - Rediriger vers la liste après succès.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/users/user_form/user_form_view_model.dart` (mise à jour)  
- `FICHIER : aramco_frontend/lib/features/users/user_form/user_form_screen.dart` (mise à jour)  
**Validation** : La création/modification fonctionne, les erreurs de validation sont affichées.

---

#### **Module 2 : Gestion des Ressources Humaines (RH)**

**Prompt F-11**  
*Tâche* : Développer l'UI de la page liste des employés avec filtres par département.  
**Instructions** :  
1. Créer `lib/features/employees/employee_list/employee_list_screen.dart` :  
   - Cartes employés avec photo, nom, poste, département.  
   - Filtres par département (dropdown ou chips).  
   - Recherche globale par nom/poste.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/employees/employee_list/employee_list_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/employee_card.dart`  
**Validation** : La liste s'affiche, les filtres fonctionnent, l'UI est responsive.

---

**Prompt F-12**  
*Tâche* : Connecter la liste à l'endpoint GET /api/employees avec chargement progressif.  
**Instructions** :  
1. Créer `employee_list_view_model.dart` :  
   - Appeler `ApiService.get('/api/employees')` avec filtres.  
   - Implémenter le chargement infini ( Infinite Scroll ou pagination).  
2. Utiliser `ListView.builder` avec `ScrollController` pour le chargement progressif.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/employees/employee_list/employee_list_view_model.dart`  
- `FICHIER : aramco_frontend/lib/features/employees/employee_list/employee_list_screen.dart` (mise à jour)  
**Validation** : Les données se chargent au défilement, les filtres sont appliqués.

---

**Prompt F-13**  
*Tâche* : Développer le formulaire de demande de congé avec calendrier interactif.  
**Instructions** :  
1. Créer `lib/features/leave_requests/leave_form_screen.dart` :  
   - Sélection des dates avec `TableCalendar` (package `table_calendar`).  
   - Choix du type de congé (dropdown).  
   - Champ motif (textarea).  
2. Valider les dates (pas de week-end, pas de chevauchement).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/leave_requests/leave_form_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/date_range_picker.dart`  
**Validation** : Le calendrier s'affiche, les validations fonctionnent.

---

**Prompt F-14**  
*Tâche* : Développer l'interface d'évaluation avec sections et notes personnalisables.  
**Instructions** :  
1. Créer `lib/features/evaluations/evaluation_form_screen.dart` :  
   - Sections dynamiques (compétences, objectifs, commentaires).  
   - Notes par étoiles ou slider.  
   - Sauvegarde automatique (brouillon).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/evaluations/evaluation_form_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/rating_widget.dart`  
**Validation** : Les sections sont dynamiques, les notes sont enregistrées.

---

**Prompt F-15**  
*Tâche* : Développer la visualisation et téléchargement des fiches de paie avec filtre par mois.  
**Instructions** :  
1. Créer `lib/features/pay_slips/pay_slip_list_screen.dart` :  
   - Liste des fiches par mois/année.  
   - Aperçu PDF avec `flutter_pdfview`.  
   - Bouton de téléchargement (utilise l'endpoint d'export PDF).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/pay_slips/pay_slip_list_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/pdf_viewer.dart`  
**Validation** : Les fiches s'affichent, le PDF s'ouvre, le téléchargement fonctionne.

---

#### **Modules 3 à 8 (Exemples - Même Structure)**

**Prompt F-16 (Commandes)**  
*Tâche* : Développer l'UI de la page liste des commandes avec statuts colorés et recherche.  
**Instructions** :  
1. Créer `lib/features/orders/order_list/order_list_screen.dart` :  
   - Tableau avec colonnes : Référence, Client, Total, Statut (couleurs dynamiques).  
   - Recherche par référence/client.  
   - Filtres par statut (pending, delivered, etc.).  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/orders/order_list/order_list_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/status_chip.dart`  
**Validation** : La liste s'affiche, les statuts sont colorés, la recherche/filtre fonctionne.

---

**Prompt F-36 (Tableau de Bord)**  
*Tâche* : Développer l'UI du tableau de bord avec widgets personnalisables et glisser-déposer.  
**Instructions** :  
1. Créer `lib/features/dashboard/dashboard_screen.dart` :  
   - Grille de widgets (KPIs, graphiques, alertes).  
   - Glisser-déposer pour réorganiser (package `flutter_grid`).  
   - Bouton d'ajout/suppression de widgets.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/dashboard/dashboard_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/dashboard_widget.dart`  
**Validation** : Les widgets sont déplaçables, l'UI s'adapte à la taille de l'écran.

---

**Prompt F-41 (Exports)**  
*Tâche* : Développer l'interface d'export avec sélection de format et paramètres.  
**Instructions** :  
1. Créer `lib/features/exports/export_screen.dart` :  
   - Sélection du type de rapport (dropdown).  
   - Choix du format (PDF/Excel).  
   - Paramètres avancés (période, filtres).  
   - Bouton "Générer" avec état de chargement.  
**Fichiers** :  
- `FICHIER : aramco_frontend/lib/features/exports/export_screen.dart`  
- `FICHIER : aramco_frontend/lib/core/widgets/export_params_form.dart`  
**Validation** : L'interface s'affiche, les paramètres sont envoyés à l'API.

---

### Notes pour le Développeur Frontend

1. **Références Obligatoires** :  
   - Contrat d'API (Section 1.1 du plan) pour les endpoints.  
   - Structure du projet (Section 1.3) pour l'organisation des fichiers.  
   - Design System : Utiliser les couleurs/polices définies dans `app_theme.dart`.

2. **Bonnes Pratiques** :  
   - **Tests** : Écrire des tests unitaires pour les ViewModels et les services.  
   - **Internationalisation** : Utiliser `flutter_localizations` pour le support multilingue.  
   - **Performance** : Optimiser les images (webp), utiliser `const` widgets.

3. **Outils Recommandés** :  
   - Packages : `http`, `flutter_secure_storage`, `riverpod`, `go_router`, `table_calendar`.  
   - IDE : VS Code avec extensions Flutter/Dart.  
   - Versioning : Git avec des branches par module (ex: `feature/user-management`).

4. **Livraison** :  
   - Chaque tâche validée doit être commitée avec un message clair (ex: `feat(login): add form validation`).  
   - Demander une revue de code avant de merge dans `main`.

> **"Le code n'est pas fini tant qu'il n'est pas testé, documenté et validé par l'utilisateur."**  
> *— Philosophie de l'Architecte*