import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayTopBar extends StatelessWidget {
  const TodayTopBar({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return AppTopBar(
      title: l10n.todayHeroTitle,
      subtitle: AppSkeletonText(
        text: greetingSubtitle(l10n, dashboard),
        style: TypographyToken.level4
            .body(context)
            .copyWith(color: colors.mutedForeground),
        widthFactor: 0.64,
      ),
      trailing: const [_AssistantEntryButton(), _NotificationButton()],
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
            onPress: () => context.push(AppRoutes.notifications),
            child: Icon(
              FLucideIcons.bell,
              size: Spacing.level5 + Spacing.level1,
              color: colors.foreground,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: Spacing.level3,
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
    );
  }
}
