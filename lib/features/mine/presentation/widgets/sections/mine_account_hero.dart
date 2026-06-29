import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineSignedOutNotice extends StatelessWidget {
  const MineSignedOutNotice({
    super.key,
    required this.typography,
    required this.surface,
  });
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppStateMessageView(
      title: mineCopy(l10n, MineCopyKey.signedOutNoticeTitle),
      description: mineCopy(l10n, MineCopyKey.signedOutNoticeDescription),
      icon: Icons.lock_outline_rounded,
      actionLabel: l10n.authGoLogin,
      actionKey: const Key('mine-signed-out-login-action'),
      onAction: () => context.push(loginRouteForCurrentLocation(context)),
      tone: AppStateTone.warning,
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
    );
  }
}

class MineAccountHero extends StatelessWidget {
  const MineAccountHero({
    super.key,
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final MineDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
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
        child: AppSectionSurface(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          surface: surface,
          child: Row(
            children: [
              _AvatarPlaceholder(surface: surface),
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
                            style: typography.displayLg.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacingTokens.sm),
                        _RolePill(
                          label: mineCopy(l10n, account.roleKey),
                          surface: surface,
                          typography: typography,
                        ),
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
                          style: typography.bodyMd.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
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
                            style: typography.bodyLg.copyWith(
                              color: mineGreen,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
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
                Icons.chevron_right_rounded,
                color: surface.body,
                size: AppSpacingTokens.xl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.surface});
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: surface.canvasSoft,
      shape: BoxShape.circle,
      border: Border.all(color: surface.hairline),
    ),
    child: SizedBox.square(
      dimension: 84,
      child: Icon(Icons.person_rounded, color: surface.mute, size: 56),
    ),
  );
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.surface,
    required this.typography,
  });
  final String label;
  final AppThemeSurface surface;
  final AppTypographyScale typography;
  @override
  Widget build(BuildContext context) => DecoratedBox(
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
          const Icon(Icons.school_rounded, color: mineGreen, size: 14),
          const SizedBox(width: AppSpacingTokens.xxs),
          Text(
            label,
            style: typography.bodySmStrong.copyWith(
              color: mineGreen,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    ),
  );
}
