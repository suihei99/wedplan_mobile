import 'package:flutter/material.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class WelcomeBackgroundDecor extends StatelessWidget {
  const WelcomeBackgroundDecor({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8FA), Color(0xFFFFEEF2)],
            ),
          ),
        ),
        const Positioned(
          top: -50,
          right: -34,
          child: _DecorBlob(color: Color(0x33F4708A), size: 180),
        ),
        const Positioned(
          top: 140,
          left: -40,
          child: _DecorBlob(color: Color(0x22E04F6D), size: 160),
        ),
        const Positioned(
          bottom: 88,
          right: -24,
          child: _DecorBlob(color: Color(0x18F4708A), size: 140),
        ),
      ],
    );
  }
}

class _DecorBlob extends StatelessWidget {
  const _DecorBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.02)],
        ),
      ),
    );
  }
}
