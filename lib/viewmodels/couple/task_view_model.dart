import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:wedplan_mobile/models/couple/task_model.dart';
import 'package:wedplan_mobile/repositories/couple/task_repository.dart';

enum TaskFilterStatus { all, pending, completed, overdue }

class TaskViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;
  List<Task> _tasks = const <Task>[];
  String _searchQuery = '';
  TaskFilterStatus _statusFilter = TaskFilterStatus.all;

  bool get busy => _busy;
  String? get error => _error;
  List<Task> get tasks => _sortedTasks(_tasks);
  String get searchQuery => _searchQuery;
  TaskFilterStatus get statusFilter => _statusFilter;

  List<Task> get filteredTasks {
    final query = _searchQuery.trim().toLowerCase();
    return _sortedTasks(_tasks).where((task) {
      final matchesQuery =
          query.isEmpty ||
          task.taskName.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.deadline.toLowerCase().contains(query) ||
          task.priorityLabel.toLowerCase().contains(query);

      final matchesStatus = switch (_statusFilter) {
        TaskFilterStatus.all => true,
        TaskFilterStatus.pending => !task.isCompleted && !task.isOverdue,
        TaskFilterStatus.completed => task.isCompleted,
        TaskFilterStatus.overdue => task.isOverdue,
      };

      return matchesQuery && matchesStatus;
    }).toList();
  }

  int get totalTasks => _tasks.length;

  int get completedCount => _tasks.where((task) => task.isCompleted).length;

  int get pendingCount =>
      _tasks.where((task) => !task.isCompleted && !task.isOverdue).length;

  int get overdueCount => _tasks.where((task) => task.isOverdue).length;

  Future<void> loadTasks({bool forceRefresh = false}) async {
    _setBusy(true);
    _error = null;

    try {
      _tasks = await TaskRepository.instance.fetchTasks();
      notifyListeners();
    } on DioException catch (error) {
      _error = _extractMessage(error);
      if (!forceRefresh) {
        _tasks = const <Task>[];
      }
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> createTask({
    required String taskName,
    required String description,
    required String deadline,
    required int priority,
    bool isCompleted = false,
  }) async {
    _setBusy(true);
    _error = null;

    try {
      await TaskRepository.instance.createTask(<String, dynamic>{
        'task_name': taskName,
        'description': description,
        'deadline': deadline,
        'is_completed': isCompleted,
        'priority': priority,
      });
      await loadTasks(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateTask({
    required Object id,
    required String taskName,
    required String description,
    required String deadline,
    required int priority,
    required bool isCompleted,
  }) async {
    _setBusy(true);
    _error = null;

    try {
      await TaskRepository.instance.updateTask(id, <String, dynamic>{
        'task_name': taskName,
        'description': description,
        'deadline': deadline,
        'is_completed': isCompleted,
        'priority': priority,
      });
      await loadTasks(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> completeTask(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await TaskRepository.instance.completeTask(id);
      await loadTasks(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> deleteTask(Object id) async {
    _setBusy(true);
    _error = null;

    try {
      await TaskRepository.instance.deleteTask(id);
      await loadTasks(forceRefresh: true);
    } on DioException catch (error) {
      _error = _extractMessage(error);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateStatusFilter(TaskFilterStatus value) {
    _statusFilter = value;
    notifyListeners();
  }

  Task? taskById(Object id) {
    for (final task in _tasks) {
      if (task.id == id.toString()) return task;
    }
    return null;
  }

  List<Task> _sortedTasks(List<Task> items) {
    final tasks = List<Task>.from(items);
    tasks.sort((left, right) {
      if (left.isCompleted != right.isCompleted) {
        return left.isCompleted ? 1 : -1;
      }

      final leftDate = left.deadlineDate;
      final rightDate = right.deadlineDate;
      if (leftDate != null && rightDate != null) {
        final dateComparison = leftDate.compareTo(rightDate);
        if (dateComparison != 0) return dateComparison;
      } else if (leftDate != null) {
        return -1;
      } else if (rightDate != null) {
        return 1;
      }

      if (left.priority != right.priority) {
        return right.priority.compareTo(left.priority);
      }

      return left.taskName.toLowerCase().compareTo(
        right.taskName.toLowerCase(),
      );
    });
    return tasks;
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
}
