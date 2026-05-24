import 'package:intl/intl.dart';

class Task {
  Task({
    required this.id,
    required this.taskName,
    required this.description,
    required this.deadline,
    required this.isCompleted,
    required this.priority,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final String id;
  final String taskName;
  final String description;
  final String deadline;
  final bool isCompleted;
  final int priority;
  final String completedAt;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> raw;

  DateTime? get deadlineDate => _parseDate(deadline);

  DateTime? get completedDate => _parseDate(completedAt);

  DateTime? get createdDate => _parseDate(createdAt);

  DateTime? get updatedDate => _parseDate(updatedAt);

  bool get isOverdue {
    final dueDate = deadlineDate;
    if (isCompleted || dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  bool get isHighPriority => priority == 2;

  bool get isMediumPriority => priority == 1;

  bool get isLowPriority => priority == 0;

  String get statusLabel {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    return 'Pending';
  }

  String get priorityLabel {
    switch (priority) {
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      case 0:
        return 'Low';
      default:
        return 'Medium';
    }
  }

  String get deadlineLabel =>
      _formatDate(deadlineDate) ??
      (deadline.isNotEmpty ? deadline : 'No deadline');

  String get completedLabel =>
      _formatDate(completedDate) ??
      (completedAt.isNotEmpty ? completedAt : 'Not completed');

  factory Task.fromJson(Map<String, dynamic> json) {
    final source = _readMap(json, ['data', 'task'])..addAll(json);
    final statusText = _firstNonEmpty([
      _readString(source, 'status'),
      _readString(source, 'task_status'),
    ]);

    return Task(
      id: _readString(source, 'id'),
      taskName: _firstNonEmpty([
        _readString(source, 'task_name'),
        _readString(source, 'name'),
        _readString(source, 'title'),
      ]),
      description: _firstNonEmpty([
        _readString(source, 'description'),
        _readString(source, 'notes'),
        _readString(source, 'detail'),
      ]),
      deadline: _firstNonEmpty([
        _readString(source, 'deadline'),
        _readString(source, 'due_date'),
        _readString(source, 'target_date'),
      ]),
      isCompleted:
          _readBool(source, ['is_completed', 'completed', 'done']) ||
          statusText.toLowerCase() == 'completed',
      priority: _readInt(source, ['priority']) ?? 1,
      completedAt: _firstNonEmpty([
        _readString(source, 'completed_at'),
        _readString(source, 'finished_at'),
      ]),
      createdAt: _readString(source, 'created_at'),
      updatedAt: _readString(source, 'updated_at'),
      raw: source,
    );
  }

  Task copyWith({
    String? id,
    String? taskName,
    String? description,
    String? deadline,
    bool? isCompleted,
    int? priority,
    String? completedAt,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? raw,
  }) {
    return Task(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      raw: raw ?? this.raw,
    );
  }
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value;
  }
  return '';
}

String _readString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String) return value.trim();
  if (value != null) return value.toString().trim();
  return '';
}

int? _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool _readBool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty) continue;
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
  }
  return false;
}

Map<String, dynamic> _readMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
  }
  return <String, dynamic>{};
}

DateTime? _parseDate(String value) {
  if (value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim());
}

String? _formatDate(DateTime? value) {
  if (value == null) return null;
  return DateFormat('d MMM y').format(value);
}
