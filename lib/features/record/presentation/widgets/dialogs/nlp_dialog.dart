import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/record/presentation/controllers/nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/nlp_candidate_review.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/nlp_retry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpDialog extends HookConsumerWidget {
  const RecordNlpDialog({super.key, required this.occurredAt});

  final String occurredAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final state = ref.watch(recordNlpControllerProvider);
    final controller = useTextEditingController(text: state.draft);

    ref.listen<RecordNlpState>(recordNlpControllerProvider, (previous, next) {
      final msg = next.errorMessage;
      if (msg == null || msg == previous?.errorMessage) {
        return;
      }
      AppToast.show(context, msg);
    });

    Future<void> handleGenerate() async {
      if (controller.text.trim().isEmpty) {
        await AppToast.show(context, l10n.recordNlpInputRequiredToast);
        return;
      }
      final nextState = await ref
          .read(recordNlpControllerProvider.notifier)
          .generate(occurredAt: occurredAt);
      if (!context.mounted) return;
      if (nextState.hasResult && nextState.candidates.isEmpty) {
        await AppToast.show(context, l10n.recordNlpEmptyCandidatesToast);
      }
    }

    Future<void> handleSaveSelected() async {
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

    Future<void> handleReset() async {
      final confirmed = await showFDialog<bool>(
        context: context,
        builder: (dialogContext, style, animation) => AppDialogShell(
          maxWidth: 360,
          padding: const EdgeInsets.all(Spacing.level4),
          scrollable: false,
          builder: (innerContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.recordNlpResetConfirmTitle,
                style: TypographyToken.level6
                    .body(innerContext)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.recordNlpResetConfirmBody,
                style: TypographyToken.level4
                    .body(innerContext)
                    .copyWith(color: innerContext.theme.colors.mutedForeground),
              ),
              const SizedBox(height: Spacing.level4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(dialogContext).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: Spacing.level2),
                  FButton(
                    variant: FButtonVariant.primary,
                    onPress: () => Navigator.of(dialogContext).pop(true),
                    child: Text(l10n.recordNlpResetConfirmAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      if (confirmed != true) return;
      controller.clear();
      ref.read(recordNlpControllerProvider.notifier).reset();
    }

    return AppDialogShell(
      scrollable: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recordNlpSheetTitle,
                  style: TypographyToken.level6
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              FButton.icon(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(context).pop(),
                child: const Icon(FLucideIcons.x),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level2),
          Text(
            l10n.recordNlpSheetSubtitle,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('record-nlp-input-field'),
            control: FTextFieldControl.managed(
              controller: controller,
              onChange: (value) => ref
                  .read(recordNlpControllerProvider.notifier)
                  .updateDraft(value.text),
            ),
            minLines: 4,
            maxLines: 6,
            enabled: !state.isGenerating && !state.isSaving,
            hint: l10n.recordNlpInputHint,
          ),
          const SizedBox(height: Spacing.level4),
          Row(
            children: [
              Expanded(
                child: FButton(
                  variant: FButtonVariant.outline,
                  key: const Key('record-nlp-reset-action'),
                  onPress: state.isGenerating || state.isSaving
                      ? null
                      : handleReset,
                  child: Text(l10n.recordNlpResetAction),
                ),
              ),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: FButton(
                  key: const Key('record-nlp-generate-action'),
                  onPress: state.isGenerating || state.isSaving
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
            const SizedBox(height: Spacing.level5),
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
              const SizedBox(height: Spacing.level4),
              RecordNlpRetryPanel(
                failedCount: state.failedCount,
                enabled: !state.isSaving,
                onRetry: handleRetryFailed,
              ),
            ],
            const SizedBox(height: Spacing.level4),
            SizedBox(
              width: double.infinity,
              child: FButton(
                key: const Key('record-nlp-save-selected-action'),
                onPress: state.isSaving ? null : handleSaveSelected,
                child: Text(
                  state.isSaving
                      ? l10n.recordNlpSavingAction
                      : l10n.recordNlpSaveSelectedAction(state.selectedCount),
                ),
              ),
            ),
          ] else if (state.status == RecordNlpStatus.generating) ...[
            const SizedBox(height: Spacing.level5),
            const FProgress(),
          ],
        ],
      ),
    );
  }
}
