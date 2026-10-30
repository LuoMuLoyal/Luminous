import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/composition/notification/unread_count.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/surface_title_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Today page top bar.
///
/// Note: the greeting subtitle has been extracted from the Header and moved to
/// the page content area. Uses [FHeader.nested], placed at the top of a [Column]
/// rather than inside a [ListView] to avoid tight width constraint crash
/// (Forui 0.24.x known issue).
///
/// 标题即入口：点标题进入 `today` surface 的编排页（[SurfaceTitleButton]）。
class TodayTopBar extends StatelessWidget {
  const TodayTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FHeader.nested(
      title: SurfaceTitleEntry(
        surface: SurfaceId.today,
        title: l10n.todayHeroTitle,
      ),
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
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        mainAxisSize: MainAxisSize.min,
        prefix: const Icon(
          SemanticIcons.aiEntryTopBar,
          size: IconSizeTokens.md,
        ),
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
          FButton.icon(
            variant: FButtonVariant.ghost,
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
                SemanticIcons.notificationBell,
                color: colors.foreground,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: Spacing.sm,
              top: Spacing.sm,
              child: Semantics(
                label: l10n.todayNotificationsUnreadLabel,
                child: ExcludeSemantics(
                  child: FBadge.raw(
                    style: .delta(
                      decoration: .shapeDelta(
                        color: SemanticColor.destructive.solid(context),
                        shape: const CircleBorder(),
                      ),
                    ),
                    builder: (context, style) =>
                        const SizedBox.square(dimension: Spacing.sm),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
