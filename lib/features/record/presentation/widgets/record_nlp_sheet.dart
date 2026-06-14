import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
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
                  result: state.result!,
                  isSaving: state.isSaving,
                  onRemove: (index) => ref
                      .read(recordNlpControllerProvider.notifier)
                      .removeCandidateAt(index),
                ),
                const SizedBox(height: AppSpacingTokens.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('record-nlp-save-all-action'),
                    onPressed: state.isSaving ? null : _handleSaveAll,
                    child: Text(
                      state.isSaving
                          ? l10n.recordNlpSavingAction
                          : l10n.recordNlpSaveAllAction,
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
    if (state.result != null && state.result!.items.isEmpty) {
      await AppToast.show(context, l10n.recordNlpEmptyCandidatesToast);
    }
  }

  Future<void> _handleSaveAll() async {
    final l10n = AppLocalizations.of(context)!;
    final outcome = await ref.read(recordNlpControllerProvider.notifier).saveAll();
    if (!mounted) return;

    switch (outcome.kind) {
      case RecordNlpSaveOutcomeKind.saved:
        await AppToast.show(
          context,
          l10n.recordNlpSavedToast(outcome.count ?? 0),
        );
        if (mounted) Navigator.of(context).pop();
      case RecordNlpSaveOutcomeKind.empty:
        await AppToast.show(context, l10n.recordNlpNoCandidatesToSaveToast);
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
    required this.result,
    required this.isSaving,
    required this.onRemove,
  });

  final DailyRecordCandidateResult result;
  final bool isSaving;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordNlpCandidatesTitle(result.items.length),
          style: typography.displaySm,
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        Text(
          result.confirmationHint,
          style: typography.bodySm.copyWith(color: surface.body),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        for (var index = 0; index < result.items.length; index += 1) ...[
          _CandidateTile(
            item: result.items[index],
            enabled: !isSaving,
            onRemove: () => onRemove(index),
          ),
          if (index < result.items.length - 1)
            const SizedBox(height: AppSpacingTokens.sm),
        ],
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.item,
    required this.enabled,
    required this.onRemove,
  });

  final DailyRecordCandidateItem item;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final details = _candidateDetails(context, item);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            if (details != null) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                details,
                style: typography.bodySm.copyWith(color: surface.body),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              item.rationale,
              style: typography.caption.copyWith(color: surface.mute),
            ),
          ],
        ),
      ),
    );
  }

  String _candidateTitle(AppLocalizations l10n, DailyRecordCandidateItem item) {
    final title = item.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return switch (item.kind) {
      DailyRecordKind.water => l10n.recordTypeWater,
      DailyRecordKind.meal => l10n.recordTypeMeal,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.note => l10n.recordCreateKindNote,
      DailyRecordKind.sleep => l10n.recordTypeSleep,
      _ => item.kind.name,
    };
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

  String? _candidateDetails(
    BuildContext context,
    DailyRecordCandidateItem item,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (item.kind == DailyRecordKind.sleep) {
      final durationMinutes = item.payload?['durationMinutes'];
      if (durationMinutes is num && durationMinutes > 0) {
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes.round() % 60;
        if (hours <= 0) {
          return '$minutes${l10n.recordSleepMinutesUnit}';
        }
        return '$hours${l10n.todayVitalSleepUnit} $minutes${l10n.recordSleepMinutesUnit}';
      }
    }

    final value = item.value?.trim();
    final unit = item.unit?.trim();
    if (value != null && value.isNotEmpty) {
      if (unit != null && unit.isNotEmpty) {
        return '$value $unit';
      }
      return value;
    }

    final note = item.note?.trim();
    if (note != null && note.isNotEmpty) return note;
    return null;
  }
}
