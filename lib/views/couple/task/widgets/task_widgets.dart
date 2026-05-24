import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/task_model.dart';
import 'package:wedplan_mobile/viewmodels/couple/task_view_model.dart';

class TaskListHeroCard extends StatelessWidget {
  const TaskListHeroCard({super.key, required this.vm});

  final TaskViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEFF3), Color(0xFFFFF8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4D8DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF0CAD4)),
            ),
            child: Text(
              'WEDDING PLANNER WORKFLOW',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: const Color(0xFFE04F6D),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tasks List',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF21161A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track every checklist item from guest coordination to vendor confirmations with one focused board.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF6F6468),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TaskMiniStat(label: 'Total', value: vm.totalTasks.toString()),
              TaskMiniStat(
                label: 'Completed',
                value: vm.completedCount.toString(),
              ),
              TaskMiniStat(label: 'Pending', value: vm.pendingCount.toString()),
              TaskMiniStat(label: 'Overdue', value: vm.overdueCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskActionBar extends StatelessWidget {
  const TaskActionBar({
    super.key,
    required this.onAddTask,
    required this.onRefresh,
  });

  final VoidCallback onAddTask;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Add Task'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE04F6D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: onRefresh,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class TaskMiniStat extends StatelessWidget {
  const TaskMiniStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8C7980),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE04F6D),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskSearchBar extends StatelessWidget {
  const TaskSearchBar({super.key, required this.vm});

  final TaskViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: TextField(
        onChanged: vm.updateSearchQuery,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded),
          hintText: 'Search task name, description, or due date...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key, required this.vm});

  final TaskViewModel vm;

  @override
  Widget build(BuildContext context) {
    final items = <({TaskFilterStatus status, String label})>[
      (status: TaskFilterStatus.all, label: 'All'),
      (status: TaskFilterStatus.pending, label: 'Pending'),
      (status: TaskFilterStatus.completed, label: 'Completed'),
      (status: TaskFilterStatus.overdue, label: 'Overdue'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = vm.statusFilter == item.status;

          return ChoiceChip(
            selected: selected,
            label: Text(item.label),
            onSelected: (_) => vm.updateStatusFilter(item.status),
            selectedColor: const Color(0xFFFFDCE4),
            labelStyle: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFFE04F6D)
                  : const Color(0xFF6F6468),
            ),
            side: BorderSide(
              color: selected
                  ? const Color(0xFFE04F6D)
                  : const Color(0xFFF0DDE1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task);
    final priorityColor = _priorityColor(task.priority);
    final statusLabel = task.statusLabel;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0DDE1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : task.isOverdue
                        ? Icons.schedule_rounded
                        : Icons.checklist_rounded,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName.isEmpty ? 'Untitled Task' : task.taskName,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF21161A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7C6B71),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TaskMetric(
                      label: 'Due Date',
                      value: task.deadlineLabel,
                    ),
                  ),
                  Expanded(
                    child: _TaskMetric(
                      label: 'Priority',
                      value: task.priorityLabel,
                      valueColor: priorityColor,
                    ),
                  ),
                  Expanded(
                    child: _TaskMetric(
                      label: 'Complete',
                      value: task.isCompleted ? 'Yes' : 'No',
                      valueColor: task.isCompleted
                          ? const Color(0xFF2E8B57)
                          : const Color(0xFFC58B1D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: task.isCompleted ? null : onComplete,
                    icon: Icon(
                      task.isCompleted
                          ? Icons.check_circle_outline_rounded
                          : Icons.done_rounded,
                      size: 18,
                    ),
                    label: Text(task.isCompleted ? 'Completed' : 'Complete'),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(Task task) {
    if (task.isCompleted) return const Color(0xFF2E8B57);
    if (task.isOverdue) return const Color(0xFFC94B4B);
    return const Color(0xFFC58B1D);
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 2:
        return const Color(0xFFC94B4B);
      case 1:
        return const Color(0xFFC58B1D);
      case 0:
        return const Color(0xFF2E8B57);
      default:
        return const Color(0xFF6F6468);
    }
  }
}

class _TaskMetric extends StatelessWidget {
  const _TaskMetric({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF21161A),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8C7980),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.checklist_rounded,
            size: 40,
            color: Color(0xFFE04F6D),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.45,
              color: const Color(0xFF6F6468),
            ),
          ),
        ],
      ),
    );
  }
}
