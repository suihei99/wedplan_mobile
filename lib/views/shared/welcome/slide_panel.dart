import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/shared/welcome/feature_slide.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class WelcomeSlidePanel extends StatelessWidget {
  const WelcomeSlidePanel({
    super.key,
    required this.slide,
    required this.primaryDeep,
  });

  final WelcomeFeatureSlide slide;
  final Color primaryDeep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryDeep.withValues(alpha: 0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slide.subtitle != null) ...[
            Text(
              slide.subtitle!,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: welcomeTextColor.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            slide.title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: welcomeTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slide.description,
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: welcomeTextColor.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}
