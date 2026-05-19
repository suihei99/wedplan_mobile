import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class WelcomeBrandMark extends StatelessWidget {
  const WelcomeBrandMark({
    super.key,
    required this.primary,
    required this.primaryDeep,
    required this.textColor,
  });

  final Color primary;
  final Color primaryDeep;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/WebPlan_logo.webp',
          width: 112,
          height: 112,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          'WEDPLAN',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
