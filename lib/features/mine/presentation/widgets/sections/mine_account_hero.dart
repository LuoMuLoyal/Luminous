import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_shared.dart';
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
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('mine-account-manage-link'),
        onTap: () => pushAuthRequiredRoute(context, '/account'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Row(
              children: [
                _AvatarPlaceholder(),
                const SizedBox(width: AppSpacingTokens.lg),
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
                          const SizedBox(width: AppSpacingTokens.sm),
                          _RolePill(label: mineCopy(l10n, account.roleKey)),
                        ],
                      ),
                      const SizedBox(height: AppSpacingTokens.xs),
                      Wrap(
                        spacing: AppSpacingTokens.xs,
                        runSpacing: AppSpacingTokens.xxs,
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
                              radius: AppRadiusTokens.sm,
                            ),
                            child: Text(
                              dashboard.completion.percentLabel,
                              style: textTheme.titleMedium?.copyWith(
                                color: mineGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacingTokens.md),
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 8,
                          radius: AppRadiusTokens.pill,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadiusTokens.pill,
                          ),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: dashboard.completion.progress,
                            backgroundColor: mineGreen.withValues(alpha: 0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              mineGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Icon(
                  FLucideIcons.chevronRight,
                  color: colors.mutedForeground,
                  size: AppSpacingTokens.xl,
                ),
              ],
            ),
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
        color: mineGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FLucideIcons.badgeCheck, color: mineGreen, size: 14),
            const SizedBox(width: AppSpacingTokens.xxs),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: mineGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
