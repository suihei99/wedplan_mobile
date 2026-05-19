import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/viewmodels/couple/expense_view_model.dart';
import 'package:wedplan_mobile/views/couple/budget/expense/expense_add_screen.dart';
import 'package:wedplan_mobile/views/couple/budget/expense/expense_view_screen.dart';
import 'package:wedplan_mobile/views/couple/budget/expense/widgets/expense_widgets.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, required this.category});

  final BudgetCategory category;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late final ExpenseViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ExpenseViewModel(selectedCategory: widget.category)..load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ExpenseViewModel>(
        builder: (context, vm, _) {
          final category = vm.selectedCategory ?? widget.category;
          final expenses = vm.expensesForCategory(category.id);
          final currency = 'RM ';

          return Scaffold(
            backgroundColor: welcomeBackgroundColor,
            appBar: AppBar(
              backgroundColor: welcomeBackgroundColor,
              foregroundColor: welcomeTextColor,
              elevation: 0,
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${category.categoryName} Expenses',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Track every payment recorded for this category.',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6F6468),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: vm.busy
                  ? null
                  : () => _openAddExpense(context, vm, category),
              backgroundColor: welcomePrimaryDeepColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Expense',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: welcomePrimaryDeepColor,
                onRefresh: () => vm.load(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    ExpenseHeroCard(
                      category: category,
                      currencyLabel: currency,
                      onAddExpense: vm.busy
                          ? null
                          : () => _openAddExpense(context, vm, category),
                    ),
                    const SizedBox(height: 14),
                    if (vm.error != null) ...[
                      ExpenseInlineBanner(message: vm.error!),
                      const SizedBox(height: 14),
                    ],
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 360;
                        final statWidth = narrow
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 12) / 2;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: statWidth,
                              child: ExpenseStatCard(
                                label: 'Allocated',
                                value:
                                    '$currency${category.allocatedAmount.toStringAsFixed(2)}',
                                icon: Icons.account_balance_wallet_rounded,
                                accentColor: welcomePrimaryDeepColor,
                              ),
                            ),
                            SizedBox(
                              width: statWidth,
                              child: ExpenseStatCard(
                                label: 'Spent',
                                value:
                                    '$currency${category.spentAmount.toStringAsFixed(2)}',
                                icon: Icons.payments_rounded,
                                accentColor: const Color(0xFFE04F6D),
                              ),
                            ),
                            SizedBox(
                              width: statWidth,
                              child: ExpenseStatCard(
                                label: 'Remaining',
                                value:
                                    '$currency${category.remainingAmount.toStringAsFixed(2)}',
                                icon: Icons.savings_outlined,
                                accentColor: const Color(0xFF2BA56A),
                              ),
                            ),
                            SizedBox(
                              width: statWidth,
                              child: ExpenseStatCard(
                                label: 'Records',
                                value: '${expenses.length}',
                                icon: Icons.receipt_long_rounded,
                                accentColor: const Color(0xFFF0A43B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEEDCE1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Category Usage',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              _UsageChip(
                                label:
                                    '${(category.utilization * 100).toStringAsFixed(0)}% used',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              minHeight: 12,
                              value: category.utilization,
                              backgroundColor: const Color(0xFFF4E7EA),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                welcomePrimaryDeepColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 320;

                              if (compact) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${currency}${category.remainingAmount.toStringAsFixed(2)} left',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF7C6B71),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.isOverBudget
                                          ? 'This category needs attention.'
                                          : 'This category is on track.',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF7C6B71),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.isOverBudget
                                        ? 'This category is over budget.'
                                        : 'This category is on track.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7C6B71),
                                    ),
                                  ),
                                  Text(
                                    '${currency}${category.remainingAmount.toStringAsFixed(2)} left',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7C6B71),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ExpenseSectionHeader(
                      title: 'Expense Log',
                      subtitle: expenses.isEmpty
                          ? 'Add the first expense entry to begin tracking this category.'
                          : '${expenses.length} expense${expenses.length == 1 ? '' : 's'} recorded',
                    ),
                    const SizedBox(height: 12),
                    if (vm.busy && vm.overview == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (expenses.isEmpty)
                      ExpenseEmptyState(
                        onAddExpense: () =>
                            _openAddExpense(context, vm, category),
                      )
                    else
                      ...expenses.map(
                        (expense) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ExpenseItemCard(
                            expense: expense,
                            currencyLabel: currency,
                            onTap: () => _openExpenseView(
                              context,
                              vm,
                              expense,
                              category,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddExpense(
    BuildContext context,
    ExpenseViewModel vm,
    BudgetCategory category,
  ) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => ExpenseAddScreen(viewModel: vm, category: category),
      ),
    );

    if (!context.mounted || message == null || message.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openExpenseView(
    BuildContext context,
    ExpenseViewModel vm,
    BudgetExpense expense,
    BudgetCategory category,
  ) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => ExpenseViewScreen(
          viewModel: vm,
          expense: expense,
          category: category,
        ),
      ),
    );

    if (!context.mounted || message == null || message.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _UsageChip extends StatelessWidget {
  const _UsageChip({required this.label});

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
