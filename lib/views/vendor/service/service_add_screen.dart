import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/models/vendor/vendor_service_draft.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_service_management_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

class VendorServiceAddScreen extends StatefulWidget {
  const VendorServiceAddScreen({super.key, this.service});

  final VendorService? service;

  @override
  State<VendorServiceAddScreen> createState() => _VendorServiceAddScreenState();
}

class _VendorServiceAddScreenState extends State<VendorServiceAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serviceNameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  String _selectedType = vendorServiceFormOptions.first.value;
  String? _imagePath;
  String? _imageLabel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _serviceNameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VendorServiceManagementViewModel>(
      context,
      listen: false,
    );
    final service = widget.service;
    final isEditing = service != null;

    if (!_initialized && service != null) {
      _initialized = true;
      _serviceNameController.text = service.serviceName;
      _priceController.text = service.priceEstimate.toStringAsFixed(2);
      _descriptionController.text = service.description;

      final normalizedType = normalizeVendorServiceTypeSelection(
        service.typeService,
      );
      _selectedType =
          vendorServiceFormOptions.any(
            (option) => option.value == normalizedType,
          )
          ? normalizedType
          : vendorServiceFormOptions.first.value;
      _imageLabel = service.hasImage ? 'Current image attached' : null;
    }

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Service' : 'Add Service',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroCard(isEditing: isEditing),
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
                      const _FieldLabel(text: 'Service name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _serviceNameController,
                        textInputAction: TextInputAction.next,
                        decoration: serviceFieldDecoration(
                          hintText: 'Photography package, bridal styling',
                          icon: Icons.label_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Service name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(text: 'Service type'),
                      const SizedBox(height: 8),
                      VendorServiceTypeDropdown(
                        value: _selectedType,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedType = value);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Service type is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(text: 'Price estimate'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: serviceFieldDecoration(
                          hintText: '0.00',
                          icon: Icons.payments_rounded,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(text: 'Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: serviceFieldDecoration(
                          hintText:
                              'Explain the package, inclusions, and notes',
                          icon: Icons.notes_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(text: 'Service image'),
                      const SizedBox(height: 8),
                      _ImagePickerTile(
                        label: _imageLabel ?? 'Attach an image',
                        onTap: _pickImage,
                      ),
                      if (vm.error != null) ...[
                        const SizedBox(height: 16),
                        VendorServiceErrorBanner(message: vm.error!),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: vm.busy
                              ? null
                              : () => _submit(context, vm),
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
                              : Icon(
                                  isEditing
                                      ? Icons.save_rounded
                                      : Icons.add_rounded,
                                ),
                          label: Text(
                            isEditing ? 'Update Service' : 'Save Service',
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _imagePath = result.files.single.path;
      _imageLabel = result.files.single.name;
    });
  }

  Future<void> _submit(
    BuildContext context,
    VendorServiceManagementViewModel vm,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = VendorServiceDraft(
      serviceName: _serviceNameController.text.trim(),
      typeService: vendorServiceTypeApiValue(_selectedType),
      priceEstimate: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      imagePath: _imagePath,
    );

    try {
      if (widget.service == null) {
        await vm.createService(draft);
      } else {
        await vm.updateService(widget.service!.id, draft);
      }

      if (!context.mounted) return;
      Navigator.of(context).pop(
        widget.service == null
            ? 'Service created successfully.'
            : 'Service updated successfully.',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Unable to save service')),
      );
    }
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.isEditing});

  final bool isEditing;

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
              isEditing ? 'EDIT SERVICE' : 'ADD SERVICE',
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
            isEditing
                ? 'Refine the current listing.'
                : 'Create a service listing couples can trust.',
            style: GoogleFonts.manrope(
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the form short, clear, and ready for mobile users to review quickly.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF8FA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF4E1E6)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE0E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.image_outlined, color: Color(0xFFE04F6D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: welcomeTextColor,
                ),
              ),
            ),
            const Icon(Icons.upload_rounded, color: Color(0xFFE04F6D)),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

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
