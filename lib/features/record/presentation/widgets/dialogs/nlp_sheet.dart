import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/nlp_candidate_review.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/nlp_retry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Bottom-sheet replacement for the legacy [RecordNlpDialog].
///
/// Structure:
/// ```
/// DecoratedBox (bg: colors.background, border: top)
///  └─ Column
///       ├─ _DragHandle
///       ├─ _SheetHeader (title + close)
///       ├─ Expanded → SingleChildScrollView
///       │    └─ Column (text field, actions, candidates, error/progress)
///       └─ _SheetFooter (save button, fixed at bottom)
/// ```
class RecordNlpSheet extends HookConsumerWidget {
  const RecordNlpSheet({super.key, required this.occurredAt});

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
      Toast.show(context, msg);
    });

    Future<void> handleGenerate() async {
      if (controller.text.trim().isEmpty) {
        await Toast.show(context, l10n.recordNlpInputRequiredToast);
        return;
      }
      final nextState = await ref
          .read(recordNlpControllerProvider.notifier)
          .generate(occurredAt: occurredAt);
      if (!context.mounted) return;
      if (nextState.hasResult && nextState.candidates.isEmpty) {
        await Toast.show(context, l10n.recordNlpEmptyCandidatesToast);
      }
    }

    Future<void> handleSaveSelected() async {
      final outcome = await ref
          .read(recordNlpControllerProvider.notifier)
          .saveSelected();
      if (!context.mounted) return;

      switch (outcome.kind) {
        case RecordNlpSaveOutcomeKind.saved:
          await Toast.show(
            context,
            l10n.recordNlpSavedToast(outcome.savedCount ?? 0),
          );
          if (context.mounted) Navigator.of(context).pop();
        case RecordNlpSaveOutcomeKind.partial:
          await Toast.show(
            context,
            l10n.recordNlpPartialSavedToast(
              outcome.savedCount ?? 0,
              outcome.failedCount ?? 0,
            ),
          );
        case RecordNlpSaveOutcomeKind.empty:
          await Toast.show(context, l10n.recordNlpNoCandidatesSelectedToast);
        case RecordNlpSaveOutcomeKind.authRequired:
          await Toast.show(context, l10n.authLoginRequiredPrompt);
        case RecordNlpSaveOutcomeKind.error:
          await Toast.show(
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
          await Toast.show(
            context,
            l10n.recordNlpRetrySavedToast(outcome.savedCount ?? 0),
          );
          if (context.mounted &&
              ref.read(recordNlpControllerProvider).candidates.isEmpty) {
            Navigator.of(context).pop();
          }
        case RecordNlpSaveOutcomeKind.partial:
          await Toast.show(
            context,
            l10n.recordNlpPartialSavedToast(
              outcome.savedCount ?? 0,
              outcome.failedCount ?? 0,
            ),
          );
        case RecordNlpSaveOutcomeKind.empty:
          await Toast.show(context, l10n.recordNlpNoFailedCandidatesToast);
        case RecordNlpSaveOutcomeKind.authRequired:
          await Toast.show(context, l10n.authLoginRequiredPrompt);
        case RecordNlpSaveOutcomeKind.error:
          await Toast.show(
            context,
            outcome.message ?? l10n.recordCreateFailedToast,
          );
      }
    }

    Future<void> handleReset() async {
      final confirmed = await showFDialog<bool>(
        context: context,
        builder: (dialogContext, style, animation) => DialogShell(
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.level2),
              child: Container(
                width: Spacing.level10,
                height: Spacing.level1,
                decoration: BoxDecoration(
                  color: colors.mutedForeground,
                  borderRadius: BorderRadius.circular(RadiusTokens.level1),
                ),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.level4,
              Spacing.level2,
              Spacing.level2,
              Spacing.level2,
            ),
            child: Row(
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
                  child: const Icon(SemanticIcons.actionClose),
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.level4,
                vertical: Spacing.level2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    minLines: 3,
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
                  ] else if (state.status == RecordNlpStatus.generating) ...[
                    const SizedBox(height: Spacing.level5),
                    const FProgress(),
                  ] else if (state.status == RecordNlpStatus.error) ...[
                    const SizedBox(height: Spacing.level5),
                    Row(
                      children: [
                        Icon(
                          SemanticIcons.statusError,
                          color: colors.destructive,
                          size: 18,
                        ),
                        const SizedBox(width: Spacing.level2),
                        Expanded(
                          child: Text(
                            state.errorMessage ??
                                l10n.recordNlpGenerateFailedToast,
                            style: TypographyToken.level4
                                .body(context)
                                .copyWith(color: colors.destructive),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Fixed footer with save button
          if (state.hasResult)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(top: BorderSide(color: colors.border, width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.level4,
                  Spacing.level3,
                  Spacing.level4,
                  Spacing.level4,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FButton(
                    key: const Key('record-nlp-save-selected-action'),
                    onPress: state.isSaving ? null : handleSaveSelected,
                    child: Text(
                      state.isSaving
                          ? l10n.recordNlpSavingAction
                          : l10n.recordNlpSaveSelectedAction(
                              state.selectedCount,
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
