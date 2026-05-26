import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/vendor/vendor_dashboard_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/booking/booking_screen.dart';
import 'package:wedplan_mobile/views/vendor/me/me_screen.dart';
import 'package:wedplan_mobile/views/vendor/navbar/navbar.dart';
import 'package:wedplan_mobile/views/vendor/notification/notification_screen.dart';
import 'package:wedplan_mobile/views/vendor/service/service_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  late final VendorDashboardViewModel _viewModel;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = VendorDashboardViewModel()..load();
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
      child: Consumer<VendorDashboardViewModel>(
        builder: (context, vm, _) {
          final pages = <Widget>[
            _VendorDashboardHome(
              vm: vm,
              onOpenServiceTab: () => _handleNavTap(1),
              onOpenBookingTab: () => _handleNavTap(2),
              onOpenMeTab: () => _handleNavTap(3),
              onOpenNotifications: () => _openNotifications(context),
            ),
            const VendorServiceScreen(embedded: true),
            const VendorBookingScreen(embedded: true),
            const VendorMeScreen(embedded: true),
          ];

          final pageMeta = _pageMeta[_navIndex];

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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Text(
                      pageMeta.title,
                      key: ValueKey(pageMeta.title),
                      style: GoogleFonts.manrope(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      pageMeta.subtitle,
                      key: ValueKey(pageMeta.subtitle),
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6F6468),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkResponse(
                    onTap: () => _openNotifications(context),
                    radius: 22,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEFDCE0)),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: IndexedStack(
                key: ValueKey<int>(_navIndex),
                index: _navIndex,
                children: pages,
              ),
            ),
            bottomNavigationBar: VendorNavbar(
              currentIndex: _navIndex,
              onTap: _handleNavTap,
            ),
          );
        },
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VendorNotificationScreen()),
    );
  }

  void _handleNavTap(int index) {
    if (_navIndex == index) return;
    setState(() => _navIndex = index);
  }
}

class _TabMeta {
  const _TabMeta({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const List<_TabMeta> _pageMeta = <_TabMeta>[
  _TabMeta(
    title: 'Dashboard',
    subtitle: 'Monitor bookings, services, and business activity.',
  ),
  _TabMeta(
    title: 'Service',
    subtitle: 'Manage your vendor offerings from one mobile screen.',
  ),
  _TabMeta(
    title: 'Booking',
    subtitle: 'Track upcoming and completed client bookings.',
  ),
  _TabMeta(
    title: 'Me',
    subtitle: 'Review your account and business profile details.',
  ),
];

class _VendorDashboardHome extends StatelessWidget {
  const _VendorDashboardHome({
    required this.vm,
    required this.onOpenServiceTab,
    required this.onOpenBookingTab,
    required this.onOpenMeTab,
    required this.onOpenNotifications,
  });

  final VendorDashboardViewModel vm;
  final VoidCallback onOpenServiceTab;
  final VoidCallback onOpenBookingTab;
  final VoidCallback onOpenMeTab;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: welcomePrimaryDeepColor,
      onRefresh: () => vm.load(forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          _VendorHeroCard(vm: vm, onOpenNotifications: onOpenNotifications),
          const SizedBox(height: 14),
          _VendorMetricGrid(vm: vm),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Quick Actions',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionPill(
                  icon: Icons.storefront_rounded,
                  label: 'Services',
                  onTap: onOpenServiceTab,
                ),
                _ActionPill(
                  icon: Icons.event_available_rounded,
                  label: 'Bookings',
                  onTap: onOpenBookingTab,
                ),
                _ActionPill(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: onOpenMeTab,
                ),
                _ActionPill(
                  icon: Icons.notifications_none_rounded,
                  label: 'Inbox',
                  onTap: onOpenNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Upcoming Bookings',
            trailing: Text(
              '${vm.upcomingBookings.length} items',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE04F6D),
              ),
            ),
            child: _DashboardItemList(
              emptyMessage: 'No upcoming bookings found yet.',
              items: vm.upcomingBookings,
              itemBuilder: (item) => _BookingPreviewTile(item: item),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Top Services',
            trailing: Text(
              '${vm.featuredServices.length} items',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE04F6D),
              ),
            ),
            child: _DashboardItemList(
              emptyMessage: 'No service data returned yet.',
              items: vm.featuredServices,
              itemBuilder: (item) => _ServicePreviewTile(item: item),
            ),
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: vm.error!),
          ],
        ],
      ),
    );
  }
}

class _VendorHeroCard extends StatelessWidget {
  const _VendorHeroCard({required this.vm, required this.onOpenNotifications});

  final VendorDashboardViewModel vm;
  final VoidCallback onOpenNotifications;

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
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEFDCE0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB96B7D).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFCE0E5),
                  border: Border.all(color: const Color(0xFFF4C5CE)),
                ),
                alignment: Alignment.center,
                child: Text(
                  vm.initials,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE04F6D),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.businessName,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: welcomeTextColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vm.displayName,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(label: vm.statusLabel),
                        _StatusChip(label: '${vm.totalBookings} bookings'),
                        _StatusChip(label: '${vm.totalServices} services'),
                      ],
                    ),
                  ],
                ),
              ),
              InkResponse(
                onTap: onOpenNotifications,
                radius: 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEFDCE0)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded),
                      if (vm.unreadNotifications > 0)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE04F6D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            vm.summaryLabel,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6F6468),
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: vm.profileCompletionPercent / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: const Color(0xFFF4E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE04F6D)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${vm.profileCompletionPercent.toStringAsFixed(0)}% profile ready',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8D7C83),
                ),
              ),
              const Spacer(),
              Text(
                vm.statusHelper,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE04F6D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorMetricGrid extends StatelessWidget {
  const _VendorMetricGrid({required this.vm});

  final VendorDashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.42,
      children: [
        _MetricCard(
          label: 'Services',
          value: vm.totalServices.toString(),
          icon: Icons.storefront_rounded,
        ),
        _MetricCard(
          label: 'Bookings',
          value: vm.totalBookings.toString(),
          icon: Icons.event_available_rounded,
        ),
        _MetricCard(
          label: 'Pending',
          value: vm.pendingBookings.toString(),
          icon: Icons.hourglass_bottom_rounded,
        ),
        _MetricCard(
          label: 'Alerts',
          value: vm.unreadNotifications.toString(),
          icon: Icons.notifications_rounded,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEFDCE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFE04F6D)),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: welcomeTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7C6B71),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFDCE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: welcomeTextColor,
                ),
              ),
              const Spacer(),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DashboardItemList extends StatelessWidget {
  const _DashboardItemList({
    required this.items,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  final List<Map<String, dynamic>> items;
  final Widget Function(Map<String, dynamic> item) itemBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          emptyMessage,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7C6B71),
          ),
        ),
      );
    }

    final visibleItems = items.take(3).toList();
    return Column(
      children: [
        for (var index = 0; index < visibleItems.length; index++) ...[
          itemBuilder(visibleItems[index]),
          if (index < visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BookingPreviewTile extends StatelessWidget {
  const _BookingPreviewTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = _firstString([
      item['client_name'],
      item['customer_name'],
      item['couple_name'],
      item['title'],
    ], fallback: 'Booking');
    final subtitle = _firstString([
      item['service_name'],
      item['service'],
      item['booking_date'],
      item['date'],
    ], fallback: 'No date provided');
    final status = _firstString([
      item['status'],
      item['booking_status'],
      item['state'],
    ], fallback: 'Pending');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF4E1E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Color(0xFFE04F6D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C6B71),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusChip(label: status),
        ],
      ),
    );
  }
}

class _ServicePreviewTile extends StatelessWidget {
  const _ServicePreviewTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = _firstString([
      item['service_name'],
      item['name'],
      item['title'],
    ], fallback: 'Service');
    final subtitle = _firstString([
      item['type_service'],
      item['service_type'],
      item['category'],
    ], fallback: 'Service category');
    final price = _firstString([
      item['price_estimate'],
      item['price'],
      item['starting_price'],
    ], fallback: 'RM 0.00');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF4E1E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFFE04F6D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C6B71),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: welcomeTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDF2F5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE04F6D)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: welcomeTextColor,
                ),
              ),
            ],
          ),
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

String _firstString(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}
