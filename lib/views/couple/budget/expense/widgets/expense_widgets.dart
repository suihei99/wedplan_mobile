import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class ExpenseHeroCard extends StatelessWidget {
  const ExpenseHeroCard({
    super.key,
    required this.category,
    required this.currencyLabel,
    this.onAddExpense,
    this.onOpenCategoryDetails,
  });

  final BudgetCategory category;
  final String currencyLabel;
  final VoidCallback? onAddExpense;
  final VoidCallback? onOpenCategoryDetails;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (category.status) {
      BudgetCategoryStatus.healthy => const Color(0xFF2BA56A),
      BudgetCategoryStatus.low => const Color(0xFFF0A43B),
      BudgetCategoryStatus.overBudget => const Color(0xFFE04F6D),
      BudgetCategoryStatus.unknown => const Color(0xFF8D7C83),
    };

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (onAddExpense != null)
                FilledButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Expense'),
                  style: FilledButton.styleFrom(
                    backgroundColor: welcomePrimaryDeepColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              if (onOpenCategoryDetails != null)
                OutlinedButton.icon(
                  onPressed: onOpenCategoryDetails,
                  icon: const Icon(Icons.category_outlined),
                  label: const Text('Category Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: welcomePrimaryDeepColor,
                    side: const BorderSide(color: Color(0xFFEEDCE1)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExpenseStatusChip(
                      label: category.statusLabel,
                      color: statusColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.categoryName,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track every payment recorded under this budget category.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ExpenseStatusChip(
                            label: category.statusLabel,
                            color: statusColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.categoryName,
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track every payment recorded under this budget category.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7C6B71),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: welcomePrimaryDeepColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: welcomePrimaryDeepColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class ExpenseStatCard extends StatelessWidget {
  const ExpenseStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF21161A),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseItemCard extends StatelessWidget {
  const ExpenseItemCard({
    super.key,
    required this.expense,
    required this.currencyLabel,
    required this.onTap,
  });

  final BudgetExpense expense;
  final String currencyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEEDCE1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE0E5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: welcomePrimaryDeepColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.expenseName,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    expense.description.isNotEmpty
                        ? expense.description
                        : expense.paymentMethod.isNotEmpty
                        ? expense.paymentMethod
                        : expense.dateLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ExpensePill(label: expense.dateLabel),
                      if (expense.paymentMethod.isNotEmpty)
                        _ExpensePill(label: expense.paymentMethod),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$currencyLabel${expense.amount.toStringAsFixed(2)}',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: welcomePrimaryDeepColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({super.key, required this.onAddExpense});

  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: welcomePrimaryDeepColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No expenses yet',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add the first expense entry to start tracking payments for this category.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C6B71),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAddExpense,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Expense'),
            style: FilledButton.styleFrom(
              backgroundColor: welcomePrimaryDeepColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseSectionHeader extends StatelessWidget {
  const ExpenseSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7C6B71),
          ),
        ),
      ],
    );
  }
}

class ExpenseInlineBanner extends StatelessWidget {
  const ExpenseInlineBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF2),
        borderRadius: BorderRadius.circular(18),
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

class _ExpenseStatusChip extends StatelessWidget {
  const _ExpenseStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ExpensePill extends StatelessWidget {
  const _ExpensePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EEF0),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF7C6B71),
        ),
      ),
    );
  }
}
