import 'package:equatable/equatable.dart';

/// A raw, unsorted thought captured in the mind dump. It has no quadrant yet —
/// assigning one turns it into a [TaskEntity] and removes it from the dump.
class DumpEntry extends Equatable {
  const DumpEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    this.sortOrder,
  });

  final String id;
  final String text;
  final DateTime createdAt;

  /// Manual position set by drag-to-reorder; null until first reordered.
  final int? sortOrder;

  /// Unpositioned entries fall back to their creation time, which sorts after
  /// every reordered index, so new thoughts are appended at the bottom.
  int get effectiveSortOrder => sortOrder ?? createdAt.millisecondsSinceEpoch;

  DumpEntry copyWith({int? sortOrder}) {
    return DumpEntry(
      id: id,
      text: text,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, text, createdAt, sortOrder];
}
