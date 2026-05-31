import 'package:wedplan_mobile/core/router/app_router.dart';
import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/models/couple/budget_models.dart';
import 'package:wedplan_mobile/models/couple/expense_models.dart';

class ExpenseRepository {
  ExpenseRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final ExpenseRepository instance = ExpenseRepository._();

  final ApiService _apiService;

  Future<List<BudgetExpense>> fetchExpenses() async {
    final response = await _apiService.expenses();
    return _parseExpenses(response.data);
  }

  Future<BudgetExpense?> showExpense(Object id) async {
    final response = await _apiService.expenseShow(id);
    final map = _toMap(response.data);
    if (map.isEmpty) {
      return null;
    }
    return BudgetExpense.fromJson(map);
  }

  Future<Map<String, dynamic>> createExpense(ExpenseDraft draft) async {
    final response = await _apiService.expenseCreate(await draft.toFormData());
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateExpense(
    Object id,
    ExpenseDraft draft,
  ) async {
    final payload = await draft.toFormData(includePaymentMethod: true);
    payload.fields.add(const MapEntry('_method', 'PUT'));

    final response = await _apiService.expenseCreateWithPath(
      ApiRouter.expenseById(id),
      payload,
    );
    return _toMap(response.data);
  }

  Future<void> deleteExpense(Object id) async {
    await _apiService.expenseDelete(id);
  }

  List<BudgetExpense> _parseExpenses(dynamic data) {
    final map = _toMap(data);
    final list = _readList(map, const ['data', 'expenses']);

    return list
        .whereType<Map>()
        .map((item) => BudgetExpense.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    if (data is List) {
      return <String, dynamic>{'data': data};
    }
    return <String, dynamic>{};
  }

  List<dynamic> _readList(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) {
        return value;
      }
    }
    return const <dynamic>[];
  }
}
