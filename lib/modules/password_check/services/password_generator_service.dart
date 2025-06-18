import 'dart:math';

class PasswordSuggestion {
  final String type;
  final String suggestion;
  final String description;
  final String icon;

  PasswordSuggestion({
    required this.type,
    required this.suggestion,
    required this.description,
    required this.icon,
  });
}

class PasswordGeneratorService {
  final Random _random = Random();

  List<PasswordSuggestion> generateSuggestions({int count = 3}) {
    final suggestions = <PasswordSuggestion>[];

    // Farklı tipte öneriler
    suggestions.add(_generatePassphrase());
    suggestions.add(_generateStrong());
    suggestions.add(_generatePattern());

    return suggestions.take(count).toList();
  }

  PasswordSuggestion _generatePassphrase() {
    final words = [
      'kaplan',
      'deniz',
      'dağ',
      'güneş',
      'ay',
      'yıldız',
      'orman',
      'çiçek',
      'kitap',
      'müzik',
      'renk',
      'sahil',
      'bulut',
      'rüzgar',
      'ateş',
      'su'
    ];

    final selectedWords = <String>[];
    for (int i = 0; i < 3; i++) {
      selectedWords.add(words[_random.nextInt(words.length)]);
    }

    final passphrase =
        selectedWords.join('-') + _random.nextInt(100).toString();

    return PasswordSuggestion(
      type: 'passphrase',
      suggestion: passphrase,
      description: 'Kelime tabanlı, hatırlaması kolay',
      icon: '📝',
    );
  }

  PasswordSuggestion _generateStrong() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final password =
        List.generate(16, (_) => chars[_random.nextInt(chars.length)]).join();

    return PasswordSuggestion(
      type: 'strong',
      suggestion: password,
      description: 'Rastgele karakter, maksimum güvenlik',
      icon: '🔐',
    );
  }

  PasswordSuggestion _generatePattern() {
    final patterns = [
      'Büyük harf + küçük harf + sayı + özel karakter',
      'İlk harfleri büyük 3 kelime + sayı',
      'Favori şarkı + yıl + özel karakter'
    ];

    final pattern = patterns[_random.nextInt(patterns.length)];

    return PasswordSuggestion(
      type: 'pattern',
      suggestion: 'Kendiniz oluşturun',
      description: pattern,
      icon: '🎯',
    );
  }

  String generateSecurePassword({int length = 16}) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    final password = StringBuffer();

    // En az birer tane her kategoriden
    password.write(lowercase[_random.nextInt(lowercase.length)]);
    password.write(uppercase[_random.nextInt(uppercase.length)]);
    password.write(numbers[_random.nextInt(numbers.length)]);
    password.write(special[_random.nextInt(special.length)]);

    // Kalan karakterleri rastgele doldur
    const allChars = lowercase + uppercase + numbers + special;
    for (int i = 4; i < length; i++) {
      password.write(allChars[_random.nextInt(allChars.length)]);
    }

    // Karıştır
    final chars = password.toString().split('')..shuffle(_random);
    return chars.join();
  }
}
