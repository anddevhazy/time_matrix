import 'package:equatable/equatable.dart';

/// A raw, unsorted thought captured in the mind dump. It has no quadrant yet —
/// assigning one turns it into a [TaskEntity] and removes it from the dump.
class DumpEntry extends Equatable {
  const DumpEntry({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, text, createdAt];
}
