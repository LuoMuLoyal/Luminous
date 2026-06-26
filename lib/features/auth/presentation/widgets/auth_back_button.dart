import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// Auth 页面统一的左上角返回按钮。
///
/// 点击后优先返回上一级路由；如果当前已经是路由栈底（例如直接通过
/// deep link 进入登录页），则回到首页 `/`。
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return IconButton(
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: surface.body),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
