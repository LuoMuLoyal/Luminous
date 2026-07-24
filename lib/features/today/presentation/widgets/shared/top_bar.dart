import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Today page top bar.
///
/// Note: the greeting subtitle has been extracted from the Header and moved to
/// the page content area. Uses [FHeader.nested], placed at the top of a [Column]
/// rather than inside a [ListView] to avoid tight width constraint crash
/// (Forui 0.24.x known issue).
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
            unawaited(context.push(Routes.assistant));
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
                unawaited(context.push(Routes.notifications));
                return;
              }
              if (session.isLoading) {
                return;
              }
              await showAuthRequiredDialog(
                context,
                onLogin: () =>
                    context.push(loginRouteForReturnTo(Routes.notifications)),
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
