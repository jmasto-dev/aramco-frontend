import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

// Provider pour le service de stockage
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

// Provider pour le service API
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
