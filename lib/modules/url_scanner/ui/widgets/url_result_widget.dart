import 'package:flutter/material.dart';
import 'package:secure_check/modules/url_scanner/ui/widgets/heuristic_results_widget.dart';
import 'package:secure_check/modules/url_scanner/ui/widgets/recommendations_widget.dart';
import 'package:secure_check/modules/url_scanner/ui/widgets/threat_level_indicator.dart';

import '../../../../core/widgets/cyber_card.dart';
import '../../services/url_analysis_service.dart';

class UrlResultWidget extends StatelessWidget {
  final UrlAnalysisResult result;

  const UrlResultWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana sonuç kartı
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarama Sonucu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ThreatLevelIndicator(threatLevel: result.threatLevel),
                const SizedBox(height: 16),
                Text(
                  result.summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800]?.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.url,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Heuristik sonuçlar
          HeuristicResultsWidget(results: result.heuristicResults),

          const SizedBox(height: 16),

          // VirusTotal sonucu (varsa)
          if (result.virusTotalResult != null) ...[
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VirusTotal Sonucu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        result.virusTotalResult!.positiveDetections > 0
                            ? Icons.warning
                            : Icons.check_circle,
                        color: result.virusTotalResult!.positiveDetections > 0
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${result.virusTotalResult!.positiveDetections}/${result.virusTotalResult!.totalScans} motor tarafından tehlikeli olarak işaretlendi',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Öneriler
          RecommendationsWidget(recommendations: result.recommendations),
        ],
      ),
    );
  }
}
