import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Aramco SA E2E Tests', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    test('Complete User Flow - Login to Dashboard', () async {
      // Test du splash screen
      await driver!.waitFor(find.byValueKey('splash_screen'));
      await Future.delayed(Duration(seconds: 2));

      // Navigation vers l'écran de login
      await driver!.waitFor(find.byValueKey('login_screen'));
      
      // Vérification des éléments du formulaire de login
      await driver!.waitFor(find.byValueKey('email_field'));
      await driver!.waitFor(find.byValueKey('password_field'));
      await driver!.waitFor(find.byValueKey('login_button'));

      // Saisie des identifiants
      await driver!.tap(find.byValueKey('email_field'));
      await driver!.enterText('admin@aramco-sa.com');

      await driver!.tap(find.byValueKey('password_field'));
      await driver!.enterText('password123');

      // Validation du login
      await driver!.tap(find.byValueKey('login_button'));

      // Attente de la connexion et navigation vers le dashboard
      await driver!.waitFor(find.byValueKey('main_layout'), timeout: Duration(seconds: 10));
      
      // Vérification du dashboard
      await driver!.waitFor(find.byValueKey('dashboard_screen'));
      await driver!.waitFor(find.byValueKey('kpi_widgets'));
      
      print('✅ Login to Dashboard flow completed successfully');
    });

    test('Employee Management Flow', () async {
      // Connexion d'abord
      await _login(driver!);

      // Navigation vers la section employés
      await driver!.tap(find.byValueKey('employees_nav_item'));
      await driver!.waitFor(find.byValueKey('employees_screen'));

      // Vérification de la liste des employés
      await driver!.waitFor(find.byValueKey('employees_list'));
      
      // Test d'ajout d'employé
      await driver!.tap(find.byValueKey('add_employee_button'));
      await driver!.waitFor(find.byValueKey('employee_form_screen'));

      // Remplissage du formulaire
      await driver!.tap(find.byValueKey('first_name_field'));
      await driver!.enterText('John');

      await driver!.tap(find.byValueKey('last_name_field'));
      await driver!.enterText('Doe');

      await driver!.tap(find.byValueKey('email_field'));
      await driver!.enterText('john.doe@aramco-sa.com');

      await driver!.tap(find.byValueKey('phone_field'));
      await driver!.enterText('+9661234567890');

      await driver!.tap(find.byValueKey('department_field'));
      await driver!.tap(find.text('IT'));

      await driver!.tap(find.byValueKey('position_field'));
      await driver!.enterText('Software Engineer');

      await driver!.tap(find.byValueKey('salary_field'));
      await driver!.enterText('15000');

      // Sauvegarde de l'employé
      await driver!.tap(find.byValueKey('save_employee_button'));
      
      // Retour à la liste
      await driver!.waitFor(find.byValueKey('employees_screen'));
      
      print('✅ Employee management flow completed successfully');
    });

    test('Order Management Flow', () async {
      // Connexion d'abord
      await _login(driver!);

      // Navigation vers la section commandes
      await driver!.tap(find.byValueKey('orders_nav_item'));
      await driver!.waitFor(find.byValueKey('orders_screen'));

      // Vérification de la liste des commandes
      await driver!.waitFor(find.byValueKey('orders_list'));

      // Test de création de commande
      await driver!.tap(find.byValueKey('add_order_button'));
      await driver!.waitFor(find.byValueKey('order_form_screen'));

      // Remplissage du formulaire
      await driver!.tap(find.byValueKey('customer_name_field'));
      await driver!.enterText('Test Customer');

      await driver!.tap(find.byValueKey('customer_email_field'));
      await driver!.enterText('customer@test.com');

      // Ajout de produits
      await driver!.tap(find.byValueKey('add_product_button'));
      await driver!.waitFor(find.byValueKey('product_selector'));

      await driver!.tap(find.text('Test Product'));
      await driver!.tap(find.byValueKey('confirm_product_selection'));

      // Validation de la commande
      await driver!.tap(find.byValueKey('save_order_button'));
      
      // Retour à la liste
      await driver!.waitFor(find.byValueKey('orders_screen'));
      
      print('✅ Order management flow completed successfully');
    });

    test('Dashboard Widgets Interaction', () async {
      // Connexion d'abord
      await _login(driver!);

      // Vérification des widgets du dashboard
      await driver!.waitFor(find.byValueKey('dashboard_screen'));
      
      // Test d'interaction avec les KPIs
      await driver!.tap(find.byValueKey('total_employees_kpi'));
      await driver!.waitFor(find.byValueKey('employees_screen'));
      
      // Retour au dashboard
      await driver!.tap(find.byValueKey('dashboard_nav_item'));
      await driver!.waitFor(find.byValueKey('dashboard_screen'));

      // Test d'interaction avec les graphiques
      await driver!.tap(find.byValueKey('orders_chart'));
      await driver!.waitFor(find.byValueKey('orders_screen'));
      
      // Retour au dashboard
      await driver!.tap(find.byValueKey('dashboard_nav_item'));
      await driver!.waitFor(find.byValueKey('dashboard_screen'));

      // Test de personnalisation du dashboard
      await driver!.tap(find.byValueKey('customize_dashboard_button'));
      await driver!.waitFor(find.byValueKey('dashboard_customization_screen'));
      
      // Modification de l'ordre des widgets
      await driver!.tap(find.byValueKey('widget_reorder_mode'));
      await driver!.tap(find.byValueKey('widget_1'));
      await driver!.tap(find.byValueKey('move_widget_down'));
      
      // Sauvegarde de la configuration
      await driver!.tap(find.byValueKey('save_dashboard_config'));
      await driver!.waitFor(find.byValueKey('dashboard_screen'));
      
      print('✅ Dashboard widgets interaction completed successfully');
    });

    test('Search and Filter Functionality', () async {
      // Connexion d'abord
      await _login(driver!);

      // Test de recherche globale
      await driver!.tap(find.byValueKey('search_button'));
      await driver!.waitFor(find.byValueKey('global_search_screen'));

      await driver!.tap(find.byValueKey('search_input'));
      await driver!.enterText('John');

      await driver!.tap(find.byValueKey('search_button_execute'));
      await driver!.waitFor(find.byValueKey('search_results'));

      // Vérification des résultats
      await driver!.waitFor(find.byValueKey('search_result_item'));
      
      // Test de filtres
      await driver!.tap(find.byValueKey('filter_button'));
      await driver!.waitFor(find.byValueKey('search_filters'));

      await driver!.tap(find.byValueKey('filter_type_employees'));
      await driver!.tap(find.byValueKey('apply_filters'));

      // Vérification des résultats filtrés
      await driver!.waitFor(find.byValueKey('search_results'));
      
      print('✅ Search and filter functionality completed successfully');
    });

    test('Settings and Profile Management', () async {
      // Connexion d'abord
      await _login(driver!);

      // Navigation vers les paramètres
      await driver!.tap(find.byValueKey('profile_button'));
      await driver!.waitFor(find.byValueKey('profile_screen'));

      // Test de modification du profil
      await driver!.tap(find.byValueKey('edit_profile_button'));
      await driver!.waitFor(find.byValueKey('profile_form_screen'));

      await driver!.tap(find.byValueKey('first_name_field'));
      await driver!.enterText('Admin Updated');

      await driver!.tap(find.byValueKey('save_profile_button'));
      await driver!.waitFor(find.byValueKey('profile_screen'));

      // Test des paramètres de l'application
      await driver!.tap(find.byValueKey('settings_button'));
      await driver!.waitFor(find.byValueKey('settings_screen'));

      // Test du changement de thème
      await driver!.tap(find.byValueKey('theme_selector'));
      await driver!.tap(find.text('Dark'));

      // Test du changement de langue
      await driver!.tap(find.byValueKey('language_selector'));
      await driver!.tap(find.text('Français'));

      // Sauvegarde des paramètres
      await driver!.tap(find.byValueKey('save_settings_button'));
      await driver!.waitFor(find.byValueKey('profile_screen'));
      
      print('✅ Settings and profile management completed successfully');
    });

    test('Logout Flow', () async {
      // Connexion d'abord
      await _login(driver!);

      // Test de déconnexion
      await driver!.tap(find.byValueKey('logout_button'));
      
      // Confirmation de déconnexion
      await driver!.waitFor(find.byValueKey('logout_confirmation_dialog'));
      await driver!.tap(find.byValueKey('confirm_logout_button'));

      // Retour à l'écran de login
      await driver!.waitFor(find.byValueKey('login_screen'));
      
      print('✅ Logout flow completed successfully');
    });

    test('Performance Test - App Responsiveness', () async {
      // Connexion d'abord
      await _login(driver!);

      final stopwatch = Stopwatch()..start();

      // Test de navigation rapide entre les écrans
      await driver!.tap(find.byValueKey('dashboard_nav_item'));
      await driver!.waitFor(find.byValueKey('dashboard_screen'));

      await driver!.tap(find.byValueKey('employees_nav_item'));
      await driver!.waitFor(find.byValueKey('employees_screen'));

      await driver!.tap(find.byValueKey('orders_nav_item'));
      await driver!.waitFor(find.byValueKey('orders_screen'));

      await driver!.tap(find.byValueKey('dashboard_nav_item'));
      await driver!.waitFor(find.byValueKey('dashboard_screen'));

      stopwatch.stop();

      // Vérification que la navigation est rapide (< 3 secondes)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      print('✅ Performance test completed - Navigation time: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Error Handling Test', () async {
      // Test de connexion avec des identifiants invalides
      await driver!.waitFor(find.byValueKey('login_screen'));
      
      await driver!.tap(find.byValueKey('email_field'));
      await driver!.enterText('invalid@test.com');

      await driver!.tap(find.byValueKey('password_field'));
      await driver!.enterText('wrongpassword');

      await driver!.tap(find.byValueKey('login_button'));

      // Vérification du message d'erreur
      await driver!.waitFor(find.byValueKey('error_message'));
      
      // Test de connexion avec des champs vides
      await driver!.tap(find.byValueKey('email_field'));
      await driver!.enterText('');

      await driver!.tap(find.byValueKey('password_field'));
      await driver!.enterText('');

      await driver!.tap(find.byValueKey('login_button'));

      // Vérification des messages de validation
      await driver!.waitFor(find.byValueKey('email_error'));
      await driver!.waitFor(find.byValueKey('password_error'));
      
      print('✅ Error handling test completed successfully');
    });
  });
}

Future<void> _login(FlutterDriver driver) async {
  await driver.waitFor(find.byValueKey('login_screen'));
  
  await driver.tap(find.byValueKey('email_field'));
  await driver.enterText('admin@aramco-sa.com');

  await driver.tap(find.byValueKey('password_field'));
  await driver.enterText('password123');

  await driver.tap(find.byValueKey('login_button'));
  await driver.waitFor(find.byValueKey('main_layout'), timeout: Duration(seconds: 10));
}
