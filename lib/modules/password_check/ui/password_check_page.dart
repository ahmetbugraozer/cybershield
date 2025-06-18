import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/cyber_card.dart';
import '../../../core/widgets/password_strength_indicator.dart';
import '../viewmodel/password_check_provider.dart';
import 'widgets/password_suggestions_widget.dart';

class PasswordCheckPage extends ConsumerStatefulWidget {
  const PasswordCheckPage({super.key});

  @override
  ConsumerState<PasswordCheckPage> createState() => _PasswordCheckPageState();
}

class _PasswordCheckPageState extends ConsumerState<PasswordCheckPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strengthResult = ref.watch(passwordStrengthProvider);
    final breachCheckAsync = ref.watch(breachCheckProvider);
    final password = ref.watch(passwordInputProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parola Gücü Kontrolü'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parolanızı Kontrol Edin',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Parola gücünüzü analiz edin ve veri ihlallerini kontrol edin.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onChanged: (value) {
                        ref.read(passwordInputProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Parolanızı girin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (strengthResult != null) ...[
                      PasswordStrengthIndicator(
                        score: strengthResult.score,
                        breachCount: breachCheckAsync.when(
                          data: (result) => result?.breachCount ?? 0,
                          loading: () => -1, // -1 = loading state
                          error: (_, __) => 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // İhlal kontrol durumu
                      if (password.isNotEmpty && password.length >= 3)
                        breachCheckAsync.when(
                          data: (result) => result != null &&
                                  result.breachCount > 0
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning,
                                          color: Colors.red, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          result.message,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Parola bilinen ihlallerde bulunamadı',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                          loading: () => const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('İhlal kontrolü yapılıyor...'),
                            ],
                          ),
                          error: (error, _) => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'İhlal kontrolü yapılamadı',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Expanded(child: PasswordSuggestionsWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
