import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/task_model.dart';

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _HeroCard(task: task),
        const SizedBox(height: 16),
        _ActionBanner(
          task: task,
          onComplete: onComplete,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        const SizedBox(height: 16),
        _SummaryCard(task: task),
        const SizedBox(height: 16),
        _DetailsCard(task: task),
        const SizedBox(height: 16),
        _TimelineCard(task: task),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8EE), Color(0xFFFFF7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4D8DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskName.isNotEmpty ? task.taskName : 'Task Detail',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.description.isNotEmpty
                      ? task.description
                      : 'No description has been added yet.',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: const Color(0xFF6F6468),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: task.statusLabel.toUpperCase(),
                      color: statusColor,
                    ),
                    _Pill(
                      label: 'PRIORITY ${task.priorityLabel.toUpperCase()}',
                      color: _priorityColor(task.priority),
                    ),
                    _Pill(
                      label: 'DUE ${task.deadlineLabel.toUpperCase()}',
                      color: const Color(0xFFE04F6D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.task,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Task Actions',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryActionButton(
            label: task.isCompleted ? 'Task Completed' : 'Mark as Complete',
            icon: task.isCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.done_rounded,
            color: task.isCompleted
                ? const Color(0xFF2E8B57)
                : const Color(0xFFE04F6D),
            onPressed: task.isCompleted ? null : onComplete,
          ),
          const SizedBox(height: 10),
          _PrimaryActionButton(
            label: 'Edit Task',
            icon: Icons.edit_outlined,
            color: const Color(0xFFE04F6D),
            onPressed: onEdit,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete Task'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC94B4B),
              side: const BorderSide(color: Color(0xFFF2B8BF)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFDCEEE3),
        disabledForegroundColor: const Color(0xFF2E8B57),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Summary',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Due Date',
                  value: task.deadlineLabel,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Priority',
                  value: task.priorityLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(label: 'Status', value: task.statusLabel),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Completed',
                  value: task.isCompleted ? 'Yes' : 'No',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8C7980),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF21161A),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Details',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailLine(
            label: 'Task name',
            value: task.taskName.isEmpty ? '-' : task.taskName,
          ),
          _DetailLine(
            label: 'Description',
            value: task.description.isEmpty ? '-' : task.description,
          ),
          _DetailLine(label: 'Deadline', value: task.deadlineLabel),
          _DetailLine(label: 'Priority', value: task.priorityLabel),
          _DetailLine(
            label: 'Completed',
            value: task.isCompleted ? 'Yes' : 'No',
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 102,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8C7980),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF21161A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailLine(
            label: 'Created',
            value: task.createdAt.isEmpty ? '-' : task.createdAt,
          ),
          _DetailLine(
            label: 'Updated',
            value: task.updatedAt.isEmpty ? '-' : task.updatedAt,
          ),
          _DetailLine(
            label: 'Completed At',
            value: task.completedAt.isEmpty
                ? 'Not completed'
                : task.completedAt,
          ),
        ],
      ),
    );
  }
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
