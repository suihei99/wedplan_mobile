import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/couple/couple_dashboard_view_model.dart';
import 'package:wedplan_mobile/views/couple/budget/budget_screen.dart';
import 'package:wedplan_mobile/views/couple/me/me_screen.dart';
import 'package:wedplan_mobile/views/couple/vendorlist/vendorlist_screen.dart';
import 'package:wedplan_mobile/views/couple/guest/guestlist_screen.dart';
import 'package:wedplan_mobile/views/couple/me/notification/notification_screen.dart';
import 'package:wedplan_mobile/views/couple/task/task_screen.dart';
import 'package:wedplan_mobile/views/couple/navbar/navbar.dart';
import 'package:wedplan_mobile/views/couple/widgets/dashboard_cards.dart';

class CoupleDashboardScreen extends StatefulWidget {
  const CoupleDashboardScreen({super.key});

  @override
  State<CoupleDashboardScreen> createState() => _CoupleDashboardScreenState();
}

class _CoupleDashboardScreenState extends State<CoupleDashboardScreen> {
  late final CoupleDashboardViewModel _viewModel;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = CoupleDashboardViewModel()..load();
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
      child: Consumer<CoupleDashboardViewModel>(
        builder: (context, vm, _) {
          final pages = <Widget>[
            _DashboardHome(
              vm: vm,
              onTapBudget: () => _handleNavTap(1),
              onTapGuests: () => _handleNavTap(3),
              onTapTasks: () => _openTaskScreen(context),
              onTapVendors: () => _handleNavTap(2),
              onTapTaskList: () => _openTaskScreen(context),
            ),
            BudgetScreen(embedded: true),
            const VendorListScreen(embedded: true),
            // Embed the guestlist screen here so the CoupleNavbar 'Guest' tab
            // shows the real guest listing instead of the placeholder.
            const GuestListScreen(embedded: true),
            const MeScreen(embedded: true),
          ];

          final pageMeta = _pageMeta[_navIndex];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFFAF4F5),
              foregroundColor: const Color(0xFF21161A),
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
                    onTap: () => _showNotifications(context),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: IndexedStack(
                  key: ValueKey<int>(_navIndex),
                  index: _navIndex,
                  children: pages,
                ),
              ),
            ),
            bottomNavigationBar: CoupleNavbar(
              currentIndex: _navIndex,
              onTap: _handleNavTap,
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

  void _showNotifications(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationScreen()));
  }

  void _openQuickAction(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label section is ready for routing.',
          style: GoogleFonts.manrope(),
        ),
      ),
    );
  }

  void _openBudget(BuildContext context) {
    _handleNavTap(1);
  }

  Future<void> _openTaskScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => const TaskScreen()));

    if (!mounted) return;
    await _viewModel.load(forceRefresh: true);
  }

  void _handleNavTap(int index) {
    if (_navIndex == index) {
      return;
    }

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
    subtitle: 'Welcome back, here\'s your wedding planning overview.',
  ),
  _TabMeta(
    title: 'Budget',
    subtitle: 'Track allocations, spending, and category health in one place.',
  ),
  _TabMeta(
    title: 'Vendors',
    subtitle: 'Browse vendors, services, and bookings in one tab.',
  ),
  _TabMeta(
    title: 'Guest',
    subtitle: 'Manage invitations, RSVPs, and check-ins in one place.',
  ),
  _TabMeta(
    title: 'Me',
    subtitle: 'Manage your account and couple settings here.',
  ),
];

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEFDCE0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE0E5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Color(0xFFE04F6D),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6F6468),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.vm,
    required this.onTapBudget,
    required this.onTapGuests,
    required this.onTapTasks,
    required this.onTapVendors,
    required this.onTapTaskList,
  });

  final CoupleDashboardViewModel vm;
  final VoidCallback onTapBudget;
  final VoidCallback onTapGuests;
  final VoidCallback onTapTasks;
  final VoidCallback onTapVendors;
  final VoidCallback onTapTaskList;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFE04F6D),
      onRefresh: () => vm.load(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardHeader(vm: vm),
            const SizedBox(height: 16),
            DashboardStatGrid(
              vm: vm,
              onTapBudget: onTapBudget,
              onTapGuests: onTapGuests,
              onTapTasks: onTapTasks,
              onTapVendors: onTapVendors,
              onTapTaskList: onTapTaskList,
            ),
            if (vm.error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: vm.error!),
            ],
            const SizedBox(height: 88),
          ],
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

class _TaskSheetAction extends StatelessWidget {
  const _TaskSheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF6F8),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFFE04F6D)),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
