import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class CyberShieldApp extends StatelessWidget {
  const CyberShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberShield',
      theme: AppTheme.darkTheme,
      home: const MainNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
