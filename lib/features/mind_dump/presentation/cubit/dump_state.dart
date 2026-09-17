part of 'dump_cubit.dart';

sealed class DumpState extends Equatable {
  const DumpState();

  @override
  List<Object?> get props => [];
}

class DumpInitial extends DumpState {
  const DumpInitial();
}

class DumpLoading extends DumpState {
  const DumpLoading();
}

class DumpLoaded extends DumpState {
  const DumpLoaded({
    required this.entries,
    this.assignments = const {},
    this.isSaving = false,
    this.errorMessage,
  });

  final List<DumpEntry> entries;

  /// Quadrant picked for each entry id, held locally until the user saves.
  /// Entries absent from this map stay in the dump untouched.
  final Map<String, Quadrant> assignments;

  final bool isSaving;
  final String? errorMessage;

  /// In manual order; entries never reordered read oldest first, in the order
  /// things were dumped.
  List<DumpEntry> get orderedEntries {
    final ordered = [...entries]
      ..sort((a, b) {
        final byOrder = a.effectiveSortOrder.compareTo(b.effectiveSortOrder);
        return byOrder != 0 ? byOrder : a.createdAt.compareTo(b.createdAt);
      });
    return ordered;
  }

  /// Only entries that still exist can be saved — an assignment can outlive its
  /// entry if the same dump is edited on another device mid-triage.
  int get pendingCount =>
      entries.where((entry) => assignments.containsKey(entry.id)).length;

  DumpLoaded copyWith({
    List<DumpEntry>? entries,
    Map<String, Quadrant>? assignments,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DumpLoaded(
      entries: entries ?? this.entries,
      assignments: assignments ?? this.assignments,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [entries, assignments, isSaving, errorMessage];
}

class DumpError extends DumpState {
  const DumpError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
