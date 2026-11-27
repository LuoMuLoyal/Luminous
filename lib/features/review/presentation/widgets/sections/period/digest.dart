import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class ReviewPeriodDigestSection extends StatelessWidget {
  const ReviewPeriodDigestSection({
    super.key,
    required this.dashboard,
    required this.canAccessProtectedData,
    required this.digestEnabled,
    required this.briefingState,
    required this.selectedRange,
    this.onRangeChanged,
    this.onGenerate,
    required this.l10n,
  });

  final ReviewDashboard dashboard;
  final bool canAccessProtectedData;
  final bool? digestEnabled;
  final ReviewDigestCardState briefingState;
  final ReviewDigestRange selectedRange;
  final ValueChanged<ReviewDigestRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final content = buildReviewDigestContentFromDashboard(
      l10n: l10n,
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      digestEnabled: digestEnabled,
      briefingState: briefingState,
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
                Icon(
                  SemanticIcons.briefingGenerated,
                  color: SemanticColor.primary.solid(context),
                  size: IconSizeTokens.lg,
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reviewDigestSummaryTitle,
                        style: typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
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
                          FSelectGroup<ReviewDigestRange>(
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
                                value: ReviewDigestRange.last7Days,
                                label: Text(l10n.reviewRangeLast7Days),
                              ),
                              FSelectGroupItemMixin.radio(
                                value: ReviewDigestRange.last30Days,
                                label: Text(l10n.reviewRangeLast30Days),
                              ),
                              FSelectGroupItemMixin.radio(
                                value: ReviewDigestRange.custom,
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
                  styleSheet: MarkdownStyle.assistantGenerated(
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
                  onPress: briefingState.isLoading || onGenerate == null
                      ? null
                      : () async {
                          await onGenerate!();
                        },
                  prefix: Icon(
                    briefingState.isLoading
                        ? SemanticIcons.briefingAnalyzing
                        : SemanticIcons.briefingGenerate,
                    size: 16,
                  ),
                  child: Text(
                    briefingState.isLoading
                        ? reviewDigestSummaryGeneratingLabel(
                            l10n,
                            selectedRange,
                          )
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
