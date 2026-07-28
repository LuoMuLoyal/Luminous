import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/symptom_flow.dart';
import 'package:luminous/features/record/presentation/quick_entry/water_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordFastEntryDialog extends ConsumerStatefulWidget {
  const RecordFastEntryDialog({
    super.key,
    required this.kind,
    required this.occurredAt,
    required this.currentDateTime,
    required this.moreRoute,
    this.animation,
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final DateTime currentDateTime;
  final String moreRoute;
  final Animation<double>? animation;

  @override
  ConsumerState<RecordFastEntryDialog> createState() =>
      _RecordFastEntryDialogState();
}

class _RecordFastEntryDialogState extends ConsumerState<RecordFastEntryDialog> {
  bool _saving = false;
  bool _multiSelect = false;
  final Set<int> _selectedIndexes = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = dailyRecordKindLabel(l10n, widget.kind);
    final choices = recordFastEntryChoicesFor(widget.kind, l10n);

    return FDialog(
      key: Key('record-fast-entry-${widget.kind.name}'),
      animation: widget.animation,
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordFastEntryTitle(typeLabel),
              style: style.titleTextStyle,
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.recordFastEntryDateHint(widget.occurredAt),
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: [
                for (var index = 0; index < choices.length; index += 1)
                  _QuickChoiceChip(
                    key: Key(
                      'record-fast-entry-choice-${widget.kind.name}-$index',
                    ),
                    label: choices[index].label,
                    prefix: choices[index].prefix,
                    selected: _selectedIndexes.contains(index),
                    enabled: !_saving,
                    onTap: () => _handleChoiceTap(index, choices[index]),
                  ),
              ],
            ),
            if (_saving) ...[
              const SizedBox(height: Spacing.level4),
              const Center(child: FProgress()),
            ],
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_supportsMultiSelect) ...[
                  FButton(
                    variant: FButtonVariant.ghost,
                    key: const Key('record-fast-entry-multi-select-action'),
                    onPress: _saving || _multiSelect
                        ? null
                        : () => setState(() => _multiSelect = true),
                    child: Text(l10n.recordFastEntryMultiSelectAction),
                  ),
                  const SizedBox(width: Spacing.level3),
                ],
                if (!_multiSelect) ...[
                  FButton(
                    variant: FButtonVariant.ghost,
                    key: const Key('record-fast-entry-more-action'),
                    onPress: _saving ? null : _openMore,
                    child: Text(l10n.recordFastEntryMoreAction),
                  ),
                  const SizedBox(width: Spacing.level3),
                ],
                if (_multiSelect) ...[
                  FButton(
                    key: const Key('record-fast-entry-confirm-action'),
                    onPress: _saving || _selectedIndexes.isEmpty
                        ? null
                        : () => _saveSelectedChoices(choices),
                    child: Text(l10n.commonConfirm),
                  ),
                  const SizedBox(width: Spacing.level3),
                ],
                FButton(
                  variant: FButtonVariant.ghost,
                  key: const Key('record-fast-entry-cancel-action'),
                  onPress: _saving ? null : _cancel,
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _supportsMultiSelect => widget.kind == DailyRecordKind.symptom;

  void _handleChoiceTap(int index, RecordFastChoice choice) {
    if (!_multiSelect) {
      unawaited(_saveChoice(choice));
      return;
    }

    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _cancel() {
    if (_multiSelect) {
      setState(() {
        _multiSelect = false;
        _selectedIndexes.clear();
      });
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _openMore() async {
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(context.push(widget.moreRoute));
  }

  Future<void> _saveChoice(RecordFastChoice choice) async {
    setState(() => _saving = true);
    try {
      final item = await ref
          .read(dailyRecordRepositoryProvider)
          .create(
            DailyRecordCreateInput(
              kind: widget.kind,
              occurredAt: widget.occurredAt,
              occurredTime: formatRecordTimeValue(widget.currentDateTime),
              title: choice.title,
              value: choice.value,
              unit: choice.unit,
              note: choice.note,
              payload: choice.payload,
            ),
          );

      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.dailyRecords);

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (_offersImmediateUndo(widget.kind)) {
        unawaited(
          Toast.showWithAction(
            context,
            l10n.recordQuickSavedToast,
            l10n.recordQuickUndoAction,
            () {
              unawaited(_undoCreatedRecord(item.id));
            },
          ),
        );
      } else {
        unawaited(Toast.show(context, l10n.recordCreateSavedToast));
      }
      Navigator.of(context).pop();
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('RecordFastEntryDialog._saveChoice: failed: $e');
      if (!mounted) return;
      unawaited(
        Toast.show(
          context,
          AppLocalizations.of(context)!.recordCreateFailedToast,
        ),
      );
      setState(() => _saving = false);
    }
  }

  Future<void> _saveSelectedChoices(List<RecordFastChoice> choices) async {
    final selectedChoices = [
      for (final index in _selectedIndexes) _symptomChoiceFor(choices[index]),
    ];

    setState(() => _saving = true);
    final result =
        await SymptomQuickEntryFlow(
          createRecord: ref.read(dailyRecordRepositoryProvider).create,
          emitDataChange: (topic) =>
              ref.read(dataChangeBusProvider.notifier).emit(topic),
          registerUndo: (_) {},
        ).recordBatch(
          QuickEntryRecordContext(
            occurredAt: widget.occurredAt,
            occurredTime: formatRecordTimeValue(widget.currentDateTime),
          ),
          selectedChoices,
        );

    if (!mounted) return;
    if (result.failed.isEmpty) {
      unawaited(
        Toast.show(
          context,
          AppLocalizations.of(context)!.recordCreateSavedToast,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    final failedTitles = result.failed.map((choice) => choice.title).toSet();
    setState(() {
      _saving = false;
      _selectedIndexes
        ..clear()
        ..addAll(
          choices.indexed
              .where((entry) => failedTitles.contains(entry.$2.title))
              .map((entry) => entry.$1),
        );
    });

    unawaited(
      Toast.show(
        context,
        AppLocalizations.of(context)!.recordFastEntryPartialFailedToast(
          result.succeeded.length,
          result.failed.length,
        ),
      ),
    );
  }

  SymptomQuickChoice _symptomChoiceFor(RecordFastChoice choice) {
    return SymptomQuickChoice(
      title: choice.title ?? choice.label,
      value: choice.value,
      note: choice.note,
      payload: choice.payload,
    );
  }

  bool _offersImmediateUndo(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.symptom || DailyRecordKind.mood => true,
      _ => false,
    };
  }

  Future<void> _undoCreatedRecord(String recordId) async {
    try {
      await QuickEntryUndoService(
        deleteDailyRecord: ref.read(dailyRecordRepositoryProvider).delete,
        emitDataChange: (topic) =>
            ref.read(dataChangeBusProvider.notifier).emit(topic),
      ).undo(QuickEntryUndoAction.deleteDailyRecord(recordId: recordId));
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('RecordFastEntryDialog._undoCreatedRecord: failed: $e');
      if (!mounted) return;
      unawaited(
        Toast.show(
          context,
          AppLocalizations.of(context)!.recordQuickUndoFailedToast,
        ),
      );
    }
  }
}

class _QuickChoiceChip extends StatelessWidget {
  const _QuickChoiceChip({
    super.key,
    required this.label,
    this.prefix,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Widget? prefix;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: selected ? FButtonVariant.primary : FButtonVariant.outline,
      onPress: enabled ? onTap : null,
      prefix: prefix,
      child: Text(label),
    );
  }
}
