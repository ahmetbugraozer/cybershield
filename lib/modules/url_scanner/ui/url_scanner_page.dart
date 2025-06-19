import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/cyber_card.dart';
import '../viewmodel/url_scanner_provider.dart';
import 'widgets/url_result_widget.dart';

class UrlScannerPage extends ConsumerStatefulWidget {
  const UrlScannerPage({super.key});

  @override
  ConsumerState<UrlScannerPage> createState() => _UrlScannerPageState();
}

class _UrlScannerPageState extends ConsumerState<UrlScannerPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urlInput = ref.watch(urlInputProvider);
    final isValidUrl = ref.watch(urlValidationProvider);
    final isAnalyzing = ref.watch(isAnalyzingProvider);
    final analysisResult = ref.watch(manualUrlAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Güvenlik Tarayıcısı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF2E1A1A)],
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
                      'URL Güvenlik Kontrolü',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Şüpheli bağlantıları tarayın ve phishing saldırılarından korunun.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'URL adresini girin',
                        hintText: 'https://example.com veya example.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                urlInput.isEmpty
                                    ? Colors.grey
                                    : (isValidUrl ? Colors.green : Colors.red),
                          ),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (urlInput.isNotEmpty)
                              Icon(
                                isValidUrl ? Icons.check_circle : Icons.error,
                                color: isValidUrl ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () async {
                                final clipboardData = await Clipboard.getData(
                                  'text/plain',
                                );
                                if (clipboardData?.text != null) {
                                  _urlController.text = clipboardData!.text!;
                                  ref.read(urlInputProvider.notifier).state =
                                      clipboardData.text!;
                                }
                              },
                            ),
                            if (_urlController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _urlController.clear();
                                  ref.read(urlInputProvider.notifier).state =
                                      '';
                                },
                              ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(urlInputProvider.notifier).state = value;
                      },
                    ),

                    // URL validasyon mesajı
                    if (urlInput.isNotEmpty && !isValidUrl) ...[
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
                                'Geçerli bir URL girin (örn: https://example.com)',
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
                            (isAnalyzing ||
                                    _urlController.text.isEmpty ||
                                    !isValidUrl)
                                ? null
                                : () async {
                                  final url = _urlController.text.trim();
                                  if (url.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Lütfen bir URL girin'),
                                      ),
                                    );
                                    return;
                                  }

                                  await ref
                                      .read(manualUrlAnalysisProvider.notifier)
                                      .analyzeUrl(url);
                                },
                        child:
                            isAnalyzing
                                ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Taranıyor...'),
                                  ],
                                )
                                : const Text('Tara'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: analysisResult.when(
                  data:
                      (result) =>
                          result != null
                              ? UrlResultWidget(result: result)
                              : const Center(
                                child: Text(
                                  'URL girin ve tarama başlatın',
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
                            Text('URL güvenlik taraması yapılıyor...'),
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
                                  'Tarama sırasında hata oluştu',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.3),
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
                                          final url =
                                              _urlController.text.trim();
                                          if (url.isNotEmpty) {
                                            await ref
                                                .read(
                                                  manualUrlAnalysisProvider
                                                      .notifier,
                                                )
                                                .analyzeUrl(url);
                                          }
                                        },
                                        child: const Text('Tekrar Dene'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _urlController.clear();
                                          ref
                                              .read(urlInputProvider.notifier)
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
      ),
    );
  }
}
