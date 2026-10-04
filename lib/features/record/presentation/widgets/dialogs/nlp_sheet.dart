import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/candidate_review.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/retry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Bottom-sheet replacement for the legacy [RecordNlpDialog].
///
/// Structure:
/// ```
/// SheetSurface (colors.card + 圆角顶边)
///  └─ DraggableScrollableSheet (往上拖可展开)
///       └─ Column
///            ├─ SheetDragHandle
///            ├─ header (title + close)
///            ├─ Expanded → SingleChildScrollView
///            │    └─ Column (text field, actions, candidates, error/progress)
///            └─ footer (save button, fixed at bottom)
/// ```
class RecordNlpSheet extends HookConsumerWidget {
  const RecordNlpSheet({super.key, required this.occurredAt});

  /// sheet 的初始/最小高度（占可用高度比例）；往上拖可展开到整屏。
  static const _initialSize = 0.85;
  static const _minSize = 0.6;

  final String occurredAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(recordNlpControllerProvider);
    final controller = useTextEditingController(text: state.draft);
    final typography = context.theme.typography;

    ref.listen<RecordNlpState>(recordNlpControllerProvider, (previous, next) {
      // 同一个失败对象不重复提示；重试/编辑会把 error 清空，下一次失败自然再提示。
      final error = next.error;
      if (error == null || identical(error, previous?.error)) {
        return;
      }
      if (!context.mounted) return;
      unawaited(
        Toast.show(
          context,
          userMessageFromError(
            error,
            l10n: l10n,
            fallback: l10n.recordNlpGenerateFailedToast,
          ),
        ),
      );
    });

    Future<void> handleGenerate() async {
      if (controller.text.trim().isEmpty) {
        if (!context.mounted) return;
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
          await Toast.show(context, l10n.recordCreateFailedToast);
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
          await Toast.show(context, l10n.recordCreateFailedToast);
      }
    }

    Future<void> handleReset() async {
      final confirmed = await showFDialog<bool>(
        context: context,
        builder: (dialogContext, style, animation) => DialogShell(
          maxWidth: 360,
          padding: const EdgeInsets.all(Spacing.lg),
          // 走 DialogShell 默认滚动:窄屏 + 大字号下确认文案 + 按钮可能超过弹窗上限。
          builder: (innerContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.recordNlpResetConfirmTitle,
                style: innerContext.theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.recordNlpResetConfirmBody,
                style: innerContext.theme.typography.body.sm.copyWith(
                  color: SemanticColor.neutral.solid(innerContext),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              // 按钮是固有宽度:Row 会先给它们无界主轴约束、把右缘顶出弹窗。
              DialogActionRow(
                actions: [
                  DialogActionButton(
                    label: l10n.commonCancel,
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(dialogContext).pop(false),
                  ),
                  DialogActionButton(
                    label: l10n.recordNlpResetConfirmAction,
                    onPress: () => Navigator.of(dialogContext).pop(true),
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

    return SheetSurface(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: _initialSize,
        minChildSize: _minSize,
        maxChildSize: 1,
        snap: true,
        builder: (context, scrollController) => ScrollConfiguration(
          // 让鼠标/触控板也能拖动（桌面与 Web）。
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetDragHandle(),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.sm,
                  Spacing.sm,
                  Spacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.recordNlpSheetTitle,
                        style: typography.body.lg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // 关闭按钮是固有宽度:给宽度上限,标题(Expanded)才不会被挤。
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 56),
                      child: FButton.icon(
                        variant: FButtonVariant.ghost,
                        onPress: () => Navigator.of(context).pop(),
                        child: const Icon(SemanticIcons.actionClose),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recordNlpSheetSubtitle,
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
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
                      const SizedBox(height: Spacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: FButton(
                              variant: FButtonVariant.outline,
                              key: const Key('record-nlp-reset-action'),
                              onPress: state.isGenerating || state.isSaving
                                  ? null
                                  : handleReset,
                              // 按钮内部内容是 Row(Row 给非 flex 子节点无界主轴约束),
                              // 长标签(如 en 的 "Parse candidates")会按固有宽度排版
                              // 并溢出按钮右缘;Flexible + ellipsis 让标签随可用宽度收敛。
                              child: Flexible(
                                child: Text(
                                  l10n.recordNlpResetAction,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: FButton(
                              key: const Key('record-nlp-generate-action'),
                              onPress: state.isGenerating || state.isSaving
                                  ? null
                                  : handleGenerate,
                              child: Flexible(
                                child: Text(
                                  state.isGenerating
                                      ? l10n.recordNlpGeneratingAction
                                      : l10n.recordNlpGenerateAction,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.hasResult) ...[
                        const SizedBox(height: Spacing.xl),
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
                          const SizedBox(height: Spacing.lg),
                          RecordNlpRetryPanel(
                            failedCount: state.failedCount,
                            enabled: !state.isSaving,
                            onRetry: handleRetryFailed,
                          ),
                        ],
                      ] else if (state.status ==
                          RecordNlpStatus.generating) ...[
                        const SizedBox(height: Spacing.xl),
                        const FProgress(),
                      ] else if (state.status == RecordNlpStatus.error) ...[
                        const SizedBox(height: Spacing.xl),
                        Row(
                          children: [
                            Icon(
                              SemanticIcons.statusError,
                              color: SemanticColor.destructive.solid(context),
                              size: 18,
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: Text(
                                userMessageFromError(
                                  state.error,
                                  l10n: l10n,
                                  fallback: l10n.recordNlpGenerateFailedToast,
                                ),
                                style: typography.body.sm.copyWith(
                                  color: SemanticColor.destructive.solid(
                                    context,
                                  ),
                                ),
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
                    border: Border(
                      top: BorderSide(
                        color: SemanticColor.neutral.border(context),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.md,
                      Spacing.lg,
                      Spacing.lg,
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
        ),
      ),
    );
  }
}
