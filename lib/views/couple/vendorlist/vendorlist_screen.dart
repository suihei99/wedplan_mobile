import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_service_view_model.dart';
import 'package:wedplan_mobile/views/couple/vendorlist/vendorlist_view_screen.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  late final VendorServiceViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = VendorServiceViewModel()..load();
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
      child: Consumer<VendorServiceViewModel>(
        builder: (context, vm, _) {
          final body = _VendorListContent(
            vm: vm,
            searchController: _searchController,
            onOpenService: (service) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VendorListViewScreen(service: service),
                ),
              );
            },
          );

          final refreshableBody = RefreshIndicator(
            color: welcomePrimaryDeepColor,
            onRefresh: () => vm.load(forceRefresh: true),
            child: body,
          );

          if (widget.embedded) {
            return refreshableBody;
          }

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
                    'Vendor Directory',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Browse service providers and open their details.',
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
                  child: InkResponse(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vendor notifications can be routed here next.',
                            style: GoogleFonts.manrope(),
                          ),
                        ),
                      );
                    },
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
            body: SafeArea(child: refreshableBody),
          );
        },
      ),
    );
  }
}

class _VendorListContent extends StatelessWidget {
  const _VendorListContent({
    required this.vm,
    required this.searchController,
    required this.onOpenService,
  });

  final VendorServiceViewModel vm;
  final TextEditingController searchController;
  final void Function(VendorService service) onOpenService;

  @override
  Widget build(BuildContext context) {
    final services = vm.visibleServices;
    const typeOptions = <_TypeOption>[
      _TypeOption(value: 'all', label: 'Type of Service'),
      _TypeOption(value: 'venue', label: 'Venue'),
      _TypeOption(value: 'catering', label: 'Catering'),
      _TypeOption(value: 'photography', label: 'Photography'),
      _TypeOption(value: 'makeup_artist', label: 'Makeup Artist'),
      _TypeOption(value: 'wedding_planner', label: 'Wedding Planner'),
      _TypeOption(value: 'bridal_wear', label: 'Bridal Wear'),
      _TypeOption(value: 'decor_styling', label: 'Decor & Styling'),
      _TypeOption(value: 'entertainment', label: 'Entertainment'),
      _TypeOption(value: 'transportation', label: 'Transportation'),
      _TypeOption(value: 'other', label: 'Other'),
    ];

    return Container(
      color: welcomeBackgroundColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          _HeroCard(
            serviceCount: vm.allServices.length,
            typeCount: vm.serviceTypes.length,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;

              final searchField = TextField(
                controller: searchController,
                onChanged: vm.setQuery,
                decoration:
                    _fieldDecoration(
                      hintText: 'Search service name...',
                      icon: Icons.search_rounded,
                    ).copyWith(
                      suffixIcon: vm.query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                vm.setQuery('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
              );

              final filterField = DropdownButtonFormField<String>(
                value: vm.selectedType,
                items: typeOptions.map((type) {
                  return DropdownMenuItem<String>(
                    value: type.value,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) vm.setTypeFilter(value);
                },
                decoration: _fieldDecoration(
                  hintText: 'Type of Service',
                  icon: Icons.tune_rounded,
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    filterField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  SizedBox(width: 190, child: filterField),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Featured Services',
            subtitle: services.isEmpty
                ? 'No vendors match your current search or filter.'
                : '${services.length} service${services.length == 1 ? '' : 's'} ready to browse',
          ),
          const SizedBox(height: 12),
          if (vm.busy && vm.allServices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (services.isEmpty)
            _EmptyState(
              onReset: vm.selectedType == 'all' && vm.query.isEmpty
                  ? null
                  : () {
                      searchController.clear();
                      vm.clearFilters();
                    },
            )
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceCard(
                  service: service,
                  onTap: () => onOpenService(service),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.serviceCount, required this.typeCount});

  final int serviceCount;
  final int typeCount;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0xFFF1CFD6)),
            ),
            child: Text(
              'Vendor Services',
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
            'Vendor Directory',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Discover trusted service providers and open each listing for more details.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CompactMetric(
                  label: 'Services',
                  value: '$serviceCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactMetric(label: 'Types', value: '$typeCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactMetric(label: 'Updated', value: 'Live'),
              ),
            ],
          ),
        ],
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

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
          border: Border.all(color: const Color(0xFFEEDCE1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE04F6D).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.16,
                  child: service.hasImage
                      ? CachedNetworkImage(
                          imageUrl: service.resolvedImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF8EEF0),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF8EEF0),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: welcomePrimaryDeepColor,
                              size: 38,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF8EEF0),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: welcomePrimaryDeepColor,
                            size: 38,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Pill(label: service.serviceTypeLabel),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.vendorBusinessName.isNotEmpty
                        ? service.vendorBusinessName
                        : 'Verified vendor',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7C6B71),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (service.vendorAddress.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: welcomePrimaryDeepColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            service.vendorAddress,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C6B71),
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${service.priceLabel} / Package',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: welcomePrimaryDeepColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _WhatsAppButton(phoneNumber: service.vendorContactNumber),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5C0CA),
          style: BorderStyle.solid,
        ),
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
              color: welcomePrimaryDeepColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No vendors found',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter criteria.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onReset,
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
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7C6B71),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EEF0),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF7C6B71),
        ),
      ),
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final hasPhone = phoneNumber.trim().isNotEmpty;

    return SizedBox(
      height: 40,
      child: FilledButton(
        onPressed: hasPhone
            ? () async {
                final digits = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
                final phone = digits.startsWith('+')
                    ? digits.substring(1)
                    : digits;
                final uri = Uri.parse('https://wa.me/$phone');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: welcomePrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'WhatsApp',
          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String hintText,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(icon, color: welcomePrimaryDeepColor),
    filled: true,
    fillColor: const Color(0xFFFFFBFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFEEDCE1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFEEDCE1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: welcomePrimaryDeepColor, width: 1.4),
    ),
  );
}

String _titleCase(String value) {
  final trimmed = value.trim().replaceAll('_', ' ');
  if (trimmed.isEmpty) return 'Service';

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

class _TypeOption {
  const _TypeOption({required this.value, required this.label});

  final String value;
  final String label;
}
