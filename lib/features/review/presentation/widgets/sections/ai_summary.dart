import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// AI 纵向洞察段落：展示 AI 生成的周/月洞察摘要。
///
/// 从旧 `ReviewAiSummarySection` 改名而来，不再硬依赖 `ReviewDashboard`
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
  final ReviewAiSummaryCardState aiState;
  final ReviewAiSummaryRange selectedRange;
  final ValueChanged<ReviewAiSummaryRange>? onRangeChanged;
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
    final typography = context.theme.typography;

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
                        l10n.reviewAiSummaryTitle,
                        style: typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Spacing.level1),
                      Text(
                        content.subtitle,
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                      const SizedBox(height: Spacing.level3),
                      _RangeChipRow(
                        selectedRange: selectedRange,
                        onRangeChanged: onRangeChanged,
                        l10n: l10n,
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
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              const AppDivider(),
            ],
            if (content.lowRiskAction != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
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
              const SizedBox(height: Spacing.level3),
              Text(
                content.disclaimer!,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
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

/// AI 范围切换 chip 行：7 天 / 30 天 / 自定义。
///
/// 旧实现用 FSelectGroup radio hack 模拟单选切换（视觉是带圆点的选项
/// 列表），收敛为 pill chip 行；选中态 primary muted 底 + primary solid
/// 文字，与历史筛选行、建议徽标共用同一套 pill 视觉语言。语义层补充
/// selected 标记，读屏可感知当前选中范围。
class _RangeChipRow extends StatelessWidget {
  const _RangeChipRow({
    required this.selectedRange,
    required this.onRangeChanged,
    required this.l10n,
  });

  final ReviewAiSummaryRange selectedRange;
  final ValueChanged<ReviewAiSummaryRange>? onRangeChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('review-ai-summary-range-toggle'),
      spacing: Spacing.level2,
      runSpacing: Spacing.level2,
      children: [
        for (final (range, label) in <(ReviewAiSummaryRange, String)>[
          (ReviewAiSummaryRange.last7Days, l10n.reviewRangeLast7Days),
          (ReviewAiSummaryRange.last30Days, l10n.reviewRangeLast30Days),
          (ReviewAiSummaryRange.custom, l10n.reviewRangeCustom),
        ])
          _RangeChip(
            label: label,
            selected: range == selectedRange,
            onPress: onRangeChanged == null
                ? null
                : () => onRangeChanged!(range),
          ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.selected, this.onPress});

  final String label;
  final bool selected;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    final tone = selected ? SemanticColor.primary : SemanticColor.neutral;
    return Semantics(
      selected: selected,
      button: true,
      child: FTappable(
        onPress: onPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tone.muted(context),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.level3,
              vertical: Spacing.level2,
            ),
            child: Text(
              label,
              style: context.theme.typography.body.xs.copyWith(
                color: tone.solid(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
