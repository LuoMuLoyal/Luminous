import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart' as genui;
import 'package:luminous/core/design/design.dart';

/// 渲染一个已生成的 surface。
///
/// 这是 `genui` 的 `Surface` widget 在本仓的**唯一出口**：`genui` 的 `Surface`
/// 与 Material 的 `Surface` 同名，直接 `import` 会让调用方两边打架；而 feature
/// 的 `presentation/` 本来就不该 import `genui`。所以把它包一层、换个名字再出去。
///
/// 调用方只负责「有没有 surfaceContext」这一个判断——三态（不渲染 / 骨架 /
/// 渲染）的语义在 `GenerativeSurface` 里，这里不做重复。
class GenerativeSurfaceRenderer extends StatelessWidget {
  const GenerativeSurfaceRenderer({super.key, required this.surfaceContext});

  /// 从 `GenerativeTransport.contextFor(surfaceId)` 取得。
  final genui.SurfaceContext? surfaceContext;

  @override
  Widget build(BuildContext context) {
    final surface = surfaceContext;
    if (surface == null) {
      return const _GenerativeEmpty();
    }
    return _GenerativeErrorBoundary(
      child: genui.Surface(surfaceContext: surface),
    );
  }
}

class _GenerativeEmpty extends StatelessWidget {
  const _GenerativeEmpty();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 把渲染期异常收成一个安静的错误态。
///
/// A2UI 树来自模型，形状不可信；一棵坏的树不应该让整页崩掉。
///
/// **边界在 widget 树层面是尽力而为**：Flutter 的 `build` 异常会被框架自己
/// 报告给 `FlutterError.onError`，`try/catch` 包不住子树的 `build`。真正兜底的
/// 是 `genui` 自己的 `FallbackWidget`（它对每个组件单独 try/catch）。这个边界
/// 负责的是**本组件自己的**渲染路径，以及之后 `reportError` 回调带来的异常。
///
/// 错误文案走 ARB：这里是 `core/`，不能 import feature 的 l10n，所以由调用方
/// 通过 [errorBuilder] 注入；没有注入时不显示文字，只留一个可断言的占位。
class _GenerativeErrorBoundary extends StatefulWidget {
  const _GenerativeErrorBoundary({required this.child});

  final Widget child;

  @override
  State<_GenerativeErrorBoundary> createState() =>
      _GenerativeErrorBoundaryState();
}

class _GenerativeErrorBoundaryState extends State<_GenerativeErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Padding(
        key: const Key('generative-surface-error'),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          error.toString(),
          style: context.theme.typography.body.xs.copyWith(
            color: SemanticColor.destructive.solid(context),
          ),
        ),
      );
    }
    return widget.child;
  }

  /// 热重载后清掉上一次的错误：树可能已经变了，旧错误会让新树永远看不到。
  @override
  void reassemble() {
    super.reassemble();
    setState(() => _error = null);
  }
}
