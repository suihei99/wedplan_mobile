import 'package:flutter/material.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class WelcomeHeroArt extends StatelessWidget {
  const WelcomeHeroArt({
    super.key,
    required this.primary,
    required this.primaryDeep,
  });

  final Color primary;
  final Color primaryDeep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 138,
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 22,
            child: Icon(
              Icons.favorite,
              color: primaryDeep.withValues(alpha: 0.70),
              size: 16,
            ),
          ),
          Positioned(
            right: 10,
            top: 14,
            child: Icon(
              Icons.favorite,
              color: primary.withValues(alpha: 0.66),
              size: 14,
            ),
          ),
          Positioned(
            left: 28,
            top: 26,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.94),
                    primaryDeep.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 40,
            child: Container(
              width: 10,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            left: 60,
            top: 50,
            child: Container(
              width: 10,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
