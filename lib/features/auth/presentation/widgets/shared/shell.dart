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
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
    this.formPanel = true,
  });

  final String title;
  final Widget form;
  final Widget? formModeSelector;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  /// Wraps [form] in the white `AuthFormPanel` card. Turn off for pages that
  /// already lay out their own grouped white blocks.
  final bool formPanel;

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
        formPanel: formPanel,
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
      formPanel: formPanel,
    );
  }
}
