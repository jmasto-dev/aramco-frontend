import 'dart:convert';
import 'dart:io';

/// Script de test pour vérifier la connexion au backend Laravel
Future<void> main() async {
  const String baseUrl = 'http://127.0.0.1:8000';
  const List<String> endpoints = [
    '/api/v1/health',
    '/api/v1/info',
    '/',
    '/api',
  ];

  print('🔍 Test de connexion au backend Laravel...');
  print('📍 URL de base: $baseUrl');
  print('');

  for (final endpoint in endpoints) {
    final url = Uri.parse('$baseUrl$endpoint');
    print('🌐 Test de l\'endpoint: $endpoint');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(url);
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'Aramco-Frontend-Test/1.0');

      final response = await request.close();

      print('   ✅ Status: ${response.statusCode}');
      
      // Lire la réponse
      final responseBody = await response.transform(utf8.decoder).join();
      
      // Afficher le début de la réponse pour diagnostic
      final preview = responseBody.length > 200 
          ? responseBody.substring(0, 200) + '...' 
          : responseBody;
      
      print('   📄 Type de contenu: ${response.headers.value('content-type')}');
      print('   📝 Aperçu de la réponse:');
      print('   $preview');
      
      // Vérifier si c'est du JSON
      if (response.headers.value('content-type')?.contains('application/json') == true) {
        try {
          final jsonData = jsonDecode(responseBody);
          print('   ✅ Réponse JSON valide:');
          print('   ${jsonData}');
        } catch (e) {
          print('   ❌ Erreur de décodage JSON: $e');
        }
      } else {
        print('   ⚠️ La réponse n\'est pas du JSON');
      }
      
      client.close();
    } catch (e) {
      print('   ❌ Erreur de connexion: $e');
    }
    
    print('');
  }

  print('🏁 Tests terminés');
  print('');
  print('📋 Diagnostic:');
  print('   • Si le statut est 200 mais la réponse est HTML, il y a peut-être une erreur Laravel');
  print('   • Si le statut est 404, les routes API ne sont pas trouvées');
  print('   • Si le statut est 500, il y a une erreur serveur dans Laravel');
  print('   • Vérifiez les logs Laravel avec: php artisan log:clear && tail -f storage/logs/laravel.log');
}
