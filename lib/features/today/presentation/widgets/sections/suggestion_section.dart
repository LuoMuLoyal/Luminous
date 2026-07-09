import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayPrimarySuggestionSection extends StatefulWidget {
  const TodayPrimarySuggestionSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

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
      duration: AppAnimationDurations.widgetExpand,
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
    final items = buildSuggestionItems(l10n, widget.dashboard);
    final primary = items.first;
    final colors = context.theme.colors;

    return TodaySection(
      title: l10n.todayPrimarySuggestionSectionTitle,
      child: FCard.raw(
        key: const Key('today-primary-suggestion-card'),
        style: todayCardStyle(context, tone: primary.cardTone),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + action button row
              Row(
                children: [
                  TodayGlyphTile(
                    icon: primary.icon,
                    color: primary.color.resolve(colors),
                    size: AppSpacingTokens.level8,
                    radius: AppRadiusTokens.level3,
                    gradient: true,
                  ),
                  const Spacer(),
                  FButton(
                    onPress: () => _openSuggestion(context, primary),
                    variant: primary.type == TodayPriorityItemType.medication
                        ? FButtonVariant.primary
                        : FButtonVariant.secondary,
                    size: FButtonSizeVariant.sm,
                    child: Text(primary.action),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              // Title
              Text(
                primary.title,
                style: AppTypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              // Reason
              Text(
                primary.reason,
                style: AppTypographyToken.level4
                    .body(context)
                    .copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              // Progress bar (water)
              if (primary.progress case final progress?) ...[
                const SizedBox(height: AppSpacingTokens.level3),
                FDeterminateProgress(value: progress),
              ],
              // Collapsible evidence/boundary
              const SizedBox(height: AppSpacingTokens.level3),
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
                    const SizedBox(height: AppSpacingTokens.level3),
                    _SuggestionMetaBlock(
                      label: l10n.todaySuggestionEvidenceLabel,
                      value: primary.evidence,
                    ),
                    const SizedBox(height: AppSpacingTokens.level3),
                    _SuggestionMetaBlock(
                      label: l10n.todaySuggestionBoundaryLabel,
                      value: primary.boundary,
                    ),
                  ],
                ),
              ),
              // Feedback actions
              const SizedBox(height: AppSpacingTokens.level4),
              _SuggestionFeedbackRow(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  void _openSuggestion(BuildContext context, TodaySuggestionItem item) {
    switch (item.type) {
      case TodayPriorityItemType.medication:
        context.go(AppRoutes.medicine);
      case TodayPriorityItemType.water:
        context.push('${AppRoutes.recordCreate}?kind=water');
    }
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
            style: AppTypographyToken.level3
                .body(context)
                .copyWith(color: colors.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: AppSpacingTokens.level1),
          AnimatedRotation(
            turns: expanded ? 0.25 : 0,
            duration: AppAnimationDurations.widgetQuick,
            child: Icon(
              FLucideIcons.chevronRight,
              size: AppSpacingTokens.level4,
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
        const SizedBox(width: AppSpacingTokens.level2),
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
  const TodaySecondarySuggestionsSection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = buildSuggestionItems(
      l10n,
      dashboard,
    ).skip(1).take(2).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.theme.colors;

    return TodaySection(
      title: l10n.todaySecondarySuggestionSectionTitle,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index += 1) ...[
            if (index > 0) const SizedBox(height: AppSpacingTokens.level3),
            FCard.raw(
              key: Key('today-secondary-suggestion-$index'),
              style: todayCardStyle(context, tone: TodayCardTone.soft),
              child: FTappable(
                onPress: () => _openSuggestion(context, items[index]),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.level4),
                  child: Row(
                    children: [
                      TodayGlyphTile(
                        icon: items[index].icon,
                        color: items[index].color.resolve(colors),
                        size: AppSpacingTokens.level7,
                        radius: AppRadiusTokens.level3,
                        gradient: false,
                      ),
                      const SizedBox(width: AppSpacingTokens.level3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[index].title,
                              style: AppTypographyToken.level5
                                  .body(context)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacingTokens.level1),
                            Text(
                              items[index].reason,
                              style: AppTypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.level2),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: AppSpacingTokens.level5,
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

  void _openSuggestion(BuildContext context, TodaySuggestionItem item) {
    switch (item.type) {
      case TodayPriorityItemType.medication:
        context.go(AppRoutes.medicine);
      case TodayPriorityItemType.water:
        context.push('${AppRoutes.recordCreate}?kind=water');
    }
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
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacingTokens.level1),
        Text(value, style: AppTypographyToken.level4.body(context)),
      ],
    );
  }
}
