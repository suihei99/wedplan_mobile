import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/models/couple/budget_models.dart';

class BudgetRepository {
  BudgetRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final BudgetRepository instance = BudgetRepository._();

  final ApiService _apiService;
  BudgetOverview? _cache;

  Future<BudgetOverview> fetchOverview({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final responses = await Future.wait<dynamic>([
      _apiService.budgets(),
      _apiService.expenses(),
    ]);

    final overview = BudgetOverview.fromJson(
      budgetJson: _toMap(responses[0].data),
      expenseJson: _toMap(responses[1].data),
    );
    _cache = overview;
    return overview;
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final response = await _apiService.budgetCreate(data);
    _cache = null;
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> showCategory(Object id) async {
    final response = await _apiService.budgetShow(id);
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateCategory(
    Object id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.budgetUpdate(id, data);
    _cache = null;
    return _toMap(response.data);
  }

  Future<void> deleteCategory(Object id) async {
    await _apiService.budgetDelete(id);
    _cache = null;
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{'data': data};
  }
}
