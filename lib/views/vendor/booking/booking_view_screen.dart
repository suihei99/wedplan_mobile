import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_booking_draft.dart';
import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/repositories/vendor/vendor_service_management_repository.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_booking_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/booking/widgets/vendor_booking_widgets.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

class VendorBookingViewScreen extends StatefulWidget {
  const VendorBookingViewScreen({super.key, required this.booking});

  final Map<String, dynamic> booking;

  @override
  State<VendorBookingViewScreen> createState() =>
      _VendorBookingViewScreenState();
}

class _VendorBookingViewScreenState extends State<VendorBookingViewScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _booking;
  late final TextEditingController _coupleIdController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  VendorService? _selectedService;
  bool _status = false;
  bool _initialized = false;
  bool _loadingServiceOptions = true;
  bool _loadingBooking = true;
  bool _saving = false;
  List<VendorService> _serviceOptions = const <VendorService>[];
  String? _error;

  @override
  void initState() {
    super.initState();
    _coupleIdController = TextEditingController();
    _dateController = TextEditingController(
      text: DateFormat('d MMM y').format(_selectedDate),
    );
    _notesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = Provider.of<VendorBookingViewModel>(context, listen: false);
      if (vm.couples.isEmpty && vm.bookings.isEmpty && !vm.busy) {
        vm.load();
      }
      if (vm.couples.isEmpty) {
        vm.loadCouples();
      }
    });
    _loadServiceOptions();
    _loadBooking();
  }

  @override
  void dispose() {
    _coupleIdController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VendorBookingViewModel>(context, listen: false);
    final booking = _currentBooking();
    final coupleOptions = _coupleOptions(
      vm.couples.isNotEmpty ? vm.couples : vm.bookings,
      booking,
    );
    final selectedCouple = _selectedCoupleOption(coupleOptions);
    final selectedCoupleLabel =
        selectedCouple?.compactLabel ?? 'Select a couple';

    if (!_initialized && booking != null) {
      _initialized = true;
      _coupleIdController.text = _coupleSelectionId(booking);
      _notesController.text = _readString(booking, const [
        'notes',
        'description',
      ]);
      _status = _readStatus(booking);
      final parsedDate = DateTime.tryParse(
        _readString(booking, const ['booking_date', 'date', 'scheduled_at']),
      );
      if (parsedDate != null) {
        _selectedDate = parsedDate;
        _dateController.text = DateFormat('d MMM y').format(parsedDate);
      }
    }

    if (_selectedService == null && _serviceOptions.isNotEmpty) {
      _selectedService = _serviceFromBooking(booking);
      _selectedService ??= _serviceOptions.first;
    }

    final currentService =
        _selectedService ??
        (_serviceOptions.isNotEmpty ? _serviceOptions.first : null);

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          'Edit Booking',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: vm.busy ? null : () => _confirmDelete(context, booking),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _loadingBooking
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VendorBookingInlinePreview(
                      coupleLabel: selectedCoupleLabel,
                      typeService:
                          currentService?.serviceName ?? 'Select a service',
                      bookingDateLabel: _dateController.text.trim(),
                      isConfirmed: _status,
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xFFEEDCE1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Booking details',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const VendorBookingFormLabel(text: 'Couple'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedCouple?.id,
                              items: coupleOptions
                                  .map(
                                    (option) => DropdownMenuItem<String>(
                                      value: option.id,
                                      child: _CoupleOptionTile(option: option),
                                    ),
                                  )
                                  .toList(),
                              selectedItemBuilder: (context) => coupleOptions
                                  .map(
                                    (option) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        option.compactLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: coupleOptions.isEmpty
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _coupleIdController.text = value;
                                      });
                                    },
                              decoration: vendorBookingFieldDecoration(
                                hintText: coupleOptions.isEmpty
                                    ? 'No couples available'
                                    : 'Choose a couple',
                                icon: Icons.group_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Couple is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const VendorBookingFormLabel(text: 'Service name'),
                            const SizedBox(height: 8),
                            if (_loadingServiceOptions)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFEFDCE0),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Loading your services...'),
                                  ],
                                ),
                              )
                            else
                              DropdownButtonFormField<VendorService>(
                                value: currentService,
                                items: _serviceOptions
                                    .map(
                                      (service) =>
                                          DropdownMenuItem<VendorService>(
                                            value: service,
                                            child: Text(
                                              service.serviceName.isNotEmpty
                                                  ? service.serviceName
                                                  : service.serviceTypeLabel,
                                            ),
                                          ),
                                    )
                                    .toList(),
                                isExpanded: true,
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _selectedService = value);
                                },
                                decoration: vendorBookingFieldDecoration(
                                  hintText: 'Choose a service',
                                  icon: Icons.storefront_rounded,
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Service is required';
                                  }
                                  return null;
                                },
                              ),
                            const SizedBox(height: 16),
                            const VendorBookingFormLabel(text: 'Booking date'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: () => _pickDate(context),
                              decoration: vendorBookingFieldDecoration(
                                hintText: 'Select date',
                                icon: Icons.calendar_month_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Booking date is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            VendorBookingStatusSwitch(
                              value: _status,
                              onChanged: (value) {
                                setState(() => _status = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            const VendorBookingFormLabel(text: 'Notes'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 4,
                              onChanged: (_) => setState(() {}),
                              decoration: vendorBookingFieldDecoration(
                                hintText:
                                    'Morning session, venue arrival, special instructions',
                                icon: Icons.notes_rounded,
                              ),
                            ),
                            if (vm.error != null || _error != null) ...[
                              const SizedBox(height: 16),
                              VendorBookingErrorBanner(
                                message: _error ?? vm.error!,
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: (_saving || vm.busy)
                                    ? null
                                    : () => _saveBooking(context, vm, booking),
                                style: FilledButton.styleFrom(
                                  backgroundColor: welcomePrimaryDeepColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                icon: (_saving || vm.busy)
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  (_saving || vm.busy)
                                      ? 'Updating Booking...'
                                      : 'Update Booking',
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
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Map<String, dynamic>? _currentBooking() => _booking ?? widget.booking;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null) return;

    if (!mounted) return;
    setState(() {
      _selectedDate = selected;
      _dateController.text = DateFormat('d MMM y').format(selected);
    });
  }

  Future<void> _saveBooking(
    BuildContext context,
    VendorBookingViewModel vm,
    Map<String, dynamic>? booking,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bookingId = booking?['id'] ?? booking?['booking_id'];
    if (bookingId == null) return;

    if (_saving) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (dialogContext) {
          return const PopScope(
            canPop: false,
            child: AlertDialog(
              content: SizedBox(
                height: 84,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Updating booking...'),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    final draft = VendorBookingDraft(
      coupleId: _coupleIdController.text.trim(),
      typeService: _servicePayloadValue(),
      bookingDate: _selectedDate,
      status: _status,
      notes: _notesController.text.trim(),
    );

    try {
      await vm.updateBooking(bookingId, draft);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully.')),
      );
      await _loadBooking();
    } catch (_) {
      if (!context.mounted) return;
      setState(() {
        _error = vm.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Unable to save booking')),
      );
    } finally {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Map<String, dynamic>? booking,
  ) async {
    if (booking == null) return;

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

  bool _readStatus(Map<String, dynamic> source) {
    final status = source['status'];
    if (status is bool) return status;

    final value = _readString(source, const [
      'status',
      'booking_status',
      'state',
    ]);
    final normalized = value.toLowerCase();
    return normalized.contains('confirm') ||
        normalized == 'true' ||
        normalized == '1';
  }

  Future<void> _loadBooking() async {
    final bookingId = widget.booking['id'] ?? widget.booking['booking_id'];
    if (bookingId == null) {
      if (!mounted) return;
      setState(() {
        _loadingBooking = false;
      });
      return;
    }

    final vm = Provider.of<VendorBookingViewModel>(context, listen: false);
    try {
      final refreshed = await vm.showBooking(bookingId);
      if (!mounted) return;
      final updatedBooking = refreshed ?? widget.booking;
      setState(() {
        _booking = updatedBooking;
        _loadingBooking = false;
        _error = null;
      });
      _initializeFromBooking(updatedBooking);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = vm.error;
        _loadingBooking = false;
      });
      _initializeFromBooking(widget.booking);
    }
  }

  void _initializeFromBooking(Map<String, dynamic> booking) {
    _coupleIdController.text = _coupleSelectionId(booking);
    _notesController.text = _readString(booking, const [
      'notes',
      'description',
    ]);
    _status = _readStatus(booking);

    final parsedDate = DateTime.tryParse(
      _readString(booking, const ['booking_date', 'date', 'scheduled_at']),
    );
    if (parsedDate != null) {
      _selectedDate = parsedDate;
      _dateController.text = DateFormat('d MMM y').format(parsedDate);
    }

    final service = _serviceFromBooking(booking);
    if (service != null) {
      _selectedService = service;
    }
  }

  Future<void> _loadServiceOptions() async {
    try {
      final services = await VendorServiceManagementRepository.instance
          .fetchServices();
      if (!mounted) return;
      setState(() {
        _serviceOptions = services;
        _loadingServiceOptions = false;
        _selectedService =
            _selectedService ?? (services.isNotEmpty ? services.first : null);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _serviceOptions = const <VendorService>[];
        _loadingServiceOptions = false;
      });
    }
  }

  List<_CoupleOption> _coupleOptions(
    List<Map<String, dynamic>> couples,
    Map<String, dynamic>? currentBooking,
  ) {
    final options = <_CoupleOption>[];
    final seen = <String>{};

    for (final bookingItem in [
      ...couples,
      if (currentBooking != null) currentBooking,
    ]) {
      final id = _coupleSelectionId(bookingItem);
      if (id.isEmpty || !seen.add(id)) continue;
      options.add(_coupleOptionFromBooking(bookingItem, id));
    }

    return options;
  }

  _CoupleOption? _selectedCoupleOption(List<_CoupleOption> options) {
    final current = _coupleIdController.text.trim();
    if (current.isNotEmpty) {
      for (final option in options) {
        if (option.id == current) return option;
      }
    }
    return options.isNotEmpty ? options.first : null;
  }

  String _coupleSelectionId(Map<String, dynamic> booking) {
    final prefersBookingId = _looksLikeBookingRecord(booking);
    final directId = _firstNonEmpty(
      prefersBookingId
          ? [
              _readString(booking, const ['couple_id', 'customer_id']),
              _readString(booking, const ['id']),
            ]
          : [
              _readString(booking, const ['id']),
              _readString(booking, const ['couple_id', 'customer_id']),
            ],
    );
    if (directId.isNotEmpty) return directId;

    final nestedCouple = _readMap(booking, const [
      'couple',
      'user',
      'owner',
      'host',
    ]);
    return _readString(nestedCouple, const ['id']);
  }

  bool _looksLikeBookingRecord(Map<String, dynamic> booking) {
    return booking.containsKey('booking_date') ||
        booking.containsKey('type_service') ||
        booking.containsKey('booking_status') ||
        booking.containsKey('notes') ||
        booking.containsKey('status');
  }

  VendorService? _serviceFromBooking(Map<String, dynamic>? booking) {
    if (booking == null) return null;
    final type = _readString(booking, const [
      'type_service',
      'service_type',
      'category',
    ]);
    if (type.isEmpty) return null;

    for (final service in _serviceOptions) {
      if (service.typeService.trim().toLowerCase() ==
          type.trim().toLowerCase()) {
        return service;
      }
      if (service.serviceName.trim().toLowerCase() ==
          type.trim().toLowerCase()) {
        return service;
      }
    }

    return null;
  }

  String _servicePayloadValue() {
    final service = _selectedService;
    if (service == null) return '';
    return service.typeService.trim().isNotEmpty
        ? service.typeService.trim()
        : service.serviceName.trim();
  }

  Map<String, dynamic> _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map<String, dynamic>(
          (entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue),
        );
      }
    }
    return const <String, dynamic>{};
  }

  _CoupleOption _coupleOptionFromBooking(
    Map<String, dynamic> booking,
    String id,
  ) {
    final source = _bookingResourceLocal(booking);
    final name = _firstNonEmpty([
      _readString(source, const ['couple_name']),
      _buildCoupleName(source),
      _readString(source, const ['display_name']),
      _readString(source, const ['customer_name', 'client_name', 'title']),
      'Couple #$id',
    ]);
    final email = _readString(source, const ['email', 'couple_email']);

    return _CoupleOption(id: id, name: name, email: email);
  }

  Map<String, dynamic> _bookingResourceLocal(Map<String, dynamic> booking) {
    final candidates = [
      ['data', 'booking', 'resource'],
      ['data', 'resource'],
      ['booking', 'resource'],
      ['resource'],
      ['data'],
    ];

    for (final path in candidates) {
      final value = _readMap(booking, path);
      if (value.isNotEmpty) return value;
    }

    return booking;
  }

  String _buildCoupleName(Map<String, dynamic> source) {
    final partnerOne = _readString(source, const ['partner_1_name']);
    final partnerTwo = _readString(source, const ['partner_2_name']);
    if (partnerOne.isNotEmpty && partnerTwo.isNotEmpty) {
      return '$partnerOne & $partnerTwo';
    }
    return '';
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value;
    }
    return '';
  }
}

class _CoupleOption {
  const _CoupleOption({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  String get compactLabel {
    if (name.isNotEmpty && email.isNotEmpty) return '$name • $email';
    if (name.isNotEmpty) return name;
    if (email.isNotEmpty) return email;
    return 'Couple';
  }
}

class _CoupleOptionTile extends StatelessWidget {
  const _CoupleOptionTile({required this.option});

  final _CoupleOption option;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            option.name.isNotEmpty ? option.name : 'Couple',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (option.email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              option.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
