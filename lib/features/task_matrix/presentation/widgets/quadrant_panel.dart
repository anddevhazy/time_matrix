import 'package:flutter/material.dart';

import '../../../global/components/empty_state.dart';
import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import 'quadrant_x.dart';
import 'task_card.dart';

class QuadrantPanel extends StatelessWidget {
  const QuadrantPanel({
    super.key,
    required this.quadrant,
    required this.tasks,
    required this.onAcceptTask,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onToggleCompletion,
    required this.onDeleteTask,
  });

  final Quadrant quadrant;
  final List<TaskEntity> tasks;
  final ValueChanged<String> onAcceptTask;
  final VoidCallback onAddTask;
  final ValueChanged<TaskEntity> onTaskTap;
  final ValueChanged<String> onToggleCompletion;
  final ValueChanged<String> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => onAcceptTask(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovering ? quadrant.color : AppColors.border,
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(quadrant: quadrant, count: tasks.length, onAddTask: onAddTask),
              Expanded(
                child: tasks.isEmpty
                    ? EmptyState(
                        icon: Icons.inbox_outlined,
                        message: isHovering ? 'Drop to move here' : 'No tasks here yet',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () => onTaskTap(task),
                            onToggleCompletion: () => onToggleCompletion(task.id),
                            onDelete: () => onDeleteTask(task.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.quadrant, required this.count, required this.onAddTask});

  final Quadrant quadrant;
  final int count;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: quadrant.color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: quadrant.color, borderRadius: BorderRadius.circular(8)),
            child: Icon(quadrant.icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(quadrant.title, style: AppTextStyles.title),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: quadrant.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.caption.copyWith(color: quadrant.color),
                      ),
                    ),
                  ],
                ),
                Text(quadrant.subtitle, style: AppTextStyles.subtitle),
              ],
            ),
          ),
          IconButton(
            onPressed: onAddTask,
            icon: Icon(Icons.add_rounded, color: quadrant.color),
            tooltip: 'Add task to ${quadrant.title}',
          ),
        ],
      ),
    );
  }
}
