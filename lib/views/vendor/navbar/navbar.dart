import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

typedef VendorNavTapCallback = void Function(int index);

class VendorNavbar extends StatelessWidget {
  const VendorNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final VendorNavTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: const Color(0xFFFCE0E5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? const Color(0xFFE04F6D) : const Color(0xFF8D7C83),
          );
        }),
      ),
      child: NavigationBar(
        height: 68,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFCE0E5),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_rounded),
            label: 'Service',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Booking',
          ),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Me'),
        ],
      ),
    );
  }
}
