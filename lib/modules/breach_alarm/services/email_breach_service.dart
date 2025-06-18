import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/env_config.dart';

class BreachInfo {
  final String name;
  final String title;
  final String domain;
  final DateTime breachDate;
  final int pwnCount;
  final String description;
  final List<String> dataClasses;
  final bool isVerified;
  final bool isFabricated;

  BreachInfo({
    required this.name,
    required this.title,
    required this.domain,
    required this.breachDate,
    required this.pwnCount,
    required this.description,
    required this.dataClasses,
    required this.isVerified,
    required this.isFabricated,
  });

  factory BreachInfo.fromJson(Map<String, dynamic> json) {
    return BreachInfo(
      name: json['Name'] ?? '',
      title: json['Title'] ?? '',
      domain: json['Domain'] ?? '',
      breachDate: DateTime.parse(json['BreachDate'] ?? '1970-01-01'),
      pwnCount: json['PwnCount'] ?? 0,
      description: json['Description'] ?? '',
      dataClasses: List<String>.from(json['DataClasses'] ?? []),
      isVerified: json['IsVerified'] ?? false,
      isFabricated: json['IsFabricated'] ?? false,
    );
  }
}

class EmailBreachResult {
  final String email;
  final bool hasBreaches;
  final List<BreachInfo> breaches;
  final DateTime lastChecked;
  final String message;

  EmailBreachResult({
    required this.email,
    required this.hasBreaches,
    required this.breaches,
    required this.lastChecked,
    required this.message,
  });
}

class EmailBreachService {
  final Dio _dio;
  static const String _baseUrl = 'https://haveibeenpwned.com/api/v3';

  EmailBreachService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'User-Agent': 'CyberShield-Mobile-App',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // API anahtarı varsa header'a ekle (opsiyonel)
    if (EnvConfig.hasHibpKey) {
      _dio.options.headers['hibp-api-key'] = EnvConfig.hibpApiKey;
    }
  }

  Future<EmailBreachResult> checkEmailBreaches(String email) async {
    if (!_isValidEmail(email)) {
      return EmailBreachResult(
        email: email,
        hasBreaches: false,
        breaches: [],
        lastChecked: DateTime.now(),
        message: 'Geçersiz e-posta adresi formatı',
      );
    }

    try {
      // URL encode email address
      final encodedEmail = Uri.encodeComponent(email);

      final response = await _dio.get(
        '$_baseUrl/breachedaccount/$encodedEmail',
        queryParameters: {'truncateResponse': 'false'},
        options: Options(
          validateStatus: (status) {
            // 200 (found breaches), 404 (no breaches), 429 (rate limit) kabul et
            return status != null &&
                (status == 200 || status == 404 || status == 429);
          },
        ),
      );

      debugPrint('HIBP API Response: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> breachesJson = response.data;
          final breaches =
              breachesJson.map((json) => BreachInfo.fromJson(json)).toList();

          return EmailBreachResult(
            email: email,
            hasBreaches: true,
            breaches: breaches,
            lastChecked: DateTime.now(),
            message: '${breaches.length} veri ihlali bulundu',
          );
        } else {
          // Unexpected response format
          return EmailBreachResult(
            email: email,
            hasBreaches: false,
            breaches: [],
            lastChecked: DateTime.now(),
            message: 'API yanıt formatı beklenmedik',
          );
        }
      } else if (response.statusCode == 404) {
        return EmailBreachResult(
          email: email,
          hasBreaches: false,
          breaches: [],
          lastChecked: DateTime.now(),
          message: 'Bu e-posta adresi bilinen veri ihlallerinde bulunamadı ✓',
        );
      } else if (response.statusCode == 429) {
        return EmailBreachResult(
          email: email,
          hasBreaches: false,
          breaches: [],
          lastChecked: DateTime.now(),
          message:
              'Çok fazla istek. Lütfen 1-2 dakika bekleyip tekrar deneyin.',
        );
      } else {
        throw Exception('API yanıt hatası: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      return _handleError(e, email);
    } catch (e) {
      debugPrint('General Exception: $e');
      return EmailBreachResult(
        email: email,
        hasBreaches: false,
        breaches: [],
        lastChecked: DateTime.now(),
        message: 'Beklenmeyen hata: ${e.toString()}',
      );
    }
  }

  EmailBreachResult _handleError(DioException error, String email) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Bağlantı zaman aşımı - İnternet bağlantınızı kontrol edin';
        break;
      case DioExceptionType.connectionError:
        message = 'İnternet bağlantısı yok - Lütfen bağlantınızı kontrol edin';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 429) {
          message =
              'Çok fazla istek gönderildi. 1-2 dakika bekleyip tekrar deneyin.';
        } else if (error.response?.statusCode == 401) {
          message = 'API erişim hatası - Servis geçici olarak kullanılamıyor';
        } else if (error.response?.statusCode == 404) {
          return EmailBreachResult(
            email: email,
            hasBreaches: false,
            breaches: [],
            lastChecked: DateTime.now(),
            message: 'Bu e-posta adresi bilinen veri ihlallerinde bulunamadı',
          );
        } else {
          message = 'Servis hatası - Lütfen daha sonra tekrar deneyin';
        }
        break;
      default:
        message = 'Bağlantı hatası - Lütfen tekrar deneyin';
    }

    return EmailBreachResult(
      email: email,
      hasBreaches: false,
      breaches: [],
      lastChecked: DateTime.now(),
      message: message,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
