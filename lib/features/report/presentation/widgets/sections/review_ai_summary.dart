import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// AI 纵向洞察段落：展示 AI 生成的周/月洞察摘要。
///
/// 从旧 `ReportAiSummarySection` 改名而来，不再硬依赖 `ReportDashboard`
/// 实体——只接收 `aiSummaryEnabled` 布尔值即可，适配 Review 主路径。
class ReviewAiSummarySection extends StatelessWidget {
  const ReviewAiSummarySection({
    super.key,
    required this.aiSummaryEnabled,
    required this.canAccessProtectedData,
    required this.aiState,
    required this.selectedRange,
    this.onRangeChanged,
    this.onGenerate,
    required this.l10n,
  });

  final bool aiSummaryEnabled;
  final bool canAccessProtectedData;
  final ReportAiSummaryCardState aiState;
  final ReportAiSummaryRange selectedRange;
  final ValueChanged<ReportAiSummaryRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final content = buildReviewAiSummaryContent(
      l10n: l10n,
      aiSummaryEnabled: aiSummaryEnabled,
      canAccessProtectedData: canAccessProtectedData,
      aiState: aiState,
      selectedRange: selectedRange,
      colors: colors,
    );

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
                            key: const Key('review-ai-summary-range-toggle'),
                            control: onRangeChanged == null
                                ? FMultiValueControl.lifted(
                                    value: {selectedRange},
                                    onChange: (_) {},
                                  )
                                : FMultiValueControl.lifted(
                                    value: {selectedRange},
                                    onChange: (selection) {
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
                  styleSheet: MarkdownStyle.ai(
                    context,
                    paragraphWeight: FontWeight.w700,
                  ),
                ),
              ),
              const AppDivider(),
            ],
            if (content.observedPattern != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
                child: Text(
                  content.observedPattern!,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
              const AppDivider(),
            ],
            if (content.lowRiskAction != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
                child: Text(
                  content.lowRiskAction!,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
              const AppDivider(),
            ],
            if (content.disclaimer != null) ...[
              const SizedBox(height: Spacing.level3),
              Text(
                content.disclaimer!,
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
                  key: const Key('review-ai-summary-generate-action'),
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
}
