import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// AI 纵向洞察段落：展示 AI 生成的周/月洞察摘要。
///
/// 从旧 `ReviewDigestSection` 改名而来，不再硬依赖 `ReviewDashboard`
/// 实体——只接收 `digestEnabled` 布尔值即可。
///
/// Deferred by Review Page Restructure P0-7: 建议历史与 AI 摘要已从 Review
/// 主路径下线，本 section 目前仅被 legacy dashboard 兼容页消费。不删除——
/// capability 仍有价值，待 agentic P0-3 统一 AI 数据层后复核是否归档/启用。
class ReviewDigestSection extends StatelessWidget {
  const ReviewDigestSection({
    super.key,
    required this.digestEnabled,
    required this.canAccessProtectedData,
    required this.briefingState,
    required this.selectedRange,
    this.onRangeChanged,
    this.onGenerate,
    required this.l10n,
  });

  final bool digestEnabled;
  final bool canAccessProtectedData;
  final ReviewDigestCardState briefingState;
  final ReviewDigestRange selectedRange;
  final ValueChanged<ReviewDigestRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final content = buildReviewDigestContent(
      l10n: l10n,
      digestEnabled: digestEnabled,
      canAccessProtectedData: canAccessProtectedData,
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
                  SemanticIcons.assistantEntry,
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
                  key: const Key('review-ai-summary-generate-action'),
                  onPress: briefingState.isLoading || onGenerate == null
                      ? null
                      : () async {
                          await onGenerate!();
                        },
                  prefix: Icon(
                    briefingState.isLoading
                        ? SemanticIcons.briefingAnalyzing
                        : SemanticIcons.assistantEntry,
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

  final ReviewDigestRange selectedRange;
  final ValueChanged<ReviewDigestRange>? onRangeChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('review-ai-summary-range-toggle'),
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final (range, label) in <(ReviewDigestRange, String)>[
          (ReviewDigestRange.last7Days, l10n.reviewRangeLast7Days),
          (ReviewDigestRange.last30Days, l10n.reviewRangeLast30Days),
          (ReviewDigestRange.custom, l10n.reviewRangeCustom),
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
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs.copyWith(
                color: tone.solid(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
