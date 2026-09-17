import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:time_matrix/features/global/core/error/failures.dart';
import 'package:time_matrix/features/mind_dump/domain/entities/dump_entry.dart';
import 'package:time_matrix/features/mind_dump/domain/repositories/dump_repository.dart';
import 'package:time_matrix/features/mind_dump/domain/usecases/add_dump_entry_usecase.dart';
import 'package:time_matrix/features/mind_dump/domain/usecases/delete_dump_entries_usecase.dart';
import 'package:time_matrix/features/mind_dump/domain/usecases/reorder_dump_entries_usecase.dart';
import 'package:time_matrix/features/mind_dump/domain/usecases/watch_dump_entries_usecase.dart';
import 'package:time_matrix/features/mind_dump/presentation/cubit/dump_cubit.dart';
import 'package:time_matrix/features/task_matrix/domain/entities/quadrant.dart';
import 'package:time_matrix/features/task_matrix/domain/entities/task_entity.dart';
import 'package:time_matrix/features/task_matrix/domain/repositories/task_repository.dart';
import 'package:time_matrix/features/task_matrix/domain/usecases/add_task_usecase.dart';
import 'package:time_matrix/features/task_matrix/domain/usecases/delete_task_usecase.dart';
import 'package:time_matrix/features/task_matrix/domain/usecases/reorder_tasks_usecase.dart';
import 'package:time_matrix/features/task_matrix/domain/usecases/update_task_usecase.dart';
import 'package:time_matrix/features/task_matrix/domain/usecases/watch_tasks_usecase.dart';
import 'package:time_matrix/features/task_matrix/presentation/cubit/task_cubit.dart';
import 'package:time_matrix/features/task_matrix/presentation/widgets/quadrant_panel.dart';

/// Stands in for Firestore: emits a fixed snapshot and records reorder writes.
class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(this.tasks);

  final List<TaskEntity> tasks;
  final savedOrders = <List<String>>[];

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks() => Stream.value(Right(tasks));

  @override
  Future<Either<Failure, Unit>> addTask(TaskEntity task) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> updateTask(TaskEntity task) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> reorderTasks(List<String> orderedIds) async {
    savedOrders.add(orderedIds);
    return const Right(unit);
  }
}

class _FakeDumpRepository implements DumpRepository {
  _FakeDumpRepository(this.entries);

  final List<DumpEntry> entries;
  final savedOrders = <List<String>>[];

  @override
  Stream<Either<Failure, List<DumpEntry>>> watchEntries() => Stream.value(Right(entries));

  @override
  Future<Either<Failure, Unit>> addEntry(DumpEntry entry) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteEntries(List<String> ids) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> reorderEntries(List<String> orderedIds) async {
    savedOrders.add(orderedIds);
    return const Right(unit);
  }
}

TaskEntity _task(String id, int minute, {Quadrant quadrant = Quadrant.doFirst, String? title}) =>
    TaskEntity(
      id: id,
      title: title ?? id,
      quadrant: quadrant,
      createdAt: DateTime(2026, 1, 1, 9, minute),
    );

Future<TaskCubit> _loadedTaskCubit(_FakeTaskRepository repository) async {
  final cubit = TaskCubit(
    watchTasksUsecase: WatchTasksUsecase(repository),
    addTaskUsecase: AddTaskUsecase(repository),
    updateTaskUsecase: UpdateTaskUsecase(repository),
    deleteTaskUsecase: DeleteTaskUsecase(repository),
    reorderTasksUsecase: ReorderTasksUsecase(repository),
  );
  await cubit.loadTasks();
  await Future<void>.delayed(Duration.zero);
  return cubit;
}

List<String> _ids(List<TaskEntity> tasks) => [for (final t in tasks) t.id];

void main() {
  group('TaskCubit.reorderTask', () {
    test('unpositioned tasks list oldest first', () async {
      final repository = _FakeTaskRepository([_task('c', 3), _task('a', 1), _task('b', 2)]);
      final cubit = await _loadedTaskCubit(repository);
      addTearDown(cubit.close);

      expect(_ids((cubit.state as TaskLoaded).tasksFor(Quadrant.doFirst)), ['a', 'b', 'c']);
    });

    test('moves a task down and saves the whole quadrant order', () async {
      final repository = _FakeTaskRepository([
        _task('a', 1),
        _task('b', 2),
        _task('c', 3),
        _task('other', 0, quadrant: Quadrant.schedule),
      ]);
      final cubit = await _loadedTaskCubit(repository);
      addTearDown(cubit.close);

      // ReorderableListView reports the drop slot before removal: end of list = 3.
      await cubit.reorderTask(Quadrant.doFirst, 0, 3);

      final state = cubit.state as TaskLoaded;
      expect(_ids(state.tasksFor(Quadrant.doFirst)), ['b', 'c', 'a']);
      expect(repository.savedOrders, [
        ['b', 'c', 'a'],
      ]);
      expect(state.tasks.firstWhere((t) => t.id == 'other').sortOrder, isNull);
    });

    test('while searching, hidden tasks keep their positions', () async {
      final repository = _FakeTaskRepository([
        _task('a', 1, title: 'alpha work'),
        _task('b', 2, title: 'beta'),
        _task('c', 3, title: 'gamma work'),
      ]);
      final cubit = await _loadedTaskCubit(repository);
      addTearDown(cubit.close);

      cubit.search('work');
      await cubit.reorderTask(Quadrant.doFirst, 1, 0);

      final state = cubit.state as TaskLoaded;
      expect(_ids(state.tasksFor(Quadrant.doFirst)), ['c', 'a']);
      expect(_ids(state.allTasksFor(Quadrant.doFirst)), ['c', 'b', 'a']);
      expect(repository.savedOrders, [
        ['c', 'b', 'a'],
      ]);
    });

    test('dropping a task where it started saves nothing', () async {
      final repository = _FakeTaskRepository([_task('a', 1), _task('b', 2)]);
      final cubit = await _loadedTaskCubit(repository);
      addTearDown(cubit.close);

      await cubit.reorderTask(Quadrant.doFirst, 0, 1);

      expect(repository.savedOrders, isEmpty);
    });
  });

  test('DumpCubit.reorderEntry moves an entry up and saves the order', () async {
    final repository = _FakeDumpRepository([
      for (var i = 1; i <= 3; i++)
        DumpEntry(id: 'e$i', text: 'thought $i', createdAt: DateTime(2026, 1, 1, 9, i)),
    ]);
    final taskRepository = _FakeTaskRepository([]);
    final cubit = DumpCubit(
      watchDumpEntriesUsecase: WatchDumpEntriesUsecase(repository),
      addDumpEntryUsecase: AddDumpEntryUsecase(repository),
      deleteDumpEntriesUsecase: DeleteDumpEntriesUsecase(repository),
      reorderDumpEntriesUsecase: ReorderDumpEntriesUsecase(repository),
      addTaskUsecase: AddTaskUsecase(taskRepository),
    );
    addTearDown(cubit.close);
    await cubit.loadEntries();
    await Future<void>.delayed(Duration.zero);

    await cubit.reorderEntry(2, 0);

    final ordered = (cubit.state as DumpLoaded).orderedEntries;
    expect([for (final e in ordered) e.id], ['e3', 'e1', 'e2']);
    expect(repository.savedOrders, [
      ['e3', 'e1', 'e2'],
    ]);
  });

  testWidgets('dragging the handle reorders instead of moving the task to a quadrant', (
    tester,
  ) async {
    final reorders = <(int, int)>[];
    final accepted = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: QuadrantPanel(
              quadrant: Quadrant.doFirst,
              tasks: [_task('a', 1), _task('b', 2), _task('c', 3)],
              onAcceptTask: accepted.add,
              onAddTask: () {},
              onTaskTap: (_) {},
              onToggleCompletion: (_) {},
              onDeleteTask: (_) {},
              onReorder: (oldIndex, newIndex) => reorders.add((oldIndex, newIndex)),
            ),
          ),
        ),
      ),
    );

    final firstHandle = find.byIcon(Icons.drag_handle_rounded).first;
    final gesture = await tester.startGesture(tester.getCenter(firstHandle));
    for (var i = 0; i < 20; i++) {
      await gesture.moveBy(const Offset(0, 15));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(reorders, hasLength(1));
    expect(reorders.single.$1, 0);
    expect(reorders.single.$2, greaterThan(1));
    expect(accepted, isEmpty);
  });
}
