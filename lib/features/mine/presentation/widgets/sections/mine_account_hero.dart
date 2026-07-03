import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';

import 'package:luminous/l10n/app_localizations.dart';

class MineSignedOutNotice extends StatelessWidget {
  const MineSignedOutNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppStateMessageView(
      title: mineCopy(l10n, MineCopyKey.signedOutNoticeTitle),
      description: mineCopy(l10n, MineCopyKey.signedOutNoticeDescription),
      icon: FLucideIcons.lock,
      actionLabel: l10n.authGoLogin,
      actionKey: const Key('mine-signed-out-login-action'),
      onAction: () => context.push(loginRouteForCurrentLocation(context)),
      tone: AppStateTone.warning,
      padding: const EdgeInsets.all(AppSpacingTokens.level5),
    );
  }
}

class MineAccountHero extends StatelessWidget {
  const MineAccountHero({super.key, required this.dashboard});

  final MineDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final account = dashboard.account;
    final name = account.displayName?.trim().isNotEmpty == true
        ? account.displayName!.trim()
        : mineCopy(l10n, account.displayNameKey);

    return FTappable(
      key: const Key('mine-account-manage-link'),
      onPress: () => pushAuthRequiredRoute(context, '/account'),
      child: FCard.raw(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level5),
          child: Row(
            children: [
              _AvatarPlaceholder(),
              const SizedBox(width: AppSpacingTokens.level5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacingTokens.level3),
                        _RolePill(label: mineCopy(l10n, account.roleKey)),
                      ],
                    ),
                    const SizedBox(height: AppSpacingTokens.level2),
                    Wrap(
                      spacing: AppSpacingTokens.level2,
                      runSpacing: AppSpacingTokens.level1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          mineCopy(l10n, dashboard.completion.titleKey),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        AppSkeletonSlot(
                          skeleton: const AppInlineSkeletonBlock(
                            height: 22,
                            width: 42,
                            radius: AppRadiusTokens.level2,
                          ),
                          child: Text(
                            dashboard.completion.percentLabel,
                            style: textTheme.titleMedium?.copyWith(
                              color: context.theme.colors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacingTokens.level4),
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 8,
                        radius: AppRadiusTokens.levelFull,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppRadiusTokens.levelFull,
                        ),
                        child: FDeterminateProgress(
                          value: dashboard.completion.progress,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              Icon(
                FLucideIcons.chevronRight,
                color: colors.mutedForeground,
                size: AppSpacingTokens.level6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
      ),
      child: SizedBox.square(
        dimension: 84,
        child: Icon(
          FLucideIcons.userRound,
          color: colors.mutedForeground,
          size: 48,
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level2,
          vertical: AppSpacingTokens.level1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.badgeCheck,
              color: context.theme.colors.primary,
              size: 14,
            ),
            const SizedBox(width: AppSpacingTokens.level1),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: context.theme.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
