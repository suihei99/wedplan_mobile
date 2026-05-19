import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/auth/auth_models.dart';
import 'package:wedplan_mobile/views/auth/welcome/form_fields.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class WelcomeAuthSheet extends StatefulWidget {
  const WelcomeAuthSheet({
    super.key,
    required this.mode,
    required this.primary,
    required this.primaryDeep,
    required this.textColor,
  });

  final WelcomeAuthMode mode;
  final Color primary;
  final Color primaryDeep;
  final Color textColor;

  @override
  State<WelcomeAuthSheet> createState() => _WelcomeAuthSheetState();
}

class _WelcomeAuthSheetState extends State<WelcomeAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.mode == WelcomeAuthMode.login;
    final isVendor = widget.mode == WelcomeAuthMode.registerVendor;
    final title = switch (widget.mode) {
      WelcomeAuthMode.login => 'Login to WedPlan',
      WelcomeAuthMode.registerCouple => 'Create a Couple Account',
      WelcomeAuthMode.registerVendor => 'Create a Vendor Account',
    };
    final subtitle = switch (widget.mode) {
      WelcomeAuthMode.login =>
        'Sign in to continue your wedding planning journey.',
      WelcomeAuthMode.registerCouple =>
        'Start your planning journey with a couple profile.',
      WelcomeAuthMode.registerVendor =>
        'Set up your vendor profile and start receiving bookings.',
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.72,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: welcomeSurfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: controller,
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: 18 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: widget.primaryDeep.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: widget.textColor.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isLogin) ...[
                      WelcomeFieldLabel(
                        label: 'Full name',
                        color: widget.textColor,
                      ),
                      const SizedBox(height: 8),
                      WelcomeAuthTextField(
                        controller: _nameController,
                        hintText: 'Enter your full name',
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    WelcomeFieldLabel(label: 'Email', color: widget.textColor),
                    const SizedBox(height: 8),
                    WelcomeAuthTextField(
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
                    if (!isLogin) ...[
                      WelcomeFieldLabel(
                        label: 'Phone',
                        color: widget.textColor,
                      ),
                      const SizedBox(height: 8),
                      WelcomeAuthTextField(
                        controller: _phoneController,
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    WelcomeFieldLabel(
                      label: 'Password',
                      color: widget.textColor,
                    ),
                    const SizedBox(height: 8),
                    WelcomeAuthTextField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      obscureText: !_passwordVisible,
                      textInputAction: isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
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
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: widget.primaryDeep,
                        ),
                      ),
                    ),
                    if (!isLogin) ...[
                      const SizedBox(height: 14),
                      WelcomeFieldLabel(
                        label: 'Confirm password',
                        color: widget.textColor,
                      ),
                      const SizedBox(height: 8),
                      WelcomeAuthTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm your password',
                        obscureText: !_confirmPasswordVisible,
                        textInputAction: TextInputAction.done,
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
                          onPressed: () => setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          }),
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: widget.primaryDeep,
                          ),
                        ),
                      ),
                    ],
                    if (isVendor) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              color: widget.primaryDeep,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Vendor accounts are set up for service providers, planners, and wedding businesses.',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textColor.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final payload = <String, dynamic>{
                            'email': _emailController.text.trim(),
                            'password': _passwordController.text,
                          };

                          if (!isLogin) {
                            payload.addAll(<String, dynamic>{
                              'name': _nameController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'password_confirmation':
                                  _confirmPasswordController.text,
                              'role': isVendor ? 'vendor' : 'couple',
                            });
                          }

                          Navigator.of(context).pop(
                            WelcomeAuthPayload(
                              mode: widget.mode,
                              body: payload,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryDeep,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isLogin ? 'Login' : 'Create Account',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
