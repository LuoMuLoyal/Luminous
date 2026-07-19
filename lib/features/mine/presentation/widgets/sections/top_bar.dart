import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
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
        IconActionButton(
          tooltip: l10n.mineHeaderNotifications,
          icon: FLucideIcons.bell,
          onTap: onNotificationsTap,
          showBadge: hasUnread,
        ),
        IconActionButton(
          key: const Key('mine-settings-action'),
          tooltip: l10n.mineHeaderSettings,
          icon: FLucideIcons.settings,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}
