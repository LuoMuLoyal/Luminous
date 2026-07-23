import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// Responsive content container.
///
/// - On desktop (width >= [Breakpoints.desktop]) constrains content max width to
///   [LayoutScaleResolver.maxContentWidth].
/// - Applies horizontal page padding [LayoutScaleResolver.pageHorizontalPadding] by default.
/// - Use [padding] to fully override default padding; use [expand] to fill available space.
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
    final layout = LayoutScaleResolver.resolve(width);

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Constrain content from tablet onwards to prevent full-width
          // stretching on mid-tier screens (600–1200). Mobile (< 960) stays
          // unconstrained for natural edge-to-edge layouts.
          maxWidth: width >= Breakpoints.tablet
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
