import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/guest/guest.dart';
import 'package:wedplan_mobile/viewmodels/guest/guest_management_view_model.dart';

class GuestListHeroCard extends StatelessWidget {
  const GuestListHeroCard({super.key, required this.vm});

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
          Row(
            children: [
              GuestMiniStat(label: 'Total', value: vm.totalGuests.toString()),
              const SizedBox(width: 10),
              GuestMiniStat(
                label: 'Confirmed',
                value: vm.confirmedCount.toString(),
              ),
              const SizedBox(width: 10),
              GuestMiniStat(
                label: 'Pending',
                value: vm.pendingCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GuestActionBar extends StatelessWidget {
  const GuestActionBar({
    super.key,
    required this.onAddGuest,
    required this.onRefresh,
  });

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

class GuestMiniStat extends StatelessWidget {
  const GuestMiniStat({super.key, required this.label, required this.value});

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

class GuestSearchBar extends StatelessWidget {
  const GuestSearchBar({super.key, required this.vm});

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

class GuestFilterChips extends StatelessWidget {
  const GuestFilterChips({super.key, required this.vm});

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

class GuestCard extends StatelessWidget {
  const GuestCard({
    super.key,
    required this.guest,
    required this.onTap,
    required this.onRsvp,
    required this.onEdit,
    required this.onDelete,
  });

  final Guest guest;
  final VoidCallback onTap;
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
                    child: GuestMetric(
                      label: 'Pax Count',
                      value: guest.paxCount.toString(),
                    ),
                  ),
                  Expanded(
                    child: GuestMetric(
                      label: 'Invite Code',
                      value: guest.inviteCode.isEmpty ? '-' : guest.inviteCode,
                    ),
                  ),
                  Expanded(
                    child: GuestMetric(
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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRsvp,
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                    label: const Text('RSVP'),
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

class GuestMetric extends StatelessWidget {
  const GuestMetric({super.key, required this.label, required this.value});

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

class GuestEmptyState extends StatelessWidget {
  const GuestEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

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

class RsvpSheet extends StatelessWidget {
  const RsvpSheet({super.key, required this.guest, required this.onSelected});

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
            RsvpOption(
              title: 'Confirmed',
              subtitle: 'Guest accepted the invitation.',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF2E8B57),
              onTap: () => onSelected('confirmed'),
            ),
            const SizedBox(height: 10),
            RsvpOption(
              title: 'Pending',
              subtitle: 'Keep this guest in the waiting state.',
              icon: Icons.schedule_rounded,
              color: const Color(0xFFC58B1D),
              onTap: () => onSelected('pending'),
            ),
            const SizedBox(height: 10),
            RsvpOption(
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

class RsvpOption extends StatelessWidget {
  const RsvpOption({
    super.key,
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
