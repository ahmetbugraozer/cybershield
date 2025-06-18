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
      'User-Agent': 'SecureCheck-Flutter-App/1.0',
      'Accept': 'application/json',
    };

    // API anahtarı varsa ekle
    if (EnvConfig.hasHibpKey) {
      _dio.options.headers['hibp-api-key'] = EnvConfig.hibpApiKey;
      debugPrint('HIBP API anahtarı ile çalışıyor');
    } else {
      debugPrint('⚠️ HIBP API anahtarı yok - sınırlı erişim');
    }
  }

  Future<EmailBreachResult> checkEmailBreaches(String email) async {
    if (!_isValidEmail(email)) {
      throw Exception('Geçersiz e-posta formatı');
    }

    try {
      final encodedEmail = Uri.encodeComponent(email.toLowerCase().trim());
      debugPrint('API çağrısı: $encodedEmail');

      final response = await _dio.get(
        '$_baseUrl/breachedaccount/$encodedEmail',
        queryParameters: {'truncateResponse': 'false'},
        options: Options(
          validateStatus:
              (status) =>
                  status != null && [200, 404, 429, 401].contains(status),
        ),
      );

      debugPrint('API yanıt: ${response.statusCode}');

      switch (response.statusCode) {
        case 200:
          if (response.data is List) {
            final breaches =
                (response.data as List)
                    .map((json) => BreachInfo.fromJson(json))
                    .toList();

            return EmailBreachResult(
              email: email,
              hasBreaches: true,
              breaches: breaches,
              lastChecked: DateTime.now(),
              message: '⚠️ ${breaches.length} veri ihlali bulundu!',
            );
          }
          break;

        case 404:
          return EmailBreachResult(
            email: email,
            hasBreaches: false,
            breaches: [],
            lastChecked: DateTime.now(),
            message: '✅ Bu e-posta güvenli görünüyor',
          );

        case 429:
          throw Exception('⏱️ Çok fazla istek. 1-2 dakika bekleyin.');

        case 401:
          throw Exception('🔑 API anahtarı gerekli');
      }

      throw Exception('Beklenmeyen API yanıtı: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return '⏱️ Bağlantı zaman aşımı';
      case DioExceptionType.connectionError:
        return '🌐 İnternet bağlantısı yok';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 429) return '⏱️ Çok fazla istek';
        if (status == 401) return '🔑 API anahtarı gerekli';
        return '⚠️ Servis hatası ($status)';
      default:
        return '❌ Bilinmeyen hata';
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
