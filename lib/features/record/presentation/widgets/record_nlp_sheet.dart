import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpSheet extends ConsumerStatefulWidget {
  const RecordNlpSheet({
    super.key,
    required this.occurredAt,
  });

  final String occurredAt;

  @override
  ConsumerState<RecordNlpSheet> createState() => _RecordNlpSheetState();
}

class _RecordNlpSheetState extends ConsumerState<RecordNlpSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(recordNlpControllerProvider).draft,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final state = ref.watch(recordNlpControllerProvider);

    ref.listen<RecordNlpState>(recordNlpControllerProvider, (previous, next) {
      if (next.errorMessage == null || next.errorMessage == previous?.errorMessage) {
        return;
      }
      AppToast.show(context, next.errorMessage!);
    });

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacingTokens.lg,
          right: AppSpacingTokens.lg,
          top: AppSpacingTokens.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacingTokens.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recordNlpSheetTitle,
                      style: typography.displaySm,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.recordNlpSheetSubtitle,
                style: typography.bodySm.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              TextField(
                key: const Key('record-nlp-input-field'),
                controller: _controller,
                minLines: 4,
                maxLines: 6,
                enabled: !state.isGenerating && !state.isSaving,
                onChanged: ref.read(recordNlpControllerProvider.notifier).updateDraft,
                decoration: InputDecoration(
                  hintText: l10n.recordNlpInputHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('record-nlp-reset-action'),
                      onPressed: state.isGenerating || state.isSaving
                          ? null
                          : _handleReset,
                      child: Text(l10n.recordNlpResetAction),
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('record-nlp-generate-action'),
                      onPressed: state.isGenerating || state.isSaving
                          ? null
                          : _handleGenerate,
                      child: Text(
                        state.isGenerating
                            ? l10n.recordNlpGeneratingAction
                            : l10n.recordNlpGenerateAction,
                      ),
                    ),
                  ),
                ],
              ),
              if (state.hasResult) ...[
                const SizedBox(height: AppSpacingTokens.lg),
                _CandidateReviewSection(
                  state: state,
                  onToggleSelected: (index, selected) => ref
                      .read(recordNlpControllerProvider.notifier)
                      .toggleCandidateSelected(index, selected),
                  onUpdateCandidate: (index, candidate) => ref
                      .read(recordNlpControllerProvider.notifier)
                      .updateCandidateAt(index, candidate),
                  onRemove: (index) => ref
                      .read(recordNlpControllerProvider.notifier)
                      .removeCandidateAt(index),
                ),
                const SizedBox(height: AppSpacingTokens.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('record-nlp-save-selected-action'),
                    onPressed: state.isSaving ? null : _handleSaveSelected,
                    child: Text(
                      state.isSaving
                          ? l10n.recordNlpSavingAction
                          : l10n.recordNlpSaveSelectedAction(state.selectedCount),
                    ),
                  ),
                ),
              ] else if (state.status == RecordNlpStatus.generating) ...[
                const SizedBox(height: AppSpacingTokens.lg),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleReset() {
    _controller.clear();
    ref.read(recordNlpControllerProvider.notifier).reset();
  }

  Future<void> _handleGenerate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_controller.text.trim().isEmpty) {
      await AppToast.show(context, l10n.recordNlpInputRequiredToast);
      return;
    }
    final state = await ref
        .read(recordNlpControllerProvider.notifier)
        .generate(occurredAt: widget.occurredAt);
    if (!mounted) return;
    if (state.hasResult && state.candidates.isEmpty) {
      await AppToast.show(context, l10n.recordNlpEmptyCandidatesToast);
    }
  }

  Future<void> _handleSaveSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final outcome = await ref
        .read(recordNlpControllerProvider.notifier)
        .saveSelected();
    if (!mounted) return;

    switch (outcome.kind) {
      case RecordNlpSaveOutcomeKind.saved:
        await AppToast.show(
          context,
          l10n.recordNlpSavedToast(outcome.savedCount ?? 0),
        );
        if (mounted) Navigator.of(context).pop();
      case RecordNlpSaveOutcomeKind.partial:
        await AppToast.show(
          context,
          l10n.recordNlpPartialSavedToast(
            outcome.savedCount ?? 0,
            outcome.failedCount ?? 0,
          ),
        );
      case RecordNlpSaveOutcomeKind.empty:
        await AppToast.show(context, l10n.recordNlpNoCandidatesSelectedToast);
      case RecordNlpSaveOutcomeKind.authRequired:
        await AppToast.show(context, l10n.authLoginRequiredPrompt);
      case RecordNlpSaveOutcomeKind.error:
        await AppToast.show(
          context,
          outcome.message ?? l10n.recordCreateFailedToast,
        );
    }
  }
}

class _CandidateReviewSection extends StatelessWidget {
  const _CandidateReviewSection({
    required this.state,
    required this.onToggleSelected,
    required this.onUpdateCandidate,
    required this.onRemove,
  });

  final RecordNlpState state;
  final void Function(int index, bool selected) onToggleSelected;
  final void Function(int index, RecordNlpCandidateDraft candidate)
  onUpdateCandidate;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final meta = state.resultMeta;
    if (meta == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordNlpCandidatesTitle(state.candidates.length),
          style: typography.displaySm,
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        Text(
          meta.confirmationHint,
          style: typography.bodySm.copyWith(color: surface.body),
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        Text(
          l10n.recordNlpSelectedCountHint(state.selectedCount),
          style: typography.caption.copyWith(color: surface.mute),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        for (var index = 0; index < state.candidates.length; index += 1) ...[
          _CandidateTile(
            index: index,
            item: state.candidates[index],
            enabled: !state.isSaving,
            onToggleSelected: (selected) => onToggleSelected(index, selected),
            onUpdate: (candidate) => onUpdateCandidate(index, candidate),
            onRemove: () => onRemove(index),
          ),
          if (index < state.candidates.length - 1)
            const SizedBox(height: AppSpacingTokens.sm),
        ],
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.index,
    required this.item,
    required this.enabled,
    required this.onToggleSelected,
    required this.onUpdate,
    required this.onRemove,
  });

  final int index;
  final RecordNlpCandidateDraft item;
  final bool enabled;
  final ValueChanged<bool> onToggleSelected;
  final ValueChanged<RecordNlpCandidateDraft> onUpdate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(
          color: item.selected ? AppColorTokens.cyanDeep : surface.hairline,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  key: Key('record-nlp-candidate-select-$index'),
                  value: item.selected,
                  onChanged: enabled
                      ? (value) => onToggleSelected(value ?? false)
                      : null,
                ),
                const SizedBox(width: AppSpacingTokens.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _kindLabel(l10n, item.kind),
                        style: typography.bodySmStrong.copyWith(
                          color: AppColorTokens.cyanDeep,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        _candidateTitle(l10n, item),
                        style: typography.bodyMdStrong.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: enabled ? onRemove : null,
                  child: Text(l10n.recordNlpRemoveAction),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            _CandidateEditor(
              index: index,
              item: item,
              enabled: enabled,
              onChanged: onUpdate,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              item.rationale,
              style: typography.caption.copyWith(color: surface.mute),
            ),
            if (item.lastErrorMessage != null) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.recordNlpCandidateSaveFailedHint(item.lastErrorMessage!),
                style: typography.caption.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _candidateTitle(
    AppLocalizations l10n,
    RecordNlpCandidateDraft item,
  ) {
    final title = item.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    final value = item.value?.trim();
    final note = item.note?.trim();

    switch (item.kind) {
      case DailyRecordKind.water:
        if (value != null && value.isNotEmpty) {
          return '$value ${_waterUnitLabel(l10n, item.unit)}';
        }
      case DailyRecordKind.meal:
      case DailyRecordKind.symptom:
        if (value != null && value.isNotEmpty) return value;
      case DailyRecordKind.note:
        final preview = _previewText(note);
        if (preview != null) return preview;
      case DailyRecordKind.sleep:
        final summary = _sleepSummary(l10n, item.payload);
        if (summary != null) return summary;
      case DailyRecordKind.vital:
      case DailyRecordKind.mood:
      case DailyRecordKind.activity:
        break;
    }
    return _kindLabel(l10n, item.kind);
  }

  String _kindLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordTypeWater,
      DailyRecordKind.meal => l10n.recordTypeMeal,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.note => l10n.recordCreateKindNote,
      DailyRecordKind.sleep => l10n.recordTypeSleep,
      _ => kind.name,
    };
  }

  String _waterUnitLabel(AppLocalizations l10n, String? unit) {
    return switch (_normalizedWaterUnit(unit)) {
      dailyRecordWaterCupUnit => l10n.recordWaterUnitCup,
      dailyRecordWaterTimesUnit => l10n.recordWaterUnitTimes,
      _ => l10n.recordWaterUnitMl,
    };
  }

  String? _sleepSummary(
    AppLocalizations l10n,
    Map<String, dynamic>? payload,
  ) {
    final duration = payload?['durationMinutes'];
    if (duration is! num || duration <= 0) return null;
    final minutes = duration.round();
    final hoursPart = minutes ~/ 60;
    final minutePart = minutes % 60;
    if (minutePart == 0) {
      return '${l10n.recordSleepDurationLabel} $hoursPart${l10n.todayVitalSleepUnit}';
    }
    return '${l10n.recordSleepDurationLabel} $hoursPart${l10n.todayVitalSleepUnit} $minutePart${l10n.recordSleepMinutesUnit}';
  }

  String? _previewText(String? value) {
    if (value == null || value.isEmpty) return null;
    final singleLine = value.replaceAll('\n', ' ').trim();
    if (singleLine.isEmpty) return null;
    if (singleLine.length <= 24) return singleLine;
    return '${singleLine.substring(0, 24)}...';
  }
}

class _CandidateEditor extends StatefulWidget {
  const _CandidateEditor({
    required this.index,
    required this.item,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final RecordNlpCandidateDraft item;
  final bool enabled;
  final ValueChanged<RecordNlpCandidateDraft> onChanged;

  @override
  State<_CandidateEditor> createState() => _CandidateEditorState();
}

class _CandidateEditorState extends State<_CandidateEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _valueController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title ?? '');
    _valueController = TextEditingController(text: widget.item.value ?? '');
    _noteController = TextEditingController(text: widget.item.note ?? '');
  }

  @override
  void didUpdateWidget(covariant _CandidateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title) {
      _titleController.text = widget.item.title ?? '';
    }
    if (oldWidget.item.value != widget.item.value) {
      _valueController.text = widget.item.value ?? '';
    }
    if (oldWidget.item.note != widget.item.note) {
      _noteController.text = widget.item.note ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kind = widget.item.kind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_shouldShowTitle(kind)) ...[
          TextField(
            key: Key('record-nlp-candidate-title-${widget.index}'),
            controller: _titleController,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: _titleLabel(l10n, kind),
            ),
            onChanged: (value) => _emit(title: value),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        if (_shouldShowValueOrUnit(kind)) ...[
          Row(
            children: [
              if (_shouldShowValue(kind))
                Expanded(
                  child: TextField(
                    key: Key('record-nlp-candidate-value-${widget.index}'),
                    controller: _valueController,
                    enabled: widget.enabled,
                    keyboardType: _valueKeyboardType(kind),
                    decoration: InputDecoration(
                      labelText: _valueLabel(l10n, kind),
                    ),
                    onChanged: (value) => _emit(value: value),
                  ),
                ),
              if (_shouldShowValue(kind) && _shouldShowUnit(kind))
                const SizedBox(width: AppSpacingTokens.sm),
              if (_shouldShowUnit(kind))
                Expanded(
                  child: _WaterUnitField(
                    index: widget.index,
                    enabled: widget.enabled,
                    value: widget.item.unit,
                    onChanged: (value) => _emit(unit: value),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        if (kind == DailyRecordKind.sleep) ...[
          _SleepCandidateFields(
            index: widget.index,
            item: widget.item,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        TextField(
          key: Key('record-nlp-candidate-note-${widget.index}'),
          controller: _noteController,
          enabled: widget.enabled,
          minLines: _noteMinLines(kind),
          maxLines: _noteMaxLines(kind),
          decoration: InputDecoration(labelText: _noteLabel(l10n, kind)),
          onChanged: (value) => _emit(note: value),
        ),
      ],
    );
  }

  bool _shouldShowTitle(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => false,
      DailyRecordKind.sleep => false,
      _ => true,
    };
  }

  bool _shouldShowValue(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => false,
      DailyRecordKind.sleep => false,
      _ => true,
    };
  }

  bool _shouldShowUnit(DailyRecordKind kind) {
    return kind == DailyRecordKind.water;
  }

  bool _shouldShowValueOrUnit(DailyRecordKind kind) {
    return _shouldShowValue(kind) || _shouldShowUnit(kind);
  }

  String _valueLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordCreateValueWater,
      DailyRecordKind.meal => l10n.recordCreateValueMeal,
      DailyRecordKind.symptom => l10n.recordCreateValueSymptom,
      _ => l10n.recordCreateValueVital,
    };
  }

  String _titleLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.meal => l10n.recordNlpMealTitleOptional,
      DailyRecordKind.symptom => l10n.recordNlpSymptomTitleLabel,
      _ => l10n.recordCreateFieldTitleOptional,
    };
  }

  String _noteLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => l10n.recordNlpNoteBodyLabel,
      _ => l10n.recordNlpDetailsLabel,
    };
  }

  TextInputType? _valueKeyboardType(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => const TextInputType.numberWithOptions(
        decimal: true,
      ),
      _ => null,
    };
  }

  int _noteMinLines(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => 3,
      _ => 2,
    };
  }

  int _noteMaxLines(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => 5,
      _ => 3,
    };
  }

  void _emit({
    String? title,
    String? value,
    String? unit,
    String? note,
  }) {
    widget.onChanged(
      widget.item.copyWith(
        title: title ?? widget.item.title,
        value: value ?? widget.item.value,
        unit: unit ?? widget.item.unit,
        note: note ?? widget.item.note,
        lastErrorMessage: null,
      ),
    );
  }
}

class _WaterUnitField extends StatelessWidget {
  const _WaterUnitField({
    required this.index,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  final int index;
  final bool enabled;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedUnit = _normalizedWaterUnit(value);

    return DropdownButtonFormField<String>(
      key: Key('record-nlp-candidate-unit-$index-$normalizedUnit'),
      initialValue: normalizedUnit,
      decoration: InputDecoration(labelText: l10n.recordCreateFieldUnit),
      items: [
        DropdownMenuItem(
          value: dailyRecordWaterDefaultUnit,
          child: Text(l10n.recordWaterUnitMl),
        ),
        DropdownMenuItem(
          value: dailyRecordWaterCupUnit,
          child: Text(l10n.recordWaterUnitCup),
        ),
        DropdownMenuItem(
          value: dailyRecordWaterTimesUnit,
          child: Text(l10n.recordWaterUnitTimes),
        ),
      ],
      onChanged: enabled
          ? (nextValue) => onChanged(nextValue ?? dailyRecordWaterDefaultUnit)
          : null,
    );
  }
}

class _SleepCandidateFields extends StatelessWidget {
  const _SleepCandidateFields({
    required this.index,
    required this.item,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final RecordNlpCandidateDraft item;
  final bool enabled;
  final ValueChanged<RecordNlpCandidateDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final payload = Map<String, dynamic>.from(item.payload ?? const <String, dynamic>{});
    final quality = payload['quality'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: Key('record-nlp-candidate-sleep-duration-$index'),
          enabled: enabled,
          initialValue: _durationValue(payload['durationMinutes']),
          decoration: InputDecoration(labelText: l10n.recordSleepDurationLabel),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final minutes = int.tryParse(value.trim());
            final nextPayload = Map<String, dynamic>.from(payload);
            if (minutes == null || minutes <= 0) {
              nextPayload.remove('durationMinutes');
            } else {
              nextPayload['durationMinutes'] = minutes;
            }
            onChanged(
              item.copyWith(
                payload: nextPayload,
                lastErrorMessage: null,
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        DropdownButtonFormField<String>(
          key: Key('record-nlp-candidate-sleep-quality-$index'),
          initialValue: quality,
          decoration: InputDecoration(labelText: l10n.recordSleepQualityLabel),
          items: sleepQualityOptions(l10n)
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.key,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: enabled
              ? (value) {
                  final nextPayload = Map<String, dynamic>.from(payload);
                  if (value == null || value.isEmpty) {
                    nextPayload.remove('quality');
                  } else {
                    nextPayload['quality'] = value;
                  }
                  onChanged(
                    item.copyWith(
                      payload: nextPayload,
                      lastErrorMessage: null,
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }

  String _durationValue(Object? value) {
    if (value is num && value > 0) {
      return value.round().toString();
    }
    return '';
  }
}

String _normalizedWaterUnit(String? value) {
  final normalized = value?.trim();
  return switch (normalized) {
    dailyRecordWaterCupUnit => dailyRecordWaterCupUnit,
    dailyRecordWaterTimesUnit => dailyRecordWaterTimesUnit,
    _ => dailyRecordWaterDefaultUnit,
  };
}
