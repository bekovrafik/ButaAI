import 'package:flutter/material.dart';
import 'screens/cockpit_home_screen.dart';
import 'theme/buta_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ButaCockpitApp());
}

class ButaCockpitApp extends StatelessWidget {
  const ButaCockpitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ButaAI Cockpit',
      debugShowCheckedModeBanner: false,
      theme: ButaTheme.darkTheme,
      home: const CockpitHomeScreen(),
    );
  }
}
