import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/models/vendor/vendor_service_draft.dart';
import 'package:wedplan_mobile/viewmodels/vendor/vendor_service_management_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

class VendorServiceViewScreen extends StatefulWidget {
  const VendorServiceViewScreen({super.key, required this.service});

  final VendorService service;

  @override
  State<VendorServiceViewScreen> createState() =>
      _VendorServiceViewScreenState();
}

class _VendorServiceViewScreenState extends State<VendorServiceViewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serviceNameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  VendorService? _service;
  bool _busy = true;
  bool _saving = false;
  String? _error;
  String _selectedType = vendorServiceFormOptions.first.value;
  String? _imagePath;
  String? _imageLabel;

  @override
  void initState() {
    super.initState();
    _serviceNameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _service = widget.service;
    _syncFormWithService(widget.service);
    _loadService();
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
    final service = _service ?? widget.service;

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          service.serviceName,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _busy ? null : _loadService,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: _busy ? null : () => _confirmDelete(context, service),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _busy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroPanel(service: service, localImagePath: _imagePath),
                      const SizedBox(height: 16),
                      _LiveServicePreview(
                        serviceName: _serviceNameController.text.trim(),
                        serviceType: _selectedType,
                        priceText: _priceController.text.trim(),
                      ),
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
                            Text(
                              'Service details',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel(text: 'Service name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _serviceNameController,
                              onChanged: (_) => setState(() {}),
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
                              onChanged: (_) => setState(() {}),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.next,
                              decoration: serviceFieldDecoration(
                                hintText: '0.00',
                                icon: Icons.payments_rounded,
                              ),
                              validator: (value) {
                                final parsed = double.tryParse(
                                  (value ?? '').trim(),
                                );
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
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              VendorServiceErrorBanner(message: _error!),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _saveChanges,
                                style: FilledButton.styleFrom(
                                  backgroundColor: welcomePrimaryDeepColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                icon: _saving
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
                                  'Save Changes',
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
      ),
    );
  }

  Future<void> _loadService() async {
    final vm = Provider.of<VendorServiceManagementViewModel>(
      context,
      listen: false,
    );
    try {
      final refreshed = await vm.showService(widget.service.id);
      if (!mounted) return;
      setState(() {
        _service = refreshed ?? widget.service;
        _syncFormWithService(_service ?? widget.service);
        _busy = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _service = widget.service;
        _syncFormWithService(widget.service);
        _error = vm.error;
        _busy = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _imagePath = result.files.single.path;
      _imageLabel = result.files.single.name;
    });
  }

  void _syncFormWithService(VendorService service) {
    _serviceNameController.text = service.serviceName;
    _priceController.text = service.priceEstimate.toStringAsFixed(2);
    _descriptionController.text = service.description;

    final normalizedType = normalizeVendorServiceTypeSelection(
      service.typeService,
    );
    _selectedType =
        vendorServiceFormOptions.any((option) => option.value == normalizedType)
        ? normalizedType
        : vendorServiceFormOptions.first.value;

    _imagePath = null;
    _imageLabel = service.hasImage ? 'Current image attached' : null;
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentService = _service ?? widget.service;
    final vm = Provider.of<VendorServiceManagementViewModel>(
      context,
      listen: false,
    );
    final draft = VendorServiceDraft(
      serviceName: _serviceNameController.text.trim(),
      typeService: vendorServiceTypeApiValue(_selectedType),
      priceEstimate: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      imagePath: _imagePath,
    );

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final updated = await vm.updateService(currentService.id, draft);
      if (!mounted) return;
      setState(() {
        _service = updated ?? currentService;
        _syncFormWithService(_service ?? currentService);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = vm.error ?? 'Unable to update service';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VendorService service,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete service?'),
          content: Text(
            'Remove ${service.serviceName} from the service catalog?',
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

    final vm = Provider.of<VendorServiceManagementViewModel>(
      context,
      listen: false,
    );
    try {
      await vm.deleteService(service.id);
      if (!mounted) return;
      Navigator.of(context).pop('Service deleted successfully.');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Unable to delete service')),
      );
    }
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.service, this.localImagePath});

  final VendorService service;
  final String? localImagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: SizedBox(
        height: 220,
        child: localImagePath != null && localImagePath!.trim().isNotEmpty
            ? Image.file(
                File(localImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallbackImage(),
              )
            : service.hasImage
            ? CachedNetworkImage(
                imageUrl: service.resolvedImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFF9EEF1),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => _fallbackImage(),
              )
            : _fallbackImage(),
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
        size: 48,
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

class _LiveServicePreview extends StatelessWidget {
  const _LiveServicePreview({
    required this.serviceName,
    required this.serviceType,
    required this.priceText,
  });

  final String serviceName;
  final String serviceType;
  final String priceText;

  @override
  Widget build(BuildContext context) {
    final parsed = double.tryParse(priceText);
    final title = serviceName.isEmpty ? 'Service name preview' : serviceName;
    final typeLabel = vendorServiceFormOptions
        .firstWhere(
          (option) => option.value == serviceType,
          orElse: () =>
              const VendorServiceTypeOption(value: 'other', label: 'Other'),
        )
        .label;
    final priceLabel = parsed == null
        ? 'RM 0.00'
        : 'RM ${parsed.toStringAsFixed(2)}';

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
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MetaChip(label: typeLabel),
              const SizedBox(height: 6),
              Text(
                priceLabel,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: welcomePrimaryDeepColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
