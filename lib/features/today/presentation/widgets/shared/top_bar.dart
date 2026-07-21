import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Today 页面顶栏，使用 FHeader.nested。
///
/// 注意：问候语（subtitle）已从 Header 中拆分，放到页面内容区显示。
class TodayTopBar extends StatelessWidget {
  const TodayTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FHeader.nested(
      title: Text(l10n.todayHeroTitle),
      suffixes: const [_AssistantEntryButton(), _NotificationButton()],
    );
  }
}

class _AssistantEntryButton extends ConsumerWidget {
  const _AssistantEntryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    return FTooltip(
      tipBuilder: (context, controller) => Text(l10n.assistantEntryTitle),
      child: FButton(
        key: const Key('today-assistant-entry'),
        onPress: () async {
          if (session.canAccessProtectedData) {
            unawaited(context.push(AppRoutes.assistant));
            return;
          }
          if (session.isLoading) {
            return;
          }
          await showAuthRequiredDialog(
            context,
            onLogin: () => context.push(loginRouteForReturnTo('/assistant')),
          );
        },
        variant: FButtonVariant.secondary,
        size: FButtonSizeVariant.sm,
        mainAxisSize: MainAxisSize.min,
        prefix: const Icon(FLucideIcons.sparkles, size: Spacing.level4),
        child: Text(l10n.assistantEntryTitle),
      ),
    );
  }
}

class _NotificationButton extends ConsumerWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final session = ref.watch(authSessionProvider);
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final hasUnread =
        unreadAsync.whenOrNull(data: (count) => count > 0) ?? false;

    return FTooltip(
      tipBuilder: (context, controller) => Text(l10n.todayNotificationsTooltip),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton(
            variant: FButtonVariant.outline,
            size: FButtonSizeVariant.sm,
            onPress: () async {
              if (session.canAccessProtectedData) {
                unawaited(context.push(AppRoutes.notifications));
                return;
              }
              if (session.isLoading) {
                return;
              }
              await showAuthRequiredDialog(
                context,
                onLogin: () => context.push(
                  loginRouteForReturnTo(AppRoutes.notifications),
                ),
              );
            },
            child: Semantics(
              label: l10n.todayNotificationsTooltip,
              button: true,
              child: Icon(
                FLucideIcons.bell,
                size: Spacing.level5 + Spacing.level1,
                color: colors.foreground,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: Spacing.level3,
              top: Spacing.level2,
              child: Semantics(
                label: l10n.todayNotificationsUnreadLabel,
                child: ExcludeSemantics(
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
              ),
            ),
        ],
      ),
    );
  }
}
