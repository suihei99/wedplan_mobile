import 'package:intl/intl.dart';

enum BudgetCategoryStatus { healthy, low, overBudget, unknown }

class BudgetCategory {
  BudgetCategory({
    required this.id,
    required this.categoryName,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.expenseCount,
    required this.raw,
  });

  final dynamic id;
  final String categoryName;
  final double allocatedAmount;
  final double spentAmount;
  final double remainingAmount;
  final int expenseCount;
  final Map<String, dynamic> raw;

  double get utilization => allocatedAmount > 0
      ? (spentAmount / allocatedAmount).clamp(0.0, 1.5)
      : 0.0;

  double get remainingPercent => allocatedAmount > 0
      ? (remainingAmount / allocatedAmount).clamp(-1.0, 1.0)
      : 0.0;

  bool get isOverBudget => remainingAmount < 0 || spentAmount > allocatedAmount;

  BudgetCategoryStatus get status {
    final explicit = _readString(raw, ['status', 'budget_status']);
    switch (explicit.toLowerCase()) {
      case 'healthy':
      case 'ok':
      case 'balanced':
        return BudgetCategoryStatus.healthy;
      case 'low':
      case 'warning':
        return BudgetCategoryStatus.low;
      case 'over':
      case 'overbudget':
      case 'over_budget':
        return BudgetCategoryStatus.overBudget;
    }

    if (isOverBudget) return BudgetCategoryStatus.overBudget;
    if (allocatedAmount <= 0) return BudgetCategoryStatus.unknown;
    if (utilization >= 0.85) return BudgetCategoryStatus.low;
    return BudgetCategoryStatus.healthy;
  }

  String get statusLabel {
    switch (status) {
      case BudgetCategoryStatus.healthy:
        return 'Healthy';
      case BudgetCategoryStatus.low:
        return 'Watch';
      case BudgetCategoryStatus.overBudget:
        return 'Over Budget';
      case BudgetCategoryStatus.unknown:
        return 'Not Set';
    }
  }

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    final data = _unwrap(json);
    final id = data['id'] ?? data['budget_category_id'] ?? data['category_id'];
    final allocated = _firstDouble([
      data['allocated_amount'],
      data['budget_amount'],
      data['amount'],
      data['category_amount'],
      data['allocated'],
    ]);
    final spent = _firstDouble([
      data['spent_amount'],
      data['budget_spent'],
      data['spent'],
      data['used_amount'],
      data['total_spent'],
    ]);
    final remaining = _firstDouble([
      data['remaining_amount'],
      data['remaining'],
      data['budget_remaining'],
    ]);

    return BudgetCategory(
      id: id,
      categoryName: _firstString([
        data['category_name'],
        data['name'],
        data['title'],
        data['budget_name'],
      ], fallback: 'Budget Category'),
      allocatedAmount: allocated,
      spentAmount: spent,
      remainingAmount: remaining != 0 ? remaining : allocated - spent,
      expenseCount: _firstInt([
        data['expense_count'],
        data['expenses_count'],
        data['count'],
      ]),
      raw: json,
    );
  }
}

class BudgetExpense {
  BudgetExpense({
    required this.id,
    required this.budgetCategoryId,
    required this.expenseName,
    required this.amount,
    required this.datePaid,
    required this.description,
    required this.paymentMethod,
    required this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final dynamic id;
  final dynamic budgetCategoryId;
  final String expenseName;
  final double amount;
  final String datePaid;
  final String description;
  final String paymentMethod;
  final String receiptUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  String get dateLabel => _formatDate(datePaid) ?? datePaid;

  factory BudgetExpense.fromJson(Map<String, dynamic> json) {
    final data = _unwrap(json);
    return BudgetExpense(
      id: data['id'] ?? data['expense_id'],
      budgetCategoryId:
          data['budget_category_id'] ??
          data['category_id'] ??
          data['budget_id'],
      expenseName: _firstString([
        data['expense_name'],
        data['name'],
        data['title'],
      ], fallback: 'Expense'),
      amount: _firstDouble([
        data['amount'],
        data['expense_amount'],
        data['total'],
      ]),
      datePaid: _firstString([
        data['date_paid'],
        data['paid_at'],
        data['date'],
        data['expense_date'],
      ]),
      description: _firstString([
        data['description'],
        data['notes'],
        data['remark'],
      ]),
      paymentMethod: _firstString([data['payment_method'], data['method']]),
      receiptUrl: _firstString([
        data['receipt_url'],
        data['receipt'],
        data['file_url'],
      ]),
      createdAt: _parseDateTime(data['created_at']),
      updatedAt: _parseDateTime(data['updated_at']),
      raw: json,
    );
  }
}

class BudgetOverview {
  BudgetOverview({
    required this.totalBudget,
    required this.totalAllocated,
    required this.totalSpent,
    required this.remainingBudget,
    required this.categories,
    required this.expenses,
    required this.raw,
  });

  final double totalBudget;
  final double totalAllocated;
  final double totalSpent;
  final double remainingBudget;
  final List<BudgetCategory> categories;
  final List<BudgetExpense> expenses;
  final Map<String, dynamic> raw;

  double get budgetUtilization =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.5) : 0.0;

  int get healthyCategoryCount => categories
      .where((category) => category.status == BudgetCategoryStatus.healthy)
      .length;

  int get overBudgetCategoryCount => categories
      .where((category) => category.status == BudgetCategoryStatus.overBudget)
      .length;

  int get lowCategoryCount => categories
      .where((category) => category.status == BudgetCategoryStatus.low)
      .length;

  factory BudgetOverview.fromJson({
    required Map<String, dynamic> budgetJson,
    required Map<String, dynamic> expenseJson,
  }) {
    final budgetData = _unwrap(budgetJson);
    final expenseData = _unwrap(expenseJson);
    final categoriesRaw = _readList(budgetData, [
      'categories',
      'budget_categories',
      'items',
    ]);
    final expensesRaw = _readList(expenseData, [
      'expenses',
      'recent_expenses',
      'latest_expenses',
      'budget_expenses',
    ]);

    final categories = categoriesRaw
        .whereType<Map>()
        .map((item) => BudgetCategory.fromJson(item.cast<String, dynamic>()))
        .toList();
    final expenses = expensesRaw
        .whereType<Map>()
        .map((item) => BudgetExpense.fromJson(item.cast<String, dynamic>()))
        .toList();

    final totalBudget = _firstDouble([
      budgetData['total_budget'],
      budgetData['total_budget_limit'],
      budgetData['budget_limit'],
      budgetData['effective_budget_limit'],
    ]);
    final totalAllocated = _firstDouble([
      budgetData['total_allocated'],
      budgetData['allocated_total'],
      budgetData['sum_allocated'],
      categories.fold<double>(
        0.0,
        (sum, category) => sum + category.allocatedAmount,
      ),
    ]);
    final totalSpent = _firstDouble([
      budgetData['total_spent'],
      budgetData['spent'],
      budgetData['budget_spent'],
      budgetData['total_expenses'],
      expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount),
    ]);
    final remainingBudget = _firstDouble([
      budgetData['remaining_budget'],
      budgetData['budget_remaining'],
      budgetData['remaining'],
      totalBudget > 0 ? totalBudget - totalAllocated : 0.0,
      totalBudget > 0 ? totalBudget - totalSpent : 0.0,
    ]);

    return BudgetOverview(
      totalBudget: totalBudget,
      totalAllocated: totalAllocated,
      totalSpent: totalSpent,
      remainingBudget: remainingBudget,
      categories: categories,
      expenses: expenses,
      raw: budgetJson,
    );
  }
}

Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) {
    return data.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
  return json;
}

List<dynamic> _readList(Map<String, dynamic> source, List<String> keys) {
  final data = source['data'];
  if (data is List) return data;

  for (final key in keys) {
    final value = source[key];
    if (value is List) return value;
  }
  return const <dynamic>[];
}

String _firstString(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
  }
  return fallback;
}

double _firstDouble(List<dynamic> values) {
  for (final value in values) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return 0.0;
}

int _firstInt(List<dynamic> values) {
  for (final value in values) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

DateTime? _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}

String? _formatDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateFormat('d MMM y').format(parsed);
}

String _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
  }
  return '';
}
