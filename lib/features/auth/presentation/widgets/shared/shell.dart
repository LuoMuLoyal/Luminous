import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

import 'package:luminous/features/auth/presentation/widgets/shared/desktop_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/mobile_shell.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.form,
    this.formModeSelector,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final Widget? formModeSelector;
  final bool enableFormAnimation;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    if (isDesktop) {
      return DesktopAuthShell(
        title: title,
        subtitle: subtitle,
        logo: logo,
        leading: leading,
        centerTitle: centerTitle,
        formModeSelector: formModeSelector,
        form: form,
        enableFormAnimation: enableFormAnimation,
      );
    }

    return MobileAuthShell(
      title: title,
      subtitle: subtitle,
      logo: logo,
      leading: leading,
      centerTitle: centerTitle,
      formModeSelector: formModeSelector,
      form: form,
      enableFormAnimation: enableFormAnimation,
    );
  }
}
