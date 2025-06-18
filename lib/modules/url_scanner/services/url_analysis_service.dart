import 'virus_total_service.dart';
import 'heuristic_checker_service.dart';

enum ThreatLevel {
  safe, // Güvenli
  suspicious, // Şüpheli
  dangerous // Tehlikeli
}

class UrlAnalysisResult {
  final String url;
  final ThreatLevel threatLevel;
  final String summary;
  final List<HeuristicResult> heuristicResults;
  final VirusTotalResult? virusTotalResult;
  final List<String> recommendations;

  UrlAnalysisResult({
    required this.url,
    required this.threatLevel,
    required this.summary,
    required this.heuristicResults,
    this.virusTotalResult,
    required this.recommendations,
  });
}

class UrlAnalysisService {
  final VirusTotalService _virusTotalService;
  final HeuristicCheckerService _heuristicService;

  UrlAnalysisService()
      : _virusTotalService = VirusTotalService(),
        _heuristicService = HeuristicCheckerService();

  Future<UrlAnalysisResult> analyzeUrl(String url) async {
    // Heuristik kontrolleri yap
    final heuristicResults = _heuristicService.analyzeUrl(url);

    // VirusTotal kontrolü (opsiyonel)
    VirusTotalResult? vtResult;
    try {
      vtResult = await _virusTotalService.scanUrl(url);
    } catch (e) {
      // VirusTotal hatası önemli değil, heuristik sonuçlarla devam et
    }

    // Tehdit seviyesini hesapla
    final threatLevel = _calculateThreatLevel(heuristicResults, vtResult);

    // Özet ve öneriler oluştur
    final summary = _generateSummary(threatLevel, heuristicResults, vtResult);
    final recommendations =
        _generateRecommendations(threatLevel, heuristicResults);

    return UrlAnalysisResult(
      url: url,
      threatLevel: threatLevel,
      summary: summary,
      heuristicResults: heuristicResults,
      virusTotalResult: vtResult,
      recommendations: recommendations,
    );
  }

  ThreatLevel _calculateThreatLevel(
    List<HeuristicResult> heuristicResults,
    VirusTotalResult? vtResult,
  ) {
    // VirusTotal sonucu varsa öncelik ver
    if (vtResult != null && vtResult.isScanned) {
      if (vtResult.positiveDetections > 0) {
        return ThreatLevel.dangerous;
      }
    }

    // Heuristik sonuçları değerlendir
    int highSeverityCount = 0;
    int mediumSeverityCount = 0;
    int failedChecks = 0;

    for (final result in heuristicResults) {
      if (!result.isPassed) {
        failedChecks++;
        if (result.severity == 'high') {
          highSeverityCount++;
        } else if (result.severity == 'medium') {
          mediumSeverityCount++;
        }
      }
    }

    // Tehdit seviyesi hesaplama
    if (highSeverityCount > 0) {
      return ThreatLevel.dangerous;
    } else if (mediumSeverityCount >= 2 || failedChecks >= 3) {
      return ThreatLevel.suspicious;
    } else {
      return ThreatLevel.safe;
    }
  }

  String _generateSummary(
    ThreatLevel threatLevel,
    List<HeuristicResult> heuristicResults,
    VirusTotalResult? vtResult,
  ) {
    switch (threatLevel) {
      case ThreatLevel.safe:
        return '🟢 Bu URL güvenli görünüyor. Önemli güvenlik sorunu tespit edilmedi.';
      case ThreatLevel.suspicious:
        return '🟡 Bu URL şüpheli. Dikkatli olun ve kişisel bilgilerinizi paylaşmayın.';
      case ThreatLevel.dangerous:
        return '🔴 Bu URL tehlikeli! Siteyi ziyaret etmeyin ve bağlantıya tıklamayın.';
    }
  }

  List<String> _generateRecommendations(
    ThreatLevel threatLevel,
    List<HeuristicResult> heuristicResults,
  ) {
    final recommendations = <String>[];

    switch (threatLevel) {
      case ThreatLevel.safe:
        recommendations.addAll([
          'Site güvenli görünse de kişisel bilgilerinizi dikkatli paylaşın',
          'Her zaman HTTPS bağlantı kullanmaya özen gösterin',
          'Şüphe duyduğunuzda URL\'yi tekrar kontrol edin',
        ]);
        break;
      case ThreatLevel.suspicious:
        recommendations.addAll([
          'Bu siteye kişisel bilgilerinizi girmeyin',
          'Banka/kredi kartı bilgilerinizi paylaşmayın',
          'Şüpheniz varsa siteyi ziyaret etmeyin',
          'URL\'yi doğrudan tarayıcıya yazarak kontrol edin',
        ]);
        break;
      case ThreatLevel.dangerous:
        recommendations.addAll([
          'Bu siteyi kesinlikle ziyaret etmeyin!',
          'Bağlantıyı başkalarıyla paylaşmayın',
          'Antivirüs programınızı güncelleyin',
          'Bu URL\'yi spam olarak bildirin',
        ]);
        break;
    }

    return recommendations;
  }
}
