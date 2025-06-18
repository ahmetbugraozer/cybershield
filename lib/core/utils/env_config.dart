import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get virusTotalApiKey => dotenv.env['VIRUSTOTAL_API_KEY'] ?? '';

  static const String? _hibpApiKey = null; // 'your-api-key-here'
  static String get hibpApiKey => _hibpApiKey ?? '';

  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  static bool get hasVirusTotalKey => virusTotalApiKey.isNotEmpty;
  static bool get hasHibpKey => _hibpApiKey != null && _hibpApiKey!.isNotEmpty;
}
