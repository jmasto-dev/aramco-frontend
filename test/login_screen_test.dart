import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aramco_frontend/presentation/screens/login_screen.dart';
import 'package:aramco_frontend/presentation/providers/auth_provider.dart';

void main() {
  group('Tests de l\'écran de connexion - Tâche F-03', () {
    testWidgets('L\'écran de connexion s\'affiche correctement', (WidgetTester tester) async {
      // Construire le widget avec ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Vérifier que les éléments principaux sont présents
      expect(find.text('Bienvenue'), findsOneWidget);
      expect(find.text('Connectez-vous à votre espace Aramco SA'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Se souvenir de moi'), findsOneWidget);
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets('Les informations de support sont affichées', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Vérifier que les informations de support sont présentes
      expect(find.text('Besoin d\'aide ?'), findsOneWidget);
      expect(find.text('+221 33 123 45 67'), findsOneWidget);
      expect(find.text('support@aramco-sa.com'), findsOneWidget);
    });

    testWidgets('Le bouton "Mot de passe oublié" affiche une boîte de dialogue', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Cliquer sur le lien "Mot de passe oublié"
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      // Vérifier que la boîte de dialogue s'affiche
      expect(find.text('Mot de passe oublié'), findsOneWidget);
      expect(find.text('Veuillez contacter votre administrateur pour réinitialiser votre mot de passe.'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('L\'option "Se souvenir de moi" fonctionne', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Trouver la checkbox
      final checkbox = find.byType(Checkbox);

      // Vérifier qu'elle est initialement décochée
      expect(tester.widget<Checkbox>(checkbox).value, false);

      // Cliquer sur la checkbox
      await tester.tap(checkbox);
      await tester.pump();

      // Vérifier qu'elle est maintenant cochée
      expect(tester.widget<Checkbox>(checkbox).value, true);
    });

    testWidgets('Les champs de formulaire acceptent la saisie', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Trouver les champs de texte
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      // Saisir du texte dans les champs
      await tester.enterText(emailField, 'test@aramco-sa.com');
      await tester.enterText(passwordField, 'Password123!');

      // Vérifier que le texte a été saisi
      expect(find.text('test@aramco-sa.com'), findsOneWidget);
      expect(find.text('Password123!'), findsOneWidget);
    });

    testWidgets('Le logo Aramco SA est affiché', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Vérifier que l'icône de l'entreprise est présente
      expect(find.byIcon(Icons.business), findsOneWidget);
    });
  });
}
