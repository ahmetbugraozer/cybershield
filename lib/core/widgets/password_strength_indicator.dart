import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int score; // 0-4 arası
  final int breachCount;

  const PasswordStrengthIndicator({
    super.key,
    required this.score,
    required this.breachCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStrengthBar(),
            ),
            const SizedBox(width: 12),
            Text(
              _getEmoji(),
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getStrengthText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getStrengthColor(),
                fontWeight: FontWeight.w600,
              ),
        ),
        if (breachCount > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Text(
              '⚠️ Bu parola $breachCount defa sızdırılmış!',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStrengthBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey[800],
      ),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 2 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: index < score ? _getStrengthColor() : Colors.transparent,
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getEmoji() {
    switch (score) {
      case 0:
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '😊';
      case 4:
        return '😍';
      default:
        return '😞';
    }
  }

  String _getStrengthText() {
    switch (score) {
      case 0:
      case 1:
        return 'Çok Zayıf';
      case 2:
        return 'Zayıf';
      case 3:
        return 'İyi';
      case 4:
        return 'Çok Güçlü';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getStrengthColor() {
    switch (score) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
