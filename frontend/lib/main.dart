// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Timer

import 'screens/index_screen.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const SpeachMeApp(),
    ),
  );
}

class SpeachMeApp extends StatefulWidget {
  const SpeachMeApp({super.key});

  @override
  State<SpeachMeApp> createState() => _SpeachMeAppState();
}

class _SpeachMeAppState extends State<SpeachMeApp> {
  Timer? _heartbeatTimer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Start a periodic timer that calls /heartbeat every 30 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _apiService.pingBackend();
    });
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Academy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F1E4),
      ),
      home: const IndexScreen(),
      debugShowCheckedModeBanner: false,
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
    );
  }
}
