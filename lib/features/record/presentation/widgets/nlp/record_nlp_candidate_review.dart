import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/record_nlp_candidate_editor.dart';
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
            RecordNlpCandidateEditor(
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
