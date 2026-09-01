import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// 骨架屏:镜像 Review 首屏真实段落的形状——事件头卡 + 四段正文卡 +
/// AI 总结卡 + 建议历史卡 + 历史卡。
///
/// 旧版骨架画的是已下线 legacy 报表(指标网格/趋势图/导出卡)的形状,
/// 加载完成时整页换血式跳变;真实内容是单列布局,因此骨架在移动端与
/// 桌面端均为单列。仍不渲染任何假指标、假日期或假 AI 文本。
class ReviewSkeletonView extends StatelessWidget {
  const ReviewSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventHeaderPlaceholder(),
          SizedBox(height: Spacing.level4),
          _SectionCardPlaceholder(),
          SizedBox(height: Spacing.level4),
          _SectionCardPlaceholder(),
          SizedBox(height: Spacing.level4),
          _SectionCardPlaceholder(),
          SizedBox(height: Spacing.level4),
          _SectionCardPlaceholder(),
          SizedBox(height: Spacing.level4),
          _AiSummaryPlaceholder(),
          SizedBox(height: Spacing.level4),
          _SuggestionHistoryPlaceholder(),
          SizedBox(height: Spacing.level4),
          _HistoryPlaceholder(),
        ],
      ),
    );
  }
}

/// 事件头卡:大标题 + 状态 chip / 结束按钮行 + 元信息行 + 主操作按钮。
class _EventHeaderPlaceholder extends StatelessWidget {
  const _EventHeaderPlaceholder();

  @override
  Widget build(BuildContext context) {
    final pillRadius = context.theme.style.borderRadius.pill.topLeft.x;
    return InlineSkeletonSection(
      children: [
        const InlineSkeletonBlock(height: 24, widthFactor: 0.55),
        const SizedBox(height: Spacing.level3),
        Row(
          children: [
            InlineSkeletonBlock(height: 20, width: 64, radius: pillRadius),
            const Spacer(),
            const InlineSkeletonBlock(height: 24, width: 52),
          ],
        ),
        const SizedBox(height: Spacing.level2),
        const InlineSkeletonBlock(height: 12, widthFactor: 0.45),
        const SizedBox(height: Spacing.level2),
        const InlineSkeletonBlock(height: 12, widthFactor: 0.35),
        const SizedBox(height: Spacing.level4),
        InlineSkeletonBlock(
          height: 44,
          radius: context.theme.style.borderRadius.md.topLeft.x,
        ),
      ],
    );
  }
}

/// 四段正文卡:图标 + 标题行,正文为两条「小图标 + 文字」事实行。
class _SectionCardPlaceholder extends StatelessWidget {
  const _SectionCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        Row(
          children: [
            InlineSkeletonCircle(size: 20),
            SizedBox(width: Spacing.level3),
            Expanded(child: InlineSkeletonBlock(height: 14, widthFactor: 0.4)),
          ],
        ),
        SizedBox(height: Spacing.level4),
        Row(
          children: [
            InlineSkeletonCircle(size: 14),
            SizedBox(width: Spacing.level2),
            Expanded(child: InlineSkeletonBlock(height: 12, widthFactor: 0.85)),
          ],
        ),
        SizedBox(height: Spacing.level3),
        Row(
          children: [
            InlineSkeletonCircle(size: 14),
            SizedBox(width: Spacing.level2),
            Expanded(child: InlineSkeletonBlock(height: 12, widthFactor: 0.6)),
          ],
        ),
      ],
    );
  }
}

/// AI 总结卡:头像 + 标题/副标题 + 范围单选行 + 正文行 + 生成按钮。
class _AiSummaryPlaceholder extends StatelessWidget {
  const _AiSummaryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        Row(
          children: [
            InlineSkeletonCircle(size: 32),
            SizedBox(width: Spacing.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InlineSkeletonBlock(height: 14, widthFactor: 0.3),
                  SizedBox(height: Spacing.level2),
                  InlineSkeletonBlock(height: 12, widthFactor: 0.55),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.level4),
        Row(
          children: [
            InlineSkeletonBlock(height: 14, width: 56),
            SizedBox(width: Spacing.level3),
            InlineSkeletonBlock(height: 14, width: 64),
            SizedBox(width: Spacing.level3),
            InlineSkeletonBlock(height: 14, width: 56),
          ],
        ),
        SizedBox(height: Spacing.level4),
        InlineSkeletonBlock(height: 14, widthFactor: 0.92),
        SizedBox(height: Spacing.level3),
        InlineSkeletonBlock(height: 14, widthFactor: 0.84),
        SizedBox(height: Spacing.level3),
        InlineSkeletonBlock(height: 14, widthFactor: 0.68),
        SizedBox(height: Spacing.level4),
        Align(
          alignment: Alignment.centerLeft,
          child: InlineSkeletonBlock(height: 36, width: 120),
        ),
      ],
    );
  }
}

/// 建议历史卡:标题行 + 两条建议 tile(头像 + 两行文案 + 徽标)。
class _SuggestionHistoryPlaceholder extends StatelessWidget {
  const _SuggestionHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const Row(
          children: [
            InlineSkeletonCircle(size: 20),
            SizedBox(width: Spacing.level3),
            Expanded(child: InlineSkeletonBlock(height: 14, widthFactor: 0.4)),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level3),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InlineSkeletonCircle(size: 36),
              SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InlineSkeletonBlock(height: 14, widthFactor: 0.6),
                    SizedBox(height: Spacing.level2),
                    InlineSkeletonBlock(height: 12, widthFactor: 0.85),
                  ],
                ),
              ),
              SizedBox(width: Spacing.level3),
              InlineSkeletonBlock(height: 20, width: 48),
            ],
          ),
        ],
      ],
    );
  }
}

/// 历史卡:标题行 + 筛选 chips + 两条历史行 + 「加载更多」按钮。
class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const Row(
          children: [
            InlineSkeletonCircle(size: 20),
            SizedBox(width: Spacing.level3),
            Expanded(child: InlineSkeletonBlock(height: 14, widthFactor: 0.35)),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        const Row(
          children: [
            InlineSkeletonBlock(height: 28, width: 52),
            SizedBox(width: Spacing.level2),
            InlineSkeletonBlock(height: 28, width: 64),
            SizedBox(width: Spacing.level2),
            InlineSkeletonBlock(height: 28, width: 64),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level3),
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InlineSkeletonBlock(height: 14, widthFactor: 0.5),
                    SizedBox(height: Spacing.level1),
                    InlineSkeletonBlock(height: 12, widthFactor: 0.35),
                  ],
                ),
              ),
              SizedBox(width: Spacing.level3),
              InlineSkeletonBlock(height: 20, width: 48),
            ],
          ),
        ],
        const SizedBox(height: Spacing.level4),
        const Align(
          alignment: Alignment.centerRight,
          child: InlineSkeletonBlock(height: 28, width: 72),
        ),
      ],
    );
  }
}
