import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_management_view_model.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_add_screen.dart';

class GuestListViewScreen extends StatelessWidget {
  const GuestListViewScreen({super.key, this.guestId});

  final String? guestId;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<GuestManagementViewModel>(context);
    final guest = guestId == null ? _firstGuest(vm) : vm.guestById(guestId!);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guest?.name.isNotEmpty == true ? guest!.name : 'Guest Detail',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Update RSVP information, contact details, and invitation sharing.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7C6B71),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: guest == null
                ? null
                : () => _shareWhatsApp(context, guest),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: guest == null
              ? _EmptyDetailState(
                  title: 'Guest not found',
                  subtitle:
                      'Go back to the guest list and select an invitation record.',
                )
              : ListView(
                  children: [
                    _HeroCard(guest: guest),
                    const SizedBox(height: 16),
                    _ActionBanner(
                      guest: guest,
                      onShare: () => _shareWhatsApp(context, guest),
                      onEdit: () => _openEditor(context, guest),
                      onConfirm: () => _markStatus(
                        context,
                        guest,
                        'confirmed',
                        'marked as confirmed',
                      ),
                      onPending: () => _markStatus(
                        context,
                        guest,
                        'pending',
                        'marked as pending',
                      ),
                      onDeclined: () => _markStatus(
                        context,
                        guest,
                        'declined',
                        'marked as declined',
                      ),
                      onCheckIn: () => _markCheckIn(context, guest),
                      onDelete: () => _confirmDelete(context, vm, guest),
                    ),
                    const SizedBox(height: 16),
                    _InvitationPreviewCard(guest: guest),
                    const SizedBox(height: 16),
                    _DetailsCard(guest: guest),
                    const SizedBox(height: 16),
                    _TimelineCard(guest: guest),
                  ],
                ),
        ),
      ),
    );
  }

  Guest? _firstGuest(GuestManagementViewModel vm) {
    if (vm.guests.isEmpty) return null;
    return vm.guests.first;
  }

  Future<void> _shareWhatsApp(BuildContext context, Guest guest) async {
    final invitationText = _buildInvitationText(guest);
    final phoneDigits = _normalizePhoneNumber(guest.phone);
    // Try opening the WhatsApp app first (app scheme).
    final appUri = phoneDigits.isNotEmpty
        ? Uri.parse(
            'whatsapp://send?phone=$phoneDigits&text=${Uri.encodeComponent(invitationText)}',
          )
        : Uri.parse(
            'whatsapp://send?text=${Uri.encodeComponent(invitationText)}',
          );
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback: wa.me (short link)
    final webUri = phoneDigits.isNotEmpty
        ? Uri.parse(
            'https://wa.me/$phoneDigits?text=${Uri.encodeComponent(invitationText)}',
          )
        : Uri.parse(
            'https://wa.me/?text=${Uri.encodeComponent(invitationText)}',
          );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Broader web fallback: api.whatsapp.com works in browsers and handles more cases.
    final apiUri = phoneDigits.isNotEmpty
        ? Uri.parse(
            'https://api.whatsapp.com/send?phone=$phoneDigits&text=${Uri.encodeComponent(invitationText)}',
          )
        : Uri.parse(
            'https://api.whatsapp.com/send?text=${Uri.encodeComponent(invitationText)}',
          );
    if (await canLaunchUrl(apiUri)) {
      await launchUrl(apiUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Diagnostic: check what canLaunchUrl reports for each URI.
    final canApp = await canLaunchUrl(appUri);
    final canWeb = await canLaunchUrl(webUri);
    final canApi = await canLaunchUrl(apiUri);
    debugPrint(
      'WhatsApp launchability -> app: $canApp, web: $canWeb, api: $canApi',
    );

    if (!context.mounted) return;

    // Show options to the user when automatic launch fails.
    final choice = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Open WhatsApp'),
          content: const Text(
            'Cannot open WhatsApp directly. Choose an action to send the invitation:',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('browser'),
              child: const Text('Open in browser'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('copy'),
              child: const Text('Copy message'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('install'),
              child: const Text('Install WhatsApp'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (choice == 'browser') {
      if (await canLaunchUrl(apiUri)) {
        await launchUrl(apiUri, mode: LaunchMode.externalApplication);
        return;
      }
      // Try launching as a string if canLaunchUrl fails unexpectedly.
      try {
        await launchUrlString(
          apiUri.toString(),
          mode: LaunchMode.externalApplication,
        );
        return;
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser.')),
        );
        return;
      }
    }

    if (choice == 'install') {
      // Try Play Store first, then web fallback.
      final market = Uri.parse('market://details?id=com.whatsapp');
      final playWeb = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.whatsapp',
      );
      if (await canLaunchUrl(market)) {
        await launchUrl(market, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(playWeb)) {
        await launchUrl(playWeb, mode: LaunchMode.externalApplication);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store.')),
      );
      return;
    }

    if (choice == 'copy') {
      await Clipboard.setData(ClipboardData(text: invitationText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invitation copied to clipboard. Paste into WhatsApp to send.',
          ),
        ),
      );
      return;
    }

    // If user cancelled dialog, do a silent fallback copy so they still have the message.
    await Clipboard.setData(ClipboardData(text: invitationText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invitation copied to clipboard.')),
    );
  }

  String _normalizePhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    // WhatsApp requires an international format. For Malaysian local numbers
    // like 0148591648, convert to 60148591648.
    if (digits.startsWith('0')) {
      return '60${digits.substring(1)}';
    }

    return digits;
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

  void _openEditor(BuildContext context, Guest guest) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<GuestManagementViewModel>(context, listen: false),
          child: GuestListAddScreen(guestId: guest.id),
        ),
      ),
    );
  }

  Future<void> _markStatus(
    BuildContext context,
    Guest guest,
    String status,
    String successMessage,
  ) async {
    try {
      await Provider.of<GuestManagementViewModel>(
        context,
        listen: false,
      ).updateRsvp(guest.id, status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${guest.name} $successMessage')));
    } catch (_) {
      if (!context.mounted) return;
      final vm = Provider.of<GuestManagementViewModel>(context, listen: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error ?? 'Failed')));
    }
  }

  Future<void> _markCheckIn(BuildContext context, Guest guest) async {
    try {
      await Provider.of<GuestManagementViewModel>(
        context,
        listen: false,
      ).checkInGuest(guest.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${guest.name} checked in')));
    } catch (_) {
      if (!context.mounted) return;
      final vm = Provider.of<GuestManagementViewModel>(context, listen: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error ?? 'Failed')));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GuestManagementViewModel vm,
    Guest guest,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete guest?'),
          content: Text('Remove ${guest.name} from the guest list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await vm.deleteGuest(guest.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${guest.name} deleted')));
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error ?? 'Failed')));
    }
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
    required this.onConfirm,
    required this.onPending,
    required this.onDeclined,
    required this.onCheckIn,
    required this.onDelete,
  });

  final Guest guest;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final VoidCallback onPending;
  final VoidCallback onDeclined;
  final VoidCallback onCheckIn;
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
          Row(
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  label: 'Confirmed',
                  onPressed: onConfirm,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryActionButton(
                  label: 'Pending',
                  onPressed: onPending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  label: 'Declined',
                  danger: true,
                  onPressed: onDeclined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryActionButton(
                  label: guest.checkedIn ? 'Checked In' : 'Check In',
                  onPressed: onCheckIn,
                ),
              ),
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

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFC94B4B) : const Color(0xFFE04F6D);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.22)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label),
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

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0DDE1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.group_off_rounded,
              size: 42,
              color: Color(0xFFE04F6D),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF6F6468),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
