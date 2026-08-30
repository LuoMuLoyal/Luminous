import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Review 四段共用的卡片骨架：图标 + 标题 + 内容。
///
/// 与旧 dashboard 的 section 卡片不同，这里不携带任何分数、状态徽标或
/// 锁定逻辑——未知段落只有一段简短的缺失原因说明。
class ReviewSectionCard extends StatelessWidget {
  const ReviewSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: Spacing.level5,
                    color: SemanticColor.primary.solid(context),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    title,
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            child,
          ],
        ),
      ),
    );
  }
}

/// unknown 段落的缺失原因行：中性信息图标 + 简短说明。
///
/// 有意不使用 destructive/warning 色调，也不展示 0 分或「需关注」状态。
class ReviewUnknownReason extends StatelessWidget {
  const ReviewUnknownReason({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          SemanticIcons.statusInfo,
          size: Spacing.level4,
          color: SemanticColor.neutral.solid(context),
        ),
        const SizedBox(width: Spacing.level2),
        Expanded(
          child: Text(
            reason,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// 事实列表的单行条目：小图标 + 文本。
class ReviewFactRow extends StatelessWidget {
  const ReviewFactRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: Spacing.level4,
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(child: Text(text, style: context.theme.typography.body.xs)),
        ],
      ),
    );
  }
}
