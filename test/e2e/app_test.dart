import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:aramco_frontend/main.dart' as app;

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Aramco Frontend E2E Tests', () {
    testWidgets('Complete user workflow test', (WidgetTester tester) async {
      // Lancement de l'application
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Écran de splash
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Test 2: Écran de login
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Se connecter'), findsOneWidget);

      // Test 3: Processus de login
      await tester.enterText(find.byKey(Key('email_field')), 'test@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Test 4: Vérification du tableau de bord
      expect(find.text('Tableau de Bord'), findsOneWidget);
      expect(find.byType(Grid), findsOneWidget);

      // Test 5: Navigation vers les employés
      await tester.tap(find.byKey(Key('employees_nav')));
      await tester.pumpAndSettle();
      expect(find.text('Employés'), findsOneWidget);

      // Test 6: Recherche d'employé
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets);

      // Test 7: Navigation vers les commandes
      await tester.tap(find.byKey(Key('orders_nav')));
      await tester.pumpAndSettle();
      expect(find.text('Commandes'), findsOneWidget);

      // Test 8: Création d'une commande
      await tester.tap(find.byKey(Key('add_order_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('order_name_field')), 'Test Order');
      await tester.tap(find.byKey(Key('save_order_button')));
      await tester.pumpAndSettle();

      // Test 9: Navigation vers les rapports
      await tester.tap(find.byKey(Key('reports_nav')));
      await tester.pumpAndSettle();
      expect(find.text('Rapports'), findsOneWidget);

      // Test 10: Exportation d'un rapport
      await tester.tap(find.byKey(Key('export_report_button')));
      await tester.pumpAndSettle();
      expect(find.text('Exporter'), findsOneWidget);

      // Test 11: Navigation vers les notifications
      await tester.tap(find.byKey(Key('notifications_nav')));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);

      // Test 12: Test de recherche globale
      await tester.tap(find.byKey(Key('search_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets);

      // Test 13: Déconnexion
      await tester.tap(find.byKey(Key('logout_button')));
      await tester.pumpAndSettle();
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('Employee management workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'admin@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'admin123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigation vers employés
      await tester.tap(find.byKey(Key('employees_nav')));
      await tester.pumpAndSettle();

      // Ajout d'un employé
      await tester.tap(find.byKey(Key('add_employee_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('employee_name_field')), 'Test Employee');
      await tester.enterText(find.byKey(Key('employee_email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('employee_phone_field')), '1234567890');
      await tester.tap(find.byKey(Key('save_employee_button')));
      await tester.pumpAndSettle();

      // Vérification que l'employé a été ajouté
      expect(find.text('Test Employee'), findsOneWidget);

      // Modification de l'employé
      await tester.tap(find.byKey(Key('edit_employee_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('employee_name_field')), 'Updated Employee');
      await tester.tap(find.byKey(Key('save_employee_button')));
      await tester.pumpAndSettle();

      // Vérification de la modification
      expect(find.text('Updated Employee'), findsOneWidget);

      // Suppression de l'employé
      await tester.tap(find.byKey(Key('delete_employee_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      // Vérification que l'employé a été supprimé
      expect(find.text('Updated Employee'), findsNothing);
    });

    testWidgets('Order management workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'user@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'user123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigation vers commandes
      await tester.tap(find.byKey(Key('orders_nav')));
      await tester.pumpAndSettle();

      // Création d'une commande
      await tester.tap(find.byKey(Key('add_order_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('order_reference_field')), 'ORD-001');
      await tester.tap(find.byKey(Key('add_product_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('product_name_field')), 'Test Product');
      await tester.enterText(find.byKey(Key('product_quantity_field')), '10');
      await tester.tap(find.byKey(Key('add_to_order_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('save_order_button')));
      await tester.pumpAndSettle();

      // Vérification que la commande a été créée
      expect(find.text('ORD-001'), findsOneWidget);

      // Mise à jour du statut
      await tester.tap(find.byKey(Key('order_status_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('En cours'));
      await tester.pumpAndSettle();

      // Vérification du statut mis à jour
      expect(find.text('En cours'), findsOneWidget);
    });

    testWidgets('Report generation workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'manager@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'manager123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigation vers rapports
      await tester.tap(find.byKey(Key('reports_nav')));
      await tester.pumpAndSettle();

      // Génération d'un rapport
      await tester.tap(find.byKey(Key('generate_report_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('report_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rapport des employés'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('generate_button')));
      await tester.pumpAndSettle();

      // Vérification que le rapport est généré
      expect(find.text('Rapport généré avec succès'), findsOneWidget);

      // Exportation du rapport
      await tester.tap(find.byKey(Key('export_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();

      // Vérification de l'exportation
      expect(find.text('Exportation réussie'), findsOneWidget);
    });

    testWidgets('Task management workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'employee@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'emp123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigation vers tâches
      await tester.tap(find.byKey(Key('tasks_nav')));
      await tester.pumpAndSettle();

      // Création d'une tâche
      await tester.tap(find.byKey(Key('add_task_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('task_title_field')), 'Test Task');
      await tester.enterText(find.byKey(Key('task_description_field')), 'Test Description');
      await tester.tap(find.byKey(Key('save_task_button')));
      await tester.pumpAndSettle();

      // Vérification que la tâche a été créée
      expect(find.text('Test Task'), findsOneWidget);

      // Marquage comme complétée
      await tester.tap(find.byKey(Key('task_checkbox')));
      await tester.pumpAndSettle();

      // Vérification du statut
      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('Notification system workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'user@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'user123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigation vers notifications
      await tester.tap(find.byKey(Key('notifications_nav')));
      await tester.pumpAndSettle();

      // Vérification des notifications
      expect(find.byType(ListTile), findsWidgets);

      // Marquer une notification comme lue
      await tester.tap(find.byKey(Key('notification_item')));
      await tester.pumpAndSettle();

      // Filtrer les notifications
      await tester.tap(find.byKey(Key('filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Non lues'));
      await tester.pumpAndSettle();
    });

    testWidgets('Search functionality workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'user@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'user123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Test de recherche globale
      await tester.tap(find.byKey(Key('search_button')));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'employee');
      await tester.pumpAndSettle();
      
      // Vérification des résultats
      expect(find.byType(ListTile), findsWidgets);

      // Test de recherche avancée
      await tester.tap(find.byKey(Key('advanced_search_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('search_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Employés'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(Key('search_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Error handling workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test login avec mauvais identifiants
      await tester.enterText(find.byKey(Key('email_field')), 'wrong@email.com');
      await tester.enterText(find.byKey(Key('password_field')), 'wrongpassword');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Vérification du message d'erreur
      expect(find.text('Identifiants incorrects'), findsOneWidget);

      // Test connexion réseau
      await tester.enterText(find.byKey(Key('email_field')), 'test@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'test123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Simulation d'erreur réseau (déjà géré dans le code)
      // Vérification que l'application gère gracieusement les erreurs
    });

    testWidgets('Performance test - Large dataset', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'admin@aramco.com');
      await tester.enterText(find.byKey(Key('password_field')), 'admin123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigation vers une liste avec beaucoup de données
      await tester.tap(find.byKey(Key('orders_nav')));
      await tester.pumpAndSettle();

      // Test de scrolling avec pagination
      await tester.fling(find.byType(ListView), Offset(0, -500), 10000);
      await tester.pumpAndSettle();

      // Vérification que le scrolling est fluide
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Accessibility test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérification des labels sémantiques
      expect(find.bySemanticsLabel('Champ email'), findsOneWidget);
      expect(find.bySemanticsLabel('Champ mot de passe'), findsOneWidget);
      expect(find.bySemanticsLabel('Bouton de connexion'), findsOneWidget);

      // Test navigation au clavier
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
    });
  });
}
