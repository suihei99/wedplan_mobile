import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/guest/guest_invitation.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_invitation_view_model.dart';
import 'package:wedplan_mobile/views/guest/guest_invitation_card.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class GuestInvitationScreen extends StatefulWidget {
  const GuestInvitationScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<GuestInvitationScreen> createState() => _GuestInvitationScreenState();
}

class _GuestInvitationScreenState extends State<GuestInvitationScreen> {
  final _codeController = TextEditingController();
  bool _scannedOnce = false;
  GuestEntryMode _entryMode = GuestEntryMode.scan;
  GuestDecision _decision = GuestDecision.undecided;
  bool _initialCodeLoaded = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onInputChanged);

    final initialCode = widget.initialCode?.trim();
    if (initialCode != null && initialCode.isNotEmpty) {
      _entryMode = GuestEntryMode.code;
      _codeController.text = initialCode;
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onInputChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInvitation(GuestInvitationViewModel vm) async {
    try {
      await vm.loadInvitation(_codeController.text);
      if (!mounted) return;
      setState(() {
        _decision = GuestDecision.undecided;
      });
    } catch (_) {}
  }

  Future<void> _acceptInvitation(GuestInvitationViewModel vm) async {
    try {
      await vm.updateRsvp(
        'confirmed',
        guestName: vm.invitation?.guestName ?? '',
      );
      if (!mounted) return;
      setState(() {
        _decision = GuestDecision.accepted;
      });
    } catch (_) {}
  }

  String _normalizeScannedCode(String raw) {
    final trimmed = raw.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.hasScheme || uri.host.isNotEmpty)) {
      final qp = uri.queryParameters;
      if (qp.containsKey('code') && qp['code']!.trim().isNotEmpty) {
        return qp['code']!.trim();
      }
      if (qp.containsKey('q') && qp['q']!.trim().isNotEmpty) {
        return qp['q']!.trim();
      }
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.last.trim();
    }

    final idx = trimmed.lastIndexOf('/');
    if (idx >= 0 && idx < trimmed.length - 1) {
      return trimmed.substring(idx + 1).trim();
    }

    return trimmed;
  }

  Future<void> _rejectInvitation(GuestInvitationViewModel vm) async {
    try {
      await vm.updateRsvp(
        'declined',
        guestName: vm.invitation?.guestName ?? '',
      );
      if (!mounted) return;
      setState(() {
        _decision = GuestDecision.rejected;
      });
    } catch (_) {}
  }

  void _resetFlow(GuestInvitationViewModel vm) {
    vm.clear();
    setState(() {
      _decision = GuestDecision.undecided;
      _entryMode = GuestEntryMode.scan;
      _scannedOnce = false;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scannerHeight = (MediaQuery.of(context).size.height * 0.38).clamp(
      250.0,
      340.0,
    );

    return ChangeNotifierProvider(
      create: (_) => GuestInvitationViewModel(),
      child: Consumer<GuestInvitationViewModel>(
        builder: (context, vm, _) {
          final initialCode = widget.initialCode?.trim();
          if (!_initialCodeLoaded &&
              initialCode != null &&
              initialCode.isNotEmpty &&
              vm.invitation == null &&
              !vm.busy) {
            _initialCodeLoaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                unawaited(_loadInvitation(vm));
              }
            });
          }

          final GuestInvitation? invitation = vm.invitation;
          final bool showLoading = vm.busy && invitation == null;

          return Scaffold(
            backgroundColor: welcomeBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: welcomeTextColor,
              elevation: 0,
              titleSpacing: 0,
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/WebPlan_logo.webp',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Guest Invitation',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GuestHeaderCard(
                          title: 'Open invitation without login',
                          subtitle:
                              'First choose Scan QR or Enter Code. After load, accept or reject; if already accepted, rescan or enter another code.',
                          icon: Icons.local_activity_rounded,
                        ),
                        const SizedBox(height: 16),
                        GuestMethodSelector(
                          selectedMode: _entryMode,
                          enabled: invitation == null,
                          onChanged: (mode) {
                            if (invitation != null) return;
                            setState(() {
                              _entryMode = mode;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: invitation == null
                              ? GuestEntryCard(
                                  key: ValueKey(_entryMode),
                                  mode: _entryMode,
                                  scannerHeight: scannerHeight,
                                  codeController: _codeController,
                                  busy: vm.busy,
                                  onCodeDetected: (code) {
                                    if (_scannedOnce) return;
                                    _scannedOnce = true;
                                    final normalized = _normalizeScannedCode(
                                      code,
                                    );
                                    _codeController.text = normalized;
                                    unawaited(_loadInvitation(vm));
                                    Future<void>.delayed(
                                      const Duration(milliseconds: 900),
                                      () {
                                        if (mounted) {
                                          _scannedOnce = false;
                                        }
                                      },
                                    );
                                  },
                                  onLoad: () => _loadInvitation(vm),
                                )
                              : GuestInvitationCard(
                                  key: ValueKey(
                                    '${invitation.invitationId}_${_decision.name}_${invitation.checkedIn}',
                                  ),
                                  invitation: invitation,
                                  busy: vm.busy,
                                  decision: _decision,
                                  onAccept: () => _acceptInvitation(vm),
                                  onReject: () => _rejectInvitation(vm),
                                  onReset: () => _resetFlow(vm),
                                ),
                        ),
                        const SizedBox(height: 16),
                        if (vm.error != null) ...[
                          GuestInfoBanner(
                            icon: Icons.error_outline_rounded,
                            color: Colors.redAccent,
                            message: vm.error!,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (invitation == null)
                          GuestInfoBanner(
                            icon: Icons.badge_rounded,
                            color: welcomePrimaryDeepColor,
                            message:
                                'When QR/code is valid, we show the invitation card where guests can RSVP for check-in.',
                          ),
                      ],
                    ),
                  ),
                  if (showLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.72),
                        child: const GuestInvitationLoadingView(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
