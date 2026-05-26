import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_service_management_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorServiceScreen extends StatefulWidget {
  const VendorServiceScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<VendorServiceScreen> createState() => _VendorServiceScreenState();
}

class _VendorServiceScreenState extends State<VendorServiceScreen> {
  late final VendorServiceManagementViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = VendorServiceManagementViewModel()..load();
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
      child: Consumer<VendorServiceManagementViewModel>(
        builder: (context, vm, _) {
          final content = _ServiceContent(
            vm: vm,
            searchController: _searchController,
            onOpenService: (service) => _showServiceDetails(context, service),
          );

          final body = RefreshIndicator(
            color: welcomePrimaryDeepColor,
            onRefresh: () => vm.load(forceRefresh: true),
            child: content,
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
                    'Service',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Review and manage the services in your catalog.',
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
            body: SafeArea(child: body),
          );
        },
      ),
    );
  }

  void _showServiceDetails(BuildContext context, VendorService service) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.48,
          maxChildSize: 0.92,
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFDCE0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    service.serviceName,
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.serviceTypeLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE04F6D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Price', value: service.priceLabel),
                  _DetailRow(
                    label: 'Business',
                    value: service.vendorBusinessName.isNotEmpty
                        ? service.vendorBusinessName
                        : 'Not provided',
                  ),
                  _DetailRow(
                    label: 'Address',
                    value: service.vendorAddress.isNotEmpty
                        ? service.vendorAddress
                        : 'Not provided',
                  ),
                  _DetailRow(
                    label: 'Contact',
                    value: service.vendorContactNumber.isNotEmpty
                        ? service.vendorContactNumber
                        : 'Not provided',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF8FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF4E1E6)),
                    ),
                    child: Text(
                      service.descriptionLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5F5358),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ServiceContent extends StatelessWidget {
  const _ServiceContent({
    required this.vm,
    required this.searchController,
    required this.onOpenService,
  });

  final VendorServiceManagementViewModel vm;
  final TextEditingController searchController;
  final void Function(VendorService service) onOpenService;

  @override
  Widget build(BuildContext context) {
    final services = vm.visibleServices;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      children: [
        _HeroCard(
          totalServices: vm.allServices.length,
          visibleCount: services.length,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: searchController,
          onChanged: vm.setQuery,
          decoration: InputDecoration(
            hintText: 'Search services, type, or business name',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: vm.query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      vm.clearQuery();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
          ),
        ),
        const SizedBox(height: 16),
        if (vm.busy && vm.allServices.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 36),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (services.isEmpty)
          _EmptyState(
            onReset: vm.query.isEmpty
                ? null
                : () {
                    searchController.clear();
                    vm.clearQuery();
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
        if (vm.error != null) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: vm.error!),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.totalServices, required this.visibleCount});

  final int totalServices;
  final int visibleCount;

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
              Icons.storefront_rounded,
              color: Color(0xFFE04F6D),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalServices services',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$visibleCount visible in the current view',
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
          border: Border.all(color: const Color(0xFFEFDCE0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
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
                    service.vendorBusinessName.isNotEmpty
                        ? service.vendorBusinessName
                        : 'Business name unavailable',
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            width: 90,
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
  const _EmptyState({this.onReset});

  final VoidCallback? onReset;

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
            'Try another search or refresh the list from the API.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onReset, child: const Text('Clear search')),
          ],
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
