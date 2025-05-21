
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/services/notification_service.dart';
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

  int _getNotificationId(String taskId) {
    return taskId.hashCode.abs(); // Hash the UUID string to get a unique integer ID
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
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
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

            await NotificationService.cancelNotification(_getNotificationId(newTask.id));
            debugPrint('Attempted to cancel existing notification for task ID: ${newTask.id}');

            if (widget.task == null) {
              await repo.addTask(newTask);
              // await NotificationService.createNotification(
              //   id: _getNotificationId(newTask.id),
              //   title: 'Task Added: ${newTask.title}',
              //   body: 'You have an upcoming task due',
              //   payload: {'taskId': newTask.id}, // Pass task ID for deep linking
              // );
            } else {
              await repo.updateTask(newTask);
              // await NotificationService.createNotification(
              //   id: _getNotificationId(newTask.id),
              //   title: 'Task Updated: ${newTask.title}',
              //   body: 'You have an upcoming task due!',
              //   payload: {'taskId': newTask.id}, // Pass task ID for deep linking
              // );
            }

            // 3. Schedule a new notification if applicable
            // Conditions for scheduling: not done, has a future due date
            if (!newTask.isDone &&
                newTask.dueDate != null &&
                newTask.dueDate!.isAfter(DateTime.now())) {

              final int intervalInSeconds = newTask.dueDate!.difference(DateTime.now()).inSeconds;

              // Only schedule if the due date is genuinely in the future (positive interval)
              if (intervalInSeconds > 0) {
                await NotificationService.createNotification(
                  id: _getNotificationId(newTask.id),
                  title: 'Task Reminder: ${newTask.title}',
                  body: 'You have an upcoming task due ${DateFormat('HH:mm').format(newTask.dueDate!)}!',
                  payload: {'taskId': newTask.id}, // Pass task ID for deep linking
                  scheduled: true,
                  interval: Duration(seconds: intervalInSeconds),
                );
                debugPrint('Scheduled new notification for task ID: ${newTask.id} at ${newTask.dueDate}');
              } else {
                // Handle case where due date is now or in the past but the notification was intended to be scheduled
                debugPrint('Due date is past or current, not scheduling new notification for task ID: ${newTask.id}');
              }
            } else {
              // If the task is done, has no due date, or due date is in the past,
              // ensure any lingering notification is cancelled (already done above, but for clarity)
              debugPrint('Task is done, no due date, or due date is past. Notification cancelled (or not scheduled).');
            }
            // --- END Awesome Notifications Logic ---

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

