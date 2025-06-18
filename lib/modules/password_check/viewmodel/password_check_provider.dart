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
final isCheckingBreachProvider = StateProvider<bool>((ref) => false);

// Password strength provider
final passwordStrengthProvider = Provider<PasswordStrengthResult?>((ref) {
  final password = ref.watch(passwordInputProvider);
  if (password.isEmpty) return null;

  final service = ref.read(passwordStrengthServiceProvider);
  return service.analyzePassword(password);
});

// Breach check provider
final breachCheckProvider = FutureProvider<BreachCheckResult?>((ref) async {
  final password = ref.watch(passwordInputProvider);
  if (password.isEmpty) return null;

  final service = ref.read(hibpServiceProvider);
  ref.read(isCheckingBreachProvider.notifier).state = true;

  try {
    final result = await service.checkPasswordBreach(password);
    return result;
  } finally {
    ref.read(isCheckingBreachProvider.notifier).state = false;
  }
});

// Password suggestions provider
final passwordSuggestionsProvider = Provider<List<PasswordSuggestion>>((ref) {
  final service = ref.read(passwordGeneratorServiceProvider);
  return service.generateSuggestions();
});
