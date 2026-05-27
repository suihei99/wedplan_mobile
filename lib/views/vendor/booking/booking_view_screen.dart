import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/vendor/vendor_booking_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/booking/booking_add_screen.dart';
import 'package:wedplan_mobile/views/vendor/booking/widgets/vendor_booking_widgets.dart';

class VendorBookingViewScreen extends StatefulWidget {
  const VendorBookingViewScreen({super.key, required this.booking});

  final Map<String, dynamic> booking;

  @override
  State<VendorBookingViewScreen> createState() =>
      _VendorBookingViewScreenState();
}

class _VendorBookingViewScreenState extends State<VendorBookingViewScreen> {
  Map<String, dynamic>? _booking;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _loadBooking();
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking ?? widget.booking;

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          bookingTitle(booking).isNotEmpty
              ? bookingTitle(booking)
              : 'Booking Detail',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _busy ? null : () => _openEditor(context, booking),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _busy ? null : () => _confirmDelete(context, booking),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _busy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VendorBookingInlinePreview(
                      coupleId: _readString(booking, const ['couple_id']),
                      typeService: bookingTypeLabel(booking),
                      bookingDateLabel: _readString(booking, const [
                        'booking_date',
                        'date',
                        'scheduled_at',
                      ]),
                      isConfirmed: _bookingStatusBool(booking),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFEEDCE1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bookingTitle(booking).isNotEmpty
                                      ? bookingTitle(booking)
                                      : 'Booking #${_readString(booking, const ['id', 'booking_id'])}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                bookingStatusLabel(booking),
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: welcomePrimaryDeepColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              VendorBookingStatusChip(
                                label: bookingTypeLabel(booking).isEmpty
                                    ? 'Service'
                                    : bookingTypeLabel(booking),
                              ),
                              VendorBookingStatusChip(
                                label:
                                    _readString(booking, const [
                                      'booking_date',
                                      'date',
                                      'scheduled_at',
                                    ]).isEmpty
                                    ? 'Date unavailable'
                                    : _readString(booking, const [
                                        'booking_date',
                                        'date',
                                        'scheduled_at',
                                      ]),
                              ),
                            ],
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            VendorBookingErrorBanner(message: _error!),
                          ],
                          const SizedBox(height: 18),
                          VendorBookingDetailRow(
                            label: 'Couple ID',
                            value:
                                _readString(booking, const [
                                  'couple_id',
                                ]).isNotEmpty
                                ? _readString(booking, const ['couple_id'])
                                : 'Not provided',
                          ),
                          VendorBookingDetailRow(
                            label: 'Service type',
                            value: bookingTypeLabel(booking).isNotEmpty
                                ? bookingTypeLabel(booking)
                                : 'Not provided',
                          ),
                          VendorBookingDetailRow(
                            label: 'Booking date',
                            value: _formatDateLabel(
                              _readString(booking, const [
                                'booking_date',
                                'date',
                                'scheduled_at',
                              ]),
                            ),
                          ),
                          VendorBookingDetailRow(
                            label: 'Status',
                            value: bookingStatusLabel(booking),
                          ),
                          VendorBookingDetailRow(
                            label: 'Notes',
                            value: bookingNotes(booking).isNotEmpty
                                ? bookingNotes(booking)
                                : 'No notes provided',
                          ),
                          if (_readString(booking, const [
                            'created_at',
                          ]).isNotEmpty)
                            VendorBookingDetailRow(
                              label: 'Created at',
                              value: _readString(booking, const ['created_at']),
                            ),
                          if (_readString(booking, const [
                            'updated_at',
                          ]).isNotEmpty)
                            VendorBookingDetailRow(
                              label: 'Updated at',
                              value: _readString(booking, const ['updated_at']),
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: () => _openEditor(context, booking),
                              style: FilledButton.styleFrom(
                                backgroundColor: welcomePrimaryDeepColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.edit_rounded),
                              label: Text(
                                'Edit Booking',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _loadBooking() async {
    final bookingId = widget.booking['id'] ?? widget.booking['booking_id'];
    if (bookingId == null) {
      setState(() {
        _busy = false;
      });
      return;
    }

    final vm = Provider.of<VendorBookingViewModel>(context, listen: false);
    try {
      final refreshed = await vm.showBooking(bookingId);
      if (!mounted) return;
      setState(() {
        _booking = refreshed ?? widget.booking;
        _busy = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = vm.error;
        _busy = false;
      });
    }
  }

  void _openEditor(BuildContext context, Map<String, dynamic> booking) {
    final vm = Provider.of<VendorBookingViewModel>(context, listen: false);
    Navigator.of(context)
        .push<String?>(
          MaterialPageRoute<String?>(
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: VendorBookingAddScreen(booking: booking),
            ),
          ),
        )
        .then((value) {
          if (!mounted || value == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(value)));
          _loadBooking();
        });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Map<String, dynamic> booking,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete booking?'),
          content: Text(
            'Remove booking #${_readString(booking, const ['id', 'booking_id'])} from the list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: welcomePrimaryDeepColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final vm = Provider.of<VendorBookingViewModel>(context, listen: false);
    try {
      await vm.deleteBooking(booking['id'] ?? booking['booking_id']);
      if (!mounted) return;
      Navigator.of(context).pop('Booking deleted successfully.');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Unable to delete booking')),
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

  bool _bookingStatusBool(Map<String, dynamic> booking) {
    final status = booking['status'];
    if (status is bool) return status;
    final value = _readString(booking, const [
      'status',
      'booking_status',
      'state',
    ]);
    final normalized = value.toLowerCase();
    return normalized.contains('confirm') ||
        normalized == 'true' ||
        normalized == '1';
  }

  String _formatDateLabel(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.isEmpty ? 'Date unavailable' : value;
    return DateFormat('d MMM y').format(parsed);
  }
}
