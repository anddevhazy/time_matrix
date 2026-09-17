import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../global/core/error/failures.dart';
import '../../../task_matrix/domain/entities/quadrant.dart';
import '../../../task_matrix/domain/entities/task_entity.dart';
import '../../../task_matrix/domain/usecases/add_task_usecase.dart';
import '../../domain/entities/dump_entry.dart';
import '../../domain/usecases/add_dump_entry_usecase.dart';
import '../../domain/usecases/delete_dump_entries_usecase.dart';
import '../../domain/usecases/reorder_dump_entries_usecase.dart';
import '../../domain/usecases/watch_dump_entries_usecase.dart';

part 'dump_state.dart';

/// Owns the mind dump. Quadrant picks are staged in state and only reach
/// Firestore when the user saves, so a mis-click costs nothing until then.
class DumpCubit extends Cubit<DumpState> {
  DumpCubit({
    required WatchDumpEntriesUsecase watchDumpEntriesUsecase,
    required AddDumpEntryUsecase addDumpEntryUsecase,
    required DeleteDumpEntriesUsecase deleteDumpEntriesUsecase,
    required ReorderDumpEntriesUsecase reorderDumpEntriesUsecase,
    required AddTaskUsecase addTaskUsecase,
  })  : _watchDumpEntriesUsecase = watchDumpEntriesUsecase,
        _addDumpEntryUsecase = addDumpEntryUsecase,
        _deleteDumpEntriesUsecase = deleteDumpEntriesUsecase,
        _reorderDumpEntriesUsecase = reorderDumpEntriesUsecase,
        _addTaskUsecase = addTaskUsecase,
        super(const DumpInitial());

  final WatchDumpEntriesUsecase _watchDumpEntriesUsecase;
  final AddDumpEntryUsecase _addDumpEntryUsecase;
  final DeleteDumpEntriesUsecase _deleteDumpEntriesUsecase;
  final ReorderDumpEntriesUsecase _reorderDumpEntriesUsecase;
  final AddTaskUsecase _addTaskUsecase;

  StreamSubscription<Either<Failure, List<DumpEntry>>>? _subscription;

  Future<void> loadEntries() async {
    emit(const DumpLoading());
    await _subscription?.cancel();
    _subscription = _watchDumpEntriesUsecase().listen((result) {
      result.fold(
        (failure) => emit(DumpError(failure)),
        (entries) {
          final current = state;
          emit(
            current is DumpLoaded
                ? current.copyWith(entries: entries)
                : DumpLoaded(entries: entries),
          );
        },
      );
    });
  }

  /// Mirrors [TaskCubit.stopWatching] — drop the listener on sign-out so it
  /// doesn't keep querying with no authenticated uid.
  Future<void> stopWatching() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(const DumpInitial());
  }

  Future<void> addEntry(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final result = await _addDumpEntryUsecase(
      DumpEntry(id: const Uuid().v4(), text: trimmed, createdAt: DateTime.now()),
    );
    result.fold(_emitError, (_) {});
  }

  /// Stages a quadrant for [entryId]; picking the same one again clears it.
  void assign(String entryId, Quadrant quadrant) {
    final current = state;
    if (current is! DumpLoaded) return;
    final assignments = Map<String, Quadrant>.from(current.assignments);
    if (assignments[entryId] == quadrant) {
      assignments.remove(entryId);
    } else {
      assignments[entryId] = quadrant;
    }
    emit(current.copyWith(assignments: assignments, clearError: true));
  }

  Future<void> discardEntry(String entryId) async {
    final current = state;
    if (current is! DumpLoaded) return;
    final assignments = Map<String, Quadrant>.from(current.assignments)..remove(entryId);
    emit(current.copyWith(assignments: assignments, clearError: true));
    final result = await _deleteDumpEntriesUsecase([entryId]);
    result.fold(_emitError, (_) {});
  }

  /// Handles a drop from [ReorderableListView]. The new order shows
  /// immediately and is then saved.
  Future<void> reorderEntry(int oldIndex, int newIndex) async {
    final current = state;
    if (current is! DumpLoaded || current.isSaving) return;
    final ordered = current.orderedEntries;
    if (oldIndex < 0 || oldIndex >= ordered.length) return;
    // The index is reported as if the dragged entry were still in the list.
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex == oldIndex) return;

    ordered.insert(newIndex, ordered.removeAt(oldIndex));
    emit(
      current.copyWith(
        entries: [for (var i = 0; i < ordered.length; i++) ordered[i].copyWith(sortOrder: i)],
        clearError: true,
      ),
    );

    final result = await _reorderDumpEntriesUsecase([for (final e in ordered) e.id]);
    result.fold(_emitError, (_) {});
  }

  /// Turns every assigned entry into a task, then removes the entries that made
  /// it across. Entries whose task failed to write keep their assignment so the
  /// user can retry; unassigned entries are left in the dump.
  Future<void> saveAssigned() async {
    final current = state;
    if (current is! DumpLoaded || current.isSaving) return;

    final pending = current.orderedEntries
        .where((entry) => current.assignments.containsKey(entry.id))
        .toList();
    if (pending.isEmpty) return;

    emit(current.copyWith(isSaving: true, clearError: true));

    final savedIds = <String>[];
    Failure? firstFailure;
    for (final entry in pending) {
      final result = await _addTaskUsecase(
        TaskEntity(
          id: const Uuid().v4(),
          title: entry.text,
          quadrant: current.assignments[entry.id]!,
          createdAt: DateTime.now(),
        ),
      );
      result.fold(
        (failure) => firstFailure ??= failure,
        (_) => savedIds.add(entry.id),
      );
    }

    if (savedIds.isNotEmpty) {
      final deletion = await _deleteDumpEntriesUsecase(savedIds);
      deletion.fold((failure) => firstFailure ??= failure, (_) {});
    }

    final latest = state;
    if (latest is! DumpLoaded) return;
    final assignments = Map<String, Quadrant>.from(latest.assignments)
      ..removeWhere((id, _) => savedIds.contains(id));
    emit(
      latest.copyWith(
        assignments: assignments,
        isSaving: false,
        clearError: firstFailure == null,
        errorMessage: firstFailure?.message,
      ),
    );
  }

  void _emitError(Failure failure) {
    final current = state;
    if (current is DumpLoaded) {
      emit(current.copyWith(errorMessage: failure.message));
    } else {
      emit(DumpError(failure));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
