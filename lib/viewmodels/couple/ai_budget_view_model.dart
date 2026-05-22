import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wedplan_mobile/models/couple/ai_budget_model.dart';
import 'package:wedplan_mobile/models/couple/me_profile.dart';

class AiBudgetViewModel extends ChangeNotifier {
  bool _generated = false;
  String _selectedBudgetRange = 'Not sure yet';

  bool get generated => _generated;
  String get selectedBudgetRange => _selectedBudgetRange;

  void initialize(CoupleMeProfile? profile) {
    _selectedBudgetRange = _budgetRangeFromProfile(profile) ?? 'Not sure yet';
  }

  void selectBudgetRange(String value) {
    if (_selectedBudgetRange == value && !_generated) return;
    _selectedBudgetRange = value;
    _generated = false;
    notifyListeners();
  }

  void markGenerated() {
    if (_generated) return;
    _generated = true;
    notifyListeners();
  }

  void markUngenerated() {
    if (!_generated) return;
    _generated = false;
    notifyListeners();
  }

  void resetFromProfile(CoupleMeProfile? profile) {
    _selectedBudgetRange = _budgetRangeFromProfile(profile) ?? 'Not sure yet';
    _generated = false;
    notifyListeners();
  }

  AiBudgetEstimate buildEstimate({
    required CoupleMeProfile profile,
    required int guestCount,
  }) {
    final guestEstimate = _estimateFromGuests(guestCount);
    final rangeEstimate = _estimateFromBudgetRange(_selectedBudgetRange);
    final double profileBudget = profile.totalBudgetLimit > 0
        ? profile.totalBudgetLimit
        : 0.0;

    final combined = <double>[
      guestEstimate,
      rangeEstimate,
      profileBudget,
    ].where((value) => value > 0).reduce(math.max);

    final amount = _roundToNearest500(combined);
    return AiBudgetEstimate(amount: amount, breakdown: _buildBreakdown(amount));
  }

  String? budgetRangeFromProfile(CoupleMeProfile? profile) {
    return _budgetRangeFromProfile(profile);
  }

  String? _budgetRangeFromProfile(CoupleMeProfile? profile) {
    final budget = profile?.totalBudgetLimit ?? 0;
    if (budget >= 50000) return 'RM 50,000+';
    if (budget >= 25000) return 'RM 25,000 - RM 40,000';
    if (budget > 0) return 'RM 10,000 - RM 20,000';
    return null;
  }

  double _estimateFromBudgetRange(String range) {
    if (range == 'RM 10,000 - RM 20,000') return 15000;
    if (range == 'RM 25,000 - RM 40,000') return 35000;
    if (range == 'RM 50,000+') return 50000;
    return 0;
  }

  double _estimateFromGuests(int guestCount) {
    if (guestCount <= 0) return 0;
    if (guestCount <= 80) return 25000;
    if (guestCount <= 120) return 35000;
    if (guestCount <= 180) return 50000;
    if (guestCount <= 250) return 65000;
    return 80000;
  }

  double _roundToNearest500(double value) {
    if (value <= 0) return 0;
    return (value / 500).roundToDouble() * 500;
  }

  List<AiBudgetBreakdownItem> _buildBreakdown(double estimate) {
    if (estimate <= 0) return const <AiBudgetBreakdownItem>[];

    return [
      AiBudgetBreakdownItem(
        'Venue',
        estimate * 0.30,
        Icons.location_on_rounded,
      ),
      AiBudgetBreakdownItem(
        'Catering',
        estimate * 0.35,
        Icons.restaurant_rounded,
      ),
      AiBudgetBreakdownItem(
        'Decor',
        estimate * 0.10,
        Icons.celebration_rounded,
      ),
      AiBudgetBreakdownItem(
        'Photo & video',
        estimate * 0.10,
        Icons.camera_alt_rounded,
      ),
      AiBudgetBreakdownItem(
        'Music and emcee',
        estimate * 0.05,
        Icons.music_note_rounded,
      ),
      AiBudgetBreakdownItem(
        'Contingency',
        estimate * 0.10,
        Icons.safety_check_rounded,
      ),
    ];
  }
}
