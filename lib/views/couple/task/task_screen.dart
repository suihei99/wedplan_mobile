import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/task_model.dart';
import 'package:wedplan_mobile/viewmodels/couple/task_view_model.dart';
import 'package:wedplan_mobile/views/couple/task/task_add_screen.dart';
import 'package:wedplan_mobile/views/couple/task/task_view_screen.dart';
import 'package:wedplan_mobile/views/couple/task/widgets/task_widgets.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TaskViewModel()..loadTasks();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TaskViewModel>(
        builder: (context, vm, _) {
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
                    'Task List',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Keep your wedding checklist focused, visible, and on schedule.',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C6B71),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () => vm.loadTasks(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFFE04F6D),
                onRefresh: () => vm.loadTasks(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    TaskListHeroCard(vm: vm),
                    const SizedBox(height: 16),
                    TaskActionBar(
                      onAddTask: () => _openTaskEditor(context, null),
                      onRefresh: () => vm.loadTasks(forceRefresh: true),
                    ),
                    const SizedBox(height: 16),
                    TaskSearchBar(vm: vm),
                    const SizedBox(height: 12),
                    TaskFilterChips(vm: vm),
                    const SizedBox(height: 16),
                    if (vm.busy && vm.tasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (vm.filteredTasks.isEmpty)
                      TaskEmptyState(
                        title: vm.searchQuery.trim().isEmpty
                            ? 'No tasks yet'
                            : 'No task matches your search',
                        subtitle: vm.searchQuery.trim().isEmpty
                            ? 'Add your first wedding checklist item and keep deadlines visible.'
                            : 'Try a different task name, description, or due date.',
                      )
                    else
                      ...vm.filteredTasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            onTap: () => _openTaskDetails(context, task),
                            onComplete: () => _runTaskAction(
                              context,
                              () => vm.completeTask(task.id),
                              successMessage:
                                  '${task.taskName} marked as complete',
                            ),
                            onEdit: () => _openTaskEditor(context, task),
                            onDelete: () => _confirmDelete(context, vm, task),
                          ),
                        ),
                      ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openTaskDetails(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: TaskViewScreen(taskId: task.id),
        ),
      ),
    );
  }

  void _openTaskEditor(BuildContext context, Task? task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: TaskAddScreen(taskId: task?.id),
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
      final message = _viewModel.error ?? error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
