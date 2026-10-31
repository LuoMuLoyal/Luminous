import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart';
import 'package:luminous/core/design/design.dart';

/// 渲染一个生成式 surface。
///
/// 三层状态：
/// - 还没有 surface（未生成 / 正在生成）→ [emptyBuilder]；
/// - 有 surface → [Surface]，由 `genui` 按当前组件树渲染；
/// - 渲染中抛错 → 错误占位，不把异常抛给页面。
///
/// **不用 `Surface.defaultBuilder`** 做空态：那个 builder 在「definition 为
/// null」时触发，但页面还需要区分「从没生成过」与「生成中」，这层语义由调用方
/// 决定，包装组件只负责把两者都渲染成同一个空态。
class GenerativeSurfaceView extends StatelessWidget {
  const GenerativeSurfaceView({
    super.key,
    required this.surfaceContext,
    this.emptyBuilder,
  });

  /// 从 `GenerativeTransport.contextFor(surfaceId)` 取得；为 `null` 表示该
  /// surface 还没创建。
  final SurfaceContext? surfaceContext;

  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    final surface = surfaceContext;
    if (surface == null) {
      return emptyBuilder?.call(context) ?? const _GenerativeEmpty();
    }
    return _GenerativeErrorBoundary(
      child: Surface(surfaceContext: surface),
    );
  }
}

class _GenerativeEmpty extends StatelessWidget {
  const _GenerativeEmpty();

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Text(
        // 空态文案由调用方给（走 feature 的 ARB）；这里只是兜底。
        '',
        style: typography.body.xs,
      ),
    );
  }
}

/// 把渲染期异常收成一个安静的错误态。
///
/// A2UI 树来自模型，形状不可信；一棵坏的树不应该让整页崩掉。错误只记一次，
/// 不重试——重试同一棵树只会得到同一个错误。
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
          'Generative surface failed to render.',
          style: context.theme.typography.body.xs.copyWith(
            color: SemanticColor.destructive.solid(context),
          ),
        ),
      );
    }
    return widget.child;
  }

  @override
  void reassemble() {
    super.reassemble();
    setState(() => _error = null);
  }
}
