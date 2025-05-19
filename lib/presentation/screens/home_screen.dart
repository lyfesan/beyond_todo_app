import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/firestore_provider.dart';
import '../../data/models/task.dart';
import 'task_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(userTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: tasksAsync.when(
        data: (tasks) {
          final ongoing = tasks.where((t) => !t.isDone).toList();
          final completed = tasks.where((t) => t.isDone).toList();
          final shownTasks = _currentIndex == 0 ? ongoing : completed;

          if (shownTasks.isEmpty) {
            return const Center(child: Text('No tasks here'));
          }

          return ListView.builder(
            itemCount: shownTasks.length,
            itemBuilder: (_, i) {
              final task = shownTasks[i];
              return ListTile(
                title: Text(task.title),
                subtitle: task.dueDate != null
                    ? Text('Due: ${task.dueDate!.toLocal()}')
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showTaskDialog(task: task),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(task),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_unchecked),
            label: 'Ongoing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
        ],
      ),
    );
  }

  void _showTaskDialog({Task? task}) {
    showDialog(
      context: context,
      builder: (_) => TaskDialog(task: task),
    );
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(firestoreRepositoryProvider)
          .deleteTask(task.userId, task.id);
    }
  }
}
