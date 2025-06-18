import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/cyber_card.dart';
import '../viewmodel/breach_alarm_provider.dart';
import 'widgets/breach_result_widget.dart';
import 'widgets/breach_history_widget.dart';

class BreachAlarmPage extends ConsumerStatefulWidget {
  const BreachAlarmPage({super.key});

  @override
  ConsumerState<BreachAlarmPage> createState() => _BreachAlarmPageState();
}

class _BreachAlarmPageState extends ConsumerState<BreachAlarmPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // History service'i uygulama başlangıcında initialize et
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final historyService = ref.read(breachHistoryServiceProvider);
        await historyService.init();
        debugPrint('Geçmiş servisi başlangıçta başlatıldı');
      } catch (e) {
        debugPrint('Geçmiş servisi başlangıç hatası: $e');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValidEmail = ref.watch(emailValidationProvider);
    final email = ref.watch(emailInputProvider);
    final isChecking = ref.watch(isCheckingEmailProvider);
    // DÜZELTME: Doğru provider'ı kullan
    final checkResult = ref.watch(manualEmailCheckProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta İhlal Alarmı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kontrol Et', icon: Icon(Icons.search)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A2E1A)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Kontrol Et Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CyberCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-posta İhlal Kontrolü',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'E-posta adresinizin veri ihlallerinde yer alıp almadığını kontrol edin.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-posta adresinizi girin',
                            hintText: 'ornek@email.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.email),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    email.isEmpty
                                        ? Colors.grey
                                        : (isValidEmail
                                            ? Colors.green
                                            : Colors.red),
                              ),
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (email.isNotEmpty)
                                  Icon(
                                    isValidEmail
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color:
                                        isValidEmail
                                            ? Colors.green
                                            : Colors.red,
                                    size: 20,
                                  ),
                                if (_emailController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _emailController.clear();
                                      ref
                                          .read(emailInputProvider.notifier)
                                          .state = '';
                                    },
                                  ),
                              ],
                            ),
                          ),
                          onChanged: (value) {
                            ref.read(emailInputProvider.notifier).state = value;
                          },
                        ),

                        // Email validasyon mesajı
                        if (email.isNotEmpty && !isValidEmail) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Geçerli bir e-posta adresi girin',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                (isChecking ||
                                        _emailController.text.isEmpty ||
                                        !isValidEmail)
                                    ? null
                                    : () async {
                                      final email =
                                          _emailController.text.trim();
                                      if (email.isEmpty || !isValidEmail) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Lütfen geçerli bir e-posta adresi girin',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // DÜZELTME: Doğru notifier'ı çağır
                                      await ref
                                          .read(
                                            manualEmailCheckProvider.notifier,
                                          )
                                          .checkEmail(email);
                                    },
                            child:
                                isChecking
                                    ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Kontrol ediliyor...'),
                                      ],
                                    )
                                    : const Text('Kontrol Et'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sonuç gösterimi
                  Expanded(
                    child: checkResult.when<Widget>(
                      data:
                          (result) =>
                              result != null
                                  ? BreachResultWidget(result: result)
                                  : const Center(
                                    child: Text(
                                      'E-posta adresi girin ve kontrol başlatın',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                      loading:
                          () => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('HaveIBeenPwned API kontrol ediliyor...'),
                              ],
                            ),
                          ),
                      error:
                          (error, _) => Center(
                            child: SingleChildScrollView(
                              child: CyberCard(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Kontrol sırasında hata oluştu',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        error.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final email =
                                                  _emailController.text.trim();
                                              if (email.isNotEmpty) {
                                                // DÜZELTME: Doğru notifier'ı çağır
                                                await ref
                                                    .read(
                                                      manualEmailCheckProvider
                                                          .notifier,
                                                    )
                                                    .checkEmail(email);
                                              }
                                            },
                                            child: const Text('Tekrar Dene'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _emailController.clear();
                                              ref
                                                  .read(
                                                    emailInputProvider.notifier,
                                                  )
                                                  .state = '';
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Temizle'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Geçmiş Tab
            const BreachHistoryWidget(),
          ],
        ),
      ),
    );
  }
}
