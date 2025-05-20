import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task.dart';
import '../../providers/firestore_provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

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
  TimeOfDay? _dueTime;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _dueTime = widget.task?.dueDate != null
        ? TimeOfDay.fromDateTime(widget.task!.dueDate!)
        : null;
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
              decoration: InputDecoration(
                label: Text('Title'),
                hintText: 'Enter the Title',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                label: Text('Description'),
                hintText: 'Enter the Description',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(_dueDate != null
                      ? 'Due: ${DateFormat('EEE, d MMM yyyy').format(_dueDate!)} ${_dueTime != null ? DateFormat('HH:mm').format(DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day, _dueTime!.hour, _dueTime!.minute)) : ''}'
                      : 'No due date'),
                ),
                TextButton(
                  child: const Text('Pick Date'),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dueDate = pickedDate;
                      });
                    }
                  },
                ),
                TextButton(
                  child: const Text('Pick Time'),
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime:
                      _dueTime ?? TimeOfDay.fromDateTime(DateTime.now()),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _dueTime = pickedTime;
                      });
                    }
                  },
                ),
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

            DateTime? finalDueDate;
            if (_dueDate != null) {
              if (_dueTime != null) {
                finalDueDate = DateTime(
                  _dueDate!.year,
                  _dueDate!.month,
                  _dueDate!.day,
                  _dueTime!.hour,
                  _dueTime!.minute,
                );
              } else {
                finalDueDate = _dueDate; // Only date, no time.
              }
            }
            final repo = ref.read(firestoreRepositoryProvider);
            final newTask = Task(
              id: widget.task?.id ?? const Uuid().v4(),
              userId: user.uid,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              isDone: _isDone,
              createdAt: widget.task?.createdAt ?? DateTime.now(),
              dueDate: finalDueDate,
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

