import 'package:flutter/material.dart';

import 'package:wedplan_mobile/models/auth/auth_models.dart';
import 'package:wedplan_mobile/views/couple/couple_dashboard.dart';
import 'package:wedplan_mobile/views/vendor/vendor_dashboard.dart';

void navigateToAuthDashboard(
  BuildContext context,
  Map<String, dynamic> response, {
  AuthMode fallbackMode = AuthMode.login,
}) {
  final roleValue = response['role']?.toString().trim().toLowerCase();
  final isVendor =
      roleValue == 'vendor' || fallbackMode == AuthMode.registerVendor;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => isVendor
          ? const VendorDashboardScreen()
          : const CoupleDashboardScreen(),
    ),
    (route) => false,
  );
}
