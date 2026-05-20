import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_management_view_model.dart';

class GuestListAddScreen extends StatefulWidget {
  const GuestListAddScreen({super.key, this.guestId});

  final String? guestId;

  @override
  State<GuestListAddScreen> createState() => _GuestListAddScreenState();
}

class _GuestListAddScreenState extends State<GuestListAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _paxController = TextEditingController();
  GuestFilterStatus _status = GuestFilterStatus.pending;
  bool _initialised = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _paxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<GuestManagementViewModel>(context);
    final guest = widget.guestId == null ? null : vm.guestById(widget.guestId!);

    if (!_initialised && guest != null) {
      _initialised = true;
      _nameController.text = guest.name;
      _phoneController.text = guest.phone;
      _paxController.text = guest.paxCount.toString();
      _status = switch (guest.rsvpStatus.toLowerCase()) {
        'confirmed' => GuestFilterStatus.confirmed,
        'declined' => GuestFilterStatus.declined,
        _ => GuestFilterStatus.pending,
      };
    }

    final isEditing = guest != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Guest' : 'Add Guest',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _IntroCard(isEditing: isEditing),
              const SizedBox(height: 16),
              _FieldCard(
                child: TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Guest name',
                    hintText: 'Enter guest full name',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Guest name is required'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+60123456789',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Phone number is required'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: TextFormField(
                  controller: _paxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pax count',
                    hintText: 'Number of attendees',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid pax count';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: DropdownButtonFormField<GuestFilterStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'RSVP status'),
                  items: const [
                    DropdownMenuItem(
                      value: GuestFilterStatus.pending,
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: GuestFilterStatus.confirmed,
                      child: Text('Confirmed'),
                    ),
                    DropdownMenuItem(
                      value: GuestFilterStatus.declined,
                      child: Text('Declined'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: vm.busy
                    ? null
                    : () => _saveGuest(context, vm, isEditing ? guest : null),
                icon: vm.busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Update Guest' : 'Save Guest'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE04F6D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Invite codes, QR strings, and WhatsApp sharing are generated from the guest record after save.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xFF7C6B71),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGuest(
    BuildContext context,
    GuestManagementViewModel vm,
    Guest? guest,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final status = switch (_status) {
      GuestFilterStatus.confirmed => 'confirmed',
      GuestFilterStatus.declined => 'declined',
      GuestFilterStatus.pending => 'pending',
      GuestFilterStatus.all => 'pending',
    };

    try {
      if (guest == null) {
        await vm.createGuest(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          paxCount: int.parse(_paxController.text.trim()),
          rsvpStatus: status,
        );
      } else {
        await vm.updateGuest(
          id: guest.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          paxCount: int.parse(_paxController.text.trim()),
          rsvpStatus: status,
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(guest == null ? 'Guest added' : 'Guest updated'),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error ?? 'Failed')));
    }
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEDF2), Color(0xFFFFF8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4D8DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Update a guest record' : 'Create a new guest record',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This form follows the authenticated couple guest API: name, phone, pax count, and RSVP status.',
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

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: child,
    );
  }
}
