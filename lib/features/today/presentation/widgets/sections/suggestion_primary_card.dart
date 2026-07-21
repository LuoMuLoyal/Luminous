import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/suggestion_icon_mapping.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion_interactive.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The primary suggestion card with expandable evidence, AI explain,
/// and feedback row.
///
/// Animated expand/collapse for the evidence section is controlled by an
/// internal [AnimationController].
class SuggestionPrimaryCard extends ConsumerStatefulWidget {
  const SuggestionPrimaryCard({super.key, required this.card, this.dashboard});

  final TodaySuggestionCard card;

  /// Used for the water progress bar when the card's `subtype == 'water'`.
  final TodayDashboard? dashboard;

  @override
  ConsumerState<SuggestionPrimaryCard> createState() =>
      _SuggestionPrimaryCardState();
}

class _SuggestionPrimaryCardState extends ConsumerState<SuggestionPrimaryCard>
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
    final cardTone = mapTone(card.cardTone);
    final isFading =
        card.lifecycleState == TodaySuggestionLifecycleState.fading;

    return Opacity(
      opacity: isFading ? 0.6 : 1.0,
      // When a suggestion is fading out (pending dismissal) we disable all
      // in-card interactions so users cannot trigger actions, feedback, or
      // AI explain on a card that is about to disappear.
      child: IgnorePointer(
        ignoring: isFading,
        child: FCard(
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
                      color: colorFor(card.cardTone),
                      size: Spacing.level8,
                      radius: RadiusTokens.level3,
                      gradient: true,
                    ),
                    const Spacer(),
                    FButton(
                      onPress: () =>
                          openRoute(context, card.primaryAction.route),
                      variant: isUrgent(card.cardTone)
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
                  WaterProgressBar(progress: widget.dashboard!.water.progress),
                ],
                const SizedBox(height: Spacing.level3),
                EvidenceToggleButton(
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
                        EvidenceList(
                          label: l10n.todaySuggestionEvidenceLabel,
                          evidence: card.evidence,
                        ),
                        const SizedBox(height: Spacing.level3),
                      ],
                      SuggestionMetaBlock(
                        label: l10n.todaySuggestionBoundaryLabel,
                        value: card.boundary,
                      ),
                      const SizedBox(height: Spacing.level3),
                      SuggestionAiExplainButton(suggestionId: card.id),
                    ],
                  ),
                ),
                if (card.feedbackOptions != null &&
                    card.feedbackOptions!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.level4),
                  SuggestionFeedbackRow(
                    suggestionId: card.id,
                    feedbackOptions: card.feedbackOptions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle button that expands/collapses the evidence section.
class EvidenceToggleButton extends StatelessWidget {
  const EvidenceToggleButton({
    super.key,
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

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
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
      ),
    );
  }
}

/// Labeled meta block (e.g. boundary text).
class SuggestionMetaBlock extends StatelessWidget {
  const SuggestionMetaBlock({
    super.key,
    required this.label,
    required this.value,
  });

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

/// Structured list of evidence items.
class EvidenceList extends StatelessWidget {
  const EvidenceList({super.key, required this.label, required this.evidence});

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
          EvidenceItemRow(label: evidence[i].label, value: evidence[i].value),
        ],
      ],
    );
  }
}

/// Single evidence row with label (left) and value (right).
class EvidenceItemRow extends StatelessWidget {
  const EvidenceItemRow({super.key, required this.label, required this.value});

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

/// Water intake progress bar shown on `subtype == 'water'` suggestion cards.
class WaterProgressBar extends StatelessWidget {
  const WaterProgressBar({super.key, required this.progress});

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

// ── Shared helpers ──────────────────────────────────────────────────────────

/// Maps a suggestion card tone to the shared [TodayCardTone].
TodayCardTone mapTone(TodaySuggestionCardTone tone) {
  return switch (tone) {
    TodaySuggestionCardTone.urgent => TodayCardTone.urgent,
    TodaySuggestionCardTone.warning => TodayCardTone.warning,
    TodaySuggestionCardTone.emphasis => TodayCardTone.emphasis,
    TodaySuggestionCardTone.soft => TodayCardTone.soft,
    TodaySuggestionCardTone.neutral => TodayCardTone.neutral,
  };
}

/// Whether the tone represents an urgent/warning level.
bool isUrgent(TodaySuggestionCardTone tone) {
  return tone == TodaySuggestionCardTone.urgent ||
      tone == TodaySuggestionCardTone.warning;
}

/// Resolves a [SemanticColor] for the given card tone.
SemanticColor colorFor(TodaySuggestionCardTone tone) {
  return switch (tone) {
    TodaySuggestionCardTone.urgent => SemanticColor.destructive,
    TodaySuggestionCardTone.warning => SemanticColor.warning,
    TodaySuggestionCardTone.emphasis => SemanticColor.primary,
    TodaySuggestionCardTone.soft => SemanticColor.primary,
    TodaySuggestionCardTone.neutral => SemanticColor.neutral,
  };
}
