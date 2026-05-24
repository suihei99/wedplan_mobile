import 'package:wedplan_mobile/core/network/api_service.dart';
import 'package:wedplan_mobile/models/couple/task_model.dart';

class TaskRepository {
  TaskRepository._({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  static final TaskRepository instance = TaskRepository._();

  final ApiService _apiService;

  Future<List<Task>> fetchTasks() async {
    final response = await _apiService.tasks();
    final data = _toMap(response.data);
    final items = data['data'];

    if (items is List) {
      return items
          .whereType<Map>()
          .map(
            (item) => Task.fromJson(
              item.map<String, dynamic>(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList();
    }

    if (items is Map) {
      return [
        Task.fromJson(
          items.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      ];
    }

    return const <Task>[];
  }

  Future<Task> createTask(Map<String, dynamic> data) async {
    final response = await _apiService.taskCreate(data);
    return Task.fromJson(_toMap(response.data));
  }

  Future<Task> fetchTask(Object id) async {
    final response = await _apiService.taskShow(id);
    return Task.fromJson(_toMap(response.data));
  }

  Future<Task> updateTask(Object id, Map<String, dynamic> data) async {
    final response = await _apiService.taskUpdate(id, data);
    return Task.fromJson(_toMap(response.data));
  }

  Future<Task> completeTask(Object id) async {
    final response = await _apiService.taskComplete(
      id,
      const <String, dynamic>{},
    );
    return Task.fromJson(_toMap(response.data));
  }

  Future<void> deleteTask(Object id) async {
    await _apiService.taskDelete(id);
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
