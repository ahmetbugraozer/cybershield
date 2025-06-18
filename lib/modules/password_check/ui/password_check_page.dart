import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/cyber_card.dart';
import '../../../core/widgets/password_strength_indicator.dart';

class PasswordCheckPage extends ConsumerStatefulWidget {
  const PasswordCheckPage({super.key});

  @override
  ConsumerState<PasswordCheckPage> createState() => _PasswordCheckPageState();
}

class _PasswordCheckPageState extends ConsumerState<PasswordCheckPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onChanged: (value) {
                        // TODO: Parola gücü hesaplama
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
                    const PasswordStrengthIndicator(
                      score: 2, // TODO: Gerçek skor
                      breachCount: 0, // TODO: Gerçek ihlal sayısı
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Öneri kartları buraya gelecek
            ],
          ),
        ),
      ),
    );
  }
}
