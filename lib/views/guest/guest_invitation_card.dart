import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:wedplan_mobile/models/guest/guest_invitation.dart';
import 'package:wedplan_mobile/core/services/app_session_cache.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

enum GuestEntryMode { scan, code }

enum GuestDecision { undecided, accepted, rejected }

class GuestInvitationLoadingView extends StatelessWidget {
  const GuestInvitationLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: welcomePrimaryDeepColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading invitation...',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: welcomeTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please wait while we connect to the backend.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: welcomeTextColor.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuestHeaderCard extends StatelessWidget {
  const GuestHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFFCE7EC).withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: welcomePrimaryDeepColor.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: welcomePrimaryDeepColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: welcomeTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                    color: welcomeTextColor.withValues(alpha: 0.76),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GuestMethodSelector extends StatelessWidget {
  const GuestMethodSelector({
    super.key,
    required this.selectedMode,
    required this.enabled,
    required this.onChanged,
  });

  final GuestEntryMode selectedMode;
  final bool enabled;
  final ValueChanged<GuestEntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: welcomePrimaryDeepColor.withValues(alpha: 0.10),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GuestMethodButton(
              selected: selectedMode == GuestEntryMode.scan,
              label: 'Scan QR',
              icon: Icons.qr_code_scanner_rounded,
              enabled: enabled,
              onTap: () => onChanged(GuestEntryMode.scan),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GuestMethodButton(
              selected: selectedMode == GuestEntryMode.code,
              label: 'Enter Code',
              icon: Icons.keyboard_alt_rounded,
              enabled: enabled,
              onTap: () => onChanged(GuestEntryMode.code),
            ),
          ),
        ],
      ),
    );
  }
}

class GuestMethodButton extends StatelessWidget {
  const GuestMethodButton({
    super.key,
    required this.selected,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? welcomePrimaryDeepColor : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : welcomePrimaryDeepColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : welcomeTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuestEntryCard extends StatelessWidget {
  const GuestEntryCard({
    super.key,
    required this.mode,
    required this.scannerHeight,
    required this.codeController,
    required this.busy,
    required this.onCodeDetected,
    required this.onLoad,
  });

  final GuestEntryMode mode;
  final double scannerHeight;
  final TextEditingController codeController;
  final bool busy;
  final ValueChanged<String> onCodeDetected;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: mode == GuestEntryMode.scan
            ? GuestQrScannerPane(
                key: const ValueKey('scan-pane'),
                scannerHeight: scannerHeight,
                onCodeDetected: onCodeDetected,
                codeText: codeController.text,
                busy: busy,
                onLoad: onLoad,
                allowManualLoad: false,
              )
            : GuestCodeEntryPane(
                key: const ValueKey('code-pane'),
                codeController: codeController,
                busy: busy,
                onLoad: onLoad,
              ),
      ),
    );
  }
}

class GuestQrScannerPane extends StatelessWidget {
  const GuestQrScannerPane({
    super.key,
    required this.scannerHeight,
    required this.onCodeDetected,
    required this.codeText,
    required this.busy,
    required this.onLoad,
    required this.allowManualLoad,
  });

  final double scannerHeight;
  final ValueChanged<String> onCodeDetected;
  final String codeText;
  final bool busy;
  final VoidCallback onLoad;
  final bool allowManualLoad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: scannerHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      if (capture.barcodes.isEmpty) return;
                      final raw = capture.barcodes.first.rawValue;
                      if (raw == null || raw.trim().isEmpty) return;
                      onCodeDetected(raw.trim());
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: welcomePrimaryDeepColor.withValues(
                            alpha: 0.75,
                          ),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.56),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Point the camera at the QR code on the invitation card.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (codeText.trim().isNotEmpty)
            GuestCodePreview(codeText: codeText.trim())
          else
            Text(
              'No code detected yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: welcomeTextColor.withValues(alpha: 0.72),
              ),
            ),
          if (allowManualLoad) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: busy || codeText.trim().isEmpty ? null : onLoad,
                style: ElevatedButton.styleFrom(
                  backgroundColor: welcomePrimaryDeepColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Load Invitation'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GuestCodeEntryPane extends StatelessWidget {
  const GuestCodeEntryPane({
    super.key,
    required this.codeController,
    required this.busy,
    required this.onLoad,
  });

  final TextEditingController codeController;
  final bool busy;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GuestPillInput(
            controller: codeController,
            label: 'Invitation code',
            hintText: 'Type the invitation code here',
            prefixIcon: Icons.confirmation_number_rounded,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: busy || codeController.text.trim().isEmpty
                  ? null
                  : onLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: welcomePrimaryDeepColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Open Invitation'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This works without login. The couple shares a code and you can view the invitation instantly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: welcomeTextColor.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class GuestPillInput extends StatelessWidget {
  const GuestPillInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: welcomeTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFFDF6F8),
            prefixIcon: Icon(prefixIcon, color: welcomePrimaryDeepColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: welcomePrimaryDeepColor.withValues(alpha: 0.14),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: welcomePrimaryDeepColor.withValues(alpha: 0.14),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(
                color: welcomePrimaryDeepColor,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GuestCodePreview extends StatelessWidget {
  const GuestCodePreview({super.key, required this.codeText});

  final String codeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE7EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2_rounded, color: welcomePrimaryDeepColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              codeText,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: welcomeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuestInfoBanner extends StatelessWidget {
  const GuestInfoBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: welcomeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuestInvitationCard extends StatelessWidget {
  const GuestInvitationCard({
    super.key,
    required this.invitation,
    required this.busy,
    required this.decision,
    required this.onAccept,
    required this.onReject,
    required this.onReset,
  });

  final GuestInvitation invitation;
  final bool busy;
  final GuestDecision decision;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReset;

  String _formatDate(String rawValue) {
    if (rawValue.trim().isEmpty) return 'To be announced';

    final normalized = rawValue.trim();
    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) {
      return DateFormat('d MMMM y').format(parsed.toLocal());
    }

    return normalized;
  }

  String _formatTime(String rawValue) {
    if (rawValue.trim().isEmpty) return 'To be announced';

    final normalized = rawValue.trim();
    final parsed = DateTime.tryParse('1970-01-01T$normalized');
    if (parsed != null) {
      return DateFormat('h:mm a').format(parsed.toLocal());
    }

    final timeOnly = DateFormat('HH:mm').tryParse(normalized);
    if (timeOnly != null) {
      return DateFormat('h:mm a').format(timeOnly);
    }

    return normalized;
  }

  String _formatPax(int? paxCount) {
    if (paxCount == null || paxCount <= 0) return 'Pax not set';
    return paxCount == 1 ? '1 Guest' : '$paxCount Guests';
  }

  @override
  Widget build(BuildContext context) {
    final isRsvpConfirmed = invitation.rsvpStatus.toLowerCase() == 'confirmed';
    final isAccepted = invitation.checkedIn || isRsvpConfirmed;
    final guestName = invitation.guestName.trim();
    final paxText = _formatPax(invitation.paxCount);
    final cachedCouple =
        AppSessionCache.instance.coupleDetail ?? <String, dynamic>{};

    // Try to extract wedding date/time directly from the raw payload as a
    // last-resort fallback (handles shapes like `data.wedding.date` etc.).
    final Map<String, dynamic> raw = invitation.raw;

    String? readNested(List<String> keys) {
      dynamic cur = raw;
      for (final k in keys) {
        if (cur is Map && cur.containsKey(k)) {
          cur = cur[k];
        } else {
          return null;
        }
      }
      if (cur == null) return null;
      return cur.toString();
    }

    final rawWeddingDate =
        readNested(['data', 'wedding', 'date']) ??
        readNested(['wedding', 'date']) ??
        readNested(['data', 'wedding_date']) ??
        readNested(['wedding_date']) ??
        readNested(['data', 'couple', 'wedding_date']) ??
        readNested(['couple', 'wedding_date']);

    final rawWeddingTime =
        readNested(['data', 'wedding', 'time']) ??
        readNested(['wedding', 'time']) ??
        readNested(['data', 'wedding_time']) ??
        readNested(['wedding_time']) ??
        readNested(['data', 'couple', 'wedding_time']) ??
        readNested(['couple', 'wedding_time']);

    final weddingDateSource = invitation.weddingDate.isNotEmpty
        ? invitation.weddingDate
        : (rawWeddingDate ??
              cachedCouple['wedding_date']?.toString() ??
              cachedCouple['weddingDate']?.toString() ??
              '');

    final weddingTimeSource = invitation.weddingTime.isNotEmpty
        ? invitation.weddingTime
        : (rawWeddingTime ??
              cachedCouple['wedding_time']?.toString() ??
              cachedCouple['weddingTime']?.toString() ??
              '');

    final weddingDate = _formatDate(weddingDateSource);
    final weddingTime = _formatTime(weddingTimeSource);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFFFF1F5),
            const Color(0xFFFCE7EC).withValues(alpha: 0.55),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: welcomePrimaryDeepColor.withValues(alpha: 0.10),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      welcomePrimaryDeepColor,
                      welcomePrimaryColor.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation.title,
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invitation.coupleName.isNotEmpty
                                    ? invitation.coupleName
                                    : 'WedPlan Invitation',
                                style: GoogleFonts.manrope(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.90),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GuestStatusChip(
                          checkedIn: invitation.checkedIn,
                          rsvpStatus: invitation.rsvpStatus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CardPill(
                          icon: Icons.event_rounded,
                          label: weddingDate,
                        ),
                        _CardPill(
                          icon: Icons.schedule_rounded,
                          label: weddingTime,
                        ),
                        _CardPill(icon: Icons.groups_rounded, label: paxText),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: welcomePrimaryDeepColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invitation details',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: welcomeTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GuestInfoRow(
                      label: 'Guest',
                      value: guestName.isNotEmpty
                          ? guestName
                          : 'Guest name not set',
                    ),
                    GuestInfoRow(
                      label: 'Wedding venue',
                      value: invitation.venue,
                    ),
                    GuestInfoRow(label: 'Event', value: invitation.eventName),
                    GuestInfoRow(
                      label: 'Invitation code',
                      value: invitation.code,
                    ),
                    if (invitation.message.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        invitation.message,
                        style: GoogleFonts.manrope(
                          fontSize: 13.5,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: welcomeTextColor.withValues(alpha: 0.80),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (decision == GuestDecision.accepted || isAccepted)
                _StatusPanel(
                  color: Colors.green,
                  icon: Icons.verified_rounded,
                  title: 'Invitation accepted successfully',
                  message:
                      'Your RSVP has been recorded. You can rescan or enter another code using Load another invitation.',
                )
              else if (invitation.checkedIn)
                _StatusPanel(
                  color: Colors.green,
                  icon: Icons.verified_rounded,
                  title: 'Checked in successfully',
                  message:
                      'This invitation is already marked as checked in. Keep this screen handy at the entrance.',
                )
              else if (decision == GuestDecision.rejected)
                _StatusPanel(
                  color: Colors.redAccent,
                  icon: Icons.close_rounded,
                  title: 'Invitation rejected',
                  message:
                      'You can load another invitation or scan a different QR code anytime.',
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (guestName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: welcomePrimaryDeepColor.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.badge_rounded,
                                size: 18,
                                color: welcomePrimaryDeepColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Guest name: $guestName',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: welcomeTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: busy ? null : onAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: welcomePrimaryDeepColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded, size: 20),
                              label: Text(
                                busy ? 'Processing' : 'Accept',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: busy ? null : onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: BorderSide(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              label: Text(
                                'Reject',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: busy ? null : onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    decision == GuestDecision.accepted || isAccepted
                        ? 'Rescan or enter another code'
                        : 'Load another invitation',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPill extends StatelessWidget {
  const _CardPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: welcomeTextColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GuestInfoRow extends StatelessWidget {
  const GuestInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: welcomeTextColor.withValues(alpha: 0.64),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: welcomeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuestStatusChip extends StatelessWidget {
  const GuestStatusChip({
    super.key,
    required this.checkedIn,
    required this.rsvpStatus,
  });

  final bool checkedIn;
  final String rsvpStatus;

  @override
  Widget build(BuildContext context) {
    final normalized = rsvpStatus.trim().toLowerCase();
    final isConfirmed = normalized == 'confirmed';

    final String label;
    final Color textColor;
    final Color backgroundColor;
    final Color borderColor;
    final IconData? icon;
    final bool isAccepted;

    if (checkedIn) {
      label = 'Checked In';
      textColor = Colors.green.shade800;
      backgroundColor = Colors.green.withValues(alpha: 0.16);
      borderColor = Colors.green.withValues(alpha: 0.40);
      icon = Icons.verified_rounded;
      isAccepted = false;
    } else if (isConfirmed) {
      label = 'Accepted';
      textColor = Colors.white;
      backgroundColor = const Color(0xFF4CAF50);
      borderColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_rounded;
      isAccepted = true;
    } else {
      label = 'Pending';
      textColor = welcomeTextColor;
      backgroundColor = Colors.white.withValues(alpha: 0.88);
      borderColor = welcomePrimaryDeepColor.withValues(alpha: 0.32);
      icon = null;
      isAccepted = false;
    }

    return Container(
      padding: isAccepted
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: isAccepted ? 2 : 1),
        borderRadius: BorderRadius.circular(999),
        boxShadow: isAccepted
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isAccepted ? 16 : 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: isAccepted ? 12 : 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
