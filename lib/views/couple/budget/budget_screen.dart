import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/viewmodels/couple/budget_view_model.dart';
import 'package:wedplan_mobile/views/couple/budget/budget_add_screen.dart';
import 'package:wedplan_mobile/views/couple/budget/budget_view_screen.dart';
import 'package:wedplan_mobile/views/couple/budget/expense/expense_screen.dart';
import 'package:wedplan_mobile/views/couple/budget/widgets/budget_category_card.dart';
import 'package:wedplan_mobile/views/couple/budget/widgets/budget_empty_state.dart';
import 'package:wedplan_mobile/views/couple/budget/widgets/budget_summary_card.dart';
import 'package:wedplan_mobile/views/couple/navbar/navbar.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

enum _BudgetFilter { all, healthy, overBudget }

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late final BudgetViewModel _viewModel;
  _BudgetFilter _filter = _BudgetFilter.all;
  int _navIndex = 1;

  @override
  void initState() {
    super.initState();
    _viewModel = BudgetViewModel()..load();
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
      child: Consumer<BudgetViewModel>(
        builder: (context, vm, _) {
          final overview = vm.overview;
          final currency = _currency();
          final categories = _filteredCategories(overview);
          final recentExpenses =
              overview?.expenses.take(5).toList() ?? const <BudgetExpense>[];
          final content = _BudgetContent(
            overview: overview,
            currency: currency,
            vm: vm,
            categories: categories,
            recentExpenses: recentExpenses,
            onAddCategory: () => _openAddCategory(context, vm),
            onOpenCategory: (category) =>
                _openViewCategory(context, vm, category),
          );

          if (widget.embedded) {
            return content;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFAF4F5),
            appBar: AppBar(
              backgroundColor: const Color(0xFFFAF4F5),
              foregroundColor: const Color(0xFF21161A),
              elevation: 0,
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Overview',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Track allocations, spending, and category health in one place.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkResponse(
                    onTap: () => _showNotifications(context),
                    radius: 22,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEFDCE0)),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: welcomePrimaryDeepColor,
                onRefresh: () => vm.load(forceRefresh: true),
                child: content,
              ),
            ),
            bottomNavigationBar: CoupleNavbar(
              currentIndex: _navIndex,
              onTap: (index) => _handleNavTap(context, index),
            ),
          );
        },
      ),
    );
  }

  List<BudgetCategory> _filteredCategories(BudgetOverview? overview) {
    final categories = overview?.categories ?? const <BudgetCategory>[];
    return switch (_filter) {
      _BudgetFilter.all => categories,
      _BudgetFilter.healthy =>
        categories
            .where(
              (category) => category.status == BudgetCategoryStatus.healthy,
            )
            .toList(),
      _BudgetFilter.overBudget =>
        categories
            .where(
              (category) => category.status == BudgetCategoryStatus.overBudget,
            )
            .toList(),
    };
  }

  void _openAddCategory(BuildContext context, BudgetViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BudgetAddScreen(viewModel: vm)),
    );
  }

  void _openViewCategory(
    BuildContext context,
    BudgetViewModel vm,
    BudgetCategory category,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BudgetViewScreen(
          viewModel: vm,
          category: category,
          onOpenExpenseLog: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExpenseScreen(category: category),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications panel can be routed here next.',
          style: GoogleFonts.manrope(),
        ),
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == _navIndex) {
      return;
    }

    if (index == 0) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _navIndex = index);
    if (index == 1) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$index section is ready for routing.',
          style: GoogleFonts.manrope(),
        ),
      ),
    );
  }
}

class _BudgetContent extends StatelessWidget {
  const _BudgetContent({
    required this.overview,
    required this.currency,
    required this.vm,
    required this.categories,
    required this.recentExpenses,
    required this.onAddCategory,
    required this.onOpenCategory,
  });

  final BudgetOverview? overview;
  final String currency;
  final BudgetViewModel vm;
  final List<BudgetCategory> categories;
  final List<BudgetExpense> recentExpenses;
  final VoidCallback onAddCategory;
  final void Function(BudgetCategory category) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final currentOverview = overview;
    return Container(
      color: const Color(0xFFFAF4F5),
      child: RefreshIndicator(
        color: welcomePrimaryDeepColor,
        onRefresh: () => vm.load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            _BudgetHeroCard(overview: overview, currency: currency),
            const SizedBox(height: 14),
            if (vm.error != null) ...[
              _BudgetErrorBanner(message: vm.error!),
              const SizedBox(height: 14),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                const cardGap = 12.0;
                final cardWidth = (constraints.maxWidth - cardGap) / 2;

                Widget card({
                  required String label,
                  required String value,
                  required String subtitle,
                  required IconData icon,
                  required List<Color> gradient,
                }) {
                  return SizedBox(
                    width: cardWidth,
                    child: BudgetSummaryCard(
                      label: label,
                      value: value,
                      subtitle: subtitle,
                      icon: icon,
                      gradient: gradient,
                    ),
                  );
                }

                return Wrap(
                  spacing: cardGap,
                  runSpacing: 12,
                  children: [
                    card(
                      label: 'Total Budget',
                      value: currentOverview != null
                          ? '$currency${_money(currentOverview.totalBudget)}'
                          : '${currency}0.00',
                      subtitle: 'Wedding budget ceiling',
                      icon: Icons.account_balance_wallet_rounded,
                      gradient: const [Color(0xFFF4708A), Color(0xFFE04F6D)],
                    ),
                    card(
                      label: 'Spent',
                      value: currentOverview != null
                          ? '$currency${_money(currentOverview.totalSpent)}'
                          : '${currency}0.00',
                      subtitle: 'Confirmed spending so far',
                      icon: Icons.payments_rounded,
                      gradient: const [Color(0xFFFF8DA5), Color(0xFFF06B87)],
                    ),
                    card(
                      label: 'Allocated',
                      value: currentOverview != null
                          ? '$currency${_money(currentOverview.totalAllocated)}'
                          : '${currency}0.00',
                      subtitle: 'Assigned to categories',
                      icon: Icons.pie_chart_rounded,
                      gradient: const [Color(0xFFF8AFC0), Color(0xFFF4708A)],
                    ),
                    card(
                      label: 'Remaining',
                      value: currentOverview != null
                          ? '$currency${_money(currentOverview.remainingBudget)}'
                          : '${currency}0.00',
                      subtitle: 'Still available to plan',
                      icon: Icons.savings_rounded,
                      gradient: const [Color(0xFFFFC4D0), Color(0xFFF48AA4)],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _BudgetProgressCard(overview: overview),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SectionHeader(
                    title: 'Budget Categories',
                    subtitle: overview == null
                        ? 'Loading your categories...'
                        : '${categories.length} ${categories.length == 1 ? 'category' : 'categories'} shown',
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: vm.busy ? null : onAddCategory,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Add Category',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: welcomePrimaryDeepColor,
                    backgroundColor: const Color(0xFFFCE0E5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vm.busy && overview == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (categories.isEmpty)
              BudgetEmptyState(
                title: 'No budget categories yet',
                subtitle:
                    'Create your first category to begin shaping the wedding budget.',
                actionLabel: 'Create Category',
                onAction: onAddCategory,
              )
            else
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BudgetCategoryCard(
                    category: category,
                    currencyLabel: currency,
                    onTap: () => onOpenCategory(category),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            _SectionHeader(
              title: 'Recent Expenses',
              subtitle: 'Latest recorded spend from the expense API',
            ),
            const SizedBox(height: 12),
            if (recentExpenses.isEmpty)
              const _InlineHint(
                icon: Icons.receipt_long_rounded,
                title: 'No expense records yet',
                subtitle:
                    'Once expenses are created on the backend, they will appear here automatically.',
              )
            else
              ...recentExpenses.map(
                (expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExpenseCard(
                    expense: expense,
                    currencyLabel: currency,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BudgetHeroCard extends StatelessWidget {
  const _BudgetHeroCard({required this.overview, required this.currency});

  final BudgetOverview? overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final utilization = overview?.budgetUtilization ?? 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEFF3), Color(0xFFFFFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Health',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Monitor whether your current plan is staying inside the total budget.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: welcomePrimaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: welcomePrimaryDeepColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: utilization,
              backgroundColor: const Color(0xFFF3E4E8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                welcomePrimaryDeepColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(utilization * 100).toStringAsFixed(0)}% used',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C6B71),
                ),
              ),
              Text(
                overview != null
                    ? '$currency${_money(overview!.remainingBudget)} left to allocate'
                    : 'Loading budget summary...',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C6B71),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({required this.overview});

  final BudgetOverview? overview;

  @override
  Widget build(BuildContext context) {
    final categories = overview?.categories ?? const <BudgetCategory>[];
    final total = categories.length;
    final healthy = overview?.healthyCategoryCount ?? 0;
    final low = overview?.lowCategoryCount ?? 0;
    final overBudget = overview?.overBudgetCategoryCount ?? 0;
    final percent = overview?.budgetUtilization ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;

              final chips = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: compact ? WrapAlignment.start : WrapAlignment.end,
                children: [
                  _SnapshotChip(label: '$total Categories'),
                  _SnapshotChip(label: '$healthy Balanced'),
                ],
              );

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Health Snapshot',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        chips,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Budget Health Snapshot',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        chips,
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: percent,
              backgroundColor: const Color(0xFFF4E7EA),
              valueColor: const AlwaysStoppedAnimation<Color>(
                welcomePrimaryDeepColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percent * 100).toStringAsFixed(0)}% of budget used',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C6B71),
                ),
              ),
              Text(
                '${low} Watch, $overBudget Over Budget',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C6B71),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense, required this.currencyLabel});

  final BudgetExpense expense;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                ),
                const SizedBox(height: 4),
                Text(
                  expense.description.isNotEmpty
                      ? expense.description
                      : expense.paymentMethod.isNotEmpty
                      ? expense.paymentMethod
                      : 'Expense recorded from the API',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7C6B71),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  expense.dateLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9A858B),
                  ),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : welcomeTextColor,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: welcomePrimaryDeepColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: BorderSide(
          color: selected ? welcomePrimaryDeepColor : const Color(0xFFEEDCE1),
        ),
      ),
    );
  }
}

class _SnapshotChip extends StatelessWidget {
  const _SnapshotChip({required this.label});

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

class _InlineHint extends StatelessWidget {
  const _InlineHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEDCE1)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: welcomePrimaryDeepColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetErrorBanner extends StatelessWidget {
  const _BudgetErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCCD6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE04F6D)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7C6B71),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _currency() => 'RM ';

String _money(double value) => NumberFormat('#,##0.00').format(value);
