enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.label);

  final String label;

  static TaskPriority fromName(String name) =>
      TaskPriority.values.firstWhere((p) => p.name == name, orElse: () => TaskPriority.medium);
}
