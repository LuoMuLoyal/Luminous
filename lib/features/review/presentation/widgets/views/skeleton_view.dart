import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// 骨架屏:镜像 Review 首屏真实段落的形状——周期切换行 + 覆盖率概览行 +
/// 值得注意区 + 单维趋势卡 + 事件回顾卡。
///
/// 旧版骨架画的是已下线 legacy 报表(指标网格/趋势图/导出卡)或 AI 摘要/
/// 建议历史卡的形状,加载完成时整页换血式跳变;真实内容现在是单列布局
/// (周期行 → 概览 → 值得注意 → 趋势 → 事件),骨架据此对齐,不渲染任何
/// 假指标、假日期或假 AI 文本。
class ReviewSkeletonView extends StatelessWidget {
  const ReviewSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodSwitchPlaceholder(),
          SizedBox(height: Spacing.lg),
          _CoverageStripPlaceholder(),
          SizedBox(height: Spacing.lg),
          _NoteworthyPlaceholder(),
          SizedBox(height: Spacing.lg),
          _TrendPlaceholder(),
          SizedBox(height: Spacing.lg),
          _HistoryPlaceholder(),
        ],
      ),
    );
  }
}

/// 周期切换行:周|月 两个 FTabs 的标签形状。
class _PeriodSwitchPlaceholder extends StatelessWidget {
  const _PeriodSwitchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      height: 40,
      children: [
        Row(
          children: [
            InlineSkeletonBlock(height: 14, width: 48, widthFactor: 1),
            SizedBox(width: Spacing.lg),
            InlineSkeletonBlock(height: 14, width: 48, widthFactor: 1),
          ],
        ),
      ],
    );
  }
}

/// 覆盖率概览行:一条横向可滑的维度小卡列表(图标 + 两行文案)。
class _CoverageStripPlaceholder extends StatelessWidget {
  const _CoverageStripPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const InlineSkeletonBlock(height: 14, widthFactor: 0.4),
        const SizedBox(height: Spacing.lg),
        Row(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(width: Spacing.md),
              const Expanded(child: _CoverageCardPlaceholder()),
            ],
          ],
        ),
      ],
    );
  }
}

/// 覆盖率概览的单张维度小卡:图标 + 标题 + 两行数值。
class _CoverageCardPlaceholder extends StatelessWidget {
  const _CoverageCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InlineSkeletonCircle(size: 20),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: InlineSkeletonBlock(height: 14, widthFactor: 0.8),
              ),
            ],
          ),
          SizedBox(height: Spacing.lg),
          InlineSkeletonBlock(height: 12, widthFactor: 0.6),
          SizedBox(height: Spacing.sm),
          InlineSkeletonBlock(height: 16, widthFactor: 0.4),
        ],
      ),
    );
  }
}

/// 值得注意区:标题行 + 一张结构化洞察卡的形状。
class _NoteworthyPlaceholder extends StatelessWidget {
  const _NoteworthyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        InlineSkeletonBlock(height: 14, widthFactor: 0.35),
        SizedBox(height: Spacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InlineSkeletonCircle(size: 24),
            SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InlineSkeletonBlock(height: 14, widthFactor: 0.5),
                  SizedBox(height: Spacing.md),
                  InlineSkeletonBlock(height: 12, widthFactor: 1.0),
                  SizedBox(height: Spacing.sm),
                  InlineSkeletonBlock(height: 12, widthFactor: 0.8),
                  SizedBox(height: Spacing.lg),
                  InlineSkeletonBlock(height: 11, widthFactor: 0.4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 单维趋势卡:折线图主体 + 底部覆盖率说明行。
class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        Row(
          children: [
            InlineSkeletonCircle(size: 20),
            SizedBox(width: Spacing.md),
            Expanded(child: InlineSkeletonBlock(height: 14, widthFactor: 0.4)),
            InlineSkeletonBlock(height: 20, width: 48),
          ],
        ),
        SizedBox(height: Spacing.lg),
        InlineSkeletonBlock(height: 180, widthFactor: 1.0),
        SizedBox(height: Spacing.lg),
        InlineSkeletonBlock(height: 12, widthFactor: 0.6),
      ],
    );
  }
}

/// 事件回顾卡:标题行 + 两条事件行 + 「加载更多」按钮。
class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const Row(
          children: [
            InlineSkeletonCircle(size: 20),
            SizedBox(width: Spacing.md),
            Expanded(child: InlineSkeletonBlock(height: 14, widthFactor: 0.35)),
          ],
        ),
        const SizedBox(height: Spacing.md),
        const Row(
          children: [
            InlineSkeletonBlock(height: 28, width: 52),
            SizedBox(width: Spacing.sm),
            InlineSkeletonBlock(height: 28, width: 64),
            SizedBox(width: Spacing.sm),
            InlineSkeletonBlock(height: 28, width: 64),
          ],
        ),
        const SizedBox(height: Spacing.md),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.md),
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InlineSkeletonBlock(height: 14, widthFactor: 0.5),
                    SizedBox(height: Spacing.xs),
                    InlineSkeletonBlock(height: 12, widthFactor: 0.35),
                  ],
                ),
              ),
              SizedBox(width: Spacing.md),
              InlineSkeletonBlock(height: 20, width: 48),
            ],
          ),
        ],
        const SizedBox(height: Spacing.lg),
        const Align(
          alignment: Alignment.centerRight,
          child: InlineSkeletonBlock(height: 28, width: 72),
        ),
      ],
    );
  }
}
