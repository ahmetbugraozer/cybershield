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
        ],
      ),
    );
  }
}
