import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/viewmodels/couple/me_view_model.dart';
import 'package:wedplan_mobile/views/welcome.dart';
import 'package:wedplan_mobile/views/couple/me/ai_budget/ai_budget_screen.dart';
import 'package:wedplan_mobile/views/couple/me/setting/change_password_screen.dart';
import 'package:wedplan_mobile/views/couple/me/setting/couple_view_screen.dart';
import 'package:wedplan_mobile/views/couple/navbar/navbar.dart';
import 'package:wedplan_mobile/views/couple/task/task_screen.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  late final MeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MeViewModel()..load();
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
      child: Consumer<MeViewModel>(
        builder: (context, vm, _) {
          final content = _MeContent(
            profile: vm.profile,
            vm: vm,
            onOpenAiBudget: () => _openAiBudget(context),
            onOpenProfile: () => _openProfile(context, vm),
            onOpenPassword: () => _openPassword(context, vm),
            onLogout: () => _confirmLogout(context, vm),
          );

          if (widget.embedded) {
            return content;
          }

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
                    'Me',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Account, budget intelligence, and security in one polished space.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(child: content),
            bottomNavigationBar: CoupleNavbar(
              currentIndex: 4,
              onTap: (index) {
                if (index == 4) return;
                Navigator.of(context).maybePop();
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openTaskScreen(context),
              backgroundColor: const Color(0xFFE04F6D),
              icon: const Icon(Icons.checklist_rounded, color: Colors.white),
              label: Text(
                'Tasklist',
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

  void _openTaskScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TaskScreen()));
  }

  void _openAiBudget(BuildContext context) {
    final vm = context.read<MeViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const AiBudgetScreen(),
        ),
      ),
    );
  }

  void _openProfile(BuildContext context, MeViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const CoupleViewScreen(),
        ),
      ),
    );
  }

  void _openPassword(BuildContext context, MeViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const ChangePasswordScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, MeViewModel vm) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('You will be returned to the welcome screen.'),
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
    required this.profile,
    required this.vm,
    required this.onOpenAiBudget,
    required this.onOpenProfile,
    required this.onOpenPassword,
    required this.onLogout,
  });

  final CoupleMeProfile? profile;
  final MeViewModel vm;
  final VoidCallback onOpenAiBudget;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenPassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF4F5),
      child: RefreshIndicator(
        color: welcomePrimaryDeepColor,
        onRefresh: () => vm.load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            _ProfileHeader(profile: profile),
            const SizedBox(height: 14),
            if (vm.error != null) ...[
              _ErrorBanner(message: vm.error!),
              const SizedBox(height: 14),
            ],
            _MenuSection(
              title: 'My Profile',
              items: [
                _MenuRow(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Budget Estimate',
                  description: 'Get a quick budget pace suggestion',
                  onTap: onOpenAiBudget,
                ),
                _MenuRow(
                  icon: Icons.edit_note_rounded,
                  label: 'Edit Profile',
                  description: 'Update your couple details',
                  onTap: onOpenProfile,
                ),
                _MenuRow(
                  icon: Icons.lock_rounded,
                  label: 'Change Password',
                  description: 'Keep your account protected',
                  onTap: onOpenPassword,
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
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final CoupleMeProfile? profile;

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName ?? 'Your Couple Profile';
    final summary = profile?.weddingSummary ?? 'Wedding details coming soon';

    return Container(
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
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.person_rounded,
              color: const Color(0xFFE04F6D),
              size: profile == null ? 28 : 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF6F6468),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniChip(label: 'Guests ${profile?.guestCount ?? 0}'),
                    _MiniChip(
                      label:
                          'Budget RM ${(profile?.totalBudgetLimit ?? 0).toStringAsFixed(0)}',
                    ),
                    _MiniChip(
                      label:
                          'Tasks ${profile?.completedTasks ?? 0}/${profile?.totalTasks ?? 0}',
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

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
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
