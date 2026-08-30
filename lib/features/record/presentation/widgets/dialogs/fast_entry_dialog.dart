import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/symptom_flow.dart';
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
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final choices = _resolveChoices(prefs, l10n);

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
                color: SemanticColor.neutral.solid(context),
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
                    isDefault: _isDefaultChoice(choices[index], prefs),
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

  /// Returns true if [choice] is the user's configured default for the
  /// current kind. Currently only mood choices support a default.
  bool _isDefaultChoice(RecordFastChoice choice, QuickEntryPreferences prefs) {
    if (widget.kind != DailyRecordKind.mood) return false;
    final moodLabel = choice.payload?['moodLabel'];
    return moodLabel is String && moodLabel == prefs.moodDefaultLevel;
  }

  bool get _supportsMultiSelect => widget.kind == DailyRecordKind.symptom;

  /// Returns fast-entry choices, applying user preferences for symptom.
  List<RecordFastChoice> _resolveChoices(
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
  ) {
    final base = recordFastEntryChoicesFor(widget.kind, l10n);
    if (widget.kind != DailyRecordKind.symptom) {
      if (widget.kind == DailyRecordKind.sleep) {
        return _reorderSleepChoices(base, prefs.sleepDefaultDurationMinutes);
      }
      return base;
    }

    // Filter by enabled choices (empty = all enabled).
    final enabled = prefs.symptomEnabledChoices.toSet();
    final filtered = enabled.isEmpty
        ? base
        : base.where((c) => enabled.contains(c.title)).toList();

    // Apply default severity.
    final severityLabel = _severityLabel(l10n, prefs.symptomDefaultSeverity);
    return [
      for (final choice in filtered)
        RecordFastChoice(
          label: choice.label,
          prefix: choice.prefix,
          title: choice.title,
          value: severityLabel,
          unit: choice.unit,
          note: choice.note,
          payload: choice.payload,
        ),
    ];
  }

  String _severityLabel(AppLocalizations l10n, String severity) {
    return switch (severity) {
      'moderate' => l10n.recordFastChoiceSeverityModerate,
      'severe' => l10n.recordFastChoiceSeveritySevere,
      _ => l10n.recordFastChoiceSeverityMild,
    };
  }

  /// Reorders sleep choices so the user's default duration is first.
  List<RecordFastChoice> _reorderSleepChoices(
    List<RecordFastChoice> choices,
    int defaultMinutes,
  ) {
    final matching = <RecordFastChoice>[];
    final rest = <RecordFastChoice>[];
    for (final choice in choices) {
      final minutes = choice.payload?['durationMinutes'];
      if (minutes == defaultMinutes) {
        matching.add(choice);
      } else {
        rest.add(choice);
      }
    }
    return [...matching, ...rest];
  }

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
      final result = await ref
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
          )
          .run();
      final item = result.fold((failure) => throw failure, (item) => item);

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
            // The undo action fires on a later user tap; the dialog may
            // have been dismissed in between, so guard before using the
            // context (deactivated context trips the
            // `_dependents.isEmpty` assertion).
            () {
              if (!context.mounted) return;
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
    final repository = ref.read(dailyRecordRepositoryProvider);
    final result =
        await SymptomQuickEntryFlow(
          createRecord: (input) async => (await repository.create(input).run())
              .fold((failure) => throw failure, (item) => item),
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
      final repository = ref.read(dailyRecordRepositoryProvider);
      await QuickEntryUndoService(
        deleteDailyRecord: (id) async => (await repository.delete(id).run())
            .fold((failure) => throw failure, (_) {}),
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
    this.isDefault = false,
  });

  final String label;
  final Widget? prefix;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final button = FButton(
      variant: selected ? FButtonVariant.primary : FButtonVariant.outline,
      onPress: enabled ? onTap : null,
      prefix: prefix,
      child: Text(label),
    );
    if (!isDefault) return button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: Spacing.level1),
        DecoratedBox(
          decoration: BoxDecoration(
            color: SemanticColor.primary.solid(context),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(width: 4, height: 4),
        ),
      ],
    );
  }
}
