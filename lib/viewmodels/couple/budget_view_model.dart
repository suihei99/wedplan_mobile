import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/repositories/couple/budget_repository.dart';

class BudgetViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;
  BudgetOverview? _overview;

  bool get busy => _busy;
  String? get error => _error;
  BudgetOverview? get overview => _overview;

  Future<void> load({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _overview = await BudgetRepository.instance.fetchOverview(
        forceRefresh: forceRefresh,
      );
      notifyListeners();
    } on DioException catch (error) {
      _error = _extractMessage(error);
      _overview = _fallbackOverview();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> createCategory({
    required String categoryName,
    required double allocatedAmount,
  }) async {
    _setBusy(true);
    _error = null;

    try {
      await BudgetRepository.instance.createCategory(<String, dynamic>{
        'category_name': categoryName,
        'allocated_amount': allocatedAmount,
      });
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateCategory({
    required dynamic id,
    required String categoryName,
    required double allocatedAmount,
  }) async {
    _setBusy(true);
    _error = null;

    try {
      await BudgetRepository.instance.updateCategory(id, <String, dynamic>{
        'category_name': categoryName,
        'allocated_amount': allocatedAmount,
      });
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteCategory(dynamic id) async {
    _setBusy(true);
    _error = null;

    try {
      await BudgetRepository.instance.deleteCategory(id);
      await load(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
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

  List<BudgetExpense> expensesForCategory(dynamic id) {
    final overview = _overview;
    if (overview == null) return const <BudgetExpense>[];

    return overview.expenses.where((expense) {
      final categoryId = expense.budgetCategoryId;
      return categoryId != null && categoryId.toString() == id.toString();
    }).toList();
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
