class HeuristicResult {
  final String checkName;
  final bool isPassed;
  final String description;
  final String severity; // 'low', 'medium', 'high'

  HeuristicResult({
    required this.checkName,
    required this.isPassed,
    required this.description,
    required this.severity,
  });
}

class HeuristicCheckerService {
  List<HeuristicResult> analyzeUrl(String url) {
    final results = <HeuristicResult>[];

    // URL formatı kontrolü
    results.add(_checkUrlFormat(url));

    // HTTPS kontrolü
    results.add(_checkHttps(url));

    // Domain kontrolü
    results.add(_checkDomain(url));

    // IP adresi kontrolü
    results.add(_checkIpAddress(url));

    // Şüpheli kelimeler kontrolü
    results.add(_checkSuspiciousWords(url));

    // URL uzunluğu kontrolü
    results.add(_checkUrlLength(url));

    // Subdomain kontrolü
    results.add(_checkSubdomains(url));

    // Homograf saldırı kontrolü
    results.add(_checkHomographAttack(url));

    return results;
  }

  HeuristicResult _checkUrlFormat(String url) {
    final isValid = Uri.tryParse(url) != null;
    return HeuristicResult(
      checkName: 'URL Formatı',
      isPassed: isValid,
      description: isValid ? 'Geçerli URL formatı' : 'Geçersiz URL formatı',
      severity: isValid ? 'low' : 'high',
    );
  }

  HeuristicResult _checkHttps(String url) {
    final isHttps = url.toLowerCase().startsWith('https://');
    return HeuristicResult(
      checkName: 'HTTPS Güvenliği',
      isPassed: isHttps,
      description: isHttps ? 'HTTPS kullanıyor' : 'HTTP kullanıyor (güvensiz)',
      severity: isHttps ? 'low' : 'medium',
    );
  }

  HeuristicResult _checkDomain(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.toLowerCase();

      // Bilinen güvenli domainler
      final trustedDomains = [
        'google.com',
        'youtube.com',
        'facebook.com',
        'twitter.com',
        'instagram.com',
        'linkedin.com',
        'github.com',
        'stackoverflow.com'
      ];

      final isTrusted = trustedDomains
          .any((trusted) => domain == trusted || domain.endsWith('.$trusted'));

      return HeuristicResult(
        checkName: 'Domain Güvenilirliği',
        isPassed: isTrusted,
        description: isTrusted ? 'Bilinen güvenli domain' : 'Bilinmeyen domain',
        severity: 'low',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'Domain Güvenilirliği',
        isPassed: false,
        description: 'Domain analiz edilemedi',
        severity: 'medium',
      );
    }
  }

  HeuristicResult _checkIpAddress(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;

      // IP adresi regex kontrolü
      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      final isIpAddress = ipRegex.hasMatch(host);

      return HeuristicResult(
        checkName: 'IP Adresi Kontrolü',
        isPassed: !isIpAddress,
        description: isIpAddress
            ? 'Doğrudan IP adresi kullanıyor (şüpheli)'
            : 'Domain adı kullanıyor',
        severity: isIpAddress ? 'high' : 'low',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'IP Adresi Kontrolü',
        isPassed: true,
        description: 'Kontrol edilemedi',
        severity: 'low',
      );
    }
  }

  HeuristicResult _checkSuspiciousWords(String url) {
    final suspiciousWords = [
      'secure',
      'verify',
      'update',
      'confirm',
      'login',
      'signin',
      'account',
      'suspended',
      'locked',
      'expired',
      'urgent',
      'free',
      'winner',
      'prize',
      'click',
      'download'
    ];

    final urlLower = url.toLowerCase();
    final foundWords =
        suspiciousWords.where((word) => urlLower.contains(word)).toList();

    return HeuristicResult(
      checkName: 'Şüpheli Kelimeler',
      isPassed: foundWords.isEmpty,
      description: foundWords.isEmpty
          ? 'Şüpheli kelime bulunamadı'
          : 'Şüpheli kelimeler: ${foundWords.join(", ")}',
      severity: foundWords.isEmpty ? 'low' : 'medium',
    );
  }

  HeuristicResult _checkUrlLength(String url) {
    const maxLength = 100;
    final isNormalLength = url.length <= maxLength;

    return HeuristicResult(
      checkName: 'URL Uzunluğu',
      isPassed: isNormalLength,
      description: isNormalLength
          ? 'Normal uzunlukta (${url.length} karakter)'
          : 'Çok uzun URL (${url.length} karakter)',
      severity: isNormalLength ? 'low' : 'medium',
    );
  }

  HeuristicResult _checkSubdomains(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      final parts = host.split('.');

      // 3'ten fazla subdomain şüpheli
      final hasExcessiveSubdomains = parts.length > 4;

      return HeuristicResult(
        checkName: 'Subdomain Analizi',
        isPassed: !hasExcessiveSubdomains,
        description: hasExcessiveSubdomains
            ? 'Çok fazla subdomain (${parts.length - 2})'
            : 'Normal subdomain yapısı',
        severity: hasExcessiveSubdomains ? 'medium' : 'low',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'Subdomain Analizi',
        isPassed: true,
        description: 'Analiz edilemedi',
        severity: 'low',
      );
    }
  }

  HeuristicResult _checkHomographAttack(String url) {
    // Cyrillic, Greek karakterleri kontrol et
    final suspiciousChars = RegExp(r'[а-я]|[α-ω]|[αβγδεζηθικλμνξοπρστυφχψω]');
    final hasSuspiciousChars = suspiciousChars.hasMatch(url);

    return HeuristicResult(
      checkName: 'Homograf Saldırı',
      isPassed: !hasSuspiciousChars,
      description: hasSuspiciousChars
          ? 'Şüpheli Unicode karakterler bulundu'
          : 'Standart karakterler kullanılıyor',
      severity: hasSuspiciousChars ? 'high' : 'low',
    );
  }
}
