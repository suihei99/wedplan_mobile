import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/task_model.dart';
import 'package:wedplan_mobile/viewmodels/couple/task_view_model.dart';
import 'package:wedplan_mobile/views/couple/task/task_add_screen.dart';
import 'package:wedplan_mobile/views/couple/task/widgets/task_view_widgets.dart';

class TaskViewScreen extends StatelessWidget {
  const TaskViewScreen({super.key, this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);
    final task = taskId == null ? _firstTask(vm) : vm.taskById(taskId!);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task?.taskName.isNotEmpty == true
                  ? task!.taskName
                  : 'Task Detail',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Review details, update progress, or finish the checklist item.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7C6B71),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: task == null ? null : () => _openEditor(context, task),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: task == null
              ? _EmptyDetailState(
                  title: 'Task not found',
                  subtitle:
                      'Go back to the task list and select a checklist item.',
                )
              : TaskDetailView(
                  task: task,
                  onComplete: () => _runTaskAction(
                    context,
                    () => vm.completeTask(task.id),
                    successMessage: '${task.taskName} marked as complete',
                  ),
                  onEdit: () => _openEditor(context, task),
                  onDelete: () => _confirmDelete(context, vm, task),
                ),
        ),
      ),
    );
  }

  Task? _firstTask(TaskViewModel vm) {
    if (vm.tasks.isEmpty) return null;
    return vm.tasks.first;
  }

  void _openEditor(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<TaskViewModel>(context, listen: false),
          child: TaskAddScreen(taskId: task.id),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TaskViewModel vm,
    Task task,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text('Remove ${task.taskName} from the checklist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _runTaskAction(
      context,
      () => vm.deleteTask(task.id),
      successMessage: '${task.taskName} deleted',
    );
  }

  Future<void> _runTaskAction(
    BuildContext context,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!context.mounted) return;
      final vm = Provider.of<TaskViewModel>(context, listen: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.error ?? error.toString())));
    }
  }
}

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0DDE1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
