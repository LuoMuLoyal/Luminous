import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';

/// 认证页标准滚动骨架：`SingleChildScrollView → ResponsiveContentFrame →
/// 垂直 padding（宽屏 xl3 / 窄屏 xl2）→ `Column`。
///
/// 统一包装 6 个认证子页的共同结构，每页减 ~6 行样板代码。这是**行为组合**
/// 而非样式 preset：各页内部自行决定 Column 的 children，AuthScrollBody 只
/// 负责外层的滚动 + 响应式内宽 + 垂直留白。
class AuthScrollBody extends StatelessWidget {
  const AuthScrollBody({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  /// Column 的 children（各认证页的表单/卡片内容）。
  final List<Widget> children;

  /// Column 的主轴对齐方式，默认 `start`。
  final MainAxisAlignment mainAxisAlignment;

  /// Column 的交叉轴对齐方式，默认 `stretch`（表单字段拉满宽度）。
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      child: ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
          ),
          child: Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}
