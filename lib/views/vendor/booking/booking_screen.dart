import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/vendor/vendor_booking_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/booking/booking_add_screen.dart';
import 'package:wedplan_mobile/views/vendor/booking/booking_view_screen.dart';
import 'package:wedplan_mobile/views/vendor/booking/widgets/vendor_booking_widgets.dart';

class VendorBookingScreen extends StatefulWidget {
  const VendorBookingScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<VendorBookingScreen> createState() => _VendorBookingScreenState();
}

class _VendorBookingScreenState extends State<VendorBookingScreen> {
  late final VendorBookingViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = VendorBookingViewModel()..load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<VendorBookingViewModel>(
        builder: (context, vm, _) {
          final body = RefreshIndicator(
            color: welcomePrimaryDeepColor,
            onRefresh: () => vm.load(forceRefresh: true),
            child: _BookingContent(
              vm: vm,
              searchController: _searchController,
              onAddBooking: () => _openBookingEditor(context),
              onOpenBooking: (booking) => _openBookingDetails(context, booking),
            ),
          );

          if (widget.embedded) return body;

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
                    'Booking',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Track and update vendor bookings in one mobile view.',
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
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openBookingEditor(context),
              backgroundColor: welcomePrimaryDeepColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Booking',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            body: SafeArea(child: body),
          );
        },
      ),
    );
  }

  void _openBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: VendorBookingViewScreen(booking: booking),
        ),
      ),
    );
  }

  void _openBookingEditor(
    BuildContext context, {
    Map<String, dynamic>? booking,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: VendorBookingAddScreen(booking: booking),
        ),
      ),
    );
  }
}

class _BookingContent extends StatelessWidget {
  const _BookingContent({
    required this.vm,
    required this.searchController,
    required this.onOpenBooking,
    required this.onAddBooking,
  });

  final VendorBookingViewModel vm;
  final TextEditingController searchController;
  final void Function(Map<String, dynamic> booking) onOpenBooking;
  final VoidCallback onAddBooking;

  @override
  Widget build(BuildContext context) {
    final bookings = vm.visibleBookings;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      children: [
        VendorBookingHeroCard(
          totalBookings: vm.totalBookings,
          pendingBookings: vm.pendingBookings,
          confirmedBookings: vm.confirmedBookings,
          completedBookings: vm.completedBookings,
          onAddBooking: onAddBooking,
          onRefresh: () => vm.load(forceRefresh: true),
        ),
        const SizedBox(height: 14),
        VendorBookingFilterBar(
          searchController: searchController,
          query: vm.query,
          selectedStatus: vm.selectedStatus,
          onQueryChanged: vm.setQuery,
          onClearQuery: () {
            searchController.clear();
            vm.setQuery('');
          },
          onStatusChanged: (value) {
            if (value != null) vm.setStatusFilter(value);
          },
        ),
        const SizedBox(height: 16),
        if (vm.busy && vm.bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 36),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (bookings.isEmpty)
          VendorBookingEmptyState(
            onClearFilters: vm.query.isEmpty && vm.selectedStatus == 'all'
                ? null
                : () {
                    searchController.clear();
                    vm.clearFilters();
                  },
            onAddBooking: onAddBooking,
          )
        else
          ...bookings.map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VendorBookingCard(
                booking: booking,
                onTap: () => onOpenBooking(booking),
              ),
            ),
          ),
        if (vm.error != null) ...[
          const SizedBox(height: 12),
          VendorBookingErrorBanner(message: vm.error!),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}
