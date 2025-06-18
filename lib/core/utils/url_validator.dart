class UrlValidationResult {
  final bool isValid;
  final String? correctedUrl;
  final String? errorMessage;
  final List<String> warnings;

  UrlValidationResult({
    required this.isValid,
    this.correctedUrl,
    this.errorMessage,
    this.warnings = const [],
  });
}

class UrlValidator {
  static UrlValidationResult validateAndCorrect(String input) {
    if (input.trim().isEmpty) {
      return UrlValidationResult(
        isValid: false,
        errorMessage: 'URL boş olamaz',
      );
    }

    String trimmedInput = input.trim();
    List<String> warnings = [];

    // Temel format kontrolü
    if (trimmedInput.length < 4) {
      return UrlValidationResult(isValid: false, errorMessage: 'URL çok kısa');
    }

    // Protokol kontrolü ve eklenmesi
    String correctedUrl = _addProtocolIfMissing(trimmedInput);

    // URI parsing kontrolü
    Uri? uri;
    try {
      uri = Uri.parse(correctedUrl);
    } catch (e) {
      return UrlValidationResult(
        isValid: false,
        errorMessage: 'Geçersiz URL formatı',
      );
    }

    // Scheme kontrolü
    if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
      return UrlValidationResult(
        isValid: false,
        errorMessage: 'Sadece HTTP/HTTPS URL\'leri desteklenir',
      );
    }

    // Host kontrolü
    if (uri.host.isEmpty) {
      return UrlValidationResult(
        isValid: false,
        errorMessage: 'Domain adı bulunamadı',
      );
    }

    return UrlValidationResult(
      isValid: true,
      correctedUrl: correctedUrl,
      warnings: warnings,
    );
  }

  static String _addProtocolIfMissing(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('//')) {
        return 'https:$url';
      }
      return 'https://$url';
    }
    return url;
  }

  static bool isQuickValid(String input) {
    if (input.trim().isEmpty || input.trim().length < 4) return false;

    String corrected = _addProtocolIfMissing(input.trim());

    try {
      final uri = Uri.parse(corrected);
      return uri.hasScheme &&
          uri.scheme.startsWith('http') &&
          uri.host.isNotEmpty &&
          uri.host.contains('.');
    } catch (e) {
      return false;
    }
  }
}
