import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorListViewScreen extends StatelessWidget {
  const VendorListViewScreen({super.key, required this.service});

  final VendorService service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          'Service Details',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroPanel(service: service),
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
                            service.serviceName,
                            style: GoogleFonts.manrope(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          service.priceLabel,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
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
                        _MetaChip(label: service.serviceTypeLabel),
                        _MetaChip(label: 'Verified listing'),
                        _MetaChip(
                          label: service.bookingDates.isEmpty
                              ? 'No bookings yet'
                              : '${service.bookingDates.length} booked dates',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Description',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.descriptionLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C6B71),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (service.hasVendorDetails) ...[
                      _InfoTile(
                        label: 'Business name',
                        value: service.vendorBusinessName,
                        icon: Icons.storefront_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoTile(
                        label: 'Contact number',
                        value: service.vendorContactNumber,
                        icon: Icons.phone_rounded,
                      ),
                      const SizedBox(height: 18),
                    ],
                    _BookingCalendarSection(service: service),
                    const SizedBox(height: 18),
                    _InfoTile(
                      label: 'Estimated price',
                      value: service.priceLabel,
                      icon: Icons.payments_rounded,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Service type',
                      value: service.serviceTypeLabel,
                      icon: Icons.category_rounded,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: service.vendorContactNumber.trim().isNotEmpty
                            ? () async {
                                final phone = _normalizeWhatsAppPhone(
                                  service.vendorContactNumber,
                                );
                                if (phone.isEmpty) return;

                                final uri = Uri.parse(
                                  'https://api.whatsapp.com/send?phone=$phone',
                                );
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE54D6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded),
                        label: Text(
                          'WhatsApp Vendor',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: welcomePrimaryDeepColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Back to Directory',
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
}

String _normalizeWhatsAppPhone(String phoneNumber) {
  final digits = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) return '';

  if (digits.startsWith('+')) {
    return digits.substring(1);
  }

  if (digits.startsWith('0')) {
    return '60${digits.substring(1)}';
  }

  return digits;
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.service});

  final VendorService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE0E5), Color(0xFFFFFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: service.hasImage
              ? CachedNetworkImage(
                  imageUrl: service.resolvedImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF8EEF0),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      _FallbackHero(service: service),
                )
              : _FallbackHero(service: service),
        ),
      ),
    );
  }
}

class _FallbackHero extends StatelessWidget {
  const _FallbackHero({required this.service});

  final VendorService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8EEF0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: welcomePrimaryDeepColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              service.serviceTypeLabel,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: welcomePrimaryDeepColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: welcomePrimaryDeepColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7C6B71),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: welcomeTextColor,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE0E5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: welcomePrimaryDeepColor,
        ),
      ),
    );
  }
}

class _BookingCalendarSection extends StatefulWidget {
  const _BookingCalendarSection({required this.service});

  final VendorService service;

  @override
  State<_BookingCalendarSection> createState() =>
      _BookingCalendarSectionState();
}

class _BookingCalendarSectionState extends State<_BookingCalendarSection> {
  late DateTime _focusedMonth;
  late final Set<DateTime> _bookedDates;

  @override
  void initState() {
    super.initState();
    _bookedDates = widget.service.bookingDates
        .map(_parseBookingDate)
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet();
    _focusedMonth = _bookedDates.isNotEmpty
        ? DateTime(_bookedDates.first.year, _bookedDates.first.month, 1)
        : DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final monthEnd = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstGridDay = monthStart.subtract(
      Duration(days: monthStart.weekday % 7),
    );
    final daysInGrid = monthEnd.day + (monthStart.weekday % 7);
    final totalCells = ((daysInGrid / 7).ceil()) * 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Calendar',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Booked dates are highlighted in red.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _MonthIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap:
                        _focusedMonth.month == DateTime.now().month &&
                            _focusedMonth.year == DateTime.now().year
                        ? null
                        : () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month - 1,
                                1,
                              );
                            });
                          },
                  ),
                  const SizedBox(width: 6),
                  _MonthIconButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                          1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _WeekdayLabel('S'),
              _WeekdayLabel('M'),
              _WeekdayLabel('T'),
              _WeekdayLabel('W'),
              _WeekdayLabel('T'),
              _WeekdayLabel('F'),
              _WeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 34,
            ),
            itemBuilder: (context, index) {
              final day = firstGridDay.add(Duration(days: index));
              final isCurrentMonth =
                  day.month == _focusedMonth.month &&
                  day.year == _focusedMonth.year;
              final isBooked = _bookedDates.contains(_dateOnly(day));

              return Container(
                decoration: BoxDecoration(
                  color: !isCurrentMonth
                      ? const Color(0xFFF8EEF0).withValues(alpha: 0.45)
                      : isBooked
                      ? const Color(0xFFE54D6B)
                      : const Color(0xFFFFFBFC),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isBooked
                        ? const Color(0xFFE54D6B)
                        : const Color(0xFFEEDCE1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: !isCurrentMonth
                        ? const Color(0xFFB9A7AE)
                        : isBooked
                        ? Colors.white
                        : welcomeTextColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: const Color(0xFFE54D6B), label: 'Booked'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFEEDCE1), label: 'Available'),
            ],
          ),
        ],
      ),
    );
  }

  DateTime? _parseBookingDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed.toLocal();

    final formats = <DateFormat>[
      DateFormat('yyyy-MM-dd'),
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('d/M/yyyy'),
      DateFormat('d MMM y'),
      DateFormat('d MMMM y'),
      DateFormat('MMM d, y'),
    ];

    for (final format in formats) {
      try {
        return format.parseStrict(text);
      } catch (_) {
        continue;
      }
    }

    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }

    return null;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _MonthIconButton extends StatelessWidget {
  const _MonthIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEDCE1)),
        ),
        child: Icon(icon, color: welcomePrimaryDeepColor, size: 20),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF7C6B71),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7C6B71),
          ),
        ),
      ],
    );
  }
}
