import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorServiceTypeOption {
  const VendorServiceTypeOption({required this.value, required this.label});

  final String value;
  final String label;
}

const vendorServiceFilterOptions = <VendorServiceTypeOption>[
  VendorServiceTypeOption(value: 'all', label: 'Type of Service'),
  VendorServiceTypeOption(value: 'venue', label: 'Venue'),
  VendorServiceTypeOption(value: 'catering', label: 'Catering'),
  VendorServiceTypeOption(value: 'photography', label: 'Photography'),
  VendorServiceTypeOption(value: 'makeup_artist', label: 'Makeup Artist'),
  VendorServiceTypeOption(value: 'wedding_planner', label: 'Wedding Planner'),
  VendorServiceTypeOption(value: 'bridal_wear', label: 'Bridal Wear'),
  VendorServiceTypeOption(value: 'decor_styling', label: 'Decor & Styling'),
  VendorServiceTypeOption(value: 'entertainment', label: 'Entertainment'),
  VendorServiceTypeOption(value: 'transportation', label: 'Transportation'),
  VendorServiceTypeOption(value: 'other', label: 'Other'),
];

const vendorServiceFormOptions = <VendorServiceTypeOption>[
  VendorServiceTypeOption(value: 'venue', label: 'Venue'),
  VendorServiceTypeOption(value: 'catering', label: 'Catering'),
  VendorServiceTypeOption(value: 'photography', label: 'Photography'),
  VendorServiceTypeOption(value: 'makeup_artist', label: 'Makeup Artist'),
  VendorServiceTypeOption(value: 'wedding_planner', label: 'Wedding Planner'),
  VendorServiceTypeOption(value: 'bridal_wear', label: 'Bridal Wear'),
  VendorServiceTypeOption(value: 'decor_styling', label: 'Decor & Styling'),
  VendorServiceTypeOption(value: 'entertainment', label: 'Entertainment'),
  VendorServiceTypeOption(value: 'transportation', label: 'Transportation'),
  VendorServiceTypeOption(value: 'other', label: 'Other'),
];

String normalizeVendorServiceTypeSelection(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return vendorServiceFormOptions.first.value;

  if (normalized.contains('makeup')) return 'makeup_artist';
  if (normalized.contains('planner')) return 'wedding_planner';
  if (normalized.contains('bridal')) return 'bridal_wear';
  if (normalized.contains('decor') || normalized.contains('styling')) {
    return 'decor_styling';
  }
  if (normalized.contains('photo')) return 'photography';
  if (normalized.contains('transport')) return 'transportation';
  if (normalized.contains('entertain')) return 'entertainment';
  if (normalized.contains('cater')) return 'catering';
  if (normalized.contains('venue')) return 'venue';
  if (normalized.contains('other')) return 'other';

  return normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

String vendorServiceTypeApiValue(String selectionValue) {
  final normalized = normalizeVendorServiceTypeSelection(selectionValue);
  final option = vendorServiceFormOptions.firstWhere(
    (item) => item.value == normalized,
    orElse: () => const VendorServiceTypeOption(value: 'other', label: 'Other'),
  );
  return option.label;
}

InputDecoration serviceFieldDecoration({
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

class VendorServiceHeroCard extends StatelessWidget {
  const VendorServiceHeroCard({
    super.key,
    required this.totalServices,
    required this.visibleServices,
    required this.onAddService,
    required this.onRefresh,
  });

  final int totalServices;
  final int visibleServices;
  final VoidCallback onAddService;
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

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onAddService,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Service'),
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

          final summary = Row(
            children: [
              Expanded(
                child: _CompactMetric(
                  label: 'Services',
                  value: '$totalServices',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactMetric(
                  label: 'Visible',
                  value: '$visibleServices',
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
                  'Wedding Service Manager',
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
                'Build a service catalog couples can trust.',
                style: GoogleFonts.manrope(
                  fontSize: compact ? 24 : 26,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Organize venue, catering, styling, and planning packages in a layout that stays clean on mobile.',
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

class VendorServiceFilterBar extends StatelessWidget {
  const VendorServiceFilterBar({
    super.key,
    required this.searchController,
    required this.query,
    required this.selectedType,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onTypeChanged,
  });

  final TextEditingController searchController;
  final String query;
  final String selectedType;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        final searchField = TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          decoration: serviceFieldDecoration(
            hintText: 'Search service name...',
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
          value: selectedType,
          items: vendorServiceFilterOptions
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: onTypeChanged,
          decoration: serviceFieldDecoration(
            hintText: 'Type of Service',
            icon: Icons.tune_rounded,
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
            Expanded(child: filterField),
          ],
        );
      },
    );
  }
}

class VendorServiceCard extends StatelessWidget {
  const VendorServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  final VendorService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEFDCE0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 156,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  service.hasImage
                      ? CachedNetworkImage(
                          imageUrl: service.resolvedImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF9EEF1),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _fallbackImage(),
                        )
                      : _fallbackImage(),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _StatusChip(label: service.serviceTypeLabel),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.serviceTypeLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE04F6D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.descriptionLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6F6468),
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        service.priceLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded),
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

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFFF9EEF1),
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_rounded,
        color: Color(0xFFE04F6D),
        size: 42,
      ),
    );
  }
}

class VendorServiceEmptyState extends StatelessWidget {
  const VendorServiceEmptyState({
    super.key,
    this.onClearFilters,
    this.onAddService,
  });

  final VoidCallback? onClearFilters;
  final VoidCallback? onAddService;

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
              Icons.storefront_rounded,
              color: Color(0xFFE04F6D),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No services found',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another search or create a new service listing.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          if (onClearFilters != null || onAddService != null) ...[
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
                if (onAddService != null)
                  FilledButton(
                    onPressed: onAddService,
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
                    child: const Text('Add Service'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VendorServiceErrorBanner extends StatelessWidget {
  const VendorServiceErrorBanner({super.key, required this.message});

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

class VendorServiceDetailRow extends StatelessWidget {
  const VendorServiceDetailRow({
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
            width: 96,
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

class VendorServiceTypeDropdown extends StatelessWidget {
  const VendorServiceTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: vendorServiceFormOptions
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: serviceFieldDecoration(
        hintText: 'Select service type',
        icon: Icons.category_rounded,
      ),
      validator: validator,
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

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: welcomeTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
