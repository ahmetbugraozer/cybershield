import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/utils/env_config.dart';

class VirusTotalResult {
  final bool isScanned;
  final int positiveDetections;
  final int totalScans;
  final Map<String, dynamic> scanResults;
  final String permalink;

  VirusTotalResult({
    required this.isScanned,
    required this.positiveDetections,
    required this.totalScans,
    required this.scanResults,
    required this.permalink,
  });
}

class VirusTotalService {
  final Dio _dio;
  static const String _baseUrl = 'https://www.virustotal.com/vtapi/v2';

  VirusTotalService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Future<VirusTotalResult?> scanUrl(String url) async {
    if (!EnvConfig.hasVirusTotalKey) {
      return null; // API anahtarı yoksa null döndür
    }

    try {
      // İlk önce URL'yi taraya gönder
      await _submitUrl(url);

      // Biraz bekle ve sonucu al
      await Future.delayed(const Duration(seconds: 2));

      return await _getUrlReport(url);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitUrl(String url) async {
    await _dio.post(
      '$_baseUrl/url/scan',
      data: FormData.fromMap({
        'apikey': EnvConfig.virusTotalApiKey,
        'url': url,
      }),
    );
  }

  Future<VirusTotalResult?> _getUrlReport(String url) async {
    final response = await _dio.post(
      '$_baseUrl/url/report',
      data: FormData.fromMap({
        'apikey': EnvConfig.virusTotalApiKey,
        'resource': url,
        'allinfo': '1',
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data['response_code'] == 1) {
        return VirusTotalResult(
          isScanned: true,
          positiveDetections: data['positives'] ?? 0,
          totalScans: data['total'] ?? 0,
          scanResults: data['scans'] ?? {},
          permalink: data['permalink'] ?? '',
        );
      }
    }

    return null;
  }

  VirusTotalResult? _handleError(DioException error) {
    // Rate limit veya API hatalarında null döndür
    return null;
  }
}
