import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/views/couple/me/widgets/me_section_shell.dart';

class MeAiBudgetCard extends StatelessWidget {
  const MeAiBudgetCard({
    super.key,
    required this.profile,
    required this.onOpenBudget,
    required this.onRefresh,
  });

  final CoupleMeProfile profile;
  final VoidCallback onOpenBudget;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final estimate = profile.suggestedDailyBudget;

    return MeSectionShell(
      title: 'AI Budget Estimate',
      subtitle:
          'A quick planning estimate based on your current budget and wedding timeline.',
      trailing: TextButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Refresh'),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE8EE), Color(0xFFFFF7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RM ${estimate.toStringAsFixed(0)} / day',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.budgetHealthLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC94B4B),
                        ),
                      ),
                    ],
                  ),
                ),
                _MetricPill(
                  label: '${profile.budgetUsagePercent.toStringAsFixed(0)}%',
                  subtitle: 'used',
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: profile.budgetUsagePercent / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFE04F6D),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Remaining budget: RM ${profile.remainingBudget.toStringAsFixed(0)}',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5E5056),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The estimate prioritizes pace over perfection and helps you plan spend without burning the whole budget early.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                height: 1.45,
                color: const Color(0xFF6F6468),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpenBudget,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE04F6D),
                      side: const BorderSide(color: Color(0xFFF2B8BF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Open Budget'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE04F6D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE04F6D),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7C6B71),
            ),
          ),
        ],
      ),
    );
  }
}
