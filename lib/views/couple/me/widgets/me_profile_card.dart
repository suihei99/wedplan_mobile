import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/views/couple/me/widgets/me_section_shell.dart';

class MeProfileCard extends StatelessWidget {
  const MeProfileCard({
    super.key,
    required this.profile,
    required this.onEditProfile,
  });

  final CoupleMeProfile profile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return MeSectionShell(
      title: 'Couple Details',
      subtitle:
          'Review your wedding profile and edit the account fields supported by the API.',
      trailing: TextButton(onPressed: onEditProfile, child: const Text('Edit')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(profile: profile),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName
                          : 'Couple Profile',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email.isNotEmpty
                          ? profile.email
                          : 'No email saved',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF6F6468),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(
                          label: profile.role.isNotEmpty
                              ? profile.role.toUpperCase()
                              : 'COUPLE',
                        ),
                        _Tag(label: profile.budgetHealthLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Partner 1', value: profile.partner1Name),
          _InfoRow(label: 'Partner 2', value: profile.partner2Name),
          _InfoRow(label: 'Wedding', value: profile.weddingSummary),
          _InfoRow(
            label: 'Budget limit',
            value: 'RM ${profile.totalBudgetLimit.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final CoupleMeProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.hasProfilePhoto) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFFCE0E5),
        backgroundImage: NetworkImage(profile.profilePhotoUrl),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFFCE0E5),
      child: Text(
        profile.initials,
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE04F6D),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF8C7980),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8C7980),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF21161A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
