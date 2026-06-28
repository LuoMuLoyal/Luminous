import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_settings_switch_row.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/app_back_button.dart';

/// A reusable settings page template with a master toggle at the top and a
/// list of child settings below.
///
/// When [masterValue] is false, the [children] are visually muted and
/// interactions are disabled. This is intended for settings like
/// "Sleep reminders" where sub-options only make sense when the feature is on.
class AppSettingsMasterTogglePage extends StatelessWidget {
  const AppSettingsMasterTogglePage({
    super.key,
    required this.title,
    required this.masterTitle,
    this.masterSubtitle,
    required this.masterValue,
    required this.onMasterChanged,
    required this.children,
  });

  final String title;
  final String masterTitle;
  final String? masterSubtitle;
  final bool masterValue;
  final ValueChanged<bool> onMasterChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return PageScaffoldShell(
      title: title,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        AppSettingsSwitchRow(
          title: masterTitle,
          subtitle: masterSubtitle,
          value: masterValue,
          onChanged: onMasterChanged,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        Divider(height: 1, color: surface.hairline),
        const SizedBox(height: AppSpacingTokens.md),
        _DisabledScope(
          disabled: !masterValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Wraps [child] and forces all [AppSettingsSwitchRow] /
/// [AppSettingsNavigationRow] descendants to render in a disabled state.
class _DisabledScope extends StatelessWidget {
  const _DisabledScope({required this.disabled, required this.child});

  final bool disabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!disabled) return child;

    return IgnorePointer(
      ignoring: true,
      child: Opacity(opacity: 0.45, child: child),
    );
  }
}
