import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';
import 'quadrant_x.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final card = _CardBody(
      task: task,
      onTap: onTap,
      onToggleCompletion: onToggleCompletion,
      onDelete: onDelete,
    );

    return LongPressDraggable<String>(
      data: task.id,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 260, child: Opacity(opacity: 0.9, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.task,
    required this.onTap,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggleCompletion,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      task.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 20,
                      color: task.isCompleted ? AppColors.schedule : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyles.body.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.dueDate != null || task.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (task.dueDate != null)
                              Text(
                                DateFormat.MMMd().format(task.dueDate!),
                                style: AppTextStyles.caption.copyWith(
                                  color: task.isOverdue
                                      ? AppColors.doFirst
                                      : AppColors.textSecondary,
                                ),
                              ),
                            for (final tag in task.tags)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: task.quadrant.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyles.caption.copyWith(color: task.quadrant.color),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
