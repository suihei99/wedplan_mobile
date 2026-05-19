import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: Center(
        child: Text(
          'Vendor dashboard placeholder',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
