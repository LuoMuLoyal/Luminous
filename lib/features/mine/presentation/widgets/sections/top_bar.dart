import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineTopBar extends ConsumerWidget {
  const MineTopBar({
    super.key,
    required this.onNotificationsTap,
    required this.onSettingsTap,
  });

  final VoidCallback onNotificationsTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final hasUnread =
        unreadAsync.whenOrNull(data: (count) => count > 0) ?? false;

    return AppTopBar(
      title: l10n.tabMine,
      trailing: [
        _IconActionButton(
          tooltip: l10n.mineHeaderNotifications,
          icon: FLucideIcons.bell,
          onTap: onNotificationsTap,
          showBadge: hasUnread,
        ),
        _IconActionButton(
          key: const Key('mine-settings-action'),
          tooltip: l10n.mineHeaderSettings,
          icon: FLucideIcons.settings,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton(
            onPress: onTap,
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            child: Icon(icon, size: 22, color: colors.foreground),
          ),
          if (showBadge)
            Positioned(
              right: Spacing.level2,
              top: Spacing.level2,
              child: FBadge.raw(
                style: .delta(
                  decoration: .shapeDelta(
                    color: colors.destructive,
                    shape: CircleBorder(
                      side: BorderSide(color: colors.background, width: 2),
                    ),
                  ),
                ),
                builder: (context, style) =>
                    const SizedBox.square(dimension: Spacing.level3),
              ),
            ),
        ],
      ),
    );
  }
}
