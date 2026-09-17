import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/components/drag_handle.dart';
import '../../../global/components/empty_state.dart';
import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../cubit/dump_cubit.dart';
import '../widgets/dump_entry_row.dart';

/// Capture-then-triage: type everything on your mind, tag each line with a
/// quadrant, and nothing becomes a task until you press Save.
class MindDumpView extends StatefulWidget {
  const MindDumpView({super.key});

  @override
  State<MindDumpView> createState() => _MindDumpViewState();
}

class _MindDumpViewState extends State<MindDumpView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<DumpCubit>().addEntry(text);
    _controller.clear();
    // Keep focus so a stream of thoughts can be typed without reaching for
    // the mouse between lines.
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuickAddField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmit: _submit,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<DumpCubit, DumpState>(
              builder: (context, state) {
                return switch (state) {
                  DumpInitial() || DumpLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  DumpError(:final failure) => Center(child: Text(failure.message)),
                  DumpLoaded() => _DumpList(state: state),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddField extends StatelessWidget {
  const _QuickAddField({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              hintText: 'What is on your mind? Press Enter to add it',
              prefixIcon: const Icon(Icons.psychology_alt_outlined, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _DumpList extends StatelessWidget {
  const _DumpList({required this.state});

  final DumpLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DumpCubit>();
    final entries = state.orderedEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.errorMessage != null) ...[
          _ErrorBanner(message: state.errorMessage!),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: entries.isEmpty
              ? const EmptyState(
                  icon: Icons.cloud_outlined,
                  message: 'Nothing dumped yet — start typing above.',
                )
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  proxyDecorator: reorderProxyDecorator,
                  onReorder: cubit.reorderEntry,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return DumpEntryRow(
                      key: ValueKey(entry.id),
                      entry: entry,
                      dragHandle: DragHandle(index: index, enabled: !state.isSaving),
                      selected: state.assignments[entry.id],
                      enabled: !state.isSaving,
                      onSelected: (quadrant) => cubit.assign(entry.id, quadrant),
                      onDiscard: () => cubit.discardEntry(entry.id),
                    );
                  },
                ),
        ),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SaveBar(
            pendingCount: state.pendingCount,
            isSaving: state.isSaving,
            onSave: cubit.saveAssigned,
          ),
        ],
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.pendingCount,
    required this.isSaving,
    required this.onSave,
  });

  final int pendingCount;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final hasPending = pendingCount > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            hasPending
                ? '$pendingCount item${pendingCount == 1 ? '' : 's'} ready to move'
                : 'Pick a quadrant for an item to queue it up',
            style: AppTextStyles.subtitle,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: hasPending && !isSaving ? onSave : null,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded),
          label: Text(isSaving ? 'Saving…' : 'Save${hasPending ? ' $pendingCount' : ''}'),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.doFirst.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.doFirst.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: AppColors.doFirst),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.subtitle.copyWith(color: AppColors.doFirst),
            ),
          ),
        ],
      ),
    );
  }
}
