import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_management_view_model.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_add_screen.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_view_screen.dart';
import 'package:wedplan_mobile/views/couple/guest/widgets/guestlist_widgets.dart';
import 'package:wedplan_mobile/views/couple/navbar/navbar.dart';
import 'package:wedplan_mobile/views/couple/task/task_screen.dart';

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
                GuestListHeroCard(vm: vm),
                const SizedBox(height: 16),
                GuestActionBar(
                  onAddGuest: () => _openGuestEditor(context, null),
                  onRefresh: () => vm.loadGuests(forceRefresh: true),
                ),
                const SizedBox(height: 16),
                GuestSearchBar(vm: vm),
                const SizedBox(height: 12),
                GuestFilterChips(vm: vm),
                const SizedBox(height: 16),
                if (vm.busy && vm.guests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (vm.filteredGuests.isEmpty)
                  GuestEmptyState(
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
                      child: GuestCard(
                        guest: guest,
                        onTap: () => _openGuestDetails(context, guest),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _refresh(context),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(child: content),
      bottomNavigationBar: CoupleNavbar(
        currentIndex: _navIndex,
        onTap: (index) => _handleNavTap(context, index),
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

  void _openTaskScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TaskScreen()));
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
        return RsvpSheet(
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
