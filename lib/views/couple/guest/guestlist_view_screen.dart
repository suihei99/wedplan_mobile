import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_management_view_model.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_add_screen.dart';
import 'package:wedplan_mobile/views/couple/guest/widgets/guestlist_view_widgets.dart';
import 'package:wedplan_mobile/views/couple/navbar/navbar.dart';

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
              : GuestDetailView(
                  guest: guest,
                  onShare: () => _shareWhatsApp(context, guest),
                  onEdit: () => _openEditor(context, guest),
                  onDelete: () => _confirmDelete(context, vm, guest),
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

    if (!context.mounted) return;

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

    await Clipboard.setData(ClipboardData(text: invitationText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invitation copied to clipboard.')),
    );
  }

  String _normalizePhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('0')) return '60${digits.substring(1)}';
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
  Download the mobile app here: https://wedplan.projectse.io

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
