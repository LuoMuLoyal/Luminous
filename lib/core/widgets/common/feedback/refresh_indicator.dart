import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Forui 风格的下拉刷新。
///
/// 手势与 "armed" 判定仍借用 Material 的 [RefreshIndicator.noSpinner](它只做判定,
/// 不画 spinner),指示器本体换成 Forui 的 [FCircularProgress]。这样下拉刷新不再
/// 出现 Material 的圆形 spinner(其颜色、阴影、位移都是 Material 语义)。
///
/// 用法与被替换的 [RefreshIndicator] 一致:包裹一个可 overscroll 的滚动视图,
/// 内容不足一屏时给滚动视图 `AlwaysScrollableScrollPhysics`。
class ForuiRefreshIndicator extends StatefulWidget {
  const ForuiRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.semanticsLabel,
  });

  /// 刷新回调;返回的 Future 完成时收起指示器。
  final RefreshCallback onRefresh;

  /// 被包裹的滚动内容。
  final Widget child;

  /// 由哪个 [ScrollNotification] 触发;默认最外层(depth == 0)。
  final ScrollNotificationPredicate notificationPredicate;

  /// 触发模式;默认仅在滚动到边缘时触发。
  final RefreshIndicatorTriggerMode triggerMode;

  /// 无障碍标签;同时用于指示器语义。
  final String? semanticsLabel;

  @override
  State<ForuiRefreshIndicator> createState() => _ForuiRefreshIndicatorState();
}

class _ForuiRefreshIndicatorState extends State<ForuiRefreshIndicator> {
  bool _visible = false;

  void _handleStatus(RefreshIndicatorStatus? status) {
    final visible = switch (status) {
      null ||
      RefreshIndicatorStatus.done ||
      RefreshIndicatorStatus.canceled => false,
      RefreshIndicatorStatus.drag ||
      RefreshIndicatorStatus.armed ||
      RefreshIndicatorStatus.snap ||
      RefreshIndicatorStatus.refresh => true,
    };
    if (visible != _visible) {
      setState(() => _visible = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Stack(
      children: [
        RefreshIndicator.noSpinner(
          onRefresh: widget.onRefresh,
          onStatusChange: _handleStatus,
          notificationPredicate: widget.notificationPredicate,
          triggerMode: widget.triggerMode,
          semanticsLabel: widget.semanticsLabel,
          child: widget.child,
        ),
        Positioned(
          top: Spacing.md,
          left: 0,
          right: 0,
          child: ExcludeSemantics(
            excluding: !_visible,
            child: IgnorePointer(
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, -0.5),
                duration: DurationTokens.widgetQuick,
                curve: MotionTokens.snappy,
                child: Center(
                  // 只在可见时挂载:FCircularProgress 是无限动画,常挂会让
                  // 所有 pumpAndSettle 永远等不到静止。
                  child: _visible
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.card,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SemanticColor.neutral.border(context),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.sm),
                            child: FCircularProgress(
                              semanticsLabel: widget.semanticsLabel,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
