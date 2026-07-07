import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/action_route_mapper.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

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

    final content = buildReportAiSummaryContent(
      l10n: l10n,
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      aiState: aiState,
      selectedRange: selectedRange,
      colors: colors,
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
                FAvatar.raw(
                  size: AppSpacingTokens.level8,
                  child: Icon(
                    FLucideIcons.sparkles,
                    color: AppColors.primary.resolve(colors),
                    size: AppSpacingTokens.level5,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reportAiSummaryTitle,
                        style: AppTypographyToken.level5
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacingTokens.level1),
                      Text(
                        content.subtitle,
                        style: AppTypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                      const SizedBox(height: AppSpacingTokens.level3),
                      Wrap(
                        spacing: AppSpacingTokens.level3,
                        runSpacing: AppSpacingTokens.level3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FSelectGroup<ReportAiSummaryRange>(
                            key: const Key('report-ai-summary-range-toggle'),
                            control: onRangeChanged == null
                                ? FMultiValueControl.lifted(
                                    value: {selectedRange},
                                    onChange: (_) {},
                                  )
                                : FMultiValueControl.lifted(
                                    value: {selectedRange},
                                    onChange: (selection) {
                                      if (selection.isNotEmpty) {
                                        onRangeChanged!(selection.first);
                                      }
                                    },
                                  ),
                            children: [
                              FSelectGroupItemMixin.radio(
                                value: ReportAiSummaryRange.last7Days,
                                label: Text(l10n.reportRangeLast7Days),
                              ),
                              FSelectGroupItemMixin.radio(
                                value: ReportAiSummaryRange.last30Days,
                                label: Text(l10n.reportRangeLast30Days),
                              ),
                              FSelectGroupItemMixin.radio(
                                value: ReportAiSummaryRange.custom,
                                label: Text(l10n.reportRangeCustom),
                              ),
                            ],
                          ),
                          if (actionLabel != null && action != null)
                            FButton(
                              variant: FButtonVariant.outline,
                              onPress: () => _handleAction(context, action),
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
            const AppDivider(),
            if (content.summaryText != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacingTokens.level3,
                  bottom: AppSpacingTokens.level3,
                ),
                child: AppSkeletonText(
                  text: content.summaryText!,
                  style: AppTypographyToken.level4
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                  widthFactor: 0.94,
                ),
              ),
              const AppDivider(),
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
                      padding: const EdgeInsets.only(
                        top: AppSpacingTokens.level2,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: content.bullets[index].color.resolve(colors),
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
                        style: AppTypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                        widthFactor: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < content.bullets.length - 1) const AppDivider(),
            ],
            if (content.footer != null) ...[
              const SizedBox(height: AppSpacingTokens.level3),
              const AppDivider(),
              const SizedBox(height: AppSpacingTokens.level3),
              Text(
                content.footer!,
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
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
