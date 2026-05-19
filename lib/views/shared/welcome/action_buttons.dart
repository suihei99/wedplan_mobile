import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePrimaryActionButton extends StatelessWidget {
  const WelcomePrimaryActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
    required this.busy,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class WelcomeRegisterButtons extends StatelessWidget {
  const WelcomeRegisterButtons({
    super.key,
    required this.primaryDeep,
    required this.onCouple,
    required this.onVendor,
    required this.busy,
  });

  final Color primaryDeep;
  final VoidCallback onCouple;
  final VoidCallback onVendor;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WelcomeOutlinedActionButton(
            label: 'As Couple',
            icon: Icons.favorite_border_rounded,
            borderColor: primaryDeep,
            background: Colors.white,
            foreground: const Color(0xFF21161A),
            onPressed: busy ? null : onCouple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WelcomeFilledActionButton(
            label: 'As Vendor',
            icon: Icons.storefront_rounded,
            background: primaryDeep,
            foreground: Colors.white,
            onPressed: busy ? null : onVendor,
          ),
        ),
      ],
    );
  }
}

class WelcomeGuestActionButton extends StatelessWidget {
  const WelcomeGuestActionButton({
    super.key,
    required this.onPressed,
    required this.busy,
  });

  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF21161A),
          side: BorderSide(
            color: const Color(0xFFE04F6D).withValues(alpha: 0.22),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.badge_rounded, size: 20),
        label: Text(
          'Guest Invitation',
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class WelcomeGuestInviteCard extends StatelessWidget {
  const WelcomeGuestInviteCard({
    super.key,
    required this.onPressed,
    required this.busy,
  });

  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: busy ? null : onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE04F6D).withValues(alpha: 0.14),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7EC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  size: 30,
                  color: Color(0xFFE04F6D),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest Invitation',
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF21161A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Open an invite by scanning QR or entering the code.',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF21161A).withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFFE04F6D).withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeOutlinedActionButton extends StatelessWidget {
  const _WelcomeOutlinedActionButton({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color borderColor;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(
            color: borderColor.withValues(alpha: 0.38),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _WelcomeFilledActionButton extends StatelessWidget {
  const _WelcomeFilledActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
