import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayTopBar extends StatelessWidget {
  const TodayTopBar({super.key, required this.moment});

  final TodayDayMoment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todayHeroTitle,
                style: AppTypographyToken.level9
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacingTokens.level1),
              AppSkeletonText(
                text: greetingSubtitle(l10n, moment),
                style: AppTypographyToken.level4
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                widthFactor: 0.64,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level4),
        const _AssistantEntryButton(),
        const SizedBox(width: AppSpacingTokens.level2),
        const _NotificationButton(),
      ],
    );
  }
}

class _AssistantEntryButton extends ConsumerWidget {
  const _AssistantEntryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final session = ref.watch(authSessionProvider);

    return Tooltip(
      message: l10n.assistantEntryTitle,
      child: FButton.raw(
        key: const Key('today-assistant-entry'),
        onPress: () async {
          if (session.canAccessProtectedData) {
            unawaited(context.push('/assistant'));
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
        style: .delta(
          decoration: .delta([
            .all(
              .shapeDelta(
                color: colors.primary.withValues(alpha: 0.08),
                shape: RoundedSuperellipseBorder(
                  side: BorderSide(color: colors.border),
                  borderRadius: context.theme.style.borderRadius.pill,
                ),
              ),
            ),
          ]),
          contentStyle: const .delta(
            padding: .value(
              EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level3,
                vertical: AppSpacingTokens.level2,
              ),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.sparkles,
              size: AppSpacingTokens.level4,
              color: colors.primary,
            ),
            const SizedBox(width: AppSpacingTokens.level1),
            Text(
              l10n.assistantEntryTitle,
              style: AppTypographyToken.level4
                  .body(context)
                  .copyWith(color: colors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
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

    return Tooltip(
      message: l10n.todayNotificationsTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: () => context.push('/notifications'),
            child: Icon(
              FLucideIcons.bell,
              size: AppSpacingTokens.level5 + AppSpacingTokens.level1,
              color: colors.foreground,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: AppSpacingTokens.level3,
              top: AppSpacingTokens.level2,
              child: FBadge.raw(
                style: .delta(
                  decoration: .shapeDelta(
                    color: colors.destructive,
                    shape: const CircleBorder(),
                  ),
                ),
                builder: (context, style) =>
                    const SizedBox.square(dimension: AppSpacingTokens.level2),
              ),
            ),
        ],
      ),
    );
  }
}
