/// The four quadrants of the Eisenhower time-management matrix.
enum Quadrant {
  doFirst('Do First', 'Urgent & Important'),
  schedule('Schedule', 'Not Urgent & Important'),
  delegate('Delegate', 'Urgent & Not Important'),
  eliminate('Eliminate', 'Not Urgent & Not Important');

  const Quadrant(this.title, this.subtitle);

  final String title;
  final String subtitle;

  static Quadrant fromName(String name) =>
      Quadrant.values.firstWhere((q) => q.name == name, orElse: () => Quadrant.doFirst);
}
