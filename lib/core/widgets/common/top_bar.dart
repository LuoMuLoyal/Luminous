import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';

/// Tab 根页面统一的顶部标题栏。
///
/// 与 [PageScaffold] 不同，本组件不依赖 [FScaffold.header]，而是直接嵌入 Tab 页 body
/// 顶部使用，因此自带水平内边距与 [SafeArea]。
///
/// 视觉规范：
/// - 标题使用 [TypographyToken.level8] display + [FontWeight.w800]。
/// - 可选副标题使用 [TypographyToken.level4] body + muted foreground。
/// - trailing 操作按钮横向排列，与标题之间保持 [Spacing.level4]。
/// - header 与 body 共享同一背景，不额外添加底部分割线或背景色。
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing = const [],
    this.bottom,
  });

  /// 主标题。
  final String title;

  /// 副标题，位于主标题下方。
  final Widget? subtitle;

  /// 右侧操作按钮列表。
  final List<Widget> trailing;

  /// 标题行下方的额外内容（如报告页的日期选择器 + 操作按钮区）。
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final layout = LayoutScaleResolver.resolve(
      MediaQuery.sizeOf(context).width,
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: layout.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TypographyToken.level8
                            .display(context)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: Spacing.level1),
                        DefaultTextStyle.merge(
                          style: TypographyToken.level4
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing.isNotEmpty) ...[
                  const SizedBox(width: Spacing.level4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _spacedTrailing(),
                  ),
                ],
              ],
            ),
            if (bottom != null) ...[
              const SizedBox(height: Spacing.level3),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _spacedTrailing() {
    if (trailing.length <= 1) return trailing;

    final result = <Widget>[trailing.first];
    for (var i = 1; i < trailing.length; i++) {
      result
        ..add(const SizedBox(width: Spacing.level2))
        ..add(trailing[i]);
    }
    return result;
  }
}
