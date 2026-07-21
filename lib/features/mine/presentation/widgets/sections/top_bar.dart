import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Mine 页面顶栏，使用 FHeader.nested。
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
    final colors = context.theme.colors;

    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final hasUnread =
        unreadAsync.whenOrNull(data: (count) => count > 0) ?? false;

    return FHeader.nested(
      title: Text(l10n.tabMine),
      suffixes: [
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.mineHeaderNotifications),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FButton.icon(
                onPress: onNotificationsTap,
                child: Icon(FLucideIcons.bell, color: colors.foreground),
              ),
              if (hasUnread)
                Positioned(
                  right: Spacing.level2,
                  top: Spacing.level2,
                  child: FBadge.raw(
                    style: .delta(
                      decoration: .shapeDelta(
                        color: colors.destructive,
                        shape: const CircleBorder(),
                      ),
                    ),
                    builder: (context, style) =>
                        const SizedBox.square(dimension: Spacing.level2),
                  ),
                ),
            ],
          ),
        ),
        FTooltip(
          tipBuilder: (context, controller) => Text(l10n.mineHeaderSettings),
          child: FButton.icon(
            key: const Key('mine-settings-action'),
            onPress: onSettingsTap,
            child: Icon(FLucideIcons.settings, color: colors.foreground),
          ),
        ),
      ],
    );
  }
}
