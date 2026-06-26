import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_dialog.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/record_nlp_candidate_review.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/record_nlp_retry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpDialog extends HookConsumerWidget {
  const RecordNlpDialog({super.key, required this.occurredAt});

  final String occurredAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final state = ref.watch(recordNlpControllerProvider);
    final controller = useTextEditingController(
      text: ref.read(recordNlpControllerProvider).draft,
    );

    ref.listen<RecordNlpState>(recordNlpControllerProvider, (previous, next) {
      if (next.errorMessage == null ||
          next.errorMessage == previous?.errorMessage) {
        return;
      }
      AppToast.show(context, next.errorMessage!);
    });

    Future<void> handleGenerate() async {
      final l10n = AppLocalizations.of(context)!;
      if (controller.text.trim().isEmpty) {
        await AppToast.show(context, l10n.recordNlpInputRequiredToast);
        return;
      }
      final state = await ref
          .read(recordNlpControllerProvider.notifier)
          .generate(occurredAt: occurredAt);
      if (!context.mounted) return;
      if (state.hasResult && state.candidates.isEmpty) {
        await AppToast.show(context, l10n.recordNlpEmptyCandidatesToast);
      }
    }

    Future<void> handleSaveSelected() async {
      final l10n = AppLocalizations.of(context)!;
      final outcome = await ref
          .read(recordNlpControllerProvider.notifier)
          .saveSelected();
      if (!context.mounted) return;

      switch (outcome.kind) {
        case RecordNlpSaveOutcomeKind.saved:
          await AppToast.show(
            context,
            l10n.recordNlpSavedToast(outcome.savedCount ?? 0),
          );
          if (context.mounted) Navigator.of(context).pop();
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

    Future<void> handleRetryFailed() async {
      final l10n = AppLocalizations.of(context)!;
      final outcome = await ref
          .read(recordNlpControllerProvider.notifier)
          .retryFailed();
      if (!context.mounted) return;

      switch (outcome.kind) {
        case RecordNlpSaveOutcomeKind.saved:
          await AppToast.show(
            context,
            l10n.recordNlpRetrySavedToast(outcome.savedCount ?? 0),
          );
          if (context.mounted &&
              ref.read(recordNlpControllerProvider).candidates.isEmpty) {
            Navigator.of(context).pop();
          }
        case RecordNlpSaveOutcomeKind.partial:
          await AppToast.show(
            context,
            l10n.recordNlpPartialSavedToast(
              outcome.savedCount ?? 0,
              outcome.failedCount ?? 0,
            ),
          );
        case RecordNlpSaveOutcomeKind.empty:
          await AppToast.show(context, l10n.recordNlpNoFailedCandidatesToast);
        case RecordNlpSaveOutcomeKind.authRequired:
          await AppToast.show(context, l10n.authLoginRequiredPrompt);
        case RecordNlpSaveOutcomeKind.error:
          await AppToast.show(
            context,
            outcome.message ?? l10n.recordCreateFailedToast,
          );
      }
    }

    void handleReset() {
      controller.clear();
      ref.read(recordNlpControllerProvider.notifier).reset();
    }

    return AppDialog(
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
            controller: controller,
            minLines: 4,
            maxLines: 6,
            enabled: !state.isGenerating && !state.isSaving,
            onChanged: ref
                .read(recordNlpControllerProvider.notifier)
                .updateDraft,
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
                      : handleReset,
                  child: Text(l10n.recordNlpResetAction),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: FilledButton(
                  key: const Key('record-nlp-generate-action'),
                  onPressed: state.isGenerating || state.isSaving
                      ? null
                      : handleGenerate,
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
            RecordNlpCandidateReview(
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
            if (state.hasFailedCandidates) ...[
              const SizedBox(height: AppSpacingTokens.md),
              RecordNlpRetryPanel(
                failedCount: state.failedCount,
                enabled: !state.isSaving,
                onRetry: handleRetryFailed,
              ),
            ],
            const SizedBox(height: AppSpacingTokens.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('record-nlp-save-selected-action'),
                onPressed: state.isSaving ? null : handleSaveSelected,
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
    );
  }
}
