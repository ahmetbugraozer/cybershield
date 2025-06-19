import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/url_analysis_service.dart';

// Service provider'ı
final urlAnalysisServiceProvider = Provider((ref) => UrlAnalysisService());

// State provider'ları
final urlInputProvider = StateProvider<String>((ref) => '');
final isAnalyzingProvider = StateProvider<bool>((ref) => false);

// URL validasyon provider'ı - iyileştirilmiş
final urlValidationProvider = Provider<bool>((ref) {
  final url = ref.watch(urlInputProvider);
  if (url.isEmpty) return true; // Boşsa hata gösterme

  return _isValidUrl(url);
});

// Manuel URL analiz provider'ı - daha güvenli
final manualUrlAnalysisProvider = StateNotifierProvider<
  ManualUrlAnalysisNotifier,
  AsyncValue<UrlAnalysisResult?>
>((ref) {
  return ManualUrlAnalysisNotifier(ref);
});

class ManualUrlAnalysisNotifier
    extends StateNotifier<AsyncValue<UrlAnalysisResult?>> {
  final Ref _ref;

  ManualUrlAnalysisNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> analyzeUrl(String url) async {
    // URL'yi temizle ve normalize et
    final normalizedUrl = _normalizeUrl(url.trim());

    if (!_isValidUrl(normalizedUrl)) {
      state = AsyncValue.error(
        'Geçerli bir URL girin (örn: https://example.com)',
        StackTrace.current,
      );
      return;
    }

    debugPrint('URL analizi başlatılıyor: $normalizedUrl');
    state = const AsyncValue.loading();

    try {
      _ref.read(isAnalyzingProvider.notifier).state = true;

      final service = _ref.read(urlAnalysisServiceProvider);
      final result = await service.analyzeUrl(normalizedUrl);

      state = AsyncValue.data(result);
    } catch (e) {
      debugPrint('URL analiz hatası: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _ref.read(isAnalyzingProvider.notifier).state = false;
    }
  }
}

// İyileştirilmiş URL validasyon fonksiyonu
bool _isValidUrl(String url) {
  if (url.isEmpty) return false;

  try {
    // URL'yi normalize et
    final normalizedUrl = _normalizeUrl(url);
    final uri = Uri.parse(normalizedUrl);

    // Temel kontroller
    if (!uri.hasScheme) return false;
    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) return false;
    if (uri.host.isEmpty) return false;

    // Domain format kontrolü
    final domainRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$',
    );

    // IP adresi mi kontrol et
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');

    return domainRegex.hasMatch(uri.host) || ipRegex.hasMatch(uri.host);
  } catch (e) {
    return false;
  }
}

// URL normalize fonksiyonu
String _normalizeUrl(String url) {
  if (url.isEmpty) return url;

  String normalized = url.trim();

  // Eğer scheme yoksa https ekle
  if (!normalized.contains('://')) {
    normalized = 'https://$normalized';
  }

  // www. prefix'i düzenle
  if (normalized.startsWith('www.')) {
    normalized = 'https://$normalized';
  }

  return normalized;
}
