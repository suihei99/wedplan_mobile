import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_booking_draft.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_booking_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/booking/widgets/vendor_booking_widgets.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

class VendorBookingAddScreen extends StatefulWidget {
  const VendorBookingAddScreen({super.key, this.booking});

  final Map<String, dynamic>? booking;

  @override
  State<VendorBookingAddScreen> createState() => _VendorBookingAddScreenState();
}

class _VendorBookingAddScreenState extends State<VendorBookingAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _coupleIdController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  String _selectedType = vendorServiceFormOptions.first.value;
  bool _status = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _coupleIdController = TextEditingController();
    _dateController = TextEditingController(
      text: DateFormat('d MMM y').format(_selectedDate),
    );
    _notesController = TextEditingController();
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
    final booking = widget.booking;
    final isEditing = booking != null;

    if (!_initialized && booking != null) {
      _initialized = true;
      _coupleIdController.text = _readString(booking, const ['couple_id']);
      _notesController.text = _readString(booking, const [
        'notes',
        'description',
      ]);
      _selectedType = _readType(booking);
      _status = _readStatus(booking);
      final parsedDate = DateTime.tryParse(
        _readString(booking, const ['booking_date', 'date', 'scheduled_at']),
      );
      if (parsedDate != null) {
        _selectedDate = parsedDate;
        _dateController.text = DateFormat('d MMM y').format(parsedDate);
      }
    }

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Booking' : 'Add Booking',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VendorBookingInlinePreview(
                coupleId: _coupleIdController.text.trim(),
                typeService: _selectedType,
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
                      const VendorBookingFormLabel(text: 'Couple ID'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _coupleIdController,
                        readOnly: isEditing,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: vendorBookingFieldDecoration(
                          hintText: '5',
                          icon: Icons.group_rounded,
                        ),
                        validator: (value) {
                          if (isEditing) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'Couple ID is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const VendorBookingFormLabel(text: 'Service type'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: vendorServiceFormOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option.value,
                                child: Text(option.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedType = value);
                        },
                        decoration: vendorBookingFieldDecoration(
                          hintText: 'Choose service type',
                          icon: Icons.category_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Service type is required';
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
                      if (vm.error != null) ...[
                        const SizedBox(height: 16),
                        VendorBookingErrorBanner(message: vm.error!),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: vm.busy
                              ? null
                              : () => _saveBooking(context, vm, booking),
                          style: FilledButton.styleFrom(
                            backgroundColor: welcomePrimaryDeepColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: vm.busy
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
                            isEditing ? 'Update Booking' : 'Save Booking',
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

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null) return;

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

    final draft = VendorBookingDraft(
      coupleId: _coupleIdController.text.trim(),
      typeService: _selectedType,
      bookingDate: _selectedDate,
      status: _status,
      notes: _notesController.text.trim(),
    );

    try {
      if (booking == null) {
        await vm.createBooking(draft);
      } else {
        await vm.updateBooking(booking['id'], draft);
      }

      if (!context.mounted) return;
      Navigator.of(context).pop(
        booking == null
            ? 'Booking created successfully.'
            : 'Booking updated successfully.',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Unable to save booking')),
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

  String _readType(Map<String, dynamic> source) {
    final value = _readString(source, const [
      'type_service',
      'service_type',
      'category',
    ]);
    if (value.isEmpty) return vendorServiceFormOptions.first.value;

    final normalized = value.toLowerCase().replaceAll(' ', '_');
    final option = vendorServiceFormOptions.firstWhere(
      (item) => item.value == normalized,
      orElse: () => vendorServiceFormOptions.first,
    );
    return option.value;
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
}
