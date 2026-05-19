import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wedplan_mobile/core/services/auth_service.dart';
import 'package:wedplan_mobile/views/welcome.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/couple/couple_dashboard.dart';
import 'package:wedplan_mobile/views/vendor/vendor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // small delay so splash is visible briefly
    await Future.delayed(const Duration(milliseconds: 700));

    await AuthService.instance.hydrateSessionCache();
    final loggedIn = await AuthService.instance.hasToken();

    if (!mounted) return;

    if (loggedIn) {
      final role = await AuthService.instance.role;

      if (!mounted) return;

      if (role == 'vendor') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VendorDashboardScreen()),
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CoupleDashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 126,
              height: 126,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: welcomePrimaryDeepColor.withValues(alpha: 0.16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/WebPlan_logo.webp',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
