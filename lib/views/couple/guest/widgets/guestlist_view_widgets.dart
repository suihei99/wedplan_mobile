import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';

class GuestDetailView extends StatelessWidget {
  const GuestDetailView({
    super.key,
    required this.guest,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
  });

  final Guest guest;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _HeroCard(guest: guest),
        const SizedBox(height: 16),
        _ActionBanner(
          guest: guest,
          onShare: onShare,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        const SizedBox(height: 16),
        _InvitationPreviewCard(guest: guest),
        const SizedBox(height: 16),
        _DetailsCard(guest: guest),
        const SizedBox(height: 16),
        _TimelineCard(guest: guest),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.guest});

  final Guest guest;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (guest.rsvpStatus.toLowerCase()) {
      'confirmed' => const Color(0xFF2E8B57),
      'declined' => const Color(0xFFC94B4B),
      _ => const Color(0xFFC58B1D),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8EE), Color(0xFFFFF7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4D8DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.groups_rounded, color: Color(0xFFE04F6D)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guest.phone.isNotEmpty ? guest.phone : 'No phone number',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: const Color(0xFF6F6468),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: guest.rsvpStatus.isEmpty
                          ? 'Pending'
                          : guest.rsvpStatus.toUpperCase(),
                      color: statusColor,
                    ),
                    _Pill(
                      label: 'PAX ${guest.paxCount}',
                      color: const Color(0xFFE04F6D),
                    ),
                    if (guest.checkedIn)
                      _Pill(
                        label: 'CHECKED IN',
                        color: const Color(0xFF2E8B57),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.guest,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
  });

  final Guest guest;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Guest Actions',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryActionButton(
            label: 'Send via WhatsApp',
            icon: Icons.send_rounded,
            color: const Color(0xFF25D366),
            onPressed: onShare,
          ),
          const SizedBox(height: 10),
          _PrimaryActionButton(
            label: 'Edit Guest',
            icon: Icons.edit_outlined,
            color: const Color(0xFFE04F6D),
            onPressed: onEdit,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                label: guest.rsvpStatus.isEmpty
                    ? 'PENDING'
                    : guest.rsvpStatus.toUpperCase(),
                color: guest.rsvpStatus.toLowerCase() == 'confirmed'
                    ? const Color(0xFF2E8B57)
                    : guest.rsvpStatus.toLowerCase() == 'declined'
                    ? const Color(0xFFC94B4B)
                    : const Color(0xFFC58B1D),
              ),
              if (guest.checkedIn)
                _Pill(label: 'CHECKED IN', color: const Color(0xFF2E8B57)),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete Guest'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC94B4B),
              side: const BorderSide(color: Color(0xFFF2B8BF)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _InvitationPreviewCard extends StatelessWidget {
  const _InvitationPreviewCard({required this.guest});

  final Guest guest;

  @override
  Widget build(BuildContext context) {
    final inviteCode = guest.inviteCode.isEmpty ? '-' : guest.inviteCode;
    final qrLink = inviteCode == '-'
        ? 'https://wedplan.projectse.io/guest/qr'
        : 'https://wedplan.projectse.io/guest/qr/$inviteCode';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation Preview',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _buildInvitationText(guest),
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.55,
              color: const Color(0xFF4E4045),
            ),
          ),
          const SizedBox(height: 12),
          _LinkRow(label: 'QR code link', value: qrLink),
          const SizedBox(height: 8),
          const _LinkRow(
            label: 'Mobile app',
            value: 'https://wedplan.projectse.io/mobile-app',
          ),
        ],
      ),
    );
  }

  String _buildInvitationText(Guest guest) {
    final coupleName = guest.coupleName.isNotEmpty
        ? guest.coupleName
        : 'our couple';
    final inviteCode = guest.inviteCode.isNotEmpty
        ? guest.inviteCode
        : 'INVITE CODE';
    final qrLink = inviteCode == 'INVITE CODE'
        ? 'https://wedplan.projectse.io/guest/qr'
        : 'https://wedplan.projectse.io/guest/qr/$inviteCode';

    return '''Hi ${guest.name},

You are invited to $coupleName's wedding.
Invite code: $inviteCode

View your QR code: $qrLink
Install our mobile app to check-in: https://wedplan.projectse.io/mobile-app

Please reply with your RSVP. Thank you.''';
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8C7980),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 12,
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.guest});

  final Guest guest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Details',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailLine(
            label: 'Phone',
            value: guest.phone.isEmpty ? '-' : guest.phone,
          ),
          _DetailLine(label: 'Pax Count', value: guest.paxCount.toString()),
          _DetailLine(
            label: 'Invite Code',
            value: guest.inviteCode.isEmpty ? '-' : guest.inviteCode,
          ),
          _DetailLine(
            label: 'QR String',
            value: guest.qrCodeString.isEmpty ? '-' : guest.qrCodeString,
          ),
          _DetailLine(
            label: 'Checked In',
            value: guest.checkedInAt.isEmpty ? 'No' : guest.checkedInAt,
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 102,
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
              value,
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

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.guest});

  final Guest guest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailLine(
            label: 'Created',
            value: guest.createdAt.isEmpty ? '-' : guest.createdAt,
          ),
          _DetailLine(
            label: 'Updated',
            value: guest.updatedAt.isEmpty ? '-' : guest.updatedAt,
          ),
          _DetailLine(
            label: 'Current RSVP',
            value: guest.rsvpStatus.isEmpty ? 'pending' : guest.rsvpStatus,
          ),
        ],
      ),
    );
  }
}
