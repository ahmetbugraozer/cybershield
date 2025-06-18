import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/url_analysis_service.dart';

// Service provider'ı
final urlAnalysisServiceProvider = Provider((ref) => UrlAnalysisService());

// State provider'ları
final urlInputProvider = StateProvider<String>((ref) => '');
final isAnalyzingProvider = StateProvider<bool>((ref) => false);

// URL analiz provider'ı
final urlAnalysisProvider =
    FutureProvider.autoDispose<UrlAnalysisResult?>((ref) async {
  final url = ref.watch(urlInputProvider);

  // URL boş veya geçersizse loading state'ini temizle ve null döndür
  if (url.isEmpty || !_isValidUrl(url)) {
    // Loading state'ini false yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.exists(isAnalyzingProvider)) {
        ref.read(isAnalyzingProvider.notifier).state = false;
      }
    });
    return null;
  }

  ref.read(isAnalyzingProvider.notifier).state = true;

  try {
    final service = ref.read(urlAnalysisServiceProvider);
    final result = await service.analyzeUrl(url);
    return result;
  } catch (e) {
    rethrow;
  } finally {
    // Her durumda loading state'ini temizle
    if (ref.exists(isAnalyzingProvider)) {
      ref.read(isAnalyzingProvider.notifier).state = false;
    }
  }
});

bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}
