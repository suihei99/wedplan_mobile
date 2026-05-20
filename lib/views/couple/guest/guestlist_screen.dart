import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_management_view_model.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_add_screen.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_view_screen.dart';
import 'package:wedplan_mobile/views/couple/navbar/navbar.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  late final GuestManagementViewModel _viewModel;
  int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    _viewModel = GuestManagementViewModel()..loadGuests();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<GuestManagementViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            onRefresh: () => vm.loadGuests(forceRefresh: true),
            color: const Color(0xFFE04F6D),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _GuestHeroCard(vm: vm),
                const SizedBox(height: 16),
                _ActionBar(
                  onAddGuest: () => _openGuestEditor(context, null),
                  onRefresh: () => vm.loadGuests(forceRefresh: true),
                ),
                const SizedBox(height: 16),
                _GuestSearchBar(vm: vm),
                const SizedBox(height: 12),
                _GuestFilterChips(vm: vm),
                const SizedBox(height: 16),
                if (vm.busy && vm.guests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (vm.filteredGuests.isEmpty)
                  _GuestEmptyState(
                    title: vm.searchQuery.trim().isEmpty
                        ? 'No guests yet'
                        : 'No guest matches your search',
                    subtitle: vm.searchQuery.trim().isEmpty
                        ? 'Add your first guest and generate an invite code for WhatsApp sharing.'
                        : 'Try a different name, phone number, or invite code.',
                  )
                else
                  ...vm.filteredGuests.map(
                    (guest) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GuestCard(
                        guest: guest,
                        onTap: () => _openGuestDetails(context, guest),
                        onCheckIn: () => _runGuestAction(
                          context,
                          () => vm.checkInGuest(guest.id),
                          successMessage: '${guest.name} checked in',
                        ),
                        onRsvp: () => _openQuickRsvp(context, guest),
                        onEdit: () => _openGuestEditor(context, guest),
                        onDelete: () => _confirmDelete(context, vm, guest),
                      ),
                    ),
                  ),
                const SizedBox(height: 88),
              ],
            ),
          );
        },
      ),
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
              'Guest Management',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Manage invitations, RSVP, and check-ins from your phone.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7C6B71),
              ),
            ),
          ],
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12),
        //     child: IconButton(
        //       onPressed: () => _refresh(context),
        //       icon: const Icon(Icons.refresh_rounded),
        //     ),
        //   ),
        // ],
      ),
      body: SafeArea(child: content),
      bottomNavigationBar: CoupleNavbar(
        currentIndex: _navIndex,
        onTap: (index) => _handleNavTap(context, index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGuestEditor(context, null),
        backgroundColor: const Color(0xFFE04F6D),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text(
          'Add Guest',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    await _viewModel.loadGuests(forceRefresh: true);
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == _navIndex) return;

    if (index == 0) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _navIndex = index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$index section is ready for routing.')),
    );
  }

  void _openGuestDetails(BuildContext context, Guest guest) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: GuestListViewScreen(guestId: guest.id),
        ),
      ),
    );
  }

  void _openGuestEditor(BuildContext context, Guest? guest) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: GuestListAddScreen(guestId: guest?.id),
        ),
      ),
    );
  }

  void _openQuickRsvp(BuildContext context, Guest guest) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _RsvpSheet(
          guest: guest,
          onSelected: (status) async {
            Navigator.of(sheetContext).pop();
            await _runGuestAction(
              context,
              () => _viewModel.updateRsvp(guest.id, status),
              successMessage: '${guest.name} marked as $status',
            );
          },
        );
      },
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

    await _runGuestAction(
      context,
      () => vm.deleteGuest(guest.id),
      successMessage: '${guest.name} deleted',
    );
  }

  Future<void> _runGuestAction(
    BuildContext context,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.error ?? 'Failed')));
    }
  }
}

class _GuestHeroCard extends StatelessWidget {
  const _GuestHeroCard({required this.vm});

  final GuestManagementViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEFF3), Color(0xFFFFF8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4D8DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF0CAD4)),
            ),
            child: Text(
              'WEDDING GUEST COORDINATION',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: const Color(0xFFE04F6D),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Guest Management',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF21161A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep track of your guest list, share invite codes on WhatsApp, and handle RSVP or check-in from one screen.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF6F6468),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onAddGuest, required this.onRefresh});

  final VoidCallback onAddGuest;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onAddGuest,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add Guest'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE04F6D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: onRefresh,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0DDE1)),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8C7980),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE04F6D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestSearchBar extends StatelessWidget {
  const _GuestSearchBar({required this.vm});

  final GuestManagementViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: TextField(
        onChanged: vm.updateSearchQuery,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded),
          hintText: 'Search guest name, contact, or invite code...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _GuestFilterChips extends StatelessWidget {
  const _GuestFilterChips({required this.vm});

  final GuestManagementViewModel vm;

  @override
  Widget build(BuildContext context) {
    final items = <({GuestFilterStatus status, String label})>[
      (status: GuestFilterStatus.all, label: 'All Status'),
      (status: GuestFilterStatus.pending, label: 'Pending'),
      (status: GuestFilterStatus.confirmed, label: 'Confirmed'),
      (status: GuestFilterStatus.declined, label: 'Declined'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = vm.statusFilter == item.status;

          return ChoiceChip(
            selected: selected,
            label: Text(item.label),
            onSelected: (_) => vm.updateStatusFilter(item.status),
            selectedColor: const Color(0xFFFFDCE4),
            labelStyle: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFFE04F6D)
                  : const Color(0xFF6F6468),
            ),
            side: BorderSide(
              color: selected
                  ? const Color(0xFFE04F6D)
                  : const Color(0xFFF0DDE1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({
    required this.guest,
    required this.onTap,
    required this.onCheckIn,
    required this.onRsvp,
    required this.onEdit,
    required this.onDelete,
  });

  final Guest guest;
  final VoidCallback onTap;
  final VoidCallback onCheckIn;
  final VoidCallback onRsvp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (guest.rsvpStatus.toLowerCase()) {
      'confirmed' => const Color(0xFF2E8B57),
      'declined' => const Color(0xFFC94B4B),
      _ => const Color(0xFFC58B1D),
    };

    final statusLabel = guest.rsvpStatus.isEmpty ? 'Pending' : guest.rsvpStatus;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0DDE1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.name.isEmpty ? 'Unnamed Guest' : guest.name,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF21161A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (guest.phone.isNotEmpty)
                        Text(
                          guest.phone,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7C6B71),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _GuestMetric(
                      label: 'Pax Count',
                      value: guest.paxCount.toString(),
                    ),
                  ),
                  Expanded(
                    child: _GuestMetric(
                      label: 'Invite Code',
                      value: guest.inviteCode.isEmpty ? '-' : guest.inviteCode,
                    ),
                  ),
                  Expanded(
                    child: _GuestMetric(
                      label: 'QR Ready',
                      value: guest.qrCodeString.isNotEmpty ? '✓' : '—',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 10),
                if (guest.isPending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRsvp,
                      icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                      label: const Text('RSVP'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCheckIn,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Check-In'),
                    ),
                  ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestMetric extends StatelessWidget {
  const _GuestMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8C7980),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF21161A),
          ),
        ),
      ],
    );
  }
}

class _GuestEmptyState extends StatelessWidget {
  const _GuestEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.group_off_rounded,
            size: 40,
            color: Color(0xFFE04F6D),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.45,
              color: const Color(0xFF6F6468),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpSheet extends StatelessWidget {
  const _RsvpSheet({required this.guest, required this.onSelected});

  final Guest guest;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5D7DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Update RSVP',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(guest.name, style: GoogleFonts.manrope(fontSize: 13)),
            const SizedBox(height: 14),
            _RsvpOption(
              title: 'Confirmed',
              subtitle: 'Guest accepted the invitation.',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF2E8B57),
              onTap: () => onSelected('confirmed'),
            ),
            const SizedBox(height: 10),
            _RsvpOption(
              title: 'Pending',
              subtitle: 'Keep this guest in the waiting state.',
              icon: Icons.schedule_rounded,
              color: const Color(0xFFC58B1D),
              onTap: () => onSelected('pending'),
            ),
            const SizedBox(height: 10),
            _RsvpOption(
              title: 'Declined',
              subtitle: 'Guest cannot attend the event.',
              icon: Icons.cancel_rounded,
              color: const Color(0xFFC94B4B),
              onTap: () => onSelected('declined'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RsvpOption extends StatelessWidget {
  const _RsvpOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF21161A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
      ),
    );
  }
}
