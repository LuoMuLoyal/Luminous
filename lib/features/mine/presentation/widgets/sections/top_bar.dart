import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Mine page top bar. Uses [FHeader.nested], placed at the top of a [Column]
/// rather than inside a [ListView] to avoid tight width constraint crash
/// (Forui 0.24.x known issue).
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
                variant: FButtonVariant.ghost,
                child: Icon(
                  SemanticIcons.notificationBell,
                  color: colors.foreground,
                ),
              ),
              if (hasUnread)
                Positioned(
                  right: Spacing.level2,
                  top: Spacing.level2,
                  child: FBadge.raw(
                    style: .delta(
                      decoration: .shapeDelta(
                        color: SemanticColor.destructive.solid(context),
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
            variant: FButtonVariant.ghost,
            child: Icon(SemanticIcons.actionSettings, color: colors.foreground),
          ),
        ),
      ],
    );
  }
}
