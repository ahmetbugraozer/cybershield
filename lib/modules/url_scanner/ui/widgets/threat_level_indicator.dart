import 'package:flutter/material.dart';
import '../../services/url_analysis_service.dart';

class ThreatLevelIndicator extends StatelessWidget {
  final ThreatLevel threatLevel;

  const ThreatLevelIndicator({
    super.key,
    required this.threatLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getIndicatorColor(),
              boxShadow: [
                BoxShadow(
                  color: _getIndicatorColor().withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _getIcon(),
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
                  _getTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDescription(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getTextColor().withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return Colors.green.withValues(alpha: 0.1);
      case ThreatLevel.suspicious:
        return Colors.orange.withValues(alpha: 0.1);
      case ThreatLevel.dangerous:
        return Colors.red.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return Colors.green;
      case ThreatLevel.suspicious:
        return Colors.orange;
      case ThreatLevel.dangerous:
        return Colors.red;
    }
  }

  Color _getIndicatorColor() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return Colors.green;
      case ThreatLevel.suspicious:
        return Colors.orange;
      case ThreatLevel.dangerous:
        return Colors.red;
    }
  }

  Color _getTextColor() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return Colors.green;
      case ThreatLevel.suspicious:
        return Colors.orange;
      case ThreatLevel.dangerous:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return Icons.check_circle;
      case ThreatLevel.suspicious:
        return Icons.warning;
      case ThreatLevel.dangerous:
        return Icons.dangerous;
    }
  }

  String _getTitle() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return 'GÜVENLİ';
      case ThreatLevel.suspicious:
        return 'ŞÜPHELİ';
      case ThreatLevel.dangerous:
        return 'TEHLİKELİ';
    }
  }

  String _getDescription() {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return 'Bu URL güvenli görünüyor';
      case ThreatLevel.suspicious:
        return 'Dikkatli olmanız önerilir';
      case ThreatLevel.dangerous:
        return 'Bu URL\'yi ziyaret etmeyin!';
    }
  }
}
