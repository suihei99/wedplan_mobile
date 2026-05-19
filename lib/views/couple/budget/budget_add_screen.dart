import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:wedplan_mobile/viewmodels/couple/budget_view_model.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class BudgetAddScreen extends StatefulWidget {
  const BudgetAddScreen({super.key, required this.viewModel});

  final BudgetViewModel viewModel;

  @override
  State<BudgetAddScreen> createState() => _BudgetAddScreenState();
}

class _BudgetAddScreenState extends State<BudgetAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = widget.viewModel.overview;
    final suggestions = _suggestions(overview?.totalBudget ?? 0);

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          'Add Budget Category',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroCard(totalBudget: overview?.totalBudget ?? 0),
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
                      _FieldLabel(text: 'Category name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _categoryController,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          hintText: 'Venue, Catering, Dress, Photography',
                          icon: Icons.label_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Allocated amount'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: _fieldDecoration(
                          hintText: '0.00',
                          icon: Icons.payments_rounded,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid allocated amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final amount in suggestions)
                            _SuggestionChip(
                              label: amount.label,
                              onTap: () {
                                _amountController.text = amount.value
                                    .toStringAsFixed(2);
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (widget.viewModel.error != null) ...[
                        _InlineError(message: widget.viewModel.error!),
                        const SizedBox(height: 14),
                      ],
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: widget.viewModel.busy ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: welcomePrimaryDeepColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: widget.viewModel.busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Create Category',
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.viewModel.createCategory(
        categoryName: _categoryController.text.trim(),
        allocatedAmount: double.parse(_amountController.text.trim()),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.error ?? 'Unable to create category'),
        ),
      );
    }
  }

  List<_AmountSuggestion> _suggestions(double totalBudget) {
    if (totalBudget <= 0) {
      return const [
        _AmountSuggestion(label: 'RM 5,000', value: 5000),
        _AmountSuggestion(label: 'RM 10,000', value: 10000),
        _AmountSuggestion(label: 'RM 15,000', value: 15000),
      ];
    }

    return [
      _AmountSuggestion(label: '10%', value: totalBudget * 0.10),
      _AmountSuggestion(label: '15%', value: totalBudget * 0.15),
      _AmountSuggestion(label: '20%', value: totalBudget * 0.20),
    ];
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.totalBudget});

  final double totalBudget;

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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.add_chart_rounded,
              color: welcomePrimaryDeepColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a focused allocation',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  totalBudget > 0
                      ? 'Use the suggestions below to keep your category splits balanced inside RM ${NumberFormat('#,##0.00').format(totalBudget)}.'
                      : 'No total budget is set yet, so you can create starter categories and refine them later.',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
      ),
      onPressed: onTap,
      backgroundColor: const Color(0xFFFCE0E5),
      labelStyle: const TextStyle(color: welcomePrimaryDeepColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCCD6)),
      ),
      child: Text(
        message,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF7C6B71),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String hintText,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(icon, color: welcomePrimaryDeepColor),
    filled: true,
    fillColor: const Color(0xFFFFFBFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFEEDCE1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFEEDCE1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: welcomePrimaryDeepColor, width: 1.4),
    ),
  );
}

class _AmountSuggestion {
  const _AmountSuggestion({required this.label, required this.value});

  final String label;
  final double value;
}
