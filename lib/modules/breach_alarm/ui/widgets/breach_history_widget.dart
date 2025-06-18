import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/cyber_card.dart';
import '../../viewmodel/breach_alarm_provider.dart';

class BreachHistoryWidget extends ConsumerWidget {
  const BreachHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(breachHistoryProvider);
    final recentBreachesAsync = ref.watch(recentBreachesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İstatistikler
          recentBreachesAsync.when(
            data:
                (recentBreaches) =>
                    recentBreaches.isNotEmpty
                        ? CyberCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son 30 Gün İstatistikleri',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      'Toplam İhlal',
                                      recentBreaches.length.toString(),
                                      Icons.warning,
                                      Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      'Etkilenen Hesap',
                                      recentBreaches
                                          .fold<int>(
                                            0,
                                            (sum, item) =>
                                                sum + item.breachCount,
                                          )
                                          .toString(),
                                      Icons.person,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Geçmiş listesi başlığı
          Row(
            children: [
              Text(
                'Kontrol Geçmişi',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              historyAsync.when(
                data:
                    (history) =>
                        history.isNotEmpty
                            ? TextButton.icon(
                              onPressed: () => _showClearDialog(context, ref),
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Temizle'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            )
                            : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Geçmiş listesi
          Expanded(
            child: historyAsync.when(
              data:
                  (history) =>
                      history.isEmpty
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Henüz kontrol geçmişi yok',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildHistoryCard(context, item, ref),
                              );
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Center(
                    child: Text(
                      'Geçmiş yüklenirken hata oluştu',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic item, WidgetRef ref) {
    return CyberCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.hasBreaches ? Colors.red : Colors.green,
            ),
            child: Icon(
              item.hasBreaches ? Icons.warning : Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.hasBreaches
                      ? '${item.breachCount} ihlal bulundu'
                      : 'İhlal bulunamadı',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: item.hasBreaches ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(item.lastChecked),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 8),
                        Text('Yeniden kontrol et'),
                      ],
                    ),
                    onTap: () {
                      // Email input'a set et ve kontrol başlat
                      ref.read(emailInputProvider.notifier).state = item.email;
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () async {
                      await ref
                          .read(breachHistoryServiceProvider)
                          .deleteResult(item.email);
                      ref.invalidate(breachHistoryProvider);
                    },
                  ),
                ],
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Geçmişi Temizle'),
            content: const Text(
              'Tüm kontrol geçmişini silmek istediğinizden emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(breachHistoryServiceProvider).clearAll();
                  ref.invalidate(breachHistoryProvider);
                  ref.invalidate(recentBreachesProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
  }
}
