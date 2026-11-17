import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoTask task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate;
    final overdue = due != null &&
        !task.isCompleted &&
        due.isBefore(DateTime.now()) &&
        !DateUtils.isSameDay(due, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onChanged,
          activeColor: AppTheme.violet,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
            if (due != null) ...[
              const SizedBox(height: 7),
              Row(children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: overdue ? Colors.redAccent : AppTheme.muted),
                const SizedBox(width: 5),
                Text(DateFormat('d MMM yyyy').format(due),
                    style: TextStyle(
                        fontSize: 11,
                        color: overdue ? Colors.redAccent : AppTheme.muted)),
                if (overdue) ...[
                  const SizedBox(width: 6),
                  const Text('Overdue',
                      style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                ],
              ]),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
