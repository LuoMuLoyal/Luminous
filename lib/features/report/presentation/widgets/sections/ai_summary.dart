import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/action_route_mapper.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
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

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FAvatar.raw(
                  size: Spacing.level8,
                  child: Icon(
                    SemanticIcons.aiEntry,
                    color: SemanticColor.primary.solid(context),
                    size: Spacing.level5,
                  ),
                ),
                const SizedBox(width: Spacing.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reportAiSummaryTitle,
                        style: TypographyToken.level5
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: Spacing.level1),
                      Text(
                        content.subtitle,
                        style: TypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                      const SizedBox(height: Spacing.level3),
                      Wrap(
                        spacing: Spacing.level3,
                        runSpacing: Spacing.level3,
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
                                      // FMultiValueControl.lifted 的 _ProxyNotifier
                                      // 在点击新选项时将新值添加到集合中而不移除旧值，
                                      // 因此 selection.first 可能返回旧值。过滤出
                                      // 与当前 selectedRange 不同的值即为新选中项。
                                      final next = selection
                                          .where((v) => v != selectedRange)
                                          .firstOrNull;
                                      if (next != null) {
                                        onRangeChanged!(next);
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
            const SizedBox(height: Spacing.level4),
            const AppDivider(),
            if (content.summaryText != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: Spacing.level3,
                  bottom: Spacing.level3,
                ),
                child: MarkdownBody(
                  data: content.summaryText!,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: TypographyToken.level4
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                ),
              ),
              const AppDivider(),
            ],
            for (var index = 0; index < content.bullets.length; index += 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.level2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: content.bullets[index].color.solid(context),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(dimension: Spacing.level2),
                      ),
                    ),
                    const SizedBox(width: Spacing.level3),
                    Expanded(
                      child: SkeletonText(
                        text: content.bullets[index].text,
                        style: TypographyToken.level3
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
              const SizedBox(height: Spacing.level3),
              const AppDivider(),
              const SizedBox(height: Spacing.level3),
              Text(
                content.footer!,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
            if (content.showGenerateButton) ...[
              const SizedBox(height: Spacing.level4),
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
                        ? SemanticIcons.aiAnalyzing
                        : SemanticIcons.aiEntry,
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
