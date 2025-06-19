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

    // HTTPS kontrolü - daha katı
    results.add(_checkHttps(url));

    // Domain kontrolü - gerçekçi
    results.add(_checkDomain(url));

    // IP adresi kontrolü - tehlikeli olarak işaretle
    results.add(_checkIpAddress(url));

    // Şüpheli kelimeler kontrolü - genişletilmiş
    results.add(_checkSuspiciousWords(url));

    // URL uzunluğu kontrolü
    results.add(_checkUrlLength(url));

    // Subdomain kontrolü - daha hassas
    results.add(_checkSubdomains(url));

    // Homograf saldırı kontrolü - geliştirilmiş
    results.add(_checkHomographAttack(url));

    // Yeni kontroller
    results.add(_checkSuspiciousTLD(url));
    results.add(_checkPhishingPatterns(url));

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
      description:
          isHttps ? 'HTTPS kullanıyor' : 'HTTP kullanıyor - VERİ GÜVENSİZ!',
      severity: isHttps ? 'low' : 'high', // HTTP'yi yüksek risk yap
    );
  }

  HeuristicResult _checkDomain(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.toLowerCase();

      // Bilinen GERÇEK güvenli domainler (sınırlı liste)
      final trustedDomains = [
        'google.com',
        'youtube.com',
        'github.com',
        'microsoft.com',
        'apple.com',
        'linkedin.com',
        'amazon.com',
        'facebook.com',
        'netflix.com',
        'microsoftonline.com',
        'dropbox.com',
        'discord.com',
        'drive.google.com',
        'docs.google.com',
        'twitter.com',
        'instagram.com',
        'wikipedia.org',
        'stackoverflow.com',
        'reddit.com',
        'mozilla.org',
        'adobe.com',
        'paypal.com',
        'bankofamerica.com',
        'chase.com',
        'wellsfargo.com',
        'hsbc.com',
        'citibank.com',
        'paypal.com',
        'appleid.apple.com',
        'accounts.google.com',
        'login.microsoftonline.com',
        'x.com',
        'twitch.tv',
        'spotify.com',
        'zoom.us',
        'slack.com',
        'telegram.org',
        'signal.org',
        'whatsapp.com',
        'kick.com',
        'vimeo.com',
        'pinterest.com',
        'quora.com',
      ];

      // Kesin tehlikeli domainler
      final dangerousDomains = [
        'phishing.example.com',
        'fake.site.com',
        'malware-test.com',
      ];

      if (dangerousDomains.any((dangerous) => domain.contains(dangerous))) {
        return HeuristicResult(
          checkName: 'Domain Güvenilirliği',
          isPassed: false,
          description: 'Bilinen tehlikeli domain!',
          severity: 'high',
        );
      }

      final isTrusted = trustedDomains.any(
        (trusted) => domain == trusted || domain.endsWith('.$trusted'),
      );

      return HeuristicResult(
        checkName: 'Domain Güvenilirliği',
        isPassed: isTrusted,
        description:
            isTrusted ? 'Bilinen güvenli domain' : 'Bilinmeyen/Şüpheli domain',
        severity: isTrusted ? 'low' : 'medium',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'Domain Güvenilirliği',
        isPassed: false,
        description: 'Domain analiz edilemedi - şüpheli format',
        severity: 'high',
      );
    }
  }

  HeuristicResult _checkIpAddress(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;

      final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      final isIpAddress = ipRegex.hasMatch(host);

      return HeuristicResult(
        checkName: 'IP Adresi Kontrolü',
        isPassed: !isIpAddress,
        description:
            isIpAddress
                ? 'UYARI: Doğrudan IP adresi kullanıyor! ($host)'
                : 'Normal domain adı kullanıyor',
        severity: isIpAddress ? 'high' : 'low',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'IP Adresi Kontrolü',
        isPassed: false,
        description: 'IP kontrol edilemedi',
        severity: 'medium',
      );
    }
  }

  HeuristicResult _checkSuspiciousWords(String url) {
    final suspiciousWords = [
      // Phishing kelimeleri
      'secure', 'verify', 'update', 'confirm', 'login', 'signin',
      'account', 'suspended', 'locked', 'expired', 'urgent',
      // Scam kelimeleri
      'free', 'winner', 'prize', 'click', 'download', 'offer',
      // Bankacılık taklit kelimeleri
      'bank', 'paypal', 'amazon', 'apple', 'microsoft',
      // Tehdit kelimeleri
      'warning', 'alert', 'blocked', 'virus', 'infected',
    ];

    final urlLower = url.toLowerCase();
    final foundWords =
        suspiciousWords.where((word) => urlLower.contains(word)).toList();

    String severity = 'low';
    if (foundWords.length >= 3) {
      severity = 'high';
    } else if (foundWords.length >= 2) {
      severity = 'medium';
    } else if (foundWords.isNotEmpty) {
      severity = 'medium';
    }

    return HeuristicResult(
      checkName: 'Şüpheli Kelimeler',
      isPassed: foundWords.isEmpty,
      description:
          foundWords.isEmpty
              ? 'Şüpheli kelime bulunamadı'
              : 'UYARI: Şüpheli kelimeler bulundu: ${foundWords.join(", ")}',
      severity: severity,
    );
  }

  HeuristicResult _checkUrlLength(String url) {
    const maxLength = 75; // Daha katı limit
    final isNormalLength = url.length <= maxLength;

    return HeuristicResult(
      checkName: 'URL Uzunluğu',
      isPassed: isNormalLength,
      description:
          isNormalLength
              ? 'Normal uzunlukta (${url.length} karakter)'
              : 'ŞÜPHELİ: Çok uzun URL (${url.length} karakter)',
      severity: isNormalLength ? 'low' : 'medium',
    );
  }

  HeuristicResult _checkSubdomains(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      final parts = host.split('.');

      // 2'den fazla subdomain şüpheli (daha katı)
      final hasExcessiveSubdomains = parts.length > 3;

      return HeuristicResult(
        checkName: 'Subdomain Analizi',
        isPassed: !hasExcessiveSubdomains,
        description:
            hasExcessiveSubdomains
                ? 'ŞÜPHELİ: Çok fazla subdomain! (${parts.length - 2} adet)'
                : 'Normal subdomain yapısı',
        severity: hasExcessiveSubdomains ? 'high' : 'low',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'Subdomain Analizi',
        isPassed: false,
        description: 'Subdomain analiz edilemedi',
        severity: 'medium',
      );
    }
  }

  HeuristicResult _checkHomographAttack(String url) {
    // Genişletilmiş Unicode kontrol
    final suspiciousChars = RegExp(
      r'[а-я]|[α-ω]|[αβγδεζηθικλμνξοπρστυφχψω]|[а-яё]',
    );
    final hasSuspiciousChars = suspiciousChars.hasMatch(url);

    return HeuristicResult(
      checkName: 'Homograf Saldırı',
      isPassed: !hasSuspiciousChars,
      description:
          hasSuspiciousChars
              ? 'TEHLİKE: Sahte Unicode karakterler bulundu! (аррӏе yerine apple gibi)'
              : 'Standart karakterler kullanılıyor',
      severity: hasSuspiciousChars ? 'high' : 'low',
    );
  }

  // YENİ: Şüpheli TLD kontrolü
  HeuristicResult _checkSuspiciousTLD(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      final suspiciousTlds = [
        '.tk',
        '.ml',
        '.ga',
        '.cf',
        '.click',
        '.download',
        '.loan',
      ];
      final hasSuspiciousTld = suspiciousTlds.any((tld) => host.endsWith(tld));

      return HeuristicResult(
        checkName: 'Şüpheli TLD',
        isPassed: !hasSuspiciousTld,
        description:
            hasSuspiciousTld
                ? 'ŞÜPHELİ: Riskli domain uzantısı kullanıyor'
                : 'Normal domain uzantısı',
        severity: hasSuspiciousTld ? 'high' : 'low',
      );
    } catch (e) {
      return HeuristicResult(
        checkName: 'Şüpheli TLD',
        isPassed: true,
        description: 'TLD kontrol edilemedi',
        severity: 'low',
      );
    }
  }

  // YENİ: Phishing pattern kontrolü
  HeuristicResult _checkPhishingPatterns(String url) {
    final phishingPatterns = [
      RegExp(r'[0-9]+-[0-9]+-[0-9]+'), // Sayı-sayı-sayı pattern
      RegExp(
        r'secure.*login.*verify',
        caseSensitive: false,
      ), // secure+login+verify
      RegExp(
        r'update.*account.*suspended',
        caseSensitive: false,
      ), // update+account+suspended
      RegExp(r'urgent.*click.*here', caseSensitive: false), // urgent+click+here
    ];

    final matchedPatterns =
        phishingPatterns.where((pattern) => pattern.hasMatch(url)).length;

    return HeuristicResult(
      checkName: 'Phishing Pattern',
      isPassed: matchedPatterns == 0,
      description:
          matchedPatterns > 0
              ? 'TEHLİKE: Phishing kalıbı tespit edildi! ($matchedPatterns adet)'
              : 'Bilinen phishing kalıbı bulunamadı',
      severity: matchedPatterns > 0 ? 'high' : 'low',
    );
  }
}
