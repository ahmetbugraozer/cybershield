import 'package:flutter/material.dart';
import '../../../../core/widgets/cyber_card.dart';
import '../../services/heuristic_checker_service.dart';

class HeuristicResultsWidget extends StatelessWidget {
  final List<HeuristicResult> results;

  const HeuristicResultsWidget({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenlik Kontrolleri',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildResultRow(context, result),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, HeuristicResult result) {
    final color = _getColorBySeverity(result.severity, result.isPassed);

    return Row(
      children: [
        Icon(
          result.isPassed ? Icons.check_circle : Icons.warning,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.checkName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                result.description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorBySeverity(String severity, bool isPassed) {
    if (isPassed) return Colors.green;

    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
