import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class BreachCheckResult {
  final bool isBreached;
  final int breachCount;
  final String message;

  BreachCheckResult({
    required this.isBreached,
    required this.breachCount,
    required this.message,
  });
}

class HibpService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.pwnedpasswords.com';

  HibpService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<BreachCheckResult> checkPasswordBreach(String password) async {
    try {
      // SHA-1 hash hesapla
      final bytes = utf8.encode(password);
      final digest = sha1.convert(bytes);
      final hash = digest.toString().toUpperCase();

      // K-anonymity: İlk 5 karakter
      final prefix = hash.substring(0, 5);
      final suffix = hash.substring(5);

      // API'ye sorgu gönder
      final response = await _dio.get('$_baseUrl/range/$prefix');

      if (response.statusCode == 200) {
        return _parseResponse(response.data, suffix);
      } else {
        return BreachCheckResult(
          isBreached: false,
          breachCount: 0,
          message: 'Kontrol edilemedi',
        );
      }
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return BreachCheckResult(
        isBreached: false,
        breachCount: 0,
        message: 'Beklenmeyen hata: ${e.toString()}',
      );
    }
  }

  BreachCheckResult _parseResponse(String responseData, String suffix) {
    final lines = responseData.split('\n');

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(':');
      if (parts.length == 2) {
        final hashSuffix = parts[0].trim();
        final count = int.tryParse(parts[1].trim()) ?? 0;

        if (hashSuffix == suffix) {
          return BreachCheckResult(
            isBreached: true,
            breachCount: count,
            message: 'Bu parola $count defa veri ihlalinde tespit edilmiş!',
          );
        }
      }
    }

    return BreachCheckResult(
      isBreached: false,
      breachCount: 0,
      message: 'Bu parola bilinen veri ihlallerinde bulunamadı',
    );
  }

  BreachCheckResult _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return BreachCheckResult(
          isBreached: false,
          breachCount: 0,
          message: 'Bağlantı zaman aşımı',
        );
      case DioExceptionType.connectionError:
        return BreachCheckResult(
          isBreached: false,
          breachCount: 0,
          message: 'İnternet bağlantısı yok',
        );
      default:
        return BreachCheckResult(
          isBreached: false,
          breachCount: 0,
          message: 'Servis geçici olarak kullanılamıyor',
        );
    }
  }
}
