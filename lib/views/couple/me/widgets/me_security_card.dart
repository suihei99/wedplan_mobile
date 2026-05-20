import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/couple/me/widgets/me_section_shell.dart';

class MeSecurityCard extends StatelessWidget {
  const MeSecurityCard({super.key, required this.onChangePassword});

  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return MeSectionShell(
      title: 'Security',
      subtitle:
          'Keep the account protected and update your password in a focused flow.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFFE04F6D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change password',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Use a strong password and keep your wedding planning account secure.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF6F6468),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onChangePassword,
              icon: const Icon(Icons.password_rounded),
              label: const Text('Open Password Screen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE04F6D),
                side: const BorderSide(color: Color(0xFFF2B8BF)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
