import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/email_breach_service.dart';
import '../services/breach_history_service.dart';

// Service provider'ları
final emailBreachServiceProvider = Provider((ref) => EmailBreachService());
final breachHistoryServiceProvider = Provider((ref) => BreachHistoryService());

// State provider'ları
final emailInputProvider = StateProvider<String>((ref) => '');
final isCheckingEmailProvider = StateProvider<bool>((ref) => false);

// Email validasyon provider'ı
final emailValidationProvider = Provider<bool>((ref) {
  final email = ref.watch(emailInputProvider);
  if (email.isEmpty) return true; // Boşsa hata gösterme

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
});

// TEK manuel kontrol provider'ı

// PROVIDER TANIMLAMA SIRASI DÜZELTİLDİ
final manualEmailCheckProvider = StateNotifierProvider<
  ManualEmailCheckNotifier,
  AsyncValue<EmailBreachResult?>
>((ref) {
  return ManualEmailCheckNotifier(ref);
});

class ManualEmailCheckNotifier
    extends StateNotifier<AsyncValue<EmailBreachResult?>> {
  final Ref _ref;

  ManualEmailCheckNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> checkEmail(String email) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      state = AsyncValue.error(
        'Geçerli bir e-posta adresi girin',
        StackTrace.current,
      );
      return;
    }

    debugPrint('Manuel kontrol başlatılıyor: $email');
    state = const AsyncValue.loading();

    try {
      _ref.read(isCheckingEmailProvider.notifier).state = true;

      final service = _ref.read(emailBreachServiceProvider);
      final result = await service.checkEmailBreaches(email);

      // ÖNCE SONUCU BAŞARILI OLARAK SET ET
      state = AsyncValue.data(result);

      // SONRA HISTORY'E KAYDETMEYI DENE (kritik değil)
      try {
        final historyService = _ref.read(breachHistoryServiceProvider);
        final initSuccess = await historyService.init();

        if (initSuccess) {
          await historyService.saveResult(result);
          debugPrint('Sonuç geçmişe kaydedildi');
          _ref.invalidate(breachHistoryProvider);
          _ref.invalidate(recentBreachesProvider);
        } else {
          debugPrint('Hive initialize edilemedi - history kaydedilmedi');
        }
      } catch (hiveError) {
        debugPrint('Geçmiş kaydetme hatası (kritik değil): $hiveError');
        // Hive hatası sonucu etkilemesin
      }
    } catch (e) {
      debugPrint('API hatası: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _ref.read(isCheckingEmailProvider.notifier).state = false;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

// History provider'ları
final breachHistoryProvider = FutureProvider<List<StoredBreachResult>>((
  ref,
) async {
  try {
    final historyService = ref.read(breachHistoryServiceProvider);
    await historyService.init();
    return historyService.getAllResults();
  } catch (e) {
    debugPrint('Geçmiş provider hatası: $e');
    return <StoredBreachResult>[];
  }
});

final recentBreachesProvider = FutureProvider<List<StoredBreachResult>>((
  ref,
) async {
  try {
    final historyService = ref.read(breachHistoryServiceProvider);
    await historyService.init();
    return historyService.getRecentBreaches();
  } catch (e) {
    debugPrint('Son ihlaller provider hatası: $e');
    return <StoredBreachResult>[];
  }
});

// Loading state için ayrı provider
final manualCheckLoadingProvider = StateProvider<bool>((ref) => false);
