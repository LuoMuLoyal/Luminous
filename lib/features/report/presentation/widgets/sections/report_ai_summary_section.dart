import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/router/action_route_mapper.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportAiSummarySection extends StatelessWidget {
  const ReportAiSummarySection({
    super.key,
    required this.dashboard,
    required this.canAccessProtectedData,
    required this.aiSummariesEnabled,
    required this.aiState,
    required this.selectedRange,
    this.onRangeChanged,
    this.onGenerate,
    required this.l10n,
  });

  final ReportDashboard dashboard;
  final bool canAccessProtectedData;
  final bool? aiSummariesEnabled;
  final ReportAiSummaryCardState aiState;
  final ReportAiSummaryRange selectedRange;
  final ValueChanged<ReportAiSummaryRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final content = buildReportAiSummaryContent(
      l10n: l10n,
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      aiState: aiState,
      selectedRange: selectedRange,
    );
    final action = aiState.summary?.action;
    final actionLabel = aiState.summary?.actionLabel;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconBadge(
                  icon: FLucideIcons.sparkles,
                  color: Color(0xFF0F766E),
                  size: AppSpacingTokens.level8,
                  iconSize: AppSpacingTokens.level5,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reportAiSummaryTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacingTokens.level1),
                      Text(
                        content.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacingTokens.level3),
                      Wrap(
                        spacing: AppSpacingTokens.level3,
                        runSpacing: AppSpacingTokens.level3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SegmentedButton<ReportAiSummaryRange>(
                            key: const Key('report-ai-summary-range-toggle'),
                            segments: [
                              ButtonSegment(
                                value: ReportAiSummaryRange.last7Days,
                                label: Text(l10n.reportRangeLast7Days),
                              ),
                              ButtonSegment(
                                value: ReportAiSummaryRange.last30Days,
                                label: Text(l10n.reportRangeLast30Days),
                              ),
                              ButtonSegment(
                                value: ReportAiSummaryRange.custom,
                                label: Text(l10n.reportRangeCustom),
                              ),
                            ],
                            selected: {selectedRange},
                            onSelectionChanged: onRangeChanged == null
                                ? null
                                : (selection) {
                                    if (selection.isNotEmpty) {
                                      onRangeChanged!(selection.first);
                                    }
                                  },
                          ),
                          if (actionLabel != null && action != null)
                            OutlinedButton(
                              onPressed: () => _handleAction(context, action),
                              child: Text(actionLabel),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Divider(height: 1, thickness: 1, color: colors.border),
            if (content.summaryText != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacingTokens.level3,
                  bottom: AppSpacingTokens.level3,
                ),
                child: AppSkeletonText(
                  text: content.summaryText!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  widthFactor: 0.94,
                ),
              ),
              Divider(height: 1, thickness: 1, color: colors.border),
            ],
            for (var index = 0; index < content.bullets.length; index += 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacingTokens.level3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacingTokens.level2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: content.bullets[index].color,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(
                          dimension: AppSpacingTokens.level2,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.level3),
                    Expanded(
                      child: AppSkeletonText(
                        text: content.bullets[index].text,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                        widthFactor: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < content.bullets.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.level5,
                  color: colors.border,
                ),
            ],
            if (content.footer != null) ...[
              const SizedBox(height: AppSpacingTokens.level3),
              Divider(height: 1, thickness: 1, color: colors.border),
              const SizedBox(height: AppSpacingTokens.level3),
              Text(
                content.footer!,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
            if (content.showGenerateButton) ...[
              const SizedBox(height: AppSpacingTokens.level4),
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  key: const Key('report-ai-summary-generate-action'),
                  onPress: aiState.isLoading || onGenerate == null
                      ? null
                      : () async {
                          await onGenerate!();
                        },
                  prefix: Icon(
                    aiState.isLoading
                        ? FLucideIcons.loaderCircle
                        : FLucideIcons.sparkles,
                    size: 16,
                  ),
                  child: Text(
                    aiState.isLoading
                        ? reportAiSummaryGeneratingLabel(l10n, selectedRange)
                        : l10n.reportGenerateAction,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final route = mapActionToRoute(action);
    if (route != null) {
      context.push(route);
    }
  }
}
