import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorHeroCard extends StatelessWidget {
  const VendorHeroCard({
    super.key,
    required this.serviceCount,
    required this.typeCount,
  });

  final int serviceCount;
  final int typeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE0E5), Color(0xFFFFFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0xFFF1CFD6)),
            ),
            child: Text(
              'Vendor Services',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: welcomePrimaryDeepColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Vendor Directory',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Discover trusted service providers and open each listing for more details.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CompactMetric(
                  label: 'Services',
                  value: '$serviceCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactMetric(label: 'Types', value: '$typeCount'),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _CompactMetric(label: 'Updated', value: 'Live'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VendorSectionHeader extends StatelessWidget {
  const VendorSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7C6B71),
          ),
        ),
      ],
    );
  }
}

class VendorEmptyState extends StatelessWidget {
  const VendorEmptyState({super.key, this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5C0CA),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: welcomePrimaryDeepColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No vendors found',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter criteria.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: welcomePrimaryDeepColor,
                side: const BorderSide(color: Color(0xFFEEDCE1)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: welcomeTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
