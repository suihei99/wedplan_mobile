import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/viewmodels/couple/me_view_model.dart';

class CoupleViewScreen extends StatefulWidget {
  const CoupleViewScreen({super.key});

  @override
  State<CoupleViewScreen> createState() => _CoupleViewScreenState();
}

class _CoupleViewScreenState extends State<CoupleViewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _partnerOneController;
  late final TextEditingController _partnerTwoController;
  late final TextEditingController _weddingDateController;
  late final TextEditingController _weddingTimeController;
  late final TextEditingController _weddingVenueController;
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<MeViewModel>().profile;
    _partnerOneController = TextEditingController(
      text: profile?.partner1Name ?? '',
    );
    _partnerTwoController = TextEditingController(
      text: profile?.partner2Name ?? '',
    );
    _weddingDateController = TextEditingController(
      text: profile?.weddingDate ?? '',
    );
    _weddingTimeController = TextEditingController(
      text: profile?.weddingTime ?? '',
    );
    _weddingVenueController = TextEditingController(
      text: profile?.weddingVenue ?? '',
    );
    _budgetController = TextEditingController(
      text: (profile?.totalBudgetLimit ?? 0) > 0 == true
          ? profile!.totalBudgetLimit.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _partnerOneController.dispose();
    _partnerTwoController.dispose();
    _weddingDateController.dispose();
    _weddingTimeController.dispose();
    _weddingVenueController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeViewModel>();
    final profile = vm.profile;
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              _HeroCard(profile: profile),
              const SizedBox(height: 14),
              if (vm.error != null) ...[
                _ErrorBanner(message: vm.error!),
                const SizedBox(height: 14),
              ],
              _SectionShell(
                title: 'Profile Details',
                subtitle:
                    'Update your core wedding profile details for planning and budget tracking.',
                child: Column(
                  children: [
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: _TextFieldCard(
                              label: '1 - Person Couple Name',
                              controller: _partnerOneController,
                              icon: Icons.person_rounded,
                              validatorMessage: 'Partner 1 name is required',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TextFieldCard(
                              label: '2 - Person Couple Name',
                              controller: _partnerTwoController,
                              icon: Icons.favorite_rounded,
                              validatorMessage: 'Partner 2 name is required',
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _TextFieldCard(
                        label: '1 - Person Couple Name',
                        controller: _partnerOneController,
                        icon: Icons.person_rounded,
                        validatorMessage: 'Partner 1 name is required',
                      ),
                      const SizedBox(height: 12),
                      _TextFieldCard(
                        label: '2 - Person Couple Name',
                        controller: _partnerTwoController,
                        icon: Icons.favorite_rounded,
                        validatorMessage: 'Partner 2 name is required',
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: _PickerField(
                              label: 'Wedding Date',
                              controller: _weddingDateController,
                              icon: Icons.calendar_month_rounded,
                              onTap: () => _pickDate(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PickerField(
                              label: 'Wedding Time',
                              controller: _weddingTimeController,
                              icon: Icons.schedule_rounded,
                              onTap: () => _pickTime(context),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _PickerField(
                        label: 'Wedding Date',
                        controller: _weddingDateController,
                        icon: Icons.calendar_month_rounded,
                        onTap: () => _pickDate(context),
                      ),
                      const SizedBox(height: 12),
                      _PickerField(
                        label: 'Wedding Time',
                        controller: _weddingTimeController,
                        icon: Icons.schedule_rounded,
                        onTap: () => _pickTime(context),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _TextFieldCard(
                      label: 'Wedding Venue',
                      controller: _weddingVenueController,
                      icon: Icons.location_on_rounded,
                      validatorMessage: 'Wedding venue is required',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _TextFieldCard(
                      label: 'Total Budget Limit',
                      controller: _budgetController,
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      validatorMessage: 'Budget limit is required',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionShell(
                title: 'Account Details',
                subtitle: 'Email is read-only in WedPlan settings.',
                child: Column(
                  children: [
                    _ReadOnlyRow(label: 'Email', value: profile?.email ?? '-'),
                    _ReadOnlyRow(
                      label: 'Role',
                      value: profile?.role.isNotEmpty == true
                          ? profile!.role
                          : 'couple',
                    ),
                    _ReadOnlyRow(
                      label: 'Profile Photo',
                      value: profile?.profilePhotoUrl.isNotEmpty == true
                          ? 'Uploaded'
                          : 'Not set',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.saving ? null : () => _save(context, vm),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFE04F6D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: vm.saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : Text(
                          'Save Profile',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Use this page to keep the couple details aligned with your dashboard, budget, and guest list.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xFF7C6B71),
                ),
              ),
              if (vm.success != null) ...[
                const SizedBox(height: 10),
                Text(
                  vm.success!,
                  textAlign: TextAlign.center,
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
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final currentText = _weddingDateController.text.trim();
    DateTime initialDate = DateTime(now.year, now.month, now.day);
    if (currentText.isNotEmpty) {
      final parsed = DateTime.tryParse(currentText);
      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
    );

    if (picked == null) return;

    _weddingDateController.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    final formatted = picked.format(context);
    _weddingTimeController.text = formatted;
  }

  Future<void> _save(BuildContext context, MeViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await vm.updateCoupleProfile(
        partner1Name: _partnerOneController.text,
        partner2Name: _partnerTwoController.text,
        weddingDate: _weddingDateController.text,
        weddingVenue: _weddingVenueController.text,
        weddingTime: _weddingTimeController.text,
        totalBudgetLimit: _budgetController.text,
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
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});

  final CoupleMeProfile? profile;

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
            child: const Icon(Icons.settings_rounded, color: Color(0xFFE04F6D)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your profile and secure your account details.',
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

class _SectionShell extends StatelessWidget {
  const _SectionShell({
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TextFieldCard extends StatelessWidget {
  const _TextFieldCard({
    required this.label,
    required this.controller,
    required this.icon,
    required this.validatorMessage,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String validatorMessage;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE04F6D)),
        filled: true,
        fillColor: const Color(0xFFFFFBFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF0DDE1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF0DDE1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE04F6D), width: 1.4),
        ),
      ),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) return validatorMessage;
        return null;
      },
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE04F6D)),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        filled: true,
        fillColor: const Color(0xFFFFFBFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF0DDE1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF0DDE1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE04F6D), width: 1.4),
        ),
      ),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 98,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
