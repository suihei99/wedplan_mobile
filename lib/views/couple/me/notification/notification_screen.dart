import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/couple/notification_view_model.dart';
import 'package:wedplan_mobile/views/couple/me/notification/widgets/notification_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationViewModel()..load();
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
      child: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
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
                    'Notifications',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'A calm, mobile inbox for wedding planning updates.',
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
                    onPressed: () => vm.load(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFFE04F6D),
                onRefresh: () => vm.load(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    NotificationHeroCard(vm: vm),
                    const SizedBox(height: 16),
                    NotificationActionBar(
                      onMarkAllRead: vm.markAllAsRead,
                      onRefresh: () => vm.load(forceRefresh: true),
                    ),
                    const SizedBox(height: 16),
                    NotificationSearchBar(vm: vm),
                    const SizedBox(height: 12),
                    NotificationFilterChips(vm: vm),
                    const SizedBox(height: 16),
                    if (vm.busy && vm.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (vm.items.isEmpty)
                      NotificationEmptyState(
                        title: 'No notifications yet',
                        subtitle:
                            'New dashboard updates, task reminders, and guest activity will appear here.',
                      )
                    else
                      ...vm.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NotificationCard(
                            item: item,
                            onTap: () => vm.markAsRead(item.id),
                            onMarkRead: () => vm.markAsRead(item.id),
                            onDelete: () => vm.removeItem(item.id),
                          ),
                        ),
                      ),
                    if (vm.error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: vm.error!),
                    ],
                    const SizedBox(height: 8),
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
