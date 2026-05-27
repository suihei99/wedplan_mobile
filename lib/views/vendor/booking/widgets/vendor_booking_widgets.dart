import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

const vendorBookingStatusOptions = <_BookingStatusOption>[
  _BookingStatusOption(value: 'all', label: 'All Status'),
  _BookingStatusOption(value: 'pending', label: 'Pending'),
  _BookingStatusOption(value: 'confirmed', label: 'Confirmed'),
  _BookingStatusOption(value: 'completed', label: 'Completed'),
];

class _BookingStatusOption {
  const _BookingStatusOption({required this.value, required this.label});

  final String value;
  final String label;
}

InputDecoration vendorBookingFieldDecoration({
  required String hintText,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFEFDCE0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFEFDCE0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE04F6D)),
    ),
  );
}

class VendorBookingHeroCard extends StatelessWidget {
  const VendorBookingHeroCard({
    super.key,
    required this.totalBookings,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.completedBookings,
    required this.onAddBooking,
    required this.onRefresh,
  });

  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final VoidCallback onAddBooking;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE0E5), Color(0xFFFFFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final summary = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BookingMetricChip(label: 'Total', value: '$totalBookings'),
              _BookingMetricChip(label: 'Pending', value: '$pendingBookings'),
              _BookingMetricChip(
                label: 'Confirmed',
                value: '$confirmedBookings',
              ),
              _BookingMetricChip(label: 'Done', value: '$completedBookings'),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onAddBooking,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Booking'),
                style: FilledButton.styleFrom(
                  backgroundColor: welcomePrimaryDeepColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: welcomePrimaryDeepColor,
                  side: const BorderSide(color: Color(0xFFEEDCE1)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFFF1CFD6)),
                ),
                child: Text(
                  'Booking Manager',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: welcomePrimaryDeepColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Track and update bookings from a clean mobile layout.',
                style: GoogleFonts.manrope(
                  fontSize: compact ? 24 : 26,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage couple bookings, confirm requests, and keep notes aligned with your vendor workflow.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7C6B71),
                ),
              ),
              const SizedBox(height: 16),
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [summary, const SizedBox(height: 12), actions],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: summary),
                    const SizedBox(width: 12),
                    actions,
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class VendorBookingFilterBar extends StatelessWidget {
  const VendorBookingFilterBar({
    super.key,
    required this.searchController,
    required this.query,
    required this.selectedStatus,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onStatusChanged,
  });

  final TextEditingController searchController;
  final String query;
  final String selectedStatus;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        final searchField = TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          decoration: vendorBookingFieldDecoration(
            hintText: 'Search couple, service, notes...',
            icon: Icons.search_rounded,
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    onPressed: onClearQuery,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        );

        final filterField = DropdownButtonFormField<String>(
          value: selectedStatus,
          items: vendorBookingStatusOptions
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: onStatusChanged,
          decoration: vendorBookingFieldDecoration(
            hintText: 'Status',
            icon: Icons.filter_alt_rounded,
          ),
        );

        if (compact) {
          return Column(
            children: [searchField, const SizedBox(height: 12), filterField],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: filterField),
          ],
        );
      },
    );
  }
}

class VendorBookingCard extends StatelessWidget {
  const VendorBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final Map<String, dynamic> booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = bookingTitle(booking);
    final subtitle = bookingSubtitle(booking);
    final status = bookingStatusLabel(booking);
    final notes = bookingNotes(booking);
    final typeLabel = bookingTypeLabel(booking);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE0E5),
                    borderRadius: BorderRadius.circular(16),
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
                        title.isNotEmpty
                            ? title
                            : 'Booking #${_readBookingId(booking)}',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle.isNotEmpty
                            ? subtitle
                            : 'No booking date provided',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C6B71),
                        ),
                      ),
                    ],
                  ),
                ),
                _BookingStatusChip(label: status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniInfoChip(
                  label: typeLabel.isNotEmpty
                      ? _titleCase(typeLabel)
                      : 'Service',
                ),
                _MiniInfoChip(
                  label: _formatDateLabel(
                    _readString(booking, const [
                      'booking_date',
                      'date',
                      'scheduled_at',
                    ]),
                  ),
                ),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                notes,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6F6468),
                  height: 1.45,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VendorBookingEmptyState extends StatelessWidget {
  const VendorBookingEmptyState({
    super.key,
    this.onClearFilters,
    this.onAddBooking,
  });

  final VoidCallback? onClearFilters;
  final VoidCallback? onAddBooking;

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
              Icons.event_busy_rounded,
              color: Color(0xFFE04F6D),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No bookings found',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use the add button to create a booking or clear the filters to see more results.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          if (onClearFilters != null || onAddBooking != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (onClearFilters != null)
                  OutlinedButton(
                    onPressed: onClearFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: welcomePrimaryDeepColor,
                      side: const BorderSide(color: Color(0xFFEEDCE1)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Clear filters'),
                  ),
                if (onAddBooking != null)
                  FilledButton(
                    onPressed: onAddBooking,
                    style: FilledButton.styleFrom(
                      backgroundColor: welcomePrimaryDeepColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Add Booking'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VendorBookingErrorBanner extends StatelessWidget {
  const VendorBookingErrorBanner({super.key, required this.message});

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

class VendorBookingDetailRow extends StatelessWidget {
  const VendorBookingDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8D7C83),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: welcomeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorBookingFormLabel extends StatelessWidget {
  const VendorBookingFormLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF8D7C83),
      ),
    );
  }
}

class VendorBookingStatusChip extends StatelessWidget {
  const VendorBookingStatusChip({super.key, required this.label});

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

class VendorBookingStatusSwitch extends StatelessWidget {
  const VendorBookingStatusSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFDCE0)),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Text(
          value ? 'Confirmed' : 'Pending',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          value ? 'The booking is confirmed.' : 'The booking is still pending.',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: const Color(0xFF7C6B71),
          ),
        ),
      ),
    );
  }
}

class VendorBookingInlinePreview extends StatelessWidget {
  const VendorBookingInlinePreview({
    super.key,
    required this.coupleId,
    required this.typeService,
    required this.bookingDateLabel,
    required this.isConfirmed,
  });

  final String coupleId;
  final String typeService;
  final String bookingDateLabel;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE0E5), Color(0xFFFFFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                  coupleId.isEmpty ? 'Couple ID preview' : 'Couple #$coupleId',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  typeService.isEmpty ? 'Service type preview' : typeService,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C6B71),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bookingDateLabel.isEmpty
                      ? 'Pick a booking date'
                      : bookingDateLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C6B71),
                  ),
                ),
              ],
            ),
          ),
          _BookingStatusChip(label: isConfirmed ? 'Confirmed' : 'Pending'),
        ],
      ),
    );
  }
}

class _BookingMetricChip extends StatelessWidget {
  const _BookingMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8D7C83),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: welcomeTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusChip extends StatelessWidget {
  const _BookingStatusChip({required this.label});

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

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF4E1E6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: welcomeTextColor,
        ),
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

String bookingTitle(Map<String, dynamic> booking) {
  return _readString(booking, const [
    'client_name',
    'customer_name',
    'couple_name',
    'title',
  ]);
}

String bookingSubtitle(Map<String, dynamic> booking) {
  final service = _readString(booking, const ['service_name', 'service']);
  final date = _readString(booking, const [
    'booking_date',
    'date',
    'scheduled_at',
  ]);

  if (service.isNotEmpty && date.isNotEmpty) return '$service • $date';
  if (service.isNotEmpty) return service;
  return date;
}

String bookingTypeLabel(Map<String, dynamic> booking) {
  return _readString(booking, const [
    'type_service',
    'service_type',
    'category',
  ]);
}

String bookingNotes(Map<String, dynamic> booking) {
  return _readString(booking, const ['notes', 'description', 'remark']);
}

String bookingStatusLabel(Map<String, dynamic> booking) {
  final status = booking['status'];
  if (status is bool) return status ? 'Confirmed' : 'Pending';

  final label = _readString(booking, const [
    'status',
    'booking_status',
    'state',
  ]);
  if (label.isEmpty) return 'Pending';
  final normalized = label.toLowerCase();
  if (normalized.contains('confirm')) return 'Confirmed';
  if (normalized.contains('complete')) return 'Completed';
  if (normalized.contains('cancel')) return 'Cancelled';
  if (normalized.contains('pending')) return 'Pending';
  return label;
}

String _formatDateLabel(String value) {
  if (value.isEmpty) return 'Date unavailable';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return DateFormat('d MMM y').format(parsed);
}

String _readBookingId(Map<String, dynamic> booking) {
  final value = booking['id'] ?? booking['booking_id'];
  return value?.toString() ?? '';
}

String _titleCase(String value) {
  final trimmed = value.trim().replaceAll('_', ' ');
  if (trimmed.isEmpty) return '';

  return trimmed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) => part.length == 1
            ? part.toUpperCase()
            : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}
