import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

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
    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FTile(
              onPress: () => onMasterChanged(!masterValue),
              title: Text(masterTitle),
              subtitle: masterSubtitle == null || masterSubtitle!.isEmpty
                  ? null
                  : Text(masterSubtitle!),
              suffix: FSwitch(value: masterValue, onChange: onMasterChanged),
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            const AppDivider(),
            const SizedBox(height: AppSpacingTokens.level4),
            _DisabledScope(
              disabled: !masterValue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: title,
      child: SingleChildScrollView(child: content),
    );
  }
}

/// Wraps [child] and forces all descendant settings rows to render in a
/// disabled state.
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
