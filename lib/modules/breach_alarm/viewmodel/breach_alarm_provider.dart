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

// Debounced email provider
final debouncedEmailProvider =
    StateNotifierProvider<DebouncedEmailNotifier, String>((ref) {
      return DebouncedEmailNotifier(ref);
    });

class DebouncedEmailNotifier extends StateNotifier<String> {
  final Ref _ref;
  Timer? _timer;

  DebouncedEmailNotifier(this._ref) : super('') {
    _ref.listen(emailInputProvider, (previous, next) {
      _handleEmailChange(next);
    });
  }

  void _handleEmailChange(String email) {
    _timer?.cancel();

    if (email.isEmpty || !_ref.read(emailValidationProvider)) {
      state = '';
      return;
    }

    _timer = Timer(const Duration(milliseconds: 800), () {
      state = email;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Email breach check provider
final emailBreachCheckProvider = FutureProvider.autoDispose<
  EmailBreachResult?
>((ref) async {
  final email = ref.watch(
    emailInputProvider,
  ); // Debounce kaldırıldı - direct input

  if (email.isEmpty || !ref.read(emailValidationProvider)) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.exists(isCheckingEmailProvider)) {
        ref.read(isCheckingEmailProvider.notifier).state = false;
      }
    });
    return null;
  }

  debugPrint('Starting breach check for: $email');
  ref.read(isCheckingEmailProvider.notifier).state = true;

  try {
    final service = ref.read(emailBreachServiceProvider);

    // History service initialize
    final historyService = ref.read(breachHistoryServiceProvider);
    await historyService.init();

    // Önce cache kontrol et (opsiyonel - skip edilebilir test için)
    // final lastResult = historyService.getLastResult(email);
    // if (lastResult != null && !historyService.shouldCheckAgain(email, threshold: Duration(minutes: 5))) {
    //   return EmailBreachResult(
    //     email: lastResult.email,
    //     hasBreaches: lastResult.hasBreaches,
    //     breaches: [],
    //     lastChecked: lastResult.lastChecked,
    //     message: '${lastResult.message} (önbellekten)',
    //   );
    // }

    // Direct API call
    debugPrint('Making API call...');
    final result = await service.checkEmailBreaches(email);
    debugPrint('API call completed: ${result.message}');

    // Sonucu cache'e kaydet
    await historyService.saveResult(result);

    return result;
  } catch (e) {
    debugPrint('Provider error: $e');
    final shortError =
        e.toString().length > 100
            ? '${e.toString().substring(0, 97)}...'
            : e.toString();
    throw Exception('Kontrol edilemedi: $shortError');
  } finally {
    debugPrint('Clearing loading state');
    if (ref.exists(isCheckingEmailProvider)) {
      ref.read(isCheckingEmailProvider.notifier).state = false;
    }
  }
});

// Manual trigger provider for button - düzeltilmiş versiyon
final manualEmailCheckProvider = StateNotifierProvider.family.autoDispose<
  ManualEmailCheckNotifier,
  AsyncValue<EmailBreachResult?>,
  String
>((ref, email) {
  return ManualEmailCheckNotifier(ref, email);
});

class ManualEmailCheckNotifier
    extends StateNotifier<AsyncValue<EmailBreachResult?>> {
  final Ref _ref;
  final String _email;

  ManualEmailCheckNotifier(this._ref, this._email)
    : super(const AsyncValue.data(null));

  Future<void> checkEmail() async {
    if (_email.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    debugPrint('Manual check triggered for: $_email');
    state = const AsyncValue.loading();

    try {
      final service = _ref.read(emailBreachServiceProvider);
      final result = await service.checkEmailBreaches(_email);

      // Save to history - daha güvenli şekilde
      try {
        final historyService = _ref.read(breachHistoryServiceProvider);
        await historyService.init(); // Burada init'i çağır, hata varsa yakala
        await historyService.saveResult(result);
        debugPrint('Result saved to history');
      } catch (hiveError) {
        // Hive hatası sonucu etkilemez, sadece kayıt yapılmaz
        debugPrint('Hive save error (non-critical): $hiveError');
      }

      state = AsyncValue.data(result);
    } catch (e) {
      debugPrint('API error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Loading state için ayrı provider
final manualCheckLoadingProvider = StateProvider<bool>((ref) => false);

// Breach history provider with safe initialization
final breachHistoryProvider = FutureProvider<List<StoredBreachResult>>((
  ref,
) async {
  try {
    final historyService = ref.watch(breachHistoryServiceProvider);
    await historyService.init();
    return historyService.getAllResults();
  } catch (e) {
    debugPrint('History provider error: $e');
    return <StoredBreachResult>[];
  }
});

// Recent breaches provider with safe initialization
final recentBreachesProvider = FutureProvider<List<StoredBreachResult>>((
  ref,
) async {
  try {
    final historyService = ref.watch(breachHistoryServiceProvider);
    await historyService.init();
    return historyService.getRecentBreaches();
  } catch (e) {
    debugPrint('Recent breaches provider error: $e');
    return <StoredBreachResult>[];
  }
});
