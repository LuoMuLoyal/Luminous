import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport, RenderBox;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/today/application/usecases/skip_dose.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion_interactive.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/presentation/widgets/shared/suggestion_icon_mapping.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
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
  final Set<String> _loadingActionIds = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DurationTokens.widgetExpand,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: MotionTokens.standard,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleEvidence() {
    setState(() => _evidenceExpanded = !_evidenceExpanded);
    unawaited(_controller.toggle());
  }

  Future<void> _handleSecondaryAction(TodaySuggestionAction action) async {
    if (action.actionId == 'skip_dose') {
      await _skipDose(action);
    } else {
      openRoute(context, action.route);
    }
  }

  Future<void> _skipDose(TodaySuggestionAction action) async {
    setState(() => _loadingActionIds.add(action.actionId));
    final l10n = AppLocalizations.of(context)!;
    try {
      final params = Uri.parse(action.route).queryParameters;
      final medicineId = params['currentMedicineId'];
      final scheduledFor = params['scheduledFor'];
      if (medicineId == null || scheduledFor == null) {
        // Insufficient routing information: fall back to navigating to the
        // medicine page instead of calling mark with incomplete data.
        openRoute(context, action.route);
        return;
      }

      await SkipDoseUseCase(ref: ref)(
        currentMedicineId: medicineId,
        date: scheduledFor,
        reminderId: params['reminderId'],
        scheduledTime: params['scheduledTime'],
      );
    } catch (e, st) {
      appTalker.error('skip_dose failed: $e', e, st);
      if (mounted) {
        unawaited(Toast.show(context, l10n.todaySuggestionSkipDoseError));
      }
    } finally {
      if (mounted) {
        setState(() => _loadingActionIds.remove(action.actionId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final card = widget.card;
    final cardTone = mapTone(card.cardTone);
    final isFading =
        card.lifecycleState == TodaySuggestionLifecycleState.fading;
    final typography = context.theme.typography;

    return _SuggestionImpressionTracker(
      ruleCode: card.ruleId,
      child: Opacity(
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
                        size: IconSizeTokens.level6,
                        radius: context.theme.style.borderRadius.sm.topLeft.x,
                        filled: true,
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
                    style: typography.display.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.level2),
                  Text(
                    card.reason,
                    style: typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (card.secondaryActions != null &&
                      card.secondaryActions!.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level3),
                    Wrap(
                      spacing: Spacing.level2,
                      runSpacing: Spacing.level2,
                      children: [
                        for (final action in card.secondaryActions!)
                          FButton(
                            onPress: _loadingActionIds.contains(action.actionId)
                                ? null
                                : () => _handleSecondaryAction(action),
                            variant: FButtonVariant.ghost,
                            size: FButtonSizeVariant.xs,
                            mainAxisSize: MainAxisSize.min,
                            child: _loadingActionIds.contains(action.actionId)
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: Spacing.level4,
                                        height: Spacing.level4,
                                        child: FCircularProgress.loader(),
                                      ),
                                      const SizedBox(width: Spacing.level2),
                                      Text(action.label),
                                    ],
                                  )
                                : Text(action.label),
                          ),
                      ],
                    ),
                  ],
                  if (card.subtype == 'water' && widget.dashboard != null) ...[
                    const SizedBox(height: Spacing.level3),
                    WaterProgressBar(
                      progress: widget.dashboard!.water.progress,
                    ),
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
      ),
    );
  }
}

/// Reports a `suggestion_impression` once when the wrapped card first enters
/// the visible area of its scroll viewport.
///
/// Lightweight visibility check without a third-party dependency:
/// - the card's render box global rect is intersected with the enclosing
///   [RenderAbstractViewport]'s rect on every scroll tick and after frames;
/// - `TickerMode` gates the check so cards in inactive (muted) shell branches
///   or hidden contexts do not report impressions;
/// - [ProductEventService.trackSuggestionImpression] additionally dedupes per
///   session and per rule code, so rebuilds never re-emit.
class _SuggestionImpressionTracker extends ConsumerStatefulWidget {
  const _SuggestionImpressionTracker({
    required this.ruleCode,
    required this.child,
  });

  final String ruleCode;
  final Widget child;

  @override
  ConsumerState<_SuggestionImpressionTracker> createState() =>
      _SuggestionImpressionTrackerState();
}

class _SuggestionImpressionTrackerState
    extends ConsumerState<_SuggestionImpressionTracker> {
  bool _impressionReported = false;
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachAndCheck());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fires when TickerMode flips (e.g. the Today shell branch becomes the
    // active tab again) — re-check the newly visible card.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didUpdateWidget(covariant _SuggestionImpressionTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ruleCode != widget.ruleCode) {
      _impressionReported = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    super.dispose();
  }

  void _attachAndCheck() {
    if (!mounted) return;
    _position?.removeListener(_onScroll);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_onScroll);
    _checkVisibility();
  }

  void _onScroll() => _checkVisibility();

  void _checkVisibility() {
    if (!mounted || _impressionReported) return;
    // Muted tickers mean this subtree is not actually presented (inactive
    // shell branch, offstage context) — do not report impressions there.
    if (!TickerMode.valuesOf(context).enabled) return;
    if (!_isVisibleInViewport()) return;
    _impressionReported = true;
    ref
        .read(productEventServiceProvider)
        .trackSuggestionImpression(widget.ruleCode);
  }

  bool _isVisibleInViewport() {
    try {
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) return false;
      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) return false;
      // All real viewports (RenderViewport, _RenderSingleChildViewport) are
      // RenderBoxes; the cast is defensive and never expected to throw.
      final viewportBox = viewport as RenderBox;
      final viewportRect =
          viewportBox.localToGlobal(Offset.zero) & viewportBox.size;
      final cardRect =
          renderObject.localToGlobal(Offset.zero) & renderObject.size;
      return viewportRect.overlaps(cardRect);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.primary.solid(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: Spacing.level1),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: DurationTokens.widgetQuick,
              child: Icon(
                SemanticIcons.actionNext,
                size: IconSizeTokens.level2,
                color: SemanticColor.primary.solid(context),
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
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.level1),
        Text(value, style: typography.body.sm),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.theme.typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
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
    final typography = context.theme.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          flex: 7,
          child: Text(
            value,
            style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
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
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: context.theme.style.borderRadius.pill,
            child: FDeterminateProgress(value: progress),
          ),
        ),
        const SizedBox(width: Spacing.level2),
        Text(
          '${(progress * 100).round()}%',
          style: context.theme.typography.body.xs2.copyWith(
            color: SemanticColor.neutral.solid(context),
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
