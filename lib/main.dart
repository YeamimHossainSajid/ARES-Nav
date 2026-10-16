import 'package:flutter/material.dart';

void main() {
  runApp(const AresNavApp());
}

class AresNavApp extends StatelessWidget {
  const AresNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARES Nav - Chryse Planitia Sector',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        fontFamily: 'monospace',
      ),
      home: const Scaffold(body: Center(child: Text('ARES Nav Initializing...'))),
    );
  }
}
