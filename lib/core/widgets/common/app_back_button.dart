import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// 统一返回按钮。
///
/// 行为：
/// - 若传入了 [onPressed]，直接调用自定义回调。
/// - 否则优先 `GoRouter.of(context).canPop()`；能 pop 则 `context.pop()`。
/// - 无法 pop 时回退到 [fallbackRoute]（默认 `/today`）。
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.fallbackRoute = '/today',
  });

  final VoidCallback? onPressed;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return BackButton(
      color: surface.body,
      onPressed: onPressed ?? () => _handleBack(context),
    );
  }

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }
}
