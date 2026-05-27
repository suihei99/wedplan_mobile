import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/vendor/vendor_me_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/me/setting/profile_view_screen.dart';
import 'package:wedplan_mobile/views/vendor/me/setting/reset_password_screen.dart';
import 'package:wedplan_mobile/views/welcome.dart';

class VendorMeScreen extends StatefulWidget {
  const VendorMeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<VendorMeScreen> createState() => _VendorMeScreenState();
}

class _VendorMeScreenState extends State<VendorMeScreen> {
  late final VendorMeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VendorMeViewModel()..load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<VendorMeViewModel>(
        builder: (context, vm, _) {
          final content = _MeContent(
            vm: vm,
            embedded: widget.embedded,
            onOpenProfile: () => _openProfile(context, vm),
            onOpenPassword: () => _openPassword(context, vm),
            onLogout: () => _confirmLogout(context, vm),
          );
          final body = RefreshIndicator(
            color: welcomePrimaryDeepColor,
            onRefresh: () => vm.load(forceRefresh: true),
            child: content,
          );

          if (widget.embedded) {
            return body;
          }

          return Scaffold(
            backgroundColor: welcomeBackgroundColor,
            appBar: AppBar(
              backgroundColor: welcomeBackgroundColor,
              foregroundColor: welcomeTextColor,
              elevation: 0,
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Me',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Manage your vendor account and business profile.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkResponse(
                    onTap: () => vm.load(forceRefresh: true),
                    radius: 22,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEFDCE0)),
                      ),
                      child: const Icon(Icons.refresh_rounded, size: 22),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(child: body),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openProfile(context, vm),
              backgroundColor: const Color(0xFFE04F6D),
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
              label: Text(
                'Edit Profile',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openProfile(BuildContext context, VendorMeViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const ProfileViewScreen(),
        ),
      ),
    );
  }

  void _openPassword(BuildContext context, VendorMeViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const ResetPasswordScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    VendorMeViewModel vm,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('You will return to the welcome screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await vm.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error ?? 'Logout failed')));
    }
  }
}

class _MeContent extends StatelessWidget {
  const _MeContent({
    required this.vm,
    required this.embedded,
    required this.onOpenProfile,
    required this.onOpenPassword,
    required this.onLogout,
  });

  final VendorMeViewModel vm;
  final bool embedded;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenPassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF4F5),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18, 16, 18, embedded ? 24 : 88),
        children: [
          _ProfileCard(vm: vm, onTap: onOpenProfile),
          const SizedBox(height: 14),
          if (vm.error != null) ...[
            _ErrorBanner(message: vm.error!),
            const SizedBox(height: 14),
          ],
          _MenuSection(
            title: 'Business Profile',
            items: [
              _MenuRow(
                icon: Icons.badge_outlined,
                label: 'Edit Profile',
                description: 'Update business details and documents',
                onTap: onOpenProfile,
              ),
              _MenuRow(
                icon: Icons.lock_rounded,
                label: 'Change Password',
                description: 'Protect your vendor account',
                onTap: onOpenPassword,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Business Details',
            children: [
              _InfoTile(
                label: 'Business type',
                value: vm.businessType.isNotEmpty ? vm.businessType : 'Not set',
              ),
              _InfoTile(
                label: 'Contact',
                value: vm.contactNumber.isNotEmpty
                    ? vm.contactNumber
                    : 'Not set',
              ),
              _InfoTile(
                label: 'Address',
                value: vm.address.isNotEmpty ? vm.address : 'Not set',
              ),
              _InfoTile(
                label: 'Email',
                value: vm.email.isNotEmpty ? vm.email : 'Not set',
              ),
              _InfoTile(
                label: 'Role',
                value: vm.role.isNotEmpty ? vm.role : 'vendor',
              ),
              _InfoTile(
                label: 'Documents',
                value: vm.hasBusinessDocument ? 'Uploaded' : 'Not uploaded',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MenuSection(
            title: 'Session',
            items: [
              _MenuRow(
                icon: Icons.logout_rounded,
                label: 'Logout',
                description: 'Sign out from this device',
                onTap: onLogout,
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.vm, required this.onTap});

  final VendorMeViewModel vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE8EE), Color(0xFFFFF7FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF4D8DF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(vm: vm),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.businessName,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.summaryLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6F6468),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(label: vm.statusLabel),
                        _StatusChip(label: 'Services ${vm.totalServices}'),
                        _StatusChip(label: 'Bookings ${vm.totalBookings}'),
                        _StatusChip(
                          label: vm.hasBusinessDocument
                              ? 'Document ready'
                              : 'No document',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.vm});

  final VendorMeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFCE0E5),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: vm.hasProfilePhoto
              ? Image.network(
                  vm.profilePhotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallback(vm: vm),
                )
              : _AvatarFallback(vm: vm),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFE04F6D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.vm});

  final VendorMeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        vm.initials,
        style: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE04F6D),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8D7C83),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? const Color(0xFFC94B4B) : const Color(0xFFE04F6D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: danger
                            ? const Color(0xFFC94B4B)
                            : const Color(0xFF21161A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: danger
                    ? const Color(0xFFC94B4B)
                    : const Color(0xFF8C7980),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF7C6B71),
              ),
            ),
          ),
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.only(left: 56),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF4E4E8),
                ),
              ),
            items[index],
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE0E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE04F6D),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4C5CE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFE04F6D)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
