import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';

/// Data model for a settings group in the master-detail layout.
class SettingsGroup {
  const SettingsGroup({
    required this.label,
    required this.icon,
    required this.body,
  });

  final String label;
  final IconData icon;
  final Widget body;
}

/// Desktop master-detail layout for the settings page.
///
/// Left column (~260px): section navigation with icons + labels, highlighting
/// the currently selected group.
/// Right column (flex): the selected group's settings content.
/// Account header is always shown above the master-detail area.
/// Sign-out tile is always shown below.
class SettingsMasterDetail extends StatefulWidget {
  const SettingsMasterDetail({
    super.key,
    required this.accountHeader,
    required this.signOutTile,
    required this.groups,
  });

  final Widget accountHeader;
  final Widget signOutTile;
  final List<SettingsGroup> groups;

  @override
  State<SettingsMasterDetail> createState() => _SettingsMasterDetailState();
}

class _SettingsMasterDetailState extends State<SettingsMasterDetail> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: settingsPageVerticalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.accountHeader,
            const SizedBox(height: 20.0),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left navigation column.
                  SizedBox(
                    width: 260,
                    child: FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.level2),
                        child: Column(
                          children: [
                            for (var i = 0; i < widget.groups.length; i++) ...[
                              MasterNavItem(
                                icon: widget.groups[i].icon,
                                label: widget.groups[i].label,
                                selected: i == _selectedIndex,
                                onTap: () => setState(() => _selectedIndex = i),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level6),
                  // Right content column.
                  Expanded(
                    child: SingleChildScrollView(
                      child: widget.groups[_selectedIndex].body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            widget.signOutTile,
          ],
        ),
      ),
    );
  }
}

/// A single navigation item in the settings master column.
class MasterNavItem extends StatelessWidget {
  const MasterNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return FTappable(
      onPress: onTap,
      child: AnimatedContainer(
        duration: DurationTokens.widgetQuick,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level3,
        ),
        decoration: BoxDecoration(
          color: selected
              ? SemanticColor.primary.muted(context)
              : Colors.transparent,
          borderRadius: context.theme.style.borderRadius.sm,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: IconSizeTokens.level2,
              color: selected
                  ? SemanticColor.primary.solid(context)
                  : SemanticColor.neutral.solid(context),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                label,
                style: context.theme.typography.body.sm.copyWith(
                  color: selected
                      ? colors.foreground
                      : SemanticColor.neutral.solid(context),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(
                SemanticIcons.actionNext,
                size: IconSizeTokens.level2,
                color: SemanticColor.primary.solid(context),
              ),
          ],
        ),
      ),
    );
  }
}
