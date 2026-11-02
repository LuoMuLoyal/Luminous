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
      child: _GenerativeMaterialScope(
        child: genui.Surface(surfaceContext: surface),
      ),
    );
  }
}

/// 给生成式内容套一层 Material 主题。
///
/// ## 为什么必须套
///
/// A2UI 的基础组件（`Card` / `Text` / `Divider`）是 **Material** 组件：
/// `Card` 取 `Theme.of(context).colorScheme.surface`，`Text` 走
/// `DefaultTextStyle` 里 Material 的 `bodyMedium`。本应用的界面主题是 Forui，
/// `MaterialApp.theme` 只是 `foruiMaterialTheme()` 的桥接层，`colorScheme`
/// 仍是 Material 3 的默认调色板——于是卡片会呈现 M3 的淡紫（`secondaryContainer`
/// 一系），和周围的 Forui 卡片完全不像同一套设计。
///
/// 这里不改生成内容的**结构**，只把它们用到的 Material 语义色映射到本应用的
/// 主题色：卡片用 `colors.card`、正文用 `colors.foreground`、分割线用
/// `colors.border`。映射而不是另起一套主题，是为了让生成的内容和前后的手写
/// 组件看起来是同一个产品里的东西。
class _GenerativeMaterialScope extends StatelessWidget {
  const _GenerativeMaterialScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final base = Theme.of(context);
    final scheme = base.colorScheme.copyWith(
      surface: colors.card,
      onSurface: colors.foreground,
      surfaceContainerLowest: colors.card,
      surfaceContainerLow: colors.card,
      surfaceContainer: colors.card,
      outlineVariant: colors.border,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      secondaryContainer: colors.secondary,
      onSecondaryContainer: colors.secondaryForeground,
    );

    return Theme(
      data: base.copyWith(colorScheme: scheme),
      child: DefaultTextStyle.merge(
        style: context.theme.typography.body.sm.copyWith(
          color: colors.foreground,
        ),
        child: child,
      ),
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
