import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/record_nlp_candidate_review.dart';
import 'package:luminous/features/record/presentation/widgets/nlp/record_nlp_retry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpSheet extends ConsumerStatefulWidget {
  const RecordNlpSheet({super.key, required this.occurredAt});

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

    ref.listen<RecordNlpState>(recordNlpControllerProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage == null ||
          next.errorMessage == previous?.errorMessage) {
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
          bottom:
              MediaQuery.viewInsetsOf(context).bottom + AppSpacingTokens.lg,
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
                onChanged:
                    ref.read(recordNlpControllerProvider.notifier).updateDraft,
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
                    onRetry: _handleRetryFailed,
                  ),
                ],
                const SizedBox(height: AppSpacingTokens.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('record-nlp-save-selected-action'),
                    onPressed: state.isSaving ? null : _handleSaveSelected,
                    child: Text(
                      state.isSaving
                          ? l10n.recordNlpSavingAction
                          : l10n.recordNlpSaveSelectedAction(
                              state.selectedCount,
                            ),
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
        await AppToast.show(
          context,
          l10n.recordNlpNoCandidatesSelectedToast,
        );
      case RecordNlpSaveOutcomeKind.authRequired:
        await AppToast.show(context, l10n.authLoginRequiredPrompt);
      case RecordNlpSaveOutcomeKind.error:
        await AppToast.show(
          context,
          outcome.message ?? l10n.recordCreateFailedToast,
        );
    }
  }

  Future<void> _handleRetryFailed() async {
    final l10n = AppLocalizations.of(context)!;
    final outcome = await ref
        .read(recordNlpControllerProvider.notifier)
        .retryFailed();
    if (!mounted) return;

    switch (outcome.kind) {
      case RecordNlpSaveOutcomeKind.saved:
        await AppToast.show(
          context,
          l10n.recordNlpRetrySavedToast(outcome.savedCount ?? 0),
        );
        if (mounted &&
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
        await AppToast.show(
          context,
          l10n.recordNlpNoFailedCandidatesToast,
        );
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
