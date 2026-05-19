import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/models/couple/expense_models.dart';
import 'package:wedplan_mobile/repositories/couple/budget_repository.dart';
import 'package:wedplan_mobile/repositories/couple/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  ExpenseViewModel({
    BudgetCategory? selectedCategory,
    ExpenseRepository? expenseRepository,
    BudgetRepository? budgetRepository,
  }) : _selectedCategory = selectedCategory,
       _expenseRepository = expenseRepository ?? ExpenseRepository.instance,
       _budgetRepository = budgetRepository ?? BudgetRepository.instance;

  final ExpenseRepository _expenseRepository;
  final BudgetRepository _budgetRepository;

  bool _busy = false;
  String? _error;
  BudgetOverview? _overview;
  BudgetCategory? _selectedCategory;
  List<BudgetExpense> _expenses = const <BudgetExpense>[];

  bool get busy => _busy;
  String? get error => _error;
  BudgetOverview? get overview => _overview;
  BudgetCategory? get selectedCategory => _selectedCategory;
  List<BudgetExpense> get allExpenses => _expenses;

  List<BudgetCategory> get categories =>
      _overview?.categories ?? const <BudgetCategory>[];

  List<BudgetExpense> get expenses {
    final category = _selectedCategory;
    if (category == null) return _expenses;

    return expensesForCategory(category.id);
  }

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      final responses = await Future.wait<dynamic>([
        _budgetRepository.fetchOverview(forceRefresh: forceRefresh),
        _expenseRepository.fetchExpenses(),
      ]);

      _overview = responses[0] as BudgetOverview;
      _expenses = responses[1] as List<BudgetExpense>;
      _syncSelectedCategory();
      notifyListeners();
    } on DioException catch (error) {
      _error = _extractMessage(error);
      _overview = _fallbackOverview();
      _expenses = const <BudgetExpense>[];
      _syncSelectedCategory();
    } finally {
      _setBusy(false);
    }
  }

  void selectCategory(dynamic id) {
    final category = categoryById(id);
    if (category == null) {
      return;
    }

    _selectedCategory = category;
    notifyListeners();
  }

  BudgetCategory? categoryById(dynamic id) {
    final overview = _overview;
    if (overview == null) return null;

    for (final category in overview.categories) {
      if (category.id.toString() == id.toString()) {
        return category;
      }
    }
    return null;
  }

  BudgetExpense? expenseById(dynamic id) {
    final overview = _overview;
    if (overview == null) return null;

    for (final expense in overview.expenses) {
      if (expense.id.toString() == id.toString()) {
        return expense;
      }
    }
    return null;
  }

  List<BudgetExpense> expensesForCategory(dynamic id) {
    return _expenses.where((expense) {
      final categoryId = expense.budgetCategoryId;
      return categoryId != null && categoryId.toString() == id.toString();
    }).toList();
  }

  Future<void> createExpense(ExpenseDraft draft) async {
    _setBusy(true);
    _error = null;

    try {
      await _expenseRepository.createExpense(draft);
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateExpense(Object id, ExpenseDraft draft) async {
    _setBusy(true);
    _error = null;

    try {
      await _expenseRepository.updateExpense(id, draft);
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteExpense(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await _expenseRepository.deleteExpense(id);
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _syncSelectedCategory() {
    final selectedCategory = _selectedCategory;
    if (selectedCategory == null) {
      return;
    }

    final refreshedCategory = categoryById(selectedCategory.id);
    if (refreshedCategory != null) {
      _selectedCategory = refreshedCategory;
      return;
    }

    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return error.message ?? 'Something went wrong.';
  }

  BudgetOverview _fallbackOverview() {
    return BudgetOverview(
      totalBudget: 50000,
      totalAllocated: 0,
      totalSpent: 0,
      remainingBudget: 50000,
      categories: const <BudgetCategory>[],
      expenses: const <BudgetExpense>[],
      raw: const <String, dynamic>{},
    );
  }
}
