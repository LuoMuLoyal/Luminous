import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';

/// 无事件/未登录时的「开始观察后这里会呈现什么」聚合预告卡。
///
/// 原先是 5 张独立预告卡(每张只是图标 + 标题 + 一句说明),空态页面被
/// 拉得很长、稀释主 CTA(开始健康观察);现收敛为单张卡片内的要点列表,
/// 条目文案复用各 section 的既有 l10n 字符串。
class ReviewPreviewOverviewSection extends StatelessWidget {
  const ReviewPreviewOverviewSection({super.key, required this.items});

  /// (图标, 标题, 说明) 三元组,由调用方用各 section 的既有文案组装。
  final List<(IconData, String, String)> items;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, item) in items.indexed) ...[
              if (index > 0) ...[
                const SizedBox(height: Spacing.level3),
                const AppDivider(),
                const SizedBox(height: Spacing.level3),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      item.$1,
                      color: SemanticColor.primary.solid(context),
                      size: Spacing.level5,
                    ),
                  ),
                  const SizedBox(width: Spacing.level3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Spacing.level1),
                        Text(
                          item.$3,
                          style: typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 单条预告锁定卡:legacy 报表预览(dashboard_preview.dart)仍在使用;
/// Review 主路径的空态已改用上方 [ReviewPreviewOverviewSection] 聚合卡。
class ReviewPreviewLockedSection extends StatelessWidget {
  const ReviewPreviewLockedSection({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: SemanticColor.primary.solid(context),
              size: Spacing.level5,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    body,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
