import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayPrimarySuggestionSection extends StatefulWidget {
  const TodayPrimarySuggestionSection({super.key, required this.suggestion});

  final TodaySuggestionCard? suggestion;

  @override
  State<TodayPrimarySuggestionSection> createState() =>
      _TodayPrimarySuggestionSectionState();
}

class _TodayPrimarySuggestionSectionState
    extends State<TodayPrimarySuggestionSection>
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
    final card = widget.suggestion;

    if (card == null) {
      return const SizedBox.shrink();
    }

    final colors = context.theme.colors;
    final cardTone = _mapTone(card.cardTone);

    return TodaySection(
      title: l10n.todayPrimarySuggestionSectionTitle,
      child: FCard.raw(
        key: const Key('today-primary-suggestion-card'),
        style: todayCardStyle(context, tone: cardTone),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + action button row
              Row(
                children: [
                  TodayGlyphTile(
                    icon: _iconFor(card.icon),
                    color: _colorFor(card.cardTone).resolve(colors),
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
              // Title
              Text(
                card.title,
                style: TypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level2),
              // Reason
              Text(
                card.reason,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              // Collapsible evidence/boundary
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
                    _SuggestionMetaBlock(
                      label: l10n.todaySuggestionEvidenceLabel,
                      value: card.evidence
                          .map((e) => '${e.label}: ${e.value}')
                          .join('\n'),
                    ),
                    const SizedBox(height: Spacing.level3),
                    _SuggestionMetaBlock(
                      label: l10n.todaySuggestionBoundaryLabel,
                      value: card.boundary,
                    ),
                  ],
                ),
              ),
              // Feedback actions
              const SizedBox(height: Spacing.level4),
              _SuggestionFeedbackRow(l10n: l10n),
            ],
          ),
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

class _SuggestionFeedbackRow extends StatelessWidget {
  const _SuggestionFeedbackRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      children: [
        FButton(
          onPress: () {},
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          mainAxisSize: MainAxisSize.min,
          child: Text(l10n.todaySuggestionLaterAction),
        ),
        const SizedBox(width: Spacing.level2),
        FButton(
          onPress: () {},
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          mainAxisSize: MainAxisSize.min,
          child: Text(
            l10n.todaySuggestionNotApplicableAction,
            style: TextStyle(color: colors.mutedForeground),
          ),
        ),
      ],
    );
  }
}

class TodaySecondarySuggestionsSection extends StatelessWidget {
  const TodaySecondarySuggestionsSection({
    super.key,
    required this.suggestions,
  });

  final List<TodaySuggestionCard> suggestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = suggestions.take(2).toList();
    final colors = context.theme.colors;

    return TodaySection(
      title: l10n.todaySecondarySuggestionSectionTitle,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index += 1) ...[
            if (index > 0) const SizedBox(height: Spacing.level3),
            FCard.raw(
              key: Key('today-secondary-suggestion-$index'),
              style: todayCardStyle(context, tone: TodayCardTone.soft),
              child: FTappable(
                onPress: () =>
                    _openRoute(context, items[index].primaryAction.route),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      TodayGlyphTile(
                        icon: _iconFor(items[index].icon),
                        color: _colorFor(items[index].cardTone).resolve(colors),
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
                              items[index].title,
                              style: TypographyToken.level5
                                  .body(context)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: Spacing.level1),
                            Text(
                              items[index].reason,
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

// ── Helpers ───────────────────────────────────────────────────────────────

void _openRoute(BuildContext context, String route) {
  if (route.startsWith('/')) {
    context.go(route);
  } else {
    context.push(route);
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

IconData _iconFor(String icon) {
  return switch (icon) {
    'droplets' => FLucideIcons.droplets,
    'moon' => FLucideIcons.moon,
    'activity' => FLucideIcons.activity,
    'coffee' => FLucideIcons.coffee,
    'user' => FLucideIcons.userRound,
    'clipboard' => FLucideIcons.clipboardList,
    'alert-triangle' => FLucideIcons.triangleAlert,
    'pill' => FLucideIcons.pill,
    'trending-up' => FLucideIcons.trendingUp,
    'lightbulb' => FLucideIcons.lightbulb,
    'info' => FLucideIcons.info,
    _ => FLucideIcons.sparkles,
  };
}
