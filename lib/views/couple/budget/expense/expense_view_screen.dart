import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wedplan_mobile/core/router/app_router.dart';
import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/models/couple/expense_models.dart';
import 'package:wedplan_mobile/viewmodels/couple/budget_view_model.dart';
import 'package:wedplan_mobile/viewmodels/couple/expense_view_model.dart';
import 'package:wedplan_mobile/views/couple/budget/expense/widgets/expense_widgets.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class ExpenseViewScreen extends StatefulWidget {
  const ExpenseViewScreen({
    super.key,
    required this.viewModel,
    required this.expense,
    required this.category,
  });

  final ExpenseViewModel viewModel;
  final BudgetExpense expense;
  final BudgetCategory category;

  @override
  State<ExpenseViewScreen> createState() => _ExpenseViewScreenState();
}

class _ExpenseViewScreenState extends State<ExpenseViewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;

  DateTime _selectedDate = DateTime.now();
  String _paymentMethodValue = expensePaymentMethodOptions.first.value;
  String? _receiptPath;
  String? _receiptLabel;

  @override
  void initState() {
    super.initState();
    final currentExpense =
        widget.viewModel.expenseById(widget.expense.id) ?? widget.expense;
    _selectedDate = _parseDate(currentExpense.datePaid) ?? DateTime.now();
    _nameController = TextEditingController(text: currentExpense.expenseName);
    _amountController = TextEditingController(
      text: currentExpense.amount.toStringAsFixed(2),
    );
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _descriptionController = TextEditingController(
      text: currentExpense.description,
    );
    final normalizedPaymentMethod = normalizeExpensePaymentMethod(
      currentExpense.paymentMethod,
    );
    _paymentMethodValue =
        expensePaymentMethodOptions.any(
          (option) => option.value == normalizedPaymentMethod,
        )
        ? normalizedPaymentMethod
        : expensePaymentMethodOptions.first.value;
    _receiptLabel = currentExpense.receiptUrl.isNotEmpty
        ? _receiptLabelFromUrl(currentExpense.receiptUrl)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExpense =
        widget.viewModel.expenseById(widget.expense.id) ?? widget.expense;
    final currentCategory =
        widget.viewModel.categoryById(currentExpense.budgetCategoryId) ??
        widget.category;
    final currency = 'RM ';

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      appBar: AppBar(
        backgroundColor: welcomeBackgroundColor,
        foregroundColor: welcomeTextColor,
        elevation: 0,
        title: Text(
          currentExpense.expenseName,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: widget.viewModel.busy
                ? null
                : () => _confirmDelete(context, currentExpense),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(
                expense: currentExpense,
                category: currentCategory,
                currency: currency,
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
                        'Edit Expense',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Category'),
                      const SizedBox(height: 8),
                      _ReadOnlyField(
                        value: currentCategory.categoryName,
                        icon: Icons.category_rounded,
                        helperText: 'Locked to the original budget category.',
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Expense name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        readOnly: true,
                        decoration:
                            _fieldDecoration(
                              hintText: 'Expense name',
                              icon: Icons.label_rounded,
                            ).copyWith(
                              helperText:
                                  'This value is kept from the original expense record.',
                            ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Amount'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _fieldDecoration(
                          hintText: '0.00',
                          icon: Icons.payments_rounded,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 420;
                          final dateField = TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: _fieldDecoration(
                              hintText: 'Select date',
                              icon: Icons.calendar_month_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Date is required';
                              }
                              return null;
                            },
                          );

                          if (compact) {
                            return dateField;
                          }

                          return dateField;
                        },
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Payment method'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _paymentMethodValue,
                        isExpanded: true,
                        isDense: true,
                        items: expensePaymentMethodOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option.value,
                                child: Text(
                                  option.label,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _paymentMethodValue = value);
                          }
                        },
                        decoration: _fieldDecoration(
                          hintText: 'Select payment method',
                          icon: Icons.credit_card_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Payment method is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _fieldDecoration(
                          hintText: 'Add notes about the payment',
                          icon: Icons.notes_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(text: 'Receipt'),
                      const SizedBox(height: 8),
                      _ReceiptButton(
                        label: _receiptLabel ?? 'Attach receipt file',
                        onTap: _pickReceipt,
                      ),
                      if (currentExpense.receiptUrl.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _ReceiptPreviewCard(
                          receiptUrl: currentExpense.receiptUrl,
                          onOpen: () => _openReceipt(currentExpense.receiptUrl),
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (widget.viewModel.error != null) ...[
                        ExpenseInlineBanner(message: widget.viewModel.error!),
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
                                  'Update Expense',
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  Future<void> _pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      _receiptPath = result.files.single.path;
      _receiptLabel = result.files.single.name;
    });
  }

  Future<void> _openReceipt(String receiptUrl) async {
    final normalizedUrl = _normalizeReceiptUrl(receiptUrl);
    if (normalizedUrl.isEmpty) return;

    await launchUrl(
      Uri.parse(normalizedUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final draft = ExpenseDraft(
        budgetCategoryId: widget.expense.budgetCategoryId ?? widget.category.id,
        expenseName: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        datePaid: _selectedDate,
        description: _descriptionController.text.trim(),
        paymentMethod: _paymentMethodValue,
        receiptPath: _receiptPath,
      );

      await widget.viewModel.updateExpense(widget.expense.id, draft);

      if (!mounted) return;
      Navigator.of(context).pop('Expense updated successfully.');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.error ?? 'Unable to update expense'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BudgetExpense expense,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: const Text(
            'This will remove the expense from the category log.',
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

    try {
      await widget.viewModel.deleteExpense(expense.id);
      if (!mounted) return;
      Navigator.of(context).pop('Expense deleted successfully.');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.error ?? 'Unable to delete expense'),
        ),
      );
    }
  }

  DateTime? _parseDate(String value) {
    return DateTime.tryParse(value);
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.expense,
    required this.category,
    required this.currency,
  });

  final BudgetExpense expense;
  final BudgetCategory category;
  final String currency;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(label: category.categoryName),
              _MetaChip(
                label: expense.paymentMethod.isNotEmpty
                    ? displayExpensePaymentMethod(expense.paymentMethod)
                    : 'Manual Entry',
              ),
              _MetaChip(label: expense.dateLabel),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            expense.expenseName,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            expense.description.isNotEmpty
                ? expense.description
                : 'Edit the details below and keep the category log synchronized with the backend.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$currency${expense.amount.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: welcomePrimaryDeepColor,
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.value,
    required this.icon,
    this.helperText,
  });

  final String value;
  final IconData icon;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: welcomePrimaryDeepColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: welcomeTextColor,
                  ),
                ),
                if (helperText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    helperText!,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptButton extends StatelessWidget {
  const _ReceiptButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.attach_file_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: welcomePrimaryDeepColor,
        side: const BorderSide(color: Color(0xFFEEDCE1)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _ReceiptPreviewCard extends StatelessWidget {
  const _ReceiptPreviewCard({required this.receiptUrl, required this.onOpen});

  final String receiptUrl;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = _normalizeReceiptUrl(receiptUrl);
    final receiptName = _receiptNameFromUrl(normalizedUrl);
    final isImage = _isImageUrl(normalizedUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: welcomePrimaryDeepColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt uploaded',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: welcomeTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      receiptName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onOpen, child: const Text('Open')),
            ],
          ),
          if (isImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  normalizedUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _ReceiptFilePlaceholder(
                      receiptName: receiptName,
                      onOpen: onOpen,
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _ReceiptFilePlaceholder(receiptName: receiptName, onOpen: onOpen),
          ],
        ],
      ),
    );
  }
}

class _ReceiptFilePlaceholder extends StatelessWidget {
  const _ReceiptFilePlaceholder({
    required this.receiptName,
    required this.onOpen,
  });

  final String receiptName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE0E5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                color: welcomePrimaryDeepColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  receiptName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: welcomeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open receipt'),
            style: FilledButton.styleFrom(
              backgroundColor: welcomePrimaryDeepColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

String _normalizeReceiptUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed;
  if (uri.hasScheme) return trimmed;

  final baseUri = Uri.parse(ApiRouter.baseUrl);
  final relativePath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  return baseUri.resolve(relativePath).toString();
}

String _receiptLabelFromUrl(String value) {
  final normalizedUrl = _normalizeReceiptUrl(value);
  if (normalizedUrl.isEmpty) return 'Receipt attached';

  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null || uri.pathSegments.isEmpty) return 'Receipt attached';

  final name = uri.pathSegments.last;
  return name.isNotEmpty ? name : 'Receipt attached';
}

String _receiptNameFromUrl(String value) {
  final normalizedUrl = _normalizeReceiptUrl(value);
  if (normalizedUrl.isEmpty) return 'Receipt';

  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null || uri.pathSegments.isEmpty) return 'Receipt';

  final name = uri.pathSegments.last;
  return name.isNotEmpty ? name : 'Receipt';
}

bool _isImageUrl(String value) {
  final lower = value.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif');
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE0E5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: welcomePrimaryDeepColor,
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
