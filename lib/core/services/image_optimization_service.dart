import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageOptimizationConfig {
 final int maxWidth;
 final int maxHeight;
 final int quality;
 final bool enableCache;
 final Duration cacheDuration;
 final ImageFormat format;

 const ImageOptimizationConfig({
 this.maxWidth = 1024,
 this.maxHeight = 1024,
 this.quality = 85,
 this.enableCache = true,
 this.cacheDuration = const Duration(days: 30),
 this.format = ImageFormat.jpeg,
 });
}

enum ImageFormat {
 jpeg,
 png,
 webp,
}

class OptimizedImageInfo {
 final String url;
 final String? localPath;
 final int width;
 final int height;
 final int size;
 final DateTime lastModified;
 final String format;

 const OptimizedImageInfo({
 required this.url,
 this.localPath,
 required this.width,
 required this.height,
 required this.size,
 required this.lastModified,
 required this.format,
 });
}

class ImageOptimizationService {
 static final ImageOptimizationService _instance = ImageOptimizationService._internal();
 factory ImageOptimizationService() => _instance;
 ImageOptimizationService._internal();

 final ImageOptimizationConfig _defaultConfig = const ImageOptimizationConfig();
 final Map<String, OptimizedImageInfo> _imageCache = {};
 final Map<String, Completer<Uint8List>> _loadingImages = {};
 Directory? _cacheDir;

 Future<void> initialize() {async {
 _cacheDir = await getApplicationDocumentsDirectory();
 await _cleanupExpiredCache();
 }

 String _generateCacheKey(String url, ImageOptimizationConfig config) {
 final keyData = '${url}_${config.maxWidth}_${config.maxHeight}_${config.quality}_${config.format.name}';
 final bytes = utf8.encode(keyData);
 final digest = sha256.convert(bytes);
 return '${digest.toString()}.${_getFileExtension(config.format)}';
 }

 String _getFileExtension(ImageFormat format) {
 switch (format) {
 case ImageFormat.jpeg:
 return 'jpg';
 case ImageFormat.png:
 return 'png';
 case ImageFormat.webp:
 return 'webp';
}
 }

 Future<String> _getCachePath(String key) {async {
 final dir = _cacheDir ?? await getApplicationDocumentsDirectory();
 return '${dir.path}/images/$key';
 }

 Future<void> _cleanupExpiredCache() {async {
 if (_cacheDir == null) r{eturn;

 final imagesDir = Directory('${_cacheDir!.path}/images');
 if (!await imagesDir.exists()){ return;

 await for (final entity in imagesDir.list()) {
 if (entity is File) {
 try {
 final stat = await entity.stat();
 final age = DateTime.now().difference(stat.modified);
 
 if (age > _defaultConfig.cacheDuration) {
 await entity.delete();
}
 } catch (e) {
 // Supprimer les fichiers corrompus
 try {
 await entity.delete();
} catch (_) {}
 }
 }
}
 }

 Future<bool> _isImageCached(String key) {async {
 final path = await _getCachePath(key);
 final file = File(path);
 
 if (!await file.exists()){ return false;
 
 try {
 final stat = await file.stat();
 final age = DateTime.now().difference(stat.modified);
 return age <= _defaultConfig.cacheDuration;
} catch (e) {
 return false;
}
 }

 Future<Uint8List> _loadImageFromNetwork(String url) {async {
 if (_loadingImages.containsKey(url)){ {
 return await _loadingImages[url]!.future;
}

 final completer = Completer<Uint8List>();
 _loadingImages[url] = completer;

 try {
 final response = await NetworkAssetBundle(Uri.parse(url)).load(url);
 final bytes = response.buffer.asUint8List();
 completer.complete(bytes);
 return bytes;
} catch (e) {
 completer.completeError(e);
 rethrow;
} finally {
 _loadingImages.remove(url);
}
 }

 Future<Uint8List> _resizeImage(
 Uint8List imageBytes,
 int targetWidth,
 int targetHeight,
 ImageFormat format,
 int quality,
 ) {async {
 final codec = await ui.instantiateImageCodec(imageBytes);
 final frame = await codec.getNextFrame();
 final image = frame.image;

 // Calculer les dimensions en conservant le ratio
 final originalWidth = image.width;
 final originalHeight = image.height;
 final aspectRatio = originalWidth / originalHeight;

 int finalWidth = targetWidth;
 int finalHeight = targetHeight;

 if (aspectRatio > targetWidth / targetHeight) {
 finalHeight = (targetWidth / aspectRatio).round();
} else {
 finalWidth = (targetHeight * aspectRatio).round();
}

 final resizedImage = await _resizeUiImage(image, finalWidth, finalHeight);
 
 final byteData = await resizedImage.toByteData(
 format: format == ImageFormat.png ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba,
 );

 if (byteData == null) {
 throw Exception('Failed to convert image to bytes');
}

 return byteData.buffer.asUint8List();
 }

 Future<ui.Image> _resizeUiImage(ui.Image image, int width, int height) async {
 final recorder = ui.PictureRecorder();
 final canvas = Canvas(recorder);
 
 canvas.drawImageRect(
 image,
 Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
 Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
 Paint(),
 );

 final picture = recorder.endRecording();
 final resizedImage = await picture.toImage(width, height);
 picture.dispose();
 image.dispose();

 return resizedImage;
 }

 Future<void> _cacheImage(String key, Uint8List bytes) {async {
 try {
 final path = await _getCachePath(key);
 final file = File(path);
 
 // Créer le répertoire si nécessaire
 await file.parent.create(recursive: true);
 
 await file.writeAsBytes(bytes);
} catch (e) {
 // Ignorer les erreurs de cache
;
 }

 Future<Uint8List?> _getCachedImage(String key) async {
 try {
 final path = await _getCachePath(key);
 final file = File(path);
 
 if (!await file.exists()){ return null;
 
 return await file.readAsBytes();
} catch (e) {
 return null;
}
 }

 Future<Uint8List> getOptimizedImage(
 String url, {
 ImageOptimizationConfig? config,
 }) {async {
 final imageConfig = config ?? _defaultConfig;
 final cacheKey = _generateCacheKey(url, imageConfig);

 // Vérifier le cache d'abord
 if (imageConfig.enableCache) {
 final cachedBytes = await _getCachedImage(cacheKey);
 if (cachedBytes != null) {
 return cachedBytes;
 }
}

 // Charger l'image depuis le réseau
 final originalBytes = await _loadImageFromNetwork(url);

 // Optimiser l'image
 Uint8List optimizedBytes;
 
 if (imageConfig.maxWidth >= 1024 && imageConfig.maxHeight >= 1024) {
 // Pas de redimensionnement nécessaire
 optimizedBytes = originalBytes;
} else {
 optimizedBytes = await _resizeImage(
 originalBytes,
 imageConfig.maxWidth,
 imageConfig.maxHeight,
 imageConfig.format,
 imageConfig.quality,
 );
}

 // Mettre en cache
 if (imageConfig.enableCache) {
 await _cacheImage(cacheKey, optimizedBytes);
}

 return optimizedBytes;
 }

 Future<OptimizedImageInfo?> getImageInfo(String url) async {
 if (_imageCache.containsKey(url)){ {
 return _imageCache[url];
}

 try {
 final bytes = await _loadImageFromNetwork(url);
 final codec = await ui.instantiateImageCodec(bytes);
 final frame = await codec.getNextFrame();
 final image = frame.image;

 final info = OptimizedImageInfo(
 url: url,
 width: image.width,
 height: image.height,
 size: bytes.length,
 lastModified: DateTime.now(),
 format: _detectImageFormat(bytes),
 );

 _imageCache[url] = info;
 image.dispose();

 return info;
} catch (e) {
 return null;
}
 }

 String _detectImageFormat(Uint8List bytes) {
 if (bytes.length < 4) r{eturn 'unknown';

 // JPEG
 if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
 return 'jpeg';
}

 // PNG
 if (bytes.length > 8 &&
 bytes[0] == 0x89 && bytes[1] == 0x50 && 
 bytes[2] == 0x4E && bytes[3] == 0x47) {
 return 'png';
}

 // WebP
 if (bytes.length > 12 &&
 bytes[0] == 0x52 && bytes[1] == 0x49 && 
 bytes[2] == 0x46 && bytes[3] == 0x46 &&
 bytes[8] == 0x57 && bytes[9] == 0x45 && 
 bytes[10] == 0x42 && bytes[11] == 0x50) {
 return 'webp';
}

 return 'unknown';
 }

 Future<void> preloadImages(List<String> urls, {ImageOptimizationConfig? config}) {async {
 final futures = urls.map((url) => getOptimizedImage(url, config: config));
 await Future.wait(futures);
 }

 Future<void> clearCache() {async {
 if (_cacheDir == null) r{eturn;

 final imagesDir = Directory('${_cacheDir!.path}/images');
 if (await imagesDir.exists()){ {
 await for (final entity in imagesDir.list()) {
 try {
 if (entity is File) {
 await entity.delete();
}
 } catch (e) {
 // Ignorer les erreurs
 ;
 }
}

 _imageCache.clear();
 }

 Future<int> getCacheSize() {async {
 if (_cacheDir == null) r{eturn 0;

 final imagesDir = Directory('${_cacheDir!.path}/images');
 if (!await imagesDir.exists()){ return 0;

 int totalSize = 0;
 await for (final entity in imagesDir.list()) {
 if (entity is File) {
 try {
 final stat = await entity.stat();
 totalSize += stat.size;
 } catch (e) {
 // Ignorer les erreurs
 ;
 }
}

 return totalSize;
 }

 Future<Map<String, dynamic>> getCacheStats() async {
 final size = await getCacheSize();
 final imagesDir = Directory('${_cacheDir!.path}/images');
 int fileCount = 0;

 if (await imagesDir.exists()){ {
 await for (final entity in imagesDir.list()) {
 if (entity is File) {
 fileCount++;
 }
 }
}

 return {
 'size': size,
 'sizeMB': (size / (1024 * 1024)).toStringAsFixed(2),
 'fileCount': fileCount,
 'memoryCacheSize': _imageCache.length,
};
 }

 // Optimisation pour les assets locaux
 Future<Uint8List> optimizeLocalAsset(
 String assetPath, {
 ImageOptimizationConfig? config,
 }) {async {
 final imageConfig = config ?? _defaultConfig;
 final cacheKey = 'asset_${_generateCacheKey(assetPath, imageConfig)}';

 // Vérifier le cache
 if (imageConfig.enableCache) {
 final cachedBytes = await _getCachedImage(cacheKey);
 if (cachedBytes != null) {
 return cachedBytes;
 }
}

 // Charger l'asset
 final byteData = await rootBundle.load(assetPath);
 final bytes = byteData.buffer.asUint8List();

 // Optimiser si nécessaire
 Uint8List optimizedBytes;
 
 if (imageConfig.maxWidth >= 1024 && imageConfig.maxHeight >= 1024) {
 optimizedBytes = bytes;
} else {
 optimizedBytes = await _resizeImage(
 bytes,
 imageConfig.maxWidth,
 imageConfig.maxHeight,
 imageConfig.format,
 imageConfig.quality,
 );
}

 // Mettre en cache
 if (imageConfig.enableCache) {
 await _cacheImage(cacheKey, optimizedBytes);
}

 return optimizedBytes;
 }

 // Validation des URLs d'images
 bool isValidImageUrl(String url) {
 try {
 final uri = Uri.parse(url);
 return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
} catch (e) {
 return false;
}
 }

 // Génération de thumbnails
 Future<Uint8List> generateThumbnail(
 String url, {
 int width = 150,
 int height = 150,
 int quality = 70,
 }) {async {
 final config = ImageOptimizationConfig(
 maxWidth: width,
 maxHeight: height,
 quality: quality,
 format: ImageFormat.jpeg,
 );

 return await getOptimizedImage(url, config: config);
 }

 // Compression d'image avec qualité personnalisée
 Future<Uint8List> compressImage(
 Uint8List imageBytes, {
 int quality = 80,
 ImageFormat format = ImageFormat.jpeg,
 }) {async {
 // Décoder l'image
 final codec = await ui.instantiateImageCodec(imageBytes);
 final frame = await codec.getNextFrame();
 final image = frame.image;

 // Re-encoder avec la qualité désirée
 final byteData = await image.toByteData(
 format: format == ImageFormat.png ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba,
 );

 if (byteData == null) {
 throw Exception('Failed to compress image');
}

 image.dispose();
 return byteData.buffer.asUint8List();
 }
}

// Extension pour faciliter l'utilisation avec les widgets Flutter
extension ImageOptimizationExtension on ImageOptimizationService {
 Widget buildOptimizedImage(
 String url, {
 double? width,
 double? height,
 BoxFit fit = BoxFit.cover,
 Widget? placeholder,
 Widget? errorWidget,
 ImageOptimizationConfig? config,
 }) {
 return FutureBuilder<Uint8List>(
 future: getOptimizedImage(url, config: config),
 builder: (context, snapshot) {
 if (snapshot.connectionState == ConnectionState.waiting) {
 return placeholder ??
 const SizedBox(
 width: width,
 height: height,
 color: Colors.grey[300],
 child: const Center(child: CircularProgressIndicator()),
 );
 }

 if (snapshot.hasError || !snapshot.hasData) {
 return errorWidget ??
 const SizedBox(
 width: width,
 height: height,
 color: Colors.grey[300],
 child: const Icon(Icons.error_outline, color: Colors.grey),
 );
 }

 return Image.memory(
 snapshot.data!,
 width: width,
 height: height,
 fit: fit,
 );
 },
 );
 }
}
