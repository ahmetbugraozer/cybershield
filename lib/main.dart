import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  await Hive.initFlutter();

  // .env dosyasını yükle (isteğe bağlı)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not found. Using default configuration.');
  }

  runApp(const ProviderScope(child: CyberShieldApp()));
}
