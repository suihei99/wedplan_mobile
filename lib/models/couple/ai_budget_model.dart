import 'package:flutter/material.dart';

class AiBudgetEstimate {
  const AiBudgetEstimate({
    required this.amount,
    required this.breakdown,
  });

  final double amount;
  final List<AiBudgetBreakdownItem> breakdown;
}

class AiBudgetBreakdownItem {
  const AiBudgetBreakdownItem(this.label, this.amount, this.icon);

  final String label;
  final double amount;
  final IconData icon;
}