import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/notification/notification_item.dart';
import 'package:wedplan_mobile/viewmodels/couple/notification_view_model.dart';

class NotificationHeroCard extends StatelessWidget {
  const NotificationHeroCard({super.key, required this.vm});

  final NotificationViewModel vm;

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
              'COUPLE ACTIVITY CENTER',
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
            'Notifications',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF21161A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track planning updates from your dashboard in one focused mobile inbox.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF6F6468),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              NotificationMiniStat(
                label: 'Unread',
                value: vm.unreadCount.toString(),
              ),
              NotificationMiniStat(
                label: 'Total',
                value: vm.totalCount.toString(),
              ),
              NotificationMiniStat(
                label: 'Tasks',
                value: vm.taskCount.toString(),
              ),
              NotificationMiniStat(
                label: 'Guests',
                value: vm.guestCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationActionBar extends StatelessWidget {
  const NotificationActionBar({
    super.key,
    required this.onMarkAllRead,
    required this.onRefresh,
  });

  final VoidCallback onMarkAllRead;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onMarkAllRead,
            icon: const Icon(Icons.done_all_rounded),
            label: const Text('Mark all read'),
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

class NotificationSearchBar extends StatelessWidget {
  const NotificationSearchBar({super.key, required this.vm});

  final NotificationViewModel vm;

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
          hintText: 'Search notifications...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class NotificationFilterChips extends StatelessWidget {
  const NotificationFilterChips({super.key, required this.vm});

  final NotificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final items = <({NotificationFilterType type, String label})>[
      (type: NotificationFilterType.all, label: 'All'),
      (type: NotificationFilterType.unread, label: 'Unread'),
      (type: NotificationFilterType.task, label: 'Tasks'),
      (type: NotificationFilterType.guest, label: 'Guests'),
      (type: NotificationFilterType.budget, label: 'Budget'),
      (type: NotificationFilterType.vendor, label: 'Vendors'),
      (type: NotificationFilterType.general, label: 'General'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = vm.filter == item.type;

          return ChoiceChip(
            selected: selected,
            label: Text(item.label),
            onSelected: (_) => vm.updateFilter(item.type),
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

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  final CoupleNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(item.type);

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: Icon(_iconForType(item.type), color: accent)),
                  if (!item.isRead)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Color(0xFFE04F6D),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF21161A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.createdAtLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9A858B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6F6468),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatusPill(label: item.actionLabel, color: accent),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'read') onMarkRead();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'read',
                            enabled: !item.isRead,
                            child: const Text('Mark as read'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
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

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({
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
            Icons.notifications_none_rounded,
            size: 42,
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

class NotificationMiniStat extends StatelessWidget {
  const NotificationMiniStat({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

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
        label.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

IconData _iconForType(CoupleNotificationType type) {
  return switch (type) {
    CoupleNotificationType.task => Icons.checklist_rounded,
    CoupleNotificationType.guest => Icons.group_rounded,
    CoupleNotificationType.budget => Icons.account_balance_wallet_rounded,
    CoupleNotificationType.vendor => Icons.storefront_rounded,
    CoupleNotificationType.general => Icons.notifications_none_rounded,
  };
}

Color _accentColor(CoupleNotificationType type) {
  return switch (type) {
    CoupleNotificationType.task => const Color(0xFFC94B4B),
    CoupleNotificationType.guest => const Color(0xFF5B7CFF),
    CoupleNotificationType.budget => const Color(0xFFC58B1D),
    CoupleNotificationType.vendor => const Color(0xFF2E8B57),
    CoupleNotificationType.general => const Color(0xFFE04F6D),
  };
}
