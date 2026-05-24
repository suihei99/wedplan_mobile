import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/task_model.dart';
import 'package:wedplan_mobile/viewmodels/couple/task_view_model.dart';

enum _TaskPriorityOption { high, medium, low }

class TaskAddScreen extends StatefulWidget {
  const TaskAddScreen({super.key, this.taskId});

  final String? taskId;

  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  DateTime? _deadline;
  _TaskPriorityOption _priority = _TaskPriorityOption.medium;
  bool _isCompleted = false;
  bool _initialised = false;

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);
    final task = widget.taskId == null ? null : vm.taskById(widget.taskId!);

    if (!_initialised && task != null) {
      _initialised = true;
      _taskNameController.text = task.taskName;
      _descriptionController.text = task.description;
      _deadline = task.deadlineDate;
      _deadlineController.text = _deadline == null
          ? ''
          : DateFormat('d MMM y').format(_deadline!);
      _priority = switch (task.priority) {
        2 => _TaskPriorityOption.high,
        0 => _TaskPriorityOption.low,
        _ => _TaskPriorityOption.medium,
      };
      _isCompleted = task.isCompleted;
    }

    final isEditing = task != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Task' : 'Add Task',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: task == null && isEditing
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: _EmptyTaskState(
                  title: 'Task not found',
                  subtitle:
                      'Return to the task list and choose a checklist item to edit.',
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _IntroCard(isEditing: isEditing),
                    const SizedBox(height: 16),
                    _FieldCard(
                      child: TextFormField(
                        controller: _taskNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Task name',
                          hintText: 'Confirm photographer',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Task name is required'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      child: TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Add context, contacts, or next steps',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      child: TextFormField(
                        controller: _deadlineController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          hintText: 'Choose a due date',
                          suffixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                        onTap: () => _pickDeadline(context),
                        validator: (_) =>
                            _deadline == null ? 'Deadline is required' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      child: DropdownButtonFormField<_TaskPriorityOption>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: _TaskPriorityOption.high,
                            child: Text('High'),
                          ),
                          DropdownMenuItem(
                            value: _TaskPriorityOption.medium,
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: _TaskPriorityOption.low,
                            child: Text('Low'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _priority = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      child: SwitchListTile.adaptive(
                        value: _isCompleted,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mark as completed'),
                        subtitle: const Text(
                          'Use this when the task is already finished or approved.',
                        ),
                        onChanged: (value) {
                          setState(() => _isCompleted = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: vm.busy
                          ? null
                          : () => _saveTask(context, vm, task),
                      icon: vm.busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(isEditing ? 'Update Task' : 'Save Task'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE04F6D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Deadline uses the API date format and the task stays inside your couple checklist after saving.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF7C6B71),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _deadline ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null) return;

    setState(() {
      _deadline = selected;
      _deadlineController.text = DateFormat('d MMM y').format(selected);
    });
  }

  Future<void> _saveTask(
    BuildContext context,
    TaskViewModel vm,
    Task? task,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deadline = _deadline == null
        ? ''
        : DateFormat('yyyy-MM-dd').format(_deadline!);
    final priority = switch (_priority) {
      _TaskPriorityOption.high => 2,
      _TaskPriorityOption.medium => 1,
      _TaskPriorityOption.low => 0,
    };

    try {
      if (task == null) {
        await vm.createTask(
          taskName: _taskNameController.text.trim(),
          description: _descriptionController.text.trim(),
          deadline: deadline,
          priority: priority,
          isCompleted: _isCompleted,
        );
      } else {
        await vm.updateTask(
          id: task.id,
          taskName: _taskNameController.text.trim(),
          description: _descriptionController.text.trim(),
          deadline: deadline,
          priority: priority,
          isCompleted: _isCompleted,
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(task == null ? 'Task added' : 'Task updated')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'Unable to save task')),
      );
    }
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.isEditing});

  final bool isEditing;

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
              isEditing ? 'UPDATE CHECKLIST ITEM' : 'NEW CHECKLIST ITEM',
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
            isEditing ? 'Edit Task' : 'Add Task',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF21161A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep every planning step visible, date-bound, and ready to complete from one mobile screen.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF6F6468),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: child,
    );
  }
}

class _EmptyTaskState extends StatelessWidget {
  const _EmptyTaskState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
