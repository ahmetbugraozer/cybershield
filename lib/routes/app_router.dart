import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../modules/password_check/ui/password_check_page.dart';
import '../modules/url_scanner/ui/url_scanner_page.dart';
import '../modules/breach_alarm/ui/breach_alarm_page.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PasswordCheckPage(),
    const UrlScannerPage(),
    const BreachAlarmPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.password_check),
            label: 'Parola Kontrolü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.global_search),
            label: 'URL Tarayıcı',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.shield_security),
            label: 'İhlal Alarmı',
          ),
        ],
      ),
    );
  }
}
