import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import 'quadrant_x.dart';

/// Opens the add/edit task form as a responsive modal sheet:
/// full width on mobile, a fixed-width side sheet on wide screens.
Future<TaskEntity?> showTaskFormSheet(
  BuildContext context, {
  Quadrant? initialQuadrant,
  TaskEntity? existingTask,
}) {
  final isWide = MediaQuery.sizeOf(context).width >= 700;

  return showModalBottomSheet<TaskEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Align(
      alignment: isWide ? Alignment.centerRight : Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWide ? 420 : double.infinity,
          maxHeight: isWide ? double.infinity : MediaQuery.sizeOf(context).height * 0.9,
        ),
        margin: isWide ? const EdgeInsets.all(16) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: isWide
              ? BorderRadius.circular(16)
              : const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _TaskFormContent(initialQuadrant: initialQuadrant, existingTask: existingTask),
      ),
    ),
  );
}

class _TaskFormContent extends StatefulWidget {
  const _TaskFormContent({this.initialQuadrant, this.existingTask});

  final Quadrant? initialQuadrant;
  final TaskEntity? existingTask;

  @override
  State<_TaskFormContent> createState() => _TaskFormContentState();
}

class _TaskFormContentState extends State<_TaskFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.existingTask?.title);
  late final _descriptionController =
      TextEditingController(text: widget.existingTask?.description);
  late final _tagsController =
      TextEditingController(text: widget.existingTask?.tags.join(', '));

  late Quadrant _quadrant =
      widget.existingTask?.quadrant ?? widget.initialQuadrant ?? Quadrant.doFirst;
  late TaskPriority _priority = widget.existingTask?.priority ?? TaskPriority.medium;
  late DateTime? _dueDate = widget.existingTask?.dueDate;

  bool get _isEditing => widget.existingTask != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final task = (widget.existingTask ??
            TaskEntity(
              id: const Uuid().v4(),
              title: '',
              quadrant: _quadrant,
              createdAt: DateTime.now(),
            ))
        .copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      quadrant: _quadrant,
      priority: _priority,
      dueDate: _dueDate,
      clearDueDate: _dueDate == null,
      tags: tags,
    );

    Navigator.of(context).pop(task);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(_isEditing ? 'Edit Task' : 'New Task', style: AppTextStyles.displayLarge.copyWith(fontSize: 20)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text('Quadrant', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final q in Quadrant.values)
                    ChoiceChip(
                      label: Text(q.title),
                      selected: _quadrant == q,
                      selectedColor: q.color.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: _quadrant == q ? q.color : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(color: _quadrant == q ? q.color : AppColors.border),
                      onSelected: (_) => setState(() => _quadrant = q),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Priority', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: [
                  for (final p in TaskPriority.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: 16),
              Text('Due date', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(_dueDate == null ? 'Set a due date' : DateFormat.yMMMd().format(_dueDate!)),
              ),
              if (_dueDate != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _dueDate = null),
                    child: const Text('Clear date'),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g. work, personal',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_isEditing ? 'Save changes' : 'Add task'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
