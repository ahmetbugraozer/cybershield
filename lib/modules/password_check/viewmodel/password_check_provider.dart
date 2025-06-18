import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/password_strength_service.dart';
import '../services/hibp_service.dart';
import '../services/password_generator_service.dart';

// Service provider'ları
final passwordStrengthServiceProvider =
    Provider((ref) => PasswordStrengthService());
final hibpServiceProvider = Provider((ref) => HibpService());
final passwordGeneratorServiceProvider =
    Provider((ref) => PasswordGeneratorService());

// State provider'ları
final passwordInputProvider = StateProvider<String>((ref) => '');

// Password strength provider
final passwordStrengthProvider = Provider<PasswordStrengthResult?>((ref) {
  final password = ref.watch(passwordInputProvider);
  if (password.isEmpty) return null;

  final service = ref.read(passwordStrengthServiceProvider);
  return service.analyzePassword(password);
});

// Debounced password provider (800ms gecikme ile)
final debouncedPasswordProvider = Provider<String>((ref) {
  final password = ref.watch(passwordInputProvider);

  if (password.isEmpty || password.length < 3) return '';

  // Timer ile debounce
  Timer? timer;
  ref.onDispose(() => timer?.cancel());

  timer = Timer(const Duration(milliseconds: 800), () {
    ref.invalidateSelf();
  });

  return password;
});

// Breach check provider - sadece debounced password değiştiğinde çalışır
final breachCheckProvider =
    FutureProvider.autoDispose<BreachCheckResult?>((ref) async {
  final password = ref.watch(debouncedPasswordProvider);

  if (password.isEmpty) return null;

  final service = ref.read(hibpServiceProvider);

  try {
    final result = await service.checkPasswordBreach(password);
    return result;
  } catch (e) {
    return BreachCheckResult(
      isBreached: false,
      breachCount: 0,
      message: 'Kontrol edilemedi - ${e.toString()}',
    );
  }
});

// Password suggestions provider
final passwordSuggestionsProvider = Provider<List<PasswordSuggestion>>((ref) {
  final service = ref.read(passwordGeneratorServiceProvider);
  return service.generateSuggestions();
});
