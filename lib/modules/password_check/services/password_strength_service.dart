import 'package:zxcvbn/zxcvbn.dart';

class PasswordStrengthResult {
  final int score; // 0-4
  final String feedback;
  final Duration crackTime;
  final List<String> suggestions;

  PasswordStrengthResult({
    required this.score,
    required this.feedback,
    required this.crackTime,
    required this.suggestions,
  });
}

class PasswordStrengthService {
  final Zxcvbn _zxcvbn = Zxcvbn();

  PasswordStrengthResult analyzePassword(String password) {
    if (password.isEmpty) {
      return PasswordStrengthResult(
        score: 0,
        feedback: 'Parola boş olamaz',
        crackTime: Duration.zero,
        suggestions: ['En az 8 karakter kullanın'],
      );
    }

    final result = _zxcvbn.evaluate(password);

    return PasswordStrengthResult(
      score: (result.score?.toInt()) ?? 0,
      feedback: _getFeedbackText((result.score?.toInt()) ?? 0),
      crackTime: _calculateCrackTime((result.score?.toInt()) ?? 0),
      suggestions: _generateSuggestions(result),
    );
  }

  String _getFeedbackText(int score) {
    switch (score) {
      case 0:
        return 'Çok zayıf - Birkaç saniyede kırılabilir';
      case 1:
        return 'Zayıf - Dakikalar içinde kırılabilir';
      case 2:
        return 'Orta - Saatler içinde kırılabilir';
      case 3:
        return 'Güçlü - Günler/aylar sürebilir';
      case 4:
        return 'Çok güçlü - Yüzyıllar sürebilir';
      default:
        return 'Bilinmiyor';
    }
  }

  Duration _calculateCrackTime(int score) {
    // Score'a göre tahmini crack time hesapla
    switch (score) {
      case 0:
        return const Duration(seconds: 1); // Anında
      case 1:
        return const Duration(minutes: 1); // Birkaç dakika
      case 2:
        return const Duration(hours: 1); // Birkaç saat
      case 3:
        return const Duration(days: 30); // Birkaç ay
      case 4:
        return const Duration(days: 365 * 100); // Yüzyıllar
      default:
        return const Duration(seconds: 1);
    }
  }

  List<String> _generateSuggestions(dynamic result) {
    List<String> suggestions = [];

    // zxcvbn feedback'ine göre öneriler
    if (result.feedback?.suggestions != null) {
      for (String suggestion in result.feedback.suggestions) {
        suggestions.add(_translateSuggestion(suggestion));
      }
    }

    // Genel öneriler
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Büyük ve küçük harf karışımı kullanın',
        'Sayı ve özel karakter ekleyin',
        'En az 12 karakter tercih edin',
      ]);
    }

    return suggestions.take(3).toList();
  }

  String _translateSuggestion(String suggestion) {
    final translations = {
      'Add another word or two': 'Bir veya iki kelime daha ekleyin',
      'Use a longer keyboard pattern': 'Daha uzun klavye deseni kullanın',
      'Avoid repeated words and characters':
          'Tekrarlanan kelime ve karakterlerden kaçının',
      'Avoid sequences': 'Ardışık karakterlerden kaçının',
      'Avoid recent years': 'Yakın yılları kullanmayın',
      'Avoid years that are associated with you':
          'Sizinle ilişkili yılları kullanmayın',
      'Avoid dates and years that are associated with you':
          'Sizinle ilişkili tarih ve yılları kullanmayın',
    };

    return translations[suggestion] ?? suggestion;
  }
}
