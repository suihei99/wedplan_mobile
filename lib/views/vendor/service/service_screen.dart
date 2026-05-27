import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_service_management_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/service/service_add_screen.dart';
import 'package:wedplan_mobile/views/vendor/service/service_view_screen.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

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
            onAddService: () => _openServiceEditor(context),
            onOpenService: (service) => _openServiceDetails(context, service),
            bottomPadding: widget.embedded ? 104 : 24,
          );

          final refreshableBody = RefreshIndicator(
            color: welcomePrimaryDeepColor,
            onRefresh: () => vm.load(forceRefresh: true),
            child: content,
          );

          if (widget.embedded) {
            return SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  refreshableBody,
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: FloatingActionButton.extended(
                      onPressed: () => _openServiceEditor(context),
                      backgroundColor: welcomePrimaryDeepColor,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: Text(
                        'Add Service',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
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
                    'Service',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Manage your vendor service catalog and pricing.',
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
                  onPressed: () => _openServiceEditor(context),
                  icon: const Icon(Icons.add_rounded),
                ),
                IconButton(
                  onPressed: () => vm.load(forceRefresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openServiceEditor(context),
              backgroundColor: welcomePrimaryDeepColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Service',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            body: SafeArea(child: refreshableBody),
          );
        },
      ),
    );
  }

  void _openServiceDetails(BuildContext context, VendorService service) {
    final vm = Provider.of<VendorServiceManagementViewModel>(
      context,
      listen: false,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VendorServiceViewScreen(service: service),
        ),
      ),
    );
  }

  void _openServiceEditor(BuildContext context, {VendorService? service}) {
    final vm = Provider.of<VendorServiceManagementViewModel>(
      context,
      listen: false,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VendorServiceAddScreen(service: service),
        ),
      ),
    );
  }
}

class _ServiceContent extends StatelessWidget {
  const _ServiceContent({
    required this.vm,
    required this.searchController,
    required this.onOpenService,
    required this.onAddService,
    required this.bottomPadding,
  });

  final VendorServiceManagementViewModel vm;
  final TextEditingController searchController;
  final void Function(VendorService service) onOpenService;
  final VoidCallback onAddService;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final services = vm.visibleServices;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18, 16, 18, bottomPadding),
      children: [
        VendorServiceHeroCard(
          totalServices: vm.allServices.length,
          visibleServices: services.length,
          onAddService: onAddService,
          onRefresh: () => vm.load(forceRefresh: true),
        ),
        const SizedBox(height: 14),
        VendorServiceFilterBar(
          searchController: searchController,
          query: vm.query,
          selectedType: vm.selectedType,
          onQueryChanged: vm.setQuery,
          onClearQuery: () {
            searchController.clear();
            vm.clearQuery();
          },
          onTypeChanged: (value) {
            if (value != null) vm.setTypeFilter(value);
          },
        ),
        const SizedBox(height: 16),
        if (vm.busy && vm.allServices.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 36),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (services.isEmpty)
          VendorServiceEmptyState(
            onClearFilters: vm.query.isEmpty && vm.selectedType == 'all'
                ? null
                : () {
                    searchController.clear();
                    vm.clearFilters();
                  },
            onAddService: onAddService,
          )
        else
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VendorServiceCard(
                service: service,
                onTap: () => onOpenService(service),
              ),
            ),
          ),
        if (vm.error != null) ...[
          const SizedBox(height: 12),
          VendorServiceErrorBanner(message: vm.error!),
        ],
      ],
    );
  }
}
