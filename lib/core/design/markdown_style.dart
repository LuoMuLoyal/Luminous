import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';

import 'semantic_color.dart';
import 'spacing.dart';

/// 统一 Markdown 渲染样式的唯一入口。
///
/// 提供两套预置的 [MarkdownStyleSheet]：
/// - [legal]：正式文档（法律文书 / FAQ），宽松行距、强标题层级、中性引用。
/// - [ai]：AI 生成内容（对话 / 摘要 / 建议 / 报告总结），紧凑、primary 强调、
///   气泡背景感知。
///
/// 6 处 Markdown 渲染点均应从本工厂取样式，避免各点本地 `copyWith` 漂移。
abstract final class MarkdownStyle {
  /// 正式文档（法律文书 / FAQ）：宽松行距、强标题层级、中性引用。
  ///
  /// 正文字号 sm (16px)、行高 1.7；h1/h2/h3 依次递减并带段落间距；
  /// 引用为中性 `SemanticColor.neutral.border` 左条 + `SemanticColor.neutral.solid` 文字。
  static MarkdownStyleSheet legal(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final colors = context.theme.colors;
    return base.copyWith(
      p: context.theme.typography.body.sm.copyWith(height: 1.7),
      h1: context.theme.typography.body.xl.copyWith(
        fontWeight: FontWeight.w700,
      ),
      h2: context.theme.typography.body.lg.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h3: context.theme.typography.body.md.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h1Padding: const EdgeInsets.only(top: Spacing.level6),
      h2Padding: const EdgeInsets.only(top: Spacing.level5),
      h3Padding: const EdgeInsets.only(top: Spacing.level4),
      blockquote: context.theme.typography.body.sm.copyWith(
        color: SemanticColor.neutral.solid(context),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: SemanticColor.neutral.border(context),
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: Spacing.level3),
      code: context.theme.typography.body.xs.copyWith(
        fontFamily: 'monospace',
        color: colors.foreground,
        backgroundColor: colors.secondary,
      ),
      codeblockPadding: const EdgeInsets.all(Spacing.level3),
      codeblockDecoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      a: context.theme.typography.body.sm.copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: SemanticColor.neutral.border(context)),
        ),
      ),
      tableBorder: TableBorder.all(
        color: SemanticColor.neutral.border(context),
      ),
      tableHead: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
      ),
      tableHeadCellsDecoration: BoxDecoration(color: colors.secondary),
      tableBody: context.theme.typography.body.sm,
      tableCellsPadding: const EdgeInsets.all(Spacing.level2),
    );
  }

  /// AI 生成内容（对话 / 摘要 / 建议 / 报告总结）：紧凑、primary 强调、气泡背景感知。
  ///
  /// [background] 传入气泡/容器背景色，用于代码、引用在浅色容器上的对比度适配。
  /// [paragraphWeight] 可覆盖正文字重（如摘要 w600、报告总结 w700）。
  /// [emphasizeLinks] 为 `true` 时链接加粗（w600）。
  ///
  /// F-4 视觉模板（2026-08-17 扩展）：
  /// - h1-h6 完整字号阶梯：h1→lg、h2→md、h3→sm（同正文、加粗区分），
  ///   h4→xs、h5→xs2、h6→xs2（h6 再降一档字重收尾）。
  /// - 列表缩进走 `Spacing` token（level5=20/级），bullet 与文字间距 level2=6。
  /// - 表格列宽 `IntrinsicColumnWidth`：flutter_markdown_plus 检测到该列宽类型时
  ///   自动把表格包进横向 `SingleChildScrollView`，窄屏可横向滚动而不是挤压列。
  /// - 引用块 primary 4px 左侧色条 + primary subtle 底色。
  /// - 代码块保持库默认的横向滚动（库把 `pre` 硬编码为横向 ScrollView，样式表无
  ///   折行开关；折行会破坏代码缩进，故不硬造自定义 builder，记为限制）。
  static MarkdownStyleSheet ai(
    BuildContext context, {
    Color? background,
    FontWeight? paragraphWeight,
    bool emphasizeLinks = false,
  }) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final colors = context.theme.colors;
    final codeBg = background ?? colors.secondary;
    return base.copyWith(
      p: context.theme.typography.body.sm.copyWith(
        height: 1.6,
        fontWeight: paragraphWeight,
      ),
      h1: context.theme.typography.body.lg.copyWith(
        fontWeight: FontWeight.w700,
      ),
      h2: context.theme.typography.body.md.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h3: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h4: context.theme.typography.body.xs.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h5: context.theme.typography.body.xs2.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h6: context.theme.typography.body.xs2.copyWith(
        fontWeight: FontWeight.w500,
      ),
      h1Padding: const EdgeInsets.only(top: Spacing.level5),
      h2Padding: const EdgeInsets.only(top: Spacing.level4),
      h3Padding: const EdgeInsets.only(top: Spacing.level3),
      h4Padding: const EdgeInsets.only(top: Spacing.level3),
      h5Padding: const EdgeInsets.only(top: Spacing.level2),
      h6Padding: const EdgeInsets.only(top: Spacing.level2),
      blockquote: context.theme.typography.body.sm.copyWith(
        color: SemanticColor.neutral.solid(context),
      ),
      // 引用块：primary 4px 左侧色条 + primary subtle 底色（大容器/空态级极浅色调，
      // 深浅色自动适配）。带底色后四边都需要 padding，不再只留左侧。
      blockquoteDecoration: BoxDecoration(
        color: SemanticColor.primary.subtle(context),
        border: Border(left: BorderSide(color: colors.primary, width: 4)),
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(
        Spacing.level3,
        Spacing.level2,
        Spacing.level3,
        Spacing.level2,
      ),
      listBullet: context.theme.typography.body.sm.copyWith(
        color: colors.primary,
      ),
      listIndent: Spacing.level5,
      listBulletPadding: const EdgeInsets.only(right: Spacing.level2),
      code: context.theme.typography.body.xs.copyWith(
        fontFamily: 'monospace',
        color: colors.foreground,
        backgroundColor: codeBg,
      ),
      codeblockPadding: const EdgeInsets.all(Spacing.level3),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      a: context.theme.typography.body.sm.copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
        fontWeight: emphasizeLinks ? FontWeight.w600 : null,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: SemanticColor.neutral.border(context)),
        ),
      ),
      tableBorder: TableBorder.all(
        color: SemanticColor.neutral.border(context),
      ),
      // IntrinsicColumnWidth 触发库内置的横向滚动容器（见上方 doc 注释）。
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableHead: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
      ),
      tableHeadCellsDecoration: BoxDecoration(color: colors.secondary),
      tableBody: context.theme.typography.body.sm,
      tableCellsPadding: const EdgeInsets.all(Spacing.level2),
    );
  }
}
