import 'package:flutter/material.dart';

class WelcomeFloatingBadge extends StatelessWidget {
  const WelcomeFloatingBadge({
    super.key,
    required this.icon,
    required this.primaryDeep,
  });

  final IconData icon;
  final Color primaryDeep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryDeep.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: primaryDeep, size: 30),
    );
  }
}
