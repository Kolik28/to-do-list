import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';

enum TaskFilter { all, today, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = TaskStorage();
  final _searchController = TextEditingController();
  List<TodoTask> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final tasks = await _storage.loadTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _save() => _storage.saveTasks(_tasks);

  int get _completed => _tasks.where((task) => task.isCompleted).length;

  List<TodoTask> get _visible {
    final now = DateTime.now();
    final result = _tasks.where((task) {
      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.today =>
          task.dueDate != null &&
              DateUtils.isSameDay(task.dueDate, now) &&
              !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          task.title.toLowerCase().contains(q) ||
          task.description.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return result;
  }

  Future<void> _editTask({TodoTask? task}) async {
    final title = TextEditingController(text: task?.title ?? '');
    final description = TextEditingController(text: task?.description ?? '');
    DateTime? dueDate = task?.dueDate;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refreshDialog) => AlertDialog(
          title: Text(task == null ? 'New task' : 'Edit task'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: title,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Task title', hintText: 'What needs doing?'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Description', hintText: 'Optional details'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    refreshDialog(() => dueDate = selected);
                  }
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(dueDate == null
                    ? 'Add due date'
                    : DateFormat('d MMM yyyy').format(dueDate!)),
              ),
              if (dueDate != null)
                TextButton(
                  onPressed: () => refreshDialog(() => dueDate = null),
                  child: const Text('Remove due date'),
                ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(task == null ? 'Add task' : 'Save changes'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && title.text.trim().isNotEmpty) {
      setState(() {
        if (task == null) {
          _tasks.insert(
            0,
            TodoTask(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: title.text.trim(),
              description: description.text.trim(),
              dueDate: dueDate,
              createdAt: DateTime.now(),
            ),
          );
        } else {
          final index = _tasks.indexWhere((item) => item.id == task.id);
          if (index >= 0) {
            _tasks[index] = task.copyWith(
              title: title.text.trim(),
              description: description.text.trim(),
              dueDate: dueDate,
              clearDueDate: dueDate == null,
            );
          }
        }
      });
      await _save();
    }
    title.dispose();
    description.dispose();
  }

  Future<void> _toggle(TodoTask task, bool? value) async {
    setState(() {
      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index >= 0) {
        _tasks[index] = task.copyWith(isCompleted: value ?? false);
      }
    });
    await _save();
  }

  Future<void> _delete(TodoTask task) async {
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
    await _save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Task deleted'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() => _tasks.insert(0, task));
          _save();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final progress = _tasks.isEmpty ? 0.0 : _completed / _tasks.length;
    final pending = _tasks.length - _completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('daylist.',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: CircleAvatar(
              backgroundColor: Color(0x1A6658D3),
              child: Icon(Icons.check_rounded, color: AppTheme.violet),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTask(),
        backgroundColor: AppTheme.violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 13)),
                        const SizedBox(height: 7),
                        const Text('Make today count.',
                            style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                              color: AppTheme.violet,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Expanded(
                                      child: Text('Your progress',
                                          style: TextStyle(
                                              color: Colors.white70))),
                                  Text((progress * 100).round().toString() + '%',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20)),
                                ]),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('$pending tasks left · $_completed completed',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ]),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: 'Search your tasks',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close_rounded)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(children: [
                          _FilterChip(
                            label: 'All',
                            count: _tasks.length,
                            selected: _filter == TaskFilter.all,
                            onTap: () =>
                                setState(() => _filter = TaskFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Today',
                            count: _tasks.where((t) =>
                                t.dueDate != null &&
                                DateUtils.isSameDay(t.dueDate, DateTime.now()) &&
                                !t.isCompleted).length,
                            selected: _filter == TaskFilter.today,
                            onTap: () =>
                                setState(() => _filter = TaskFilter.today),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Done',
                            count: _completed,
                            selected: _filter == TaskFilter.completed,
                            onTap: () =>
                                setState(() => _filter = TaskFilter.completed),
                          ),
                        ]),
                      ]),
                ),
                Expanded(
                  child: _visible.isEmpty
                      ? _EmptyState(
                          searching: _query.isNotEmpty,
                          onAdd: () => _editTask())
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: _visible.length,
                          itemBuilder: (context, index) {
                            final task = _visible[index];
                            return TaskTile(
                              task: task,
                              onChanged: (value) => _toggle(task, value),
                              onEdit: () => _editTask(task: task),
                              onDelete: () => _delete(task),
                            );
                          },
                        ),
                ),
              ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: selected ? AppTheme.ink : Colors.white,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
              child: Center(
                child: Text('$label ($count)',
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.muted)),
              ),
            ),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching, required this.onAdd});
  final bool searching;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(searching ? Icons.search_off_rounded : Icons.task_alt_rounded,
                size: 54, color: AppTheme.violet.withValues(alpha: 0.55)),
            const SizedBox(height: 14),
            Text(searching ? 'No matching tasks' : 'Nothing on your list',
                style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
                searching
                    ? 'Try another keyword.'
                    : 'Add a task and make your next step count.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted)),
            if (!searching) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create your first task')),
            ],
          ]),
        ),
      );
}
