import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Source badge widget displaying 'cn' or 'drugbank' label.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source, required this.l10n});

  final String source;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          borderRadius: context.theme.style.borderRadius.xs,
        ),
      ),
      child: Text(
        source == 'drugbank'
            ? l10n.medicineSearchSourceDrugbank
            : l10n.medicineSearchSourceCn,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Reference notice: muted info text with an info icon.
///
/// 不再用满宽的浅底圆角色块。那是一个「容器」，在一张整页平铺（无卡片）的
/// 说明书页里，它是唯一还带底的元素，反而比正文更抢眼。改成图标 + 弱化文字
/// 的一行说明：信息层级靠字色表达，不靠底色。
class ReferenceNotice extends StatelessWidget {
  const ReferenceNotice({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _MetaLine(
      icon: SemanticIcons.statusBanner,
      color: SemanticColor.neutral.solid(context),
      text: l10n.medicineReferenceNoticeTitle,
      textColor: SemanticColor.neutral.solid(context),
    );
  }
}

/// 元信息行（声明 / 风险入口共用）的排版骨架。
///
/// 图标放进等宽槽位、文字基线对齐：这两行紧挨着出现，若各自按图标尺寸排版，
/// 缩进会差几个像素，读起来像两段没对齐的残片。
class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.color,
    required this.text,
    required this.textColor,
    this.trailing,
    this.onTap,
    this.weight,
  });

  final IconData icon;
  final Color color;
  final String text;
  final Color textColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 固定槽位：icon 尺寸不管怎么变，文字起点都停在同一列。
        SizedBox.square(
          dimension: IconSizeTokens.lg,
          child: Center(
            child: Icon(icon, size: IconSizeTokens.md, color: color),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.theme.typography.body.sm.copyWith(
              color: textColor,
              fontWeight: weight,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (onTap == null) return row;
    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: row,
      ),
    );
  }
}

/// Risk check entry widget with navigation arrow.
class RiskCheckEntry extends StatelessWidget {
  const RiskCheckEntry({super.key, required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _MetaLine(
      icon: SemanticIcons.safetyCaution,
      color: SemanticColor.primary.solid(context),
      text: l10n.medicineDetailRiskCheckEntry,
      textColor: context.theme.colors.foreground,
      weight: FontWeight.w500,
      onTap: onTap,
      trailing: Icon(
        SemanticIcons.actionNext,
        size: IconSizeTokens.md,
        color: SemanticColor.neutral.solid(context),
      ),
    );
  }
}
