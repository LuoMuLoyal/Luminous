import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/suggestion_icon_mapping.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayPrimarySuggestionSection extends ConsumerWidget {
  const TodayPrimarySuggestionSection({super.key, this.dashboard});

  /// Used for the water progress bar when the primary card's
  /// `subtype == 'water'`.
  final TodayDashboard? dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestionAsync = ref.watch(todaySuggestionProvider);

    return TodaySection(
      title: l10n.todayPrimarySuggestionSectionTitle,
      child: suggestionAsync.when(
        data: (bundle) {
          final card = bundle?.primary;
          if (card == null) {
            return _SuggestionEmptyState(l10n: l10n);
          }
          return _PrimarySuggestionCard(card: card, dashboard: dashboard);
        },
        loading: () => const _SuggestionSkeleton(),
        error: (_, __) => _SuggestionErrorState(
          l10n: l10n,
          onRetry: () => ref.invalidate(todaySuggestionProvider),
        ),
      ),
    );
  }
}

class _PrimarySuggestionCard extends ConsumerStatefulWidget {
  const _PrimarySuggestionCard({required this.card, this.dashboard});

  final TodaySuggestionCard card;
  final TodayDashboard? dashboard;

  @override
  ConsumerState<_PrimarySuggestionCard> createState() =>
      _PrimarySuggestionCardState();
}

class _PrimarySuggestionCardState extends ConsumerState<_PrimarySuggestionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  bool _evidenceExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DurationTokens.widgetExpand,
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleEvidence() {
    setState(() => _evidenceExpanded = !_evidenceExpanded);
    _controller.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final card = widget.card;
    final colors = context.theme.colors;
    final cardTone = _mapTone(card.cardTone);
    final isFading =
        card.lifecycleState == TodaySuggestionLifecycleState.fading;

    return Opacity(
      opacity: isFading ? 0.6 : 1.0,
      child: FCard.raw(
        key: const Key('today-primary-suggestion-card'),
        style: todayCardStyle(context, tone: cardTone),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TodayGlyphTile(
                    icon: SuggestionIconMapping.resolve(card.icon),
                    color: _colorFor(card.cardTone),
                    size: Spacing.level8,
                    radius: RadiusTokens.level3,
                    gradient: true,
                  ),
                  const Spacer(),
                  FButton(
                    onPress: () =>
                        _openRoute(context, card.primaryAction.route),
                    variant: _isUrgent(card.cardTone)
                        ? FButtonVariant.primary
                        : FButtonVariant.secondary,
                    size: FButtonSizeVariant.sm,
                    child: Text(card.primaryAction.label),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level4),
              Text(
                card.title,
                style: TypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level2),
              Text(
                card.reason,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (card.subtype == 'water' && widget.dashboard != null) ...[
                const SizedBox(height: Spacing.level3),
                _WaterProgressBar(progress: widget.dashboard!.water.progress),
              ],
              const SizedBox(height: Spacing.level3),
              _EvidenceToggleButton(
                expanded: _evidenceExpanded,
                onTap: _toggleEvidence,
                l10n: l10n,
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) =>
                    FCollapsible(value: _animation.value, child: child!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Spacing.level3),
                    if (card.evidence.isNotEmpty) ...[
                      _EvidenceList(
                        label: l10n.todaySuggestionEvidenceLabel,
                        evidence: card.evidence,
                      ),
                      const SizedBox(height: Spacing.level3),
                    ],
                    _SuggestionMetaBlock(
                      label: l10n.todaySuggestionBoundaryLabel,
                      value: card.boundary,
                    ),
                    const SizedBox(height: Spacing.level3),
                    _SuggestionAiExplainButton(suggestionId: card.id),
                  ],
                ),
              ),
              if (card.feedbackOptions != null &&
                  card.feedbackOptions!.isNotEmpty) ...[
                const SizedBox(height: Spacing.level4),
                _SuggestionFeedbackRow(
                  suggestionId: card.id,
                  feedbackOptions: card.feedbackOptions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TodaySecondarySuggestionsSection extends ConsumerWidget {
  const TodaySecondarySuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestionAsync = ref.watch(todaySuggestionProvider);

    return suggestionAsync.when(
      data: (bundle) {
        final items = bundle?.secondary ?? const [];
        if (items.isEmpty) return const SizedBox.shrink();

        final visible = items.take(2).toList();
        final colors = context.theme.colors;

        return TodaySection(
          title: l10n.todaySecondarySuggestionSectionTitle,
          child: Column(
            children: [
              for (var index = 0; index < visible.length; index += 1) ...[
                if (index > 0) const SizedBox(height: Spacing.level3),
                FCard.raw(
                  key: Key('today-secondary-suggestion-$index'),
                  style: todayCardStyle(context, tone: TodayCardTone.soft),
                  child: FTappable(
                    onPress: () =>
                        _openRoute(context, visible[index].primaryAction.route),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level4),
                      child: Row(
                        children: [
                          TodayGlyphTile(
                            icon: SuggestionIconMapping.resolve(
                              visible[index].icon,
                            ),
                            color: _colorFor(visible[index].cardTone),
                            size: Spacing.level7,
                            radius: RadiusTokens.level3,
                            gradient: false,
                          ),
                          const SizedBox(width: Spacing.level3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  visible[index].title,
                                  style: TypographyToken.level5
                                      .body(context)
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: Spacing.level1),
                                Text(
                                  visible[index].reason,
                                  style: TypographyToken.level3
                                      .body(context)
                                      .copyWith(color: colors.mutedForeground),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Spacing.level2),
                          Icon(
                            FLucideIcons.chevronRight,
                            size: Spacing.level5,
                            color: colors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _SecondarySuggestionErrorState(
        onRetry: () => ref.invalidate(todaySuggestionProvider),
      ),
    );
  }
}

class _SecondarySuggestionErrorState extends StatelessWidget {
  const _SecondarySuggestionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TodaySection(
      title: l10n.todaySecondarySuggestionSectionTitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level5,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FLucideIcons.circleAlert,
                size: Spacing.level6,
                color: context.theme.colors.mutedForeground,
              ),
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.todaySuggestionSecondaryErrorHint,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: context.theme.colors.mutedForeground),
              ),
              const SizedBox(height: Spacing.level2),
              FButton(
                onPress: onRetry,
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.xs,
                child: Text(l10n.todaySuggestionRetryAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionFeedbackRow extends ConsumerStatefulWidget {
  const _SuggestionFeedbackRow({
    required this.suggestionId,
    required this.feedbackOptions,
  });

  final String suggestionId;
  final List<TodaySuggestionFeedback> feedbackOptions;

  @override
  ConsumerState<_SuggestionFeedbackRow> createState() =>
      _SuggestionFeedbackRowState();
}

class _SuggestionFeedbackRowState
    extends ConsumerState<_SuggestionFeedbackRow> {
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
        unawaited(AppToast.show(context, l10n.todaySuggestionFeedbackSuccess));
      }
    } catch (_) {
      if (mounted) {
        unawaited(AppToast.show(context, l10n.todaySuggestionFeedbackError));
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
          Icon(FLucideIcons.check, size: Spacing.level4, color: colors.primary),
          const SizedBox(width: Spacing.level1),
          Text(
            l10n.todaySuggestionFeedbackSubmitted,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.primary, fontWeight: FontWeight.w600),
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
              _labelFor(l10n, option),
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

String _labelFor(AppLocalizations l10n, TodaySuggestionFeedback feedback) {
  return switch (feedback) {
    TodaySuggestionFeedback.accepted => l10n.todaySuggestionAcceptedAction,
    TodaySuggestionFeedback.later => l10n.todaySuggestionLaterAction,
    TodaySuggestionFeedback.notApplicable =>
      l10n.todaySuggestionNotApplicableAction,
    TodaySuggestionFeedback.suppress => l10n.todaySuggestionSuppressAction,
  };
}

class _SuggestionAiExplainButton extends ConsumerStatefulWidget {
  const _SuggestionAiExplainButton({required this.suggestionId});

  final String suggestionId;

  @override
  ConsumerState<_SuggestionAiExplainButton> createState() =>
      _SuggestionAiExplainButtonState();
}

class _SuggestionAiExplainButtonState
    extends ConsumerState<_SuggestionAiExplainButton> {
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
          // Trigger the provider.
          ref.read(suggestionExplanationProvider(params).future);
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
        if (explanation == null || !explanation.aiGenerated) {
          if (_retryCount >= _maxRetries) {
            return _AiExplainUnavailable(l10n: l10n);
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
            child: Text(l10n.todaySuggestionAiExplainAction),
          );
        }
        return _AiExplainContent(explanation: explanation);
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
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: context.theme.colors.mutedForeground),
          ),
        ],
      ),
      error: (_, __) {
        if (_retryCount >= _maxRetries) {
          return _AiExplainUnavailable(l10n: l10n);
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

class _AiExplainContent extends StatelessWidget {
  const _AiExplainContent({required this.explanation});

  final TodaySuggestionExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.level3),
      decoration: BoxDecoration(
        color: SemanticColor.primary.subtle(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: SemanticColor.primary.muted(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FLucideIcons.sparkles,
                size: Spacing.level4,
                color: colors.primary,
              ),
              const SizedBox(width: Spacing.level1),
              Text(
                l10n.todaySuggestionAiLabel,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level2),
          MarkdownBody(
            data: explanation.reason,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(
              Theme.of(context),
            ).copyWith(p: TypographyToken.level4.body(context)),
          ),
          if (explanation.boundary.isNotEmpty) ...[
            const SizedBox(height: Spacing.level2),
            MarkdownBody(
              data: explanation.boundary,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiExplainUnavailable extends StatelessWidget {
  const _AiExplainUnavailable({required this.l10n});

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
            FLucideIcons.info,
            size: Spacing.level4,
            color: colors.mutedForeground,
          ),
          const SizedBox(width: Spacing.level1),
          Flexible(
            child: Text(
              l10n.todaySuggestionAiExplainMaxRetry,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionEmptyState extends StatelessWidget {
  const _SuggestionEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level6,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.sparkles,
              size: Spacing.level8,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              l10n.todaySuggestionEmptyTitle,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level1),
            Text(
              l10n.todaySuggestionEmptySubtitle,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: context.theme.colors.mutedForeground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionSkeleton extends StatelessWidget {
  const _SuggestionSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: context.theme.colors.card,
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
          border: Border.all(color: context.theme.colors.border),
        ),
      ),
    );
  }
}

class _SuggestionErrorState extends StatelessWidget {
  const _SuggestionErrorState({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level6,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.circleAlert,
              size: Spacing.level8,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              l10n.todaySuggestionErrorHint,
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(color: context.theme.colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level3),
            FButton(
              onPress: onRetry,
              variant: FButtonVariant.secondary,
              size: FButtonSizeVariant.sm,
              child: Text(l10n.todaySuggestionRetryAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceToggleButton extends StatelessWidget {
  const _EvidenceToggleButton({
    required this.expanded,
    required this.onTap,
    required this.l10n,
  });

  final bool expanded;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            expanded
                ? l10n.todaySuggestionHideEvidence
                : l10n.todaySuggestionShowEvidence,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: Spacing.level1),
          AnimatedRotation(
            turns: expanded ? 0.25 : 0,
            duration: DurationTokens.widgetQuick,
            child: Icon(
              FLucideIcons.chevronRight,
              size: Spacing.level4,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionMetaBlock extends StatelessWidget {
  const _SuggestionMetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: Spacing.level1),
        Text(value, style: TypographyToken.level4.body(context)),
      ],
    );
  }
}

class _EvidenceList extends StatelessWidget {
  const _EvidenceList({required this.label, required this.evidence});

  final String label;
  final List<TodaySuggestionEvidence> evidence;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: Spacing.level2),
        for (var i = 0; i < evidence.length; i++) ...[
          if (i > 0) const SizedBox(height: Spacing.level1),
          _EvidenceItemRow(label: evidence[i].label, value: evidence[i].value),
        ],
      ],
    );
  }
}

class _EvidenceItemRow extends StatelessWidget {
  const _EvidenceItemRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          flex: 7,
          child: Text(
            value,
            style: TypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _WaterProgressBar extends StatelessWidget {
  const _WaterProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
            child: FDeterminateProgress(value: progress),
          ),
        ),
        const SizedBox(width: Spacing.level2),
        Text(
          '${(progress * 100).round()}%',
          style: TypographyToken.level2
              .body(context)
              .copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

void _openRoute(BuildContext context, String route) {
  if (route.contains('?')) {
    context.push(route);
  } else {
    context.go(route);
  }
}

TodayCardTone _mapTone(TodaySuggestionCardTone tone) {
  return switch (tone) {
    TodaySuggestionCardTone.urgent => TodayCardTone.urgent,
    TodaySuggestionCardTone.warning => TodayCardTone.warning,
    TodaySuggestionCardTone.emphasis => TodayCardTone.emphasis,
    TodaySuggestionCardTone.soft => TodayCardTone.soft,
    TodaySuggestionCardTone.neutral => TodayCardTone.neutral,
  };
}

bool _isUrgent(TodaySuggestionCardTone tone) {
  return tone == TodaySuggestionCardTone.urgent ||
      tone == TodaySuggestionCardTone.warning;
}

SemanticColor _colorFor(TodaySuggestionCardTone tone) {
  return switch (tone) {
    TodaySuggestionCardTone.urgent => SemanticColor.destructive,
    TodaySuggestionCardTone.warning => SemanticColor.warning,
    TodaySuggestionCardTone.emphasis => SemanticColor.primary,
    TodaySuggestionCardTone.soft => SemanticColor.primary,
    TodaySuggestionCardTone.neutral => SemanticColor.neutral,
  };
}
