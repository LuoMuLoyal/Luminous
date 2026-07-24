import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/sheet_drag_handle.dart';
import 'package:luminous/features/report/presentation/widgets/shared/components.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a bottom sheet (mobile) or dialog (desktop) with the full details
/// of a [TodaySuggestionHistoryItem].
///
/// All data is already available in the item — no additional API call is
/// needed.
Future<void> showSuggestionHistoryDetailSheet(
  BuildContext context, {
  required TodaySuggestionHistoryItem suggestion,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  if (isDesktop) {
    return showFDialog<void>(
      context: context,
      builder: (_, __, ___) => DialogShell(
        maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
          MediaQuery.sizeOf(context).width,
        ),
        builder: (_) => _SuggestionHistoryDetailContent(suggestion: suggestion),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.level4),
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _SuggestionHistoryDetailContent(suggestion: suggestion),
      ),
    ),
  );
}

// ── Content ─────────────────────────────────────────────────────────────────

class _SuggestionHistoryDetailContent extends StatelessWidget {
  const _SuggestionHistoryDetailContent({required this.suggestion});

  final TodaySuggestionHistoryItem suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.level5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle (mobile only — dialog already has its own chrome).
          if (MediaQuery.sizeOf(context).width < Breakpoints.desktop)
            const Center(child: SheetDragHandle()),

          // Title row: type icon + title.
          Row(
            children: [
              Icon(_iconForType(suggestion.type), size: 20),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: TypographyToken.level6
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.level4),

          // Lifecycle badge.
          _LifecycleBadge(
            lifecycleState: suggestion.lifecycleState,
            l10n: l10n,
          ),

          const SizedBox(height: Spacing.level5),
          const AppDivider(),
          const SizedBox(height: Spacing.level5),

          // Reason body.
          Text(suggestion.reason, style: TypographyToken.level4.body(context)),

          const SizedBox(height: Spacing.level5),
          const AppDivider(),
          const SizedBox(height: Spacing.level5),

          // Meta fields.
          MetaRow(
            label: l10n.reportSuggestionHistoryDetailRuleId,
            value: suggestion.ruleId,
          ),
          MetaRow(
            label: l10n.reportSuggestionHistoryDetailRuleVersion,
            value: suggestion.ruleVersion,
          ),
          MetaRow(
            label: l10n.reportSuggestionHistoryDetailTriggerType,
            value: _triggerTypeLabel(suggestion.triggerType, l10n),
          ),
          MetaRow(
            label: l10n.reportSuggestionHistoryDetailConfidence,
            value: _confidenceLabel(suggestion.confidence, l10n),
          ),
          MetaRow(
            label: l10n.reportSuggestionHistoryDetailGeneratedAt,
            value: formatDateTimeFull(suggestion.generatedAt, locale),
          ),

          // Feedback (optional).
          if (suggestion.feedback != null) ...[
            const SizedBox(height: Spacing.level4),
            MetaRow(
              label: l10n.reportSuggestionHistoryDetailFeedback,
              value: _feedbackLabel(suggestion.feedback!, l10n),
            ),
            if (suggestion.feedbackAt != null)
              MetaRow(
                label: l10n.reportSuggestionHistoryDetailFeedbackAt,
                value: formatDateTimeFull(suggestion.feedbackAt!, locale),
              ),
          ] else ...[
            const SizedBox(height: Spacing.level4),
            MetaRow(
              label: l10n.reportSuggestionHistoryDetailFeedback,
              value: l10n.reportSuggestionHistoryDetailNoFeedback,
            ),
          ],

          // Expiry (optional).
          if (suggestion.expiredAt != null) ...[
            const SizedBox(height: Spacing.level4),
            MetaRow(
              label: l10n.reportSuggestionHistoryDetailExpiredAt,
              value: formatDateTimeFull(suggestion.expiredAt!, locale),
            ),
          ],

          const SizedBox(height: Spacing.level5),

          // Close button.
          FButton(
            variant: FButtonVariant.ghost,
            onPress: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  IconData _iconForType(TodaySuggestionType type) {
    return switch (type) {
      TodaySuggestionType.confirmedRisk => FLucideIcons.triangleAlert,
      TodaySuggestionType.compliance => FLucideIcons.clipboardList,
      TodaySuggestionType.trend => FLucideIcons.trendingUp,
      TodaySuggestionType.behaviorAdvice => FLucideIcons.lightbulb,
      TodaySuggestionType.coverage => FLucideIcons.activity,
    };
  }

  String _triggerTypeLabel(
    TodaySuggestionTriggerType type,
    AppLocalizations l10n,
  ) {
    return switch (type) {
      TodaySuggestionTriggerType.event => l10n.reportSuggestionTriggerTypeEvent,
      TodaySuggestionTriggerType.timer => l10n.reportSuggestionTriggerTypeTimer,
    };
  }

  String _confidenceLabel(
    TodaySuggestionConfidence confidence,
    AppLocalizations l10n,
  ) {
    return switch (confidence) {
      TodaySuggestionConfidence.high => l10n.reportSuggestionConfidenceHigh,
      TodaySuggestionConfidence.medium => l10n.reportSuggestionConfidenceMedium,
      TodaySuggestionConfidence.low => l10n.reportSuggestionConfidenceLow,
    };
  }

  String _feedbackLabel(
    TodaySuggestionFeedback feedback,
    AppLocalizations l10n,
  ) {
    return switch (feedback) {
      TodaySuggestionFeedback.accepted => l10n.todaySuggestionAcceptedAction,
      TodaySuggestionFeedback.later => l10n.todaySuggestionLaterAction,
      TodaySuggestionFeedback.notApplicable =>
        l10n.todaySuggestionNotApplicableAction,
      TodaySuggestionFeedback.suppress => l10n.todaySuggestionSuppressAction,
    };
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _LifecycleBadge extends StatelessWidget {
  const _LifecycleBadge({required this.lifecycleState, required this.l10n});

  final TodaySuggestionLifecycleState lifecycleState;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (semanticColor, label) = switch (lifecycleState) {
      TodaySuggestionLifecycleState.generated ||
      TodaySuggestionLifecycleState.active ||
      TodaySuggestionLifecycleState.fading => (
        SemanticColor.primary,
        l10n.reportSuggestionHistoryActiveBadge,
      ),
      TodaySuggestionLifecycleState.expired => (
        SemanticColor.neutral,
        l10n.reportSuggestionHistoryExpiredBadge,
      ),
      TodaySuggestionLifecycleState.dismissed => (
        SemanticColor.neutral,
        l10n.reportSuggestionHistoryDismissedBadge,
      ),
    };

    final color = semanticColor.solid(context);

    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: semanticColor.muted(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
          ),
        ),
      ),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
