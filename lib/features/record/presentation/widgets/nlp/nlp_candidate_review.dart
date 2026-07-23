import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/nlp_candidate_editor.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpCandidateReview extends StatelessWidget {
  const RecordNlpCandidateReview({
    super.key,
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
    final colors = context.theme.colors;

    final meta = state.resultMeta;
    if (meta == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordNlpCandidatesTitle(state.candidates.length),
          style: TypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          meta.confirmationHint,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.foreground),
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.recordNlpSelectedCountHint(state.selectedCount),
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: Spacing.level4),
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
            const SizedBox(height: Spacing.level3),
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
    final colors = context.theme.colors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FCheckbox(
                  key: Key('record-nlp-candidate-select-$index'),
                  value: item.selected,
                  enabled: enabled,
                  onChange: enabled ? onToggleSelected : null,
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _kindLabel(l10n, item.kind),
                        style: TypographyToken.level5
                            .body(context)
                            .copyWith(
                              color: context.theme.colors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: Spacing.level1),
                      Text(
                        _candidateTitle(l10n, item),
                        style: TypographyToken.level4
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: enabled ? onRemove : null,
                  child: Text(l10n.recordNlpRemoveAction),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            RecordNlpCandidateEditor(
              index: index,
              item: item,
              enabled: enabled,
              onChanged: onUpdate,
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              item.rationale,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            if (item.lastErrorMessage case final errMsg?) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.recordNlpCandidateSaveFailedHint(errMsg),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.destructive),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _candidateTitle(AppLocalizations l10n, RecordNlpCandidateDraft item) {
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
    return switch (normalizedWaterUnit(unit)) {
      dailyRecordWaterCupUnit => l10n.recordWaterUnitCup,
      dailyRecordWaterTimesUnit => l10n.recordWaterUnitTimes,
      _ => l10n.recordWaterUnitMl,
    };
  }

  String? _sleepSummary(AppLocalizations l10n, Map<String, dynamic>? payload) {
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
