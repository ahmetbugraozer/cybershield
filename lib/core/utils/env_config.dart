import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get virusTotalApiKey => dotenv.env['VIRUSTOTAL_API_KEY'] ?? '';

  static String get hibpApiKey => dotenv.env['HIBP_API_KEY'] ?? '';

  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  static bool get hasVirusTotalKey => virusTotalApiKey.isNotEmpty;
  static bool get hasHibpKey => hibpApiKey.isNotEmpty;
}
