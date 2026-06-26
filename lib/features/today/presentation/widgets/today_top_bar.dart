import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/today_components.dart';
import 'package:luminous/features/today/presentation/widgets/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayTopBar extends StatelessWidget {
  const TodayTopBar({super.key, required this.moment});

  final TodayDayMoment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todayHeroTitle,
                style: typography.displayXl.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: greetingSubtitle(l10n, moment),
                style: typography.bodyMd.copyWith(
                  color: Theme.of(context).extension<AppThemeSurface>()!.body,
                  letterSpacing: 0,
                ),
                widthFactor: 0.64,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        const _AssistantEntryButton(),
        const SizedBox(width: AppSpacingTokens.xs),
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final session = ref.watch(authSessionProvider);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Tooltip(
      message: l10n.assistantEntryTitle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('today-assistant-entry'),
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          onTap: () async {
            if (session.canAccessProtectedData) {
              context.push('/assistant');
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: TodayPalette.tealSoft,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: surface.hairline),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.sm,
                vertical: AppSpacingTokens.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: AppSpacingTokens.md,
                    color: TodayPalette.tealDeep,
                  ),
                  const SizedBox(width: AppSpacingTokens.xxs),
                  Text(
                    l10n.assistantEntryTitle,
                    style: typography.bodySmStrong.copyWith(
                      color: TodayPalette.tealDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    final theme = Theme.of(context);
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final hasUnread =
        unreadAsync.whenOrNull(data: (count) => count > 0) ?? false;

    return Tooltip(
      message: l10n.todayNotificationsTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: AppSpacingTokens.lg + AppSpacingTokens.xxs,
            ),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: AppSpacingTokens.sm,
              top: AppSpacingTokens.xs,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: AppSpacingTokens.xs),
              ),
            ),
        ],
      ),
    );
  }
}
