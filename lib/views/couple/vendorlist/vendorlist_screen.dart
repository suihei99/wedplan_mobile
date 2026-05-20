import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_service_view_model.dart';
import 'package:wedplan_mobile/views/couple/vendorlist/widgets/vendor_list_support_widgets.dart';
import 'package:wedplan_mobile/views/couple/vendorlist/widgets/vendor_service_grid.dart';
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
      _TypeOption(value: 'Venue', label: 'Venue'),
      _TypeOption(value: 'Catering', label: 'Catering'),
      _TypeOption(value: 'Photography', label: 'Photography'),
      _TypeOption(value: 'Makeup Artist', label: 'Makeup Artist'),
      _TypeOption(value: 'Wedding Planner', label: 'Wedding Planner'),
      _TypeOption(value: 'Bridal Wear', label: 'Bridal Wear'),
      _TypeOption(value: 'Decor & Styling', label: 'Decor & Styling'),
      _TypeOption(value: 'Entertainment', label: 'Entertainment'),
      _TypeOption(value: 'Transportation', label: 'Transportation'),
      _TypeOption(value: 'Other', label: 'Other'),
    ];

    return Container(
      color: welcomeBackgroundColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          VendorHeroCard(
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
          VendorSectionHeader(
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
            VendorEmptyState(
              onReset: vm.selectedType == 'all' && vm.query.isEmpty
                  ? null
                  : () {
                      searchController.clear();
                      vm.clearFilters();
                    },
            )
          else
            VendorServiceGrid(services: services, onOpenService: onOpenService),
          const SizedBox(height: 8),
        ],
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

class _TypeOption {
  const _TypeOption({required this.value, required this.label});

  final String value;
  final String label;
}
