import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../widgets/filter_bar.dart';
import '../widgets/quadrant_panel.dart';
import '../widgets/quadrant_x.dart';
import '../widgets/task_form_sheet.dart';

const _wideBreakpoint = 900.0;

class MatrixPage extends StatefulWidget {
  const MatrixPage({super.key});

  @override
  State<MatrixPage> createState() => _MatrixPageState();
}

class _MatrixPageState extends State<MatrixPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
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
                _TopBar(state: state, onAddTask: () => _openTaskForm()),
                Expanded(
                  child: switch (state) {
                    TaskInitial() || TaskLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    TaskError(:final failure) => Center(child: Text(failure.message)),
                    TaskLoaded() => LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= _wideBreakpoint;
                          return isWide
                              ? _WideMatrix(state: state, onOpenForm: _openTaskForm)
                              : _NarrowMatrix(state: state, onOpenForm: _openTaskForm);
                        },
                      ),
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
  const _TopBar({required this.state, required this.onAddTask});

  final TaskState state;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Matrix', style: AppTextStyles.displayLarge),
                    Text(
                      'Prioritize what matters using the Eisenhower method',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('New task'),
              ),
            ],
          ),
          if (state is TaskLoaded) ...[
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

typedef _OpenForm = Future<void> Function({Quadrant? initialQuadrant, TaskEntity? existingTask});

class _WideMatrix extends StatelessWidget {
  const _WideMatrix({required this.state, required this.onOpenForm});

  final TaskLoaded state;
  final _OpenForm onOpenForm;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaskCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: [
          for (final quadrant in Quadrant.values)
            QuadrantPanel(
              quadrant: quadrant,
              tasks: state.tasksFor(quadrant),
              onAcceptTask: (id) => cubit.moveTaskToQuadrant(id, quadrant),
              onAddTask: () => onOpenForm(initialQuadrant: quadrant),
              onTaskTap: (task) => onOpenForm(existingTask: task),
              onToggleCompletion: cubit.toggleCompletion,
              onDeleteTask: cubit.deleteTask,
            ),
        ],
      ),
    );
  }
}

class _NarrowMatrix extends StatefulWidget {
  const _NarrowMatrix({required this.state, required this.onOpenForm});

  final TaskLoaded state;
  final _OpenForm onOpenForm;

  @override
  State<_NarrowMatrix> createState() => _NarrowMatrixState();
}

class _NarrowMatrixState extends State<_NarrowMatrix> with SingleTickerProviderStateMixin {
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
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
