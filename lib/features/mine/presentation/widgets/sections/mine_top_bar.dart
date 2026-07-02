import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final hasUnread =
        unreadAsync.whenOrNull(data: (count) => count > 0) ?? false;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.tabMine,
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        _IconActionButton(
          tooltip: l10n.mineHeaderNotifications,
          icon: FLucideIcons.bell,
          onTap: onNotificationsTap,
          showBadge: hasUnread,
        ),
        const SizedBox(width: AppSpacingTokens.xs),
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

    return Tooltip(
      message: tooltip,
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
              right: 6,
              top: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.destructive,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 2),
                ),
                child: const SizedBox.square(dimension: 10),
              ),
            ),
        ],
      ),
    );
  }
}
