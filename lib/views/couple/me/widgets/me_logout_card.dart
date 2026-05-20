import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/couple/me/widgets/me_section_shell.dart';

class MeLogoutCard extends StatelessWidget {
  const MeLogoutCard({super.key, required this.onLogout, required this.busy});

  final VoidCallback onLogout;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return MeSectionShell(
      title: 'Logout',
      subtitle: 'Leave the account safely and return to the welcome flow.',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: busy ? null : onLogout,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(
            busy ? 'Signing out...' : 'Logout',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xFFC94B4B),
            backgroundColor: const Color(0xFFFFEFF2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}
