import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/auth/auth_models.dart';
import 'package:wedplan_mobile/viewmodels/auth/auth_view_model.dart';
import 'package:wedplan_mobile/views/auth/widgets/auth_fields.dart';
import 'package:wedplan_mobile/views/auth/widgets/auth_navigation.dart';
import 'package:wedplan_mobile/views/auth/widgets/auth_page_shell.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';
import 'package:wedplan_mobile/views/vendor/service/widgets/vendor_service_widgets.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  PlatformFile? _document;
  String? _businessTypeValue;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _businessNameController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return AuthPageShell(
            title: 'Create Vendor Account',
            subtitle:
                'Register your business profile and upload the required document to continue.',
            busy: vm.busy,
            onBack: () => Navigator.of(context).maybePop(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthFieldLabel(label: 'Email'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Business name'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _businessNameController,
                    hintText: 'Enter your business name',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Business name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Business type'),
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
                    decoration: InputDecoration(
                      hintText: 'Select business type',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: welcomePrimaryDeepColor.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: welcomePrimaryDeepColor.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: welcomePrimaryDeepColor,
                          width: 1.2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Business type is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Contact number'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _contactNumberController,
                    hintText: 'Enter your contact number',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Contact number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Address'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _addressController,
                    hintText: 'Enter your business address',
                    textInputAction: TextInputAction.next,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AuthFilePickerField(
                    label: 'Business document',
                    value: _document,
                    helperText:
                        'Upload a PDF or image file that proves your business identity.',
                    onPick: _pickDocument,
                    onChanged: (value) => setState(() => _document = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Business document is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Password'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Create a password',
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Use at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: welcomePrimaryDeepColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Confirm password'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm your password',
                    obscureText: !_confirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(
                          () => _confirmPasswordVisible =
                              !_confirmPasswordVisible,
                        );
                      },
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: welcomePrimaryDeepColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: vm.busy ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: welcomePrimaryDeepColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Create Vendor Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<PlatformFile?> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    return result?.files.single;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedFile = _document;
    if (selectedFile == null || selectedFile.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a business document.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final payload = FormData.fromMap(<String, dynamic>{
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'business_name': _businessNameController.text.trim(),
      'business_type': _businessTypeValue,
      'contact_number': _contactNumberController.text.trim(),
      'address': _addressController.text.trim(),
      'business_documents': MultipartFile.fromBytes(
        selectedFile.bytes!,
        filename: selectedFile.name,
      ),
    });

    final vm = context.read<AuthViewModel>();
    try {
      final response = await vm.submit(AuthMode.registerVendor, payload);

      if (!mounted) return;

      navigateToAuthDashboard(
        context,
        response,
        fallbackMode: AuthMode.registerVendor,
      );
    } on DioException {
      if (!mounted) return;

      final message = vm.error ?? 'Something went wrong. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }
}
