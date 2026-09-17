import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../../../mind_dump/presentation/cubit/dump_cubit.dart';
import '../../../mind_dump/presentation/pages/mind_dump_view.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../widgets/filter_bar.dart';
import '../widgets/quadrant_panel.dart';
import '../widgets/quadrant_x.dart';
import '../widgets/task_form_sheet.dart';

enum MatrixView { grid, list, tabs, dump }

class MatrixPage extends StatefulWidget {
  const MatrixPage({super.key});

  @override
  State<MatrixPage> createState() => _MatrixPageState();
}

class _MatrixPageState extends State<MatrixPage> {
  MatrixView _view = MatrixView.grid;

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
    context.read<DumpCubit>().loadEntries();
  }

  @override
  void dispose() {
    context.read<TaskCubit>().stopWatching();
    context.read<DumpCubit>().stopWatching();
    super.dispose();
  }

  Future<void> _openTaskForm({Quadrant? initialQuadrant, TaskEntity? existingTask}) async {
    final cubit = context.read<TaskCubit>();
    final result = await showTaskFormSheet(
      context,
      initialQuadrant: initialQuadrant,
      existingTask: existingTask,
    );
    if (result == null) return;
    if (existingTask == null) {
      cubit.addTask(result);
    } else {
      cubit.updateTask(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  state: state,
                  view: _view,
                  onViewChanged: (view) => setState(() => _view = view),
                  onAddTask: () => _openTaskForm(),
                ),
                Expanded(
                  child: _view == MatrixView.dump
                      ? const MindDumpView()
                      : switch (state) {
                          TaskInitial() || TaskLoading() =>
                            const Center(child: CircularProgressIndicator()),
                          TaskError(:final failure) => Center(child: Text(failure.message)),
                          TaskLoaded() => switch (_view) {
                              MatrixView.grid =>
                                _GridMatrix(state: state, onOpenForm: _openTaskForm),
                              MatrixView.list =>
                                _ListMatrix(state: state, onOpenForm: _openTaskForm),
                              MatrixView.tabs =>
                                _TabsMatrix(state: state, onOpenForm: _openTaskForm),
                              MatrixView.dump => const MindDumpView(),
                            },
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.state,
    required this.view,
    required this.onViewChanged,
    required this.onAddTask,
  });

  final TaskState state;
  final MatrixView view;
  final ValueChanged<MatrixView> onViewChanged;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Time Matrix', style: AppTextStyles.displayLarge),
                  Text(
                    'Prioritize what matters using the Eisenhower method',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ViewToggle(view: view, onChanged: onViewChanged),
                  FilledButton.icon(
                    onPressed: onAddTask,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New task'),
                  ),
                  IconButton(
                    onPressed: () => context.read<AuthCubit>().signOut(),
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Sign out',
                    color: AppColors.textSecondary,
                  ),
                ],
              );

              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), actions],
                );
              }
              return Row(
                children: [Expanded(child: title), const SizedBox(width: 12), actions],
              );
            },
          ),
          if (state is TaskLoaded && view != MatrixView.dump) ...[
            const SizedBox(height: 16),
            FilterBar(
              onSearchChanged: context.read<TaskCubit>().search,
            ),
          ],
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onChanged});

  final MatrixView view;
  final ValueChanged<MatrixView> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MatrixView>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: const [
        ButtonSegment(
          value: MatrixView.grid,
          icon: Icon(Icons.grid_view_rounded, size: 18),
          label: Text('Grid', softWrap: false),
        ),
        ButtonSegment(
          value: MatrixView.list,
          icon: Icon(Icons.view_list_rounded, size: 18),
          label: Text('List', softWrap: false),
        ),
        ButtonSegment(
          value: MatrixView.tabs,
          icon: Icon(Icons.view_carousel_outlined, size: 18),
          label: Text('Tabs', softWrap: false),
        ),
        ButtonSegment(
          value: MatrixView.dump,
          icon: Icon(Icons.psychology_alt_outlined, size: 18),
          label: Text('Dump', softWrap: false),
        ),
      ],
      selected: {view},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

typedef _OpenForm = Future<void> Function({Quadrant? initialQuadrant, TaskEntity? existingTask});

/// Always renders all four quadrants in a fixed 2x2 grid that exactly fills
/// the available space — no page-level scrolling at any screen size. Each
/// panel's own task list scrolls internally instead.
class _GridMatrix extends StatelessWidget {
  const _GridMatrix({required this.state, required this.onOpenForm});

  final TaskLoaded state;
  final _OpenForm onOpenForm;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskCubit>();

    Widget panel(Quadrant quadrant) => QuadrantPanel(
          quadrant: quadrant,
          tasks: state.tasksFor(quadrant),
          onAcceptTask: (id) => cubit.moveTaskToQuadrant(id, quadrant),
          onAddTask: () => onOpenForm(initialQuadrant: quadrant),
          onTaskTap: (task) => onOpenForm(existingTask: task),
          onToggleCompletion: cubit.toggleCompletion,
          onDeleteTask: cubit.deleteTask,
          onReorder: (oldIndex, newIndex) => cubit.reorderTask(quadrant, oldIndex, newIndex),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: panel(Quadrant.doFirst)),
                const SizedBox(width: 16),
                Expanded(child: panel(Quadrant.schedule)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(child: panel(Quadrant.delegate)),
                const SizedBox(width: 16),
                Expanded(child: panel(Quadrant.eliminate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single scrollable list with all four quadrants stacked as sections —
/// a denser, list-style alternative to the grid.
class _ListMatrix extends StatelessWidget {
  const _ListMatrix({required this.state, required this.onOpenForm});

  final TaskLoaded state;
  final _OpenForm onOpenForm;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskCubit>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        for (final quadrant in Quadrant.values) ...[
          QuadrantPanel(
            shrinkWrap: true,
            quadrant: quadrant,
            tasks: state.tasksFor(quadrant),
            onAcceptTask: (id) => cubit.moveTaskToQuadrant(id, quadrant),
            onAddTask: () => onOpenForm(initialQuadrant: quadrant),
            onTaskTap: (task) => onOpenForm(existingTask: task),
            onToggleCompletion: cubit.toggleCompletion,
            onDeleteTask: cubit.deleteTask,
            onReorder: (oldIndex, newIndex) => cubit.reorderTask(quadrant, oldIndex, newIndex),
          ),
          if (quadrant != Quadrant.values.last) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// Navigates one quadrant at a time via a tab bar — available at any screen size.
class _TabsMatrix extends StatefulWidget {
  const _TabsMatrix({required this.state, required this.onOpenForm});

  final TaskLoaded state;
  final _OpenForm onOpenForm;

  @override
  State<_TabsMatrix> createState() => _TabsMatrixState();
}

class _TabsMatrixState extends State<_TabsMatrix> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: Quadrant.values.length, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            for (final quadrant in Quadrant.values)
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(quadrant.icon, size: 16, color: quadrant.color),
                    const SizedBox(width: 6),
                    Text(quadrant.title),
                  ],
                ),
              ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (final quadrant in Quadrant.values)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: QuadrantPanel(
                    quadrant: quadrant,
                    tasks: widget.state.tasksFor(quadrant),
                    onAcceptTask: (id) => cubit.moveTaskToQuadrant(id, quadrant),
                    onAddTask: () => widget.onOpenForm(initialQuadrant: quadrant),
                    onTaskTap: (task) => widget.onOpenForm(existingTask: task),
                    onToggleCompletion: cubit.toggleCompletion,
                    onDeleteTask: cubit.deleteTask,
                    onReorder: (oldIndex, newIndex) =>
                        cubit.reorderTask(quadrant, oldIndex, newIndex),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
