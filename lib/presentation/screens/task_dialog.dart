import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task.dart';
import '../../providers/firestore_provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';

class TaskDialog extends ConsumerStatefulWidget {
  final Task? task;

  const TaskDialog({super.key, this.task});

  @override
  ConsumerState<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _dueDate;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _isDone = widget.task?.isDone ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authStateProvider).asData?.value;

    return AlertDialog(
      title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(_dueDate != null
                      ? 'Due: ${_dueDate!.toLocal()}'
                      : 'No due date'),
                ),
                TextButton(
                  child: const Text('Pick Date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                )
              ],
            ),
            CheckboxListTile(
              value: _isDone,
              title: const Text('Mark as done'),
              onChanged: (val) => setState(() => _isDone = val ?? false),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate() || user == null) return;

            final repo = ref.read(firestoreRepositoryProvider);
            final newTask = Task(
              id: widget.task?.id ?? const Uuid().v4(),
              userId: user.uid,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              isDone: _isDone,
              createdAt: widget.task?.createdAt ?? DateTime.now(),
              dueDate: _dueDate,
            );

            if (widget.task == null) {
              await repo.addTask(newTask);
            } else {
              await repo.updateTask(newTask);
            }

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
