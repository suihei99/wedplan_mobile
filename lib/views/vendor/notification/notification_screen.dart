import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/vendor/vendor_notification_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorNotificationScreen extends StatefulWidget {
  const VendorNotificationScreen({super.key});

  @override
  State<VendorNotificationScreen> createState() =>
      _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> {
  late final VendorNotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VendorNotificationViewModel()..load();
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
      child: Consumer<VendorNotificationViewModel>(
        builder: (context, vm, _) {
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
                    'Notifications',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Keep track of booking and service updates.',
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
                  onPressed: () => vm.load(forceRefresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: welcomePrimaryDeepColor,
                onRefresh: () => vm.load(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    _HeroCard(vm: vm),
                    const SizedBox(height: 14),
                    if (vm.busy && vm.notifications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (vm.notifications.isEmpty)
                      const _EmptyState(
                        title: 'No notifications yet',
                        subtitle:
                            'Vendor alerts and booking updates will appear here.',
                      )
                    else
                      ...vm.notifications.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(
                            item: item,
                            onTap: () => vm.markAsRead(item),
                            onDelete: () => vm.removeNotification(item),
                          ),
                        ),
                      ),
                    if (vm.error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: vm.error!),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.vm});

  final VendorNotificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4F7), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFDCE0)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFFE04F6D),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vm.unreadCount} unread',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'API-backed alerts for bookings and service changes.',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C6B71),
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

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = _readString(item, const ['title', 'subject']);
    final message = _readString(item, const ['message', 'body', 'description']);
    final status = _readString(item, const ['type', 'category']);
    final isRead = _readString(item, const ['read_at']).isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFDCE0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE0E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isRead
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: const Color(0xFFE04F6D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title.isNotEmpty ? title : 'Notification',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (status.isNotEmpty) _StatusChip(label: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.isNotEmpty
                        ? message
                        : 'Open the notification to view details.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onTap,
                        child: Text(isRead ? 'Viewed' : 'Mark as read'),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEFDCE0)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFFE04F6D),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
        ],
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

String _readString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}
