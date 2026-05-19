import 'package:flutter/material.dart';

import 'package:wedplan_mobile/views/shared/welcome/feature_slide.dart';
import 'package:wedplan_mobile/views/shared/welcome/floating_badge.dart';
import 'package:wedplan_mobile/views/shared/welcome/hero_art.dart';
import 'package:wedplan_mobile/views/shared/welcome/slide_panel.dart';

class WelcomeHeroCard extends StatelessWidget {
  const WelcomeHeroCard({
    super.key,
    required this.primary,
    required this.primaryDeep,
    required this.pageController,
    required this.slides,
    required this.onPageChanged,
  });

  final Color primary;
  final Color primaryDeep;
  final PageController pageController;
  final List<WelcomeFeatureSlide> slides;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: PageView.builder(
          controller: pageController,
          itemCount: slides.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            final slide = slides[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.10),
                    primaryDeep.withValues(alpha: 0.20),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Positioned(
                    top: 18,
                    right: 14,
                    child: WelcomeFloatingBadge(
                      icon: slide.icon,
                      primaryDeep: primaryDeep,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 14,
                    right: 12,
                    child: WelcomeSlidePanel(
                      slide: slide,
                      primaryDeep: primaryDeep,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 16,
                    child: WelcomeHeroArt(
                      primary: primary,
                      primaryDeep: primaryDeep,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
