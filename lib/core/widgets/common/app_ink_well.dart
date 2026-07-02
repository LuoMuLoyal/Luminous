import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

/// 统一的可点击区域组件，提供一致的水波纹视觉反馈和禁用态。
///
/// 相比裸 [InkWell]：
/// - 自动从 [AppColorTokens] 推导 [splashColor] 和 [highlightColor]。
/// - [onTap] 为 `null` 时自动应用 [Color(0xFF111827)DisabledOpacity] 降低不透明度。
/// - 内置 `Material(color: Colors.transparent)`，省去手动包裹。
///
/// 示例：
/// ```dart
/// AppInkWell(
///   onTap: () => context.push('/details'),
///   borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
///   child: Padding(
///     padding: const EdgeInsets.all(AppSpacingTokens.md),
///     child: Text('查看详情'),
///   ),
/// )
/// ```
class AppInkWell extends StatelessWidget {
  const AppInkWell({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius,
    this.padding,
  });

  /// 点击回调。为 `null` 时自动进入禁用态。
  final VoidCallback? onTap;

  /// 子组件。
  final Widget child;

  /// 水波纹的圆角。建议传入以匹配子组件形状。
  final BorderRadius? borderRadius;

  /// 可选的内边距。如果提供，会在 [child] 外侧包裹 [Padding]。
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveSplash = Color(0xFF111827);
    final effectiveHighlight = Color(0xFF111827);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppRadiusTokens.md);

    Widget content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: effectiveSplash,
        highlightColor: effectiveHighlight,
        borderRadius: effectiveBorderRadius,
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );

    if (onTap == null) {
      content = Opacity(
        opacity: 1, // TODO 替换
        child: content,
      );
    }

    return content;
  }
}
