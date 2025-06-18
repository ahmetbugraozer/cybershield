import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../services/email_breach_service.dart';

class BreachResultWidget extends StatelessWidget {
  final EmailBreachResult result;

  const BreachResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: result.hasBreaches ? Colors.red : Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: (result.hasBreaches
                                    ? Colors.red
                                    : Colors.green)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        result.hasBreaches ? Icons.warning : Icons.shield,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.hasBreaches
                                ? 'İhlal Tespit Edildi!'
                                : 'Güvenli',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  result.hasBreaches
                                      ? Colors.red
                                      : Colors.green,
                            ),
                          ),
                          Text(
                            result.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (result.hasBreaches ? Colors.red : Colors.green)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (result.hasBreaches ? Colors.red : Colors.green)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    result.message,
                    style: TextStyle(
                      color: result.hasBreaches ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Son kontrol: ${DateFormat('dd.MM.yyyy HH:mm').format(result.lastChecked)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // İHLAL DETAYLARINI GÖSTER
          if (result.hasBreaches && result.breaches.isNotEmpty) ...[
            const SizedBox(height: 16),
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İhlal Detayları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...result.breaches.map(
                    (breach) => _buildBreachCard(context, breach),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreachCard(BuildContext context, BreachInfo breach) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                breach.isVerified ? Icons.verified : Icons.warning,
                color: breach.isVerified ? Colors.orange : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  breach.title.isNotEmpty ? breach.title : breach.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (breach.domain.isNotEmpty) ...[
            Text(
              'Site: ${breach.domain}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'İhlal Tarihi: ${DateFormat('dd.MM.yyyy').format(breach.breachDate)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
          ),
          Text(
            'Etkilenen Hesap: ${_formatNumber(breach.pwnCount)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
          ),
          if (breach.dataClasses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Sızan Veriler:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  breach.dataClasses
                      .map(
                        (dataClass) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _translateDataClass(dataClass),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.orange, fontSize: 10),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
          if (breach.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Açıklama:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              breach.description.replaceAll(
                RegExp(r'<[^>]*>'),
                '',
              ), // HTML taglerini kaldır
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _translateDataClass(String dataClass) {
    const translations = {
      'Email addresses': 'E-posta adresleri',
      'Passwords': 'Şifreler',
      'Usernames': 'Kullanıcı adları',
      'Names': 'İsimler',
      'Phone numbers': 'Telefon numaraları',
      'Physical addresses': 'Fiziksel adresler',
      'Credit cards': 'Kredi kartları',
      'Social security numbers': 'Sosyal güvenlik numaraları',
      'IP addresses': 'IP adresleri',
      'Dates of birth': 'Doğum tarihleri',
      'Geographic locations': 'Coğrafi konumlar',
    };
    return translations[dataClass] ?? dataClass;
  }
}
