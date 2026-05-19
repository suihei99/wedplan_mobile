import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wedplan_mobile/core/router/app_router.dart';
import 'package:wedplan_mobile/views/welcome.dart';
import 'package:wedplan_mobile/views/splash.dart';

void main() {
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://wedplan.projectse.io/api/v1',
  );
  ApiRouter.configure(baseUrl: apiBaseUrl);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF4708A);
    const primaryDeep = Color(0xFFE04F6D);
    const textColor = Color(0xFF21161A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WedPlan App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primaryDeep,
          secondary: primary,
          surface: const Color(0xFFFFFBFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBFC),
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
