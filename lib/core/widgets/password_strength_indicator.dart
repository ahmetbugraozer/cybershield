import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int score; // 0-4
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
            _buildStrengthIndicator(),
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

  Widget _buildStrengthIndicator() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStrengthColor(),
        boxShadow: [
          BoxShadow(
            color: _getStrengthColor().withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getStrengthColor().withOpacity(0.8),
          ),
        ),
      ),
    );
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
