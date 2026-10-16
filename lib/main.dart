import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      home: const AresNavMapScreen(),
    );
  }
}

class AresNavMapScreen extends StatefulWidget {
  const AresNavMapScreen({super.key});

  @override
  State<AresNavMapScreen> createState() => _AresNavMapScreenState();
}

class _AresNavMapScreenState extends State<AresNavMapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(21.1483, -21.2798),
          initialZoom: 6.2,
        ),
        children: const [],
      ),
    );
  }
}
