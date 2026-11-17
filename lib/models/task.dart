class TodoTask {
  const TodoTask({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  TodoTask copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) =>
      TodoTask(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        isCompleted: (json['isCompleted'] as bool?) ?? false,
        dueDate: json['dueDate'] == null
            ? null
            : DateTime.tryParse(json['dueDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
