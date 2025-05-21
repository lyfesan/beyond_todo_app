import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import '../../data/models/task.dart';
import '../../data/models/app_user.dart';
import 'task_dialog.dart';
import 'package:intl/intl.dart'; // Import intl package

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
    final userAsync = ref.watch(authStateProvider);
    //final firestoreProvider = ref.watch(firestoreRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/beyond_todo_logo.png',
          height: 30,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.logout_rounded),
              onPressed: () => ref.read(authRepositoryProvider).signOut(),

            ),
          ),
        ],
      ),
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
              return InkWell(
                onTap: () => _showTaskDialog(task: task),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: task.dueDate != null
                        ? Text(
                        'Due: ${DateFormat('EEE, d MMM, HH:mm').format(task.dueDate!.toLocal())}')
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(task),
                    ),
                  ),
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
        selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.adjust_rounded,
                color: _currentIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey),
            label: 'Ongoing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded,
                color: _currentIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey),
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