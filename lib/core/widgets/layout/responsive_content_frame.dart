import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// 响应式内容容器。
///
/// - 在桌面端（宽度 >= [AppBreakpoints.desktop]）限制内容最大宽度为
///   [AppLayoutTokens.maxContentWidth]。
/// - 默认应用水平方向页面内边距 [AppLayoutTokens.pageHorizontalPadding]。
/// - 通过 [padding] 可完全覆盖默认内边距；通过 [expand] 可让内容撑满可用空间。
class ResponsiveContentFrame extends StatelessWidget {
  const ResponsiveContentFrame({
    super.key,
    required this.child,
    this.expand = false,
    this.padding,
  });

  final Widget child;

  /// 是否让居中内容撑满可用空间。
  final bool expand;

  /// 覆盖默认水平内边距。为 `null` 时使用 token 驱动的水平内边距。
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width >= AppBreakpoints.desktop
              ? layout.maxContentWidth
              : double.infinity,
        ),
        child: child,
      ),
    );

    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: layout.pageHorizontalPadding),
      child: expand ? SizedBox.expand(child: content) : content,
    );
  }
}
