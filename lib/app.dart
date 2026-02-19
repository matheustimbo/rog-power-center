import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class RogPowerApp extends StatelessWidget {
  const RogPowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROG Power Center',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFFF4444),
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
    );
  }
}
