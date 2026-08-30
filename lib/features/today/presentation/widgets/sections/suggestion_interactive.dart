import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Row of feedback buttons (accepted / later / not-applicable / suppress).
///
/// After submission, switches to a compact "submitted" indicator.
class SuggestionFeedbackRow extends ConsumerStatefulWidget {
  const SuggestionFeedbackRow({
    super.key,
    required this.suggestionId,
    required this.feedbackOptions,
  });

  final String suggestionId;
  final List<TodaySuggestionFeedback> feedbackOptions;

  @override
  ConsumerState<SuggestionFeedbackRow> createState() =>
      _SuggestionFeedbackRowState();
}

class _SuggestionFeedbackRowState extends ConsumerState<SuggestionFeedbackRow> {
  bool _isSubmitting = false;

  /// The feedback option the user submitted, if any.
  ///
  /// Once set, the row switches to a read-only "submitted" state so the user
  /// gets immediate visual confirmation even before the provider re-fetches.
  TodaySuggestionFeedback? _submittedFeedback;

  Future<void> _submit(TodaySuggestionFeedback feedback) async {
    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(todaySuggestionProvider.notifier)
          .submitFeedback(
            suggestionId: widget.suggestionId,
            feedback: feedback,
          );
      if (mounted) {
        setState(() => _submittedFeedback = feedback);
        unawaited(Toast.show(context, l10n.todaySuggestionFeedbackSuccess));
      }
    } catch (e, st) {
      appTalker.error('submitFeedback failed: $e', e, st);
      if (mounted) {
        unawaited(Toast.show(context, l10n.todaySuggestionFeedbackError));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final ordered = [
      TodaySuggestionFeedback.accepted,
      TodaySuggestionFeedback.later,
      TodaySuggestionFeedback.notApplicable,
      TodaySuggestionFeedback.suppress,
    ].where((f) => widget.feedbackOptions.contains(f)).toList();

    // Once feedback is submitted, show a compact "submitted" indicator
    // instead of the interactive buttons.
    if (_submittedFeedback != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SemanticIcons.statusDone,
            size: IconSizeTokens.level2,
            color: colors.primary,
          ),
          const SizedBox(width: Spacing.level1),
          Text(
            l10n.todaySuggestionFeedbackSubmitted,
            style: context.theme.typography.body.xs.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: Spacing.level2,
      runSpacing: Spacing.level2,
      children: [
        for (final option in ordered)
          FButton(
            onPress: _isSubmitting ? null : () => _submit(option),
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.xs,
            mainAxisSize: MainAxisSize.min,
            child: Text(
              labelFor(l10n, option),
              style:
                  option == TodaySuggestionFeedback.notApplicable ||
                      option == TodaySuggestionFeedback.suppress
                  ? TextStyle(color: colors.mutedForeground)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// Maps a [TodaySuggestionFeedback] to its localized label.
String labelFor(AppLocalizations l10n, TodaySuggestionFeedback feedback) {
  return switch (feedback) {
    TodaySuggestionFeedback.accepted => l10n.todaySuggestionAcceptedAction,
    TodaySuggestionFeedback.later => l10n.todaySuggestionLaterAction,
    TodaySuggestionFeedback.notApplicable =>
      l10n.todaySuggestionNotApplicableAction,
    TodaySuggestionFeedback.suppress => l10n.todaySuggestionSuppressAction,
  };
}

/// Button that triggers on-demand AI explanation for a suggestion.
///
/// Shows a loading spinner while fetching, and a retry button on failure
/// (up to [_maxRetries] attempts).
class SuggestionAiExplainButton extends ConsumerStatefulWidget {
  const SuggestionAiExplainButton({super.key, required this.suggestionId});

  final String suggestionId;

  @override
  ConsumerState<SuggestionAiExplainButton> createState() =>
      _SuggestionAiExplainButtonState();
}

class _SuggestionAiExplainButtonState
    extends ConsumerState<SuggestionAiExplainButton> {
  bool _isRequested = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final params = (suggestionId: widget.suggestionId, language: locale);

    if (!_isRequested) {
      return FButton(
        onPress: () {
          setState(() => _isRequested = true);
          unawaited(
            // Trigger the provider.
            ref.read(suggestionExplanationProvider(params).future),
          );
        },
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.xs,
        mainAxisSize: MainAxisSize.min,
        child: Text(l10n.todaySuggestionAiExplainAction),
      );
    }

    final explanationAsync = ref.watch(suggestionExplanationProvider(params));

    return explanationAsync.when(
      data: (explanation) {
        if (explanation == null) {
          return AiExplainUnavailable(l10n: l10n);
        }
        // aiGenerated=false means the backend returned a rule-based fallback
        // explanation (e.g. model not configured). Do not waste retries;
        // display the fallback content with a rule-based label.
        if (!explanation.aiGenerated) {
          return AiExplainContent(explanation: explanation);
        }
        return AiExplainContent(explanation: explanation);
      },
      loading: () => Row(
        children: [
          const SizedBox(
            width: Spacing.level4,
            height: Spacing.level4,
            child: FCircularProgress.loader(),
          ),
          const SizedBox(width: Spacing.level2),
          Text(
            l10n.todaySuggestionAiExplainLoading,
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
      error: (_, __) {
        if (_retryCount >= _maxRetries) {
          return AiExplainUnavailable(l10n: l10n);
        }
        return FButton(
          onPress: () {
            setState(() => _retryCount += 1);
            unawaited(
              ref.refresh(suggestionExplanationProvider(params).future),
            );
          },
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          mainAxisSize: MainAxisSize.min,
          child: Text(l10n.todaySuggestionAiExplainRetry),
        );
      },
    );
  }
}

/// Renders AI-generated explanation content (reason + boundary) as Markdown.
class AiExplainContent extends StatelessWidget {
  const AiExplainContent({super.key, required this.explanation});

  final TodaySuggestionExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.level3),
      decoration: BoxDecoration(
        color: SemanticColor.primary.subtle(context),
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: SemanticColor.primary.muted(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                explanation.aiGenerated
                    ? SemanticIcons.aiGenerated
                    : SemanticIcons.statusInfo,
                size: IconSizeTokens.level2,
                color: explanation.aiGenerated
                    ? colors.primary
                    : colors.mutedForeground,
              ),
              const SizedBox(width: Spacing.level1),
              Text(
                explanation.aiGenerated
                    ? l10n.todaySuggestionAiLabel
                    : l10n.todaySuggestionRuleBasedLabel,
                style: context.theme.typography.body.xs.copyWith(
                  color: explanation.aiGenerated
                      ? colors.primary
                      : colors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level2),
          MarkdownBody(
            data: explanation.reason,
            selectable: true,
            styleSheet: MarkdownStyle.ai(context),
          ),
          if (explanation.boundary.isNotEmpty) ...[
            const SizedBox(height: Spacing.level2),
            MarkdownBody(
              data: explanation.boundary,
              selectable: true,
              styleSheet: MarkdownStyle.ai(context).copyWith(
                p: context.theme.typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when AI explanation is unavailable after max retries.
class AiExplainUnavailable extends StatelessWidget {
  const AiExplainUnavailable({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SemanticIcons.statusInfo,
            size: IconSizeTokens.level2,
            color: colors.mutedForeground,
          ),
          const SizedBox(width: Spacing.level1),
          Flexible(
            child: Text(
              l10n.todaySuggestionAiExplainMaxRetry,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
