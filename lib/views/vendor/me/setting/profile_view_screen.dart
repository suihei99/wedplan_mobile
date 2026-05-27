import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/vendor/vendor_me_view_model.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _contactNumberController;
  late final TextEditingController _addressController;
  String? _businessTypeValue;
  String? _profilePhotoPath;
  String? _profilePhotoLabel;
  String? _documentPath;
  String? _documentLabel;

  @override
  void initState() {
    super.initState();
    final vm = context.read<VendorMeViewModel>();
    _contactNumberController = TextEditingController(text: vm.contactNumber);
    _addressController = TextEditingController(text: vm.address);
    _businessTypeValue = _initialBusinessTypeValue(vm.businessType);
  }

  @override
  void dispose() {
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VendorMeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              _HeroCard(vm: vm),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Business Details',
                subtitle:
                    'Business name is locked after registration and can only be changed by admin support.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReadOnlyRow(
                      label: 'Business Name',
                      value: vm.businessName.isNotEmpty
                          ? vm.businessName
                          : 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(label: 'Business Type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _businessTypeValue,
                      items: vendorServiceFormOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option.value,
                              child: Text(option.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _businessTypeValue = value;
                        });
                      },
                      decoration: _fieldDecoration(
                        hintText: 'Select business type',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Business type is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(label: 'Contact Number'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _contactNumberController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: _fieldDecoration(
                                  hintText: 'Enter contact number',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Contact number is required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel(label: 'Business Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      decoration: _fieldDecoration(
                        hintText: 'Enter business address',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Business address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyRow(
                      label: 'Email',
                      value: vm.email.isNotEmpty ? vm.email : 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyRow(
                      label: 'Role',
                      value: vm.role.isNotEmpty ? vm.role : 'vendor',
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyRow(
                      label: 'Profile Photo',
                      value: vm.hasProfilePhoto ? 'Uploaded' : 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _PickImageTile(
                      label:
                          _profilePhotoLabel ??
                          (vm.hasProfilePhoto
                              ? 'Current profile photo attached'
                              : 'Attach a profile photo'),
                      helperText: 'JPEG, PNG, or JPG only.',
                      onTap: _pickProfilePhoto,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Business Documentation',
                subtitle:
                    'Upload and review the document used for vendor verification.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DocumentPreviewCard(vm: vm),
                    const SizedBox(height: 12),
                    _PickImageTile(
                      label:
                          _documentLabel ??
                          (vm.hasBusinessDocument
                              ? 'Replace current business document'
                              : 'Choose business document'),
                      helperText: 'PDF, PNG, JPG, or JPEG.',
                      onTap: _pickBusinessDocument,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The uploaded file will be sent as business_documents to the settings API.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                    if (vm.error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: vm.error!),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: vm.saving ? null : () => _save(context, vm),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE04F6D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: vm.saving
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
                          'Save Profile',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (vm.success != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        vm.success!,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _profilePhotoPath = result.files.single.path;
      _profilePhotoLabel = result.files.single.name;
    });
  }

  Future<void> _pickBusinessDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _documentPath = result.files.single.path;
      _documentLabel = result.files.single.name;
    });
  }

  Future<void> _save(BuildContext context, VendorMeViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await vm.updateProfile(
        businessType: _businessTypeValue,
        contactNumber: _contactNumberController.text,
        address: _addressController.text,
        profilePhotoPath: _profilePhotoPath,
        businessDocumentPath: _documentPath,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.success ?? 'Profile updated')));
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Failed to update profile')),
      );
    }
  }

  InputDecoration _fieldDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFF1DADF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFF1DADF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE04F6D), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  String? _initialBusinessTypeValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final normalized = normalizeVendorServiceTypeSelection(trimmed);
    for (final option in vendorServiceFormOptions) {
      if (option.value == normalized ||
          option.label.toLowerCase() == trimmed.toLowerCase()) {
        return option.value;
      }
    }
    return null;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.vm});

  final VendorMeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8EE), Color(0xFFFFF7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF4D8DF)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: vm.hasProfilePhoto
                ? Image.network(
                    vm.profilePhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _AvatarFallback(vm: vm),
                  )
                : _AvatarFallback(vm: vm),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.businessName,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your business details and verification documents.',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF6F6468),
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

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.vm});

  final VendorMeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        vm.initials,
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE04F6D),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0DDE1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF21161A),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1DADF)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8C7980),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF21161A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreviewCard extends StatelessWidget {
  const _DocumentPreviewCard({required this.vm});

  final VendorMeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final documentSource = vm.businessDocumentUrl.isNotEmpty
        ? vm.businessDocumentUrl
        : vm.businessDocumentPath;
    final fileName = _fileName(documentSource);
    final isImage = _isImage(documentSource);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1DADF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current document',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8C7980),
            ),
          ),
          const SizedBox(height: 10),
          if (documentSource.isEmpty)
            Text(
              'No business document uploaded yet.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6F6468),
              ),
            )
          else ...[
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  documentSource,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _DocumentInfoRow(
                    icon: Icons.description_rounded,
                    label: fileName,
                    value: 'Image preview unavailable',
                  ),
                ),
              )
            else
              _DocumentInfoRow(
                icon: Icons.description_rounded,
                label: fileName,
                value: 'PDF document',
              ),
            const SizedBox(height: 10),
            _DocumentInfoRow(
              icon: Icons.link_rounded,
              label: 'Source',
              value: vm.businessDocumentUrl.isNotEmpty
                  ? 'Remote document URL'
                  : 'Stored document path',
            ),
          ],
        ],
      ),
    );
  }

  bool _isImage(String value) {
    final lower = value.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }

  String _fileName(String value) {
    if (value.isEmpty) return 'Business document';
    final uri = Uri.tryParse(value);
    final path = uri?.path ?? value;
    final segments = path.split('/');
    return segments.isNotEmpty && segments.last.isNotEmpty
        ? segments.last
        : 'Business document';
  }
}

class _DocumentInfoRow extends StatelessWidget {
  const _DocumentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFDCE0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE04F6D)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF21161A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
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

class _PickImageTile extends StatelessWidget {
  const _PickImageTile({
    required this.label,
    required this.helperText,
    required this.onTap,
  });

  final String label;
  final String helperText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDF2F5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.upload_file_rounded,
                size: 18,
                color: Color(0xFFE04F6D),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF21161A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      helperText,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
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
