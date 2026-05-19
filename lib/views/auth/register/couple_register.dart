import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/auth/auth_models.dart';
import 'package:wedplan_mobile/viewmodels/auth/auth_view_model.dart';
import 'package:wedplan_mobile/views/auth/widgets/auth_fields.dart';
import 'package:wedplan_mobile/views/auth/widgets/auth_navigation.dart';
import 'package:wedplan_mobile/views/auth/widgets/auth_page_shell.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class CoupleRegisterScreen extends StatefulWidget {
  const CoupleRegisterScreen({super.key});

  @override
  State<CoupleRegisterScreen> createState() => _CoupleRegisterScreenState();
}

class _CoupleRegisterScreenState extends State<CoupleRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _partnerOneController = TextEditingController();
  final _partnerTwoController = TextEditingController();
  final _weddingDateController = TextEditingController();
  final _weddingVenueController = TextEditingController();
  final _weddingTimeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _partnerOneController.dispose();
    _partnerTwoController.dispose();
    _weddingDateController.dispose();
    _weddingVenueController.dispose();
    _weddingTimeController.dispose();
    _budgetController.dispose();
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
            title: 'Create Couple Account',
            subtitle:
                'Set up your couple profile with the details your planning flow needs.',
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
                  const AuthFieldLabel(label: 'Partner 1 name'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _partnerOneController,
                    hintText: 'Enter the first partner name',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Partner 1 name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Partner 2 name'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _partnerTwoController,
                    hintText: 'Enter the second partner name',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Partner 2 name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Wedding date (optional)'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _weddingDateController,
                    hintText: 'Choose a wedding date',
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 30),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate == null) {
                        return;
                      }

                      _weddingDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                      setState(() {});
                    },
                    suffixIcon: const Icon(Icons.calendar_month_rounded),
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Wedding venue (optional)'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _weddingVenueController,
                    hintText: 'Enter the venue',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Wedding time (optional)'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _weddingTimeController,
                    hintText: 'Choose a wedding time',
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime == null) {
                        return;
                      }

                      final hours = pickedTime.hour.toString().padLeft(2, '0');
                      final minutes = pickedTime.minute.toString().padLeft(
                        2,
                        '0',
                      );
                      _weddingTimeController.text = '$hours:$minutes';
                      setState(() {});
                    },
                    suffixIcon: const Icon(Icons.schedule_rounded),
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Total budget limit (optional)'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _budgetController,
                    hintText: 'Enter your budget limit',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
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
                        'Create Couple Account',
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

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = <String, dynamic>{
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'partner_1_name': _partnerOneController.text.trim(),
      'partner_2_name': _partnerTwoController.text.trim(),
    };

    if (_weddingDateController.text.trim().isNotEmpty) {
      payload['wedding_date'] = _weddingDateController.text.trim();
    }

    if (_weddingVenueController.text.trim().isNotEmpty) {
      payload['wedding_venue'] = _weddingVenueController.text.trim();
    }

    if (_weddingTimeController.text.trim().isNotEmpty) {
      payload['wedding_time'] = _weddingTimeController.text.trim();
    }

    final budgetValue = int.tryParse(_budgetController.text.trim());
    if (budgetValue != null) {
      payload['total_budget_limit'] = budgetValue;
    }

    final vm = context.read<AuthViewModel>();
    try {
      final response = await vm.submit(AuthMode.registerCouple, payload);

      if (!mounted) return;

      navigateToAuthDashboard(
        context,
        response,
        fallbackMode: AuthMode.registerCouple,
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
