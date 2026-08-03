import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';

import 'radius.dart';
import 'spacing.dart';
import 'typography.dart';

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
  /// 正文字号 level4 (16px)、行高 1.7；h1/h2/h3 依次递减并带段落间距；
  /// 引用为中性 `colors.border` 左条 + muted 文字。
  static MarkdownStyleSheet legal(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final colors = context.theme.colors;
    return base.copyWith(
      p: TypographyToken.level4.body(context).copyWith(height: 1.7),
      h1: TypographyToken.level7
          .body(context)
          .copyWith(fontWeight: FontWeight.w700),
      h2: TypographyToken.level6
          .body(context)
          .copyWith(fontWeight: FontWeight.w600),
      h3: TypographyToken.level5
          .body(context)
          .copyWith(fontWeight: FontWeight.w600),
      h1Padding: const EdgeInsets.only(top: Spacing.level6),
      h2Padding: const EdgeInsets.only(top: Spacing.level5),
      h3Padding: const EdgeInsets.only(top: Spacing.level4),
      blockquote: TypographyToken.level4
          .body(context)
          .copyWith(color: colors.mutedForeground),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.border, width: 4)),
      ),
      blockquotePadding: const EdgeInsets.only(left: Spacing.level3),
      code: TypographyToken.level3
          .body(context)
          .copyWith(
            fontFamily: 'monospace',
            color: colors.foreground,
            backgroundColor: colors.secondary,
          ),
      codeblockPadding: const EdgeInsets.all(Spacing.level3),
      codeblockDecoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: colors.border),
      ),
      a: TypographyToken.level4
          .body(context)
          .copyWith(
            color: colors.primary,
            decoration: TextDecoration.underline,
          ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      tableBorder: TableBorder.all(color: colors.border),
      tableHead: TypographyToken.level4
          .body(context)
          .copyWith(fontWeight: FontWeight.w600),
      tableHeadCellsDecoration: BoxDecoration(color: colors.secondary),
      tableBody: TypographyToken.level4.body(context),
      tableCellsPadding: const EdgeInsets.all(Spacing.level2),
    );
  }

  /// AI 生成内容（对话 / 摘要 / 建议 / 报告总结）：紧凑、primary 强调、气泡背景感知。
  ///
  /// [background] 传入气泡/容器背景色，用于代码、引用在浅色容器上的对比度适配。
  /// [paragraphWeight] 可覆盖正文字重（如摘要 w600、报告总结 w700）。
  /// [emphasizeLinks] 为 `true` 时链接加粗（w600）。
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
      p: TypographyToken.level4
          .body(context)
          .copyWith(height: 1.6, fontWeight: paragraphWeight),
      h1: TypographyToken.level6
          .body(context)
          .copyWith(fontWeight: FontWeight.w700),
      h2: TypographyToken.level5
          .body(context)
          .copyWith(fontWeight: FontWeight.w600),
      h3: TypographyToken.level4
          .body(context)
          .copyWith(fontWeight: FontWeight.w600),
      h1Padding: const EdgeInsets.only(top: Spacing.level5),
      h2Padding: const EdgeInsets.only(top: Spacing.level4),
      h3Padding: const EdgeInsets.only(top: Spacing.level3),
      blockquote: TypographyToken.level4
          .body(context)
          .copyWith(color: colors.mutedForeground),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.primary, width: 4)),
      ),
      blockquotePadding: const EdgeInsets.only(left: Spacing.level3),
      listBullet: TypographyToken.level4
          .body(context)
          .copyWith(color: colors.primary),
      code: TypographyToken.level3
          .body(context)
          .copyWith(
            fontFamily: 'monospace',
            color: colors.foreground,
            backgroundColor: codeBg,
          ),
      codeblockPadding: const EdgeInsets.all(Spacing.level3),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: colors.border),
      ),
      a: TypographyToken.level4
          .body(context)
          .copyWith(
            color: colors.primary,
            decoration: TextDecoration.underline,
            fontWeight: emphasizeLinks ? FontWeight.w600 : null,
          ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      tableBorder: TableBorder.all(color: colors.border),
      tableHead: TypographyToken.level4
          .body(context)
          .copyWith(fontWeight: FontWeight.w600),
      tableHeadCellsDecoration: BoxDecoration(color: colors.secondary),
      tableBody: TypographyToken.level4.body(context),
      tableCellsPadding: const EdgeInsets.all(Spacing.level2),
    );
  }
}
