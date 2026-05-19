import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: welcomeTextColor,
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onFieldSubmitted,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      style: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: welcomeTextColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: welcomeTextColor.withValues(alpha: 0.42),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: welcomePrimaryDeepColor.withValues(alpha: 0.16),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: welcomePrimaryDeepColor.withValues(alpha: 0.16),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: welcomePrimaryDeepColor,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class AuthFilePickerField extends StatelessWidget {
  const AuthFilePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
    required this.onChanged,
    this.helperText,
    this.validator,
  });

  final String label;
  final PlatformFile? value;
  final Future<PlatformFile?> Function() onPick;
  final ValueChanged<PlatformFile?> onChanged;
  final String? helperText;
  final String? Function(PlatformFile?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<PlatformFile>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        final selectedFile = state.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthFieldLabel(label: label),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pickedFile = await onPick();
                state.didChange(pickedFile);
                onChanged(pickedFile);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.redAccent
                        : welcomePrimaryDeepColor.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      color: welcomePrimaryDeepColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile?.name ?? 'Choose a document',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedFile == null
                              ? welcomeTextColor.withValues(alpha: 0.42)
                              : welcomeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Browse',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: welcomePrimaryDeepColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (helperText != null) ...[
              const SizedBox(height: 6),
              Text(
                helperText!,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: welcomeTextColor.withValues(alpha: 0.62),
                ),
              ),
            ],
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText!,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
