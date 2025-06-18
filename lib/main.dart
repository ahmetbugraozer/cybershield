import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle (isteğe bağlı)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env dosyası bulunamazsa uygulamaya devam et
    debugPrint('Warning: .env file not found. Using default configuration.');
  }

  runApp(
    const ProviderScope(
      child: CyberShieldApp(),
    ),
  );
}
