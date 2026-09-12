import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewAiSummarySection extends StatelessWidget {
  const ReviewAiSummarySection({
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

  final ReviewDashboard dashboard;
  final bool canAccessProtectedData;
  final bool? aiSummariesEnabled;
  final ReviewAiSummaryCardState aiState;
  final ReviewAiSummaryRange selectedRange;
  final ValueChanged<ReviewAiSummaryRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final content = buildReviewAiSummaryContentFromDashboard(
      l10n: l10n,
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      aiState: aiState,
      selectedRange: selectedRange,
      colors: colors,
    );
    final typography = context.theme.typography;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FAvatar.raw(
                  size: Spacing.xl4,
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: SemanticIconSvg.aiEntry(
                      size: Spacing.xl,
                      color: SemanticColor.primary.solid(context),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reviewAiSummaryTitle,
                        style: typography.body.md.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        content.subtitle,
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Wrap(
                        spacing: Spacing.md,
                        runSpacing: Spacing.md,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FSelectGroup<ReviewAiSummaryRange>(
                            key: const Key('report-ai-summary-range-toggle'),
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
                                value: ReviewAiSummaryRange.last7Days,
                                label: Text(l10n.reviewRangeLast7Days),
                              ),
                              FSelectGroupItemMixin.radio(
                                value: ReviewAiSummaryRange.last30Days,
                                label: Text(l10n.reviewRangeLast30Days),
                              ),
                              FSelectGroupItemMixin.radio(
                                value: ReviewAiSummaryRange.custom,
                                label: Text(l10n.reviewRangeCustom),
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
            const SizedBox(height: Spacing.lg),
            const AppDivider(),
            if (content.summaryText != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: Spacing.md,
                  bottom: Spacing.md,
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
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                child: Text(
                  content.observedPattern!,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              const AppDivider(),
            ],
            if (content.lowRiskAction != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                child: Text(
                  content.lowRiskAction!,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              const AppDivider(),
            ],
            if (content.disclaimer != null) ...[
              const SizedBox(height: Spacing.md),
              Text(
                content.disclaimer!,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (content.showGenerateButton) ...[
              const SizedBox(height: Spacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  key: const Key('report-ai-summary-generate-action'),
                  onPress: aiState.isLoading || onGenerate == null
                      ? null
                      : () async {
                          await onGenerate!();
                        },
                  prefix: aiState.isLoading
                      ? SemanticIconSvg.aiAnalyzing(size: 16)
                      : SemanticIconSvg.aiEntry(size: 16),
                  child: Text(
                    aiState.isLoading
                        ? reviewAiSummaryGeneratingLabel(l10n, selectedRange)
                        : l10n.reviewGenerateAction,
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
