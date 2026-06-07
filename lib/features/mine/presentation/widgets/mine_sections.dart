import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineTopBar extends StatelessWidget {
  const MineTopBar({
    super.key,
    required this.onNotificationsTap,
    required this.onSettingsTap,
  });

  final VoidCallback onNotificationsTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.tabMine,
            style: typography.displayXl.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        _IconActionButton(
          tooltip: l10n.mineHeaderNotifications,
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          showBadge: true,
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        _IconActionButton(
          key: const Key('mine-settings-action'),
          tooltip: l10n.mineHeaderSettings,
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}

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
      onAction: () => context.go('/login'),
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
        onTap: account.isAuthenticated
            ? () => context.push('/account')
            : () => context.go('/login'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: _MinePanel(
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
                        Text(
                          dashboard.completion.percentLabel,
                          style: typography.bodyLg.copyWith(
                            color: _mineGreen,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: dashboard.completion.progress,
                        backgroundColor: _mineGreen.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _mineGreen,
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

class MineStatusOverview extends StatelessWidget {
  const MineStatusOverview({
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
    return _MinePanel(
      surface: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.lg,
      ),
      child: Row(
        children: [
          for (var index = 0; index < dashboard.alerts.length; index += 1) ...[
            Expanded(
              child: _StatusOverviewItem(
                entry: dashboard.alerts[index],
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ),
            if (index != dashboard.alerts.length - 1)
              Container(
                width: 1,
                height: 58,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.xs,
                ),
                color: surface.hairline,
              ),
          ],
        ],
      ),
    );
  }
}

class MineArchiveSection extends StatelessWidget {
  const MineArchiveSection({
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
    final meta = _profileMeta(l10n, dashboard.profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.mineProfileTitle, typography: typography),
        const SizedBox(height: AppSpacingTokens.sm),
        _MinePanel(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (
                var index = 0;
                index < dashboard.archiveEntries.length;
                index += 1
              )
                _ArchiveRow(
                  entry: dashboard.archiveEntries[index],
                  subtitleOverride:
                      dashboard.archiveEntries[index].titleKey ==
                          MineCopyKey.archiveBasicTitle
                      ? meta
                      : null,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                  showDivider: index != dashboard.archiveEntries.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class MineCampusServiceSection extends StatelessWidget {
  const MineCampusServiceSection({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l10n.mineCampusSectionTitle,
          typography: typography,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        _MinePanel(
          surface: surface,
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboard.campusServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacingTokens.sm,
              mainAxisSpacing: AppSpacingTokens.sm,
              mainAxisExtent: 124,
            ),
            itemBuilder: (context, index) {
              final entry = dashboard.campusServices[index];
              return _ServiceCard(
                entry: entry,
                l10n: l10n,
                typography: typography,
                surface: surface,
              );
            },
          ),
        ),
      ],
    );
  }
}

class MinePrivacySection extends StatelessWidget {
  const MinePrivacySection({
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
    return _MinePanel(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _PanelTitleRow(
            icon: Icons.shield_rounded,
            title: l10n.minePrivacyPermissionTitle,
            action: l10n.minePrivacyProtectionAction,
            typography: typography,
            surface: surface,
            onTap: () =>
                showMineToast(context, l10n.minePrivacyProtectionAction),
          ),
          for (
            var index = 0;
            index < dashboard.privacyEntries.length;
            index += 1
          )
            _PrivacyRow(
              entry: dashboard.privacyEntries[index],
              l10n: l10n,
              typography: typography,
              surface: surface,
              showDivider: index != dashboard.privacyEntries.length - 1,
            ),
        ],
      ),
    );
  }
}

class MineReminderSection extends StatelessWidget {
  const MineReminderSection({
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
    return _MinePanel(
      surface: surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitleRow(
            icon: Icons.notifications_rounded,
            title: l10n.mineReminderSectionTitle,
            typography: typography,
            surface: surface,
            onTap: () => context.push('/settings/notifications'),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboard.reminders.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacingTokens.sm,
              mainAxisSpacing: AppSpacingTokens.sm,
              mainAxisExtent: 72,
            ),
            itemBuilder: (context, index) {
              final entry = dashboard.reminders[index];
              return _ReminderChip(
                entry: entry,
                l10n: l10n,
                typography: typography,
                surface: surface,
              );
            },
          ),
        ],
      ),
    );
  }
}

class MineSettingsSection extends StatelessWidget {
  const MineSettingsSection({
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
    return _MinePanel(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _PanelTitleRow(
            icon: Icons.settings_rounded,
            title: l10n.mineAccountSettingsTitle,
            typography: typography,
            surface: surface,
            onTap: () => context.push('/settings'),
          ),
          for (
            var index = 0;
            index < dashboard.settingEntries.length;
            index += 1
          )
            _SettingRow(
              entry: dashboard.settingEntries[index],
              l10n: l10n,
              typography: typography,
              surface: surface,
              showDivider: index != dashboard.settingEntries.length - 1,
            ),
        ],
      ),
    );
  }
}

class MinePrivacyNoticeSection extends StatelessWidget {
  const MinePrivacyNoticeSection({
    super.key,
    required this.notice,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MinePrivacyNotice notice;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, notice.actionKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              _mineGreen.withValues(alpha: 0.05),
              surface.canvas,
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: _mineGreen.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              children: [
                Icon(notice.icon, color: _mineGreen, size: AppSpacingTokens.lg),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    mineCopy(l10n, notice.titleKey),
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  mineCopy(l10n, notice.actionKey),
                  style: typography.bodySmStrong.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: surface.body,
                  size: AppSpacingTokens.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusOverviewItem extends StatelessWidget {
  const _StatusOverviewItem({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MineStatusCard entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, entry.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xxs),
          child: Column(
            children: [
              _SoftIcon(
                icon: entry.icon,
                color: entry.accent,
                size: 42,
                iconSize: 23,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                mineCopy(l10n, entry.titleKey),
                style: typography.bodySmStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              Text(
                mineCopy(l10n, entry.subtitleKey),
                style: typography.caption.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              _TinyBadge(
                label: mineCopy(l10n, entry.badgeKey),
                color: entry.accent,
                typography: typography,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.showDivider,
    this.subtitleOverride,
  });

  final MineArchiveEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool showDivider;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final row = _TapRow(
      onTap: () {
        if (entry.route == null) {
          showMineToast(context, mineCopy(l10n, entry.titleKey));
          return;
        }
        context.push(entry.route!);
      },
      surface: surface,
      child: Row(
        children: [
          _SoftIcon(icon: entry.icon, color: entry.accent),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mineCopy(l10n, entry.titleKey),
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  subtitleOverride ?? mineCopy(l10n, entry.subtitleKey),
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (entry.statusKey != null) ...[
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              mineCopy(l10n, entry.statusKey!),
              style: typography.bodySmStrong.copyWith(
                color: entry.statusKey == MineCopyKey.archiveNeedsFill
                    ? AppColorTokens.warning
                    : _mineGreen,
                letterSpacing: 0,
              ),
            ),
          ],
          const SizedBox(width: AppSpacingTokens.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MineActionEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, entry.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              entry.accent.withValues(alpha: 0.04),
              surface.canvas,
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: entry.accent.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SoftIcon(
                  icon: entry.icon,
                  color: entry.accent,
                  size: 42,
                  iconSize: 22,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  mineCopy(l10n, entry.titleKey),
                  style: typography.bodySmStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  mineCopy(l10n, entry.subtitleKey),
                  style: typography.caption.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.showDivider,
  });

  final MinePrivacyEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = _TapRow(
      onTap: () => showMineToast(context, mineCopy(l10n, entry.titleKey)),
      surface: surface,
      child: Row(
        children: [
          _SoftIcon(icon: entry.icon, color: entry.accent, size: 38),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              mineCopy(l10n, entry.titleKey),
              style: typography.bodyMdStrong.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              mineCopy(l10n, entry.subtitleKey),
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          if (entry.toggleValue != null)
            IgnorePointer(
              child: Switch(
                value: entry.toggleValue!,
                onChanged: (_) {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          else
            Flexible(
              child: Text(
                mineCopy(l10n, entry.trailingKey),
                style: typography.bodySm.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          Icon(
            Icons.chevron_right_rounded,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MineReminderEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, entry.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.xs,
            ),
            child: Row(
              children: [
                _SoftIcon(
                  icon: entry.icon,
                  color: entry.accent,
                  size: 38,
                  iconSize: 20,
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mineCopy(l10n, entry.titleKey),
                        style: typography.bodySmStrong.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        mineCopy(l10n, entry.statusKey),
                        style: typography.caption.copyWith(
                          color: surface.body,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.showDivider,
  });

  final MineSettingEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = _TapRow(
      onTap: () {
        if (entry.route == null) {
          showMineToast(context, mineCopy(l10n, entry.titleKey));
          return;
        }
        context.push(entry.route!);
      },
      surface: surface,
      child: Row(
        children: [
          Icon(entry.icon, color: surface.body, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              mineCopy(l10n, entry.titleKey),
              style: typography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Flexible(
            child: Text(
              mineCopy(l10n, entry.valueKey),
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}

class _PanelTitleRow extends StatelessWidget {
  const _PanelTitleRow({
    required this.icon,
    required this.title,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? action;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TapRow(
      onTap: onTap,
      surface: surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.lg,
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: _mineGreen, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              title,
              style: typography.displaySm.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              action!,
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.child,
    required this.onTap,
    required this.surface,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacingTokens.lg,
      vertical: AppSpacingTokens.md,
    ),
  });

  final Widget child;
  final VoidCallback onTap;
  final AppThemeSurface surface;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _MinePanel extends StatelessWidget {
  const _MinePanel({
    required this.child,
    required this.surface,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
  });

  final Widget child;
  final AppThemeSurface surface;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.typography});

  final String title;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: typography.displaySm.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: SizedBox.square(
            dimension: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                if (showBadge)
                  Positioned(
                    right: AppSpacingTokens.xs,
                    top: AppSpacingTokens.xs,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: surface.canvas, width: 2),
                      ),
                      child: const SizedBox.square(dimension: 10),
                    ),
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
  const _AvatarPlaceholder({required this.surface});

  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _mineGreen.withValues(alpha: 0.1),
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
            const Icon(Icons.school_rounded, color: _mineGreen, size: 14),
            const SizedBox(width: AppSpacingTokens.xxs),
            Text(
              label,
              style: typography.bodySmStrong.copyWith(
                color: _mineGreen,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({
    required this.label,
    required this.color,
    required this.typography,
  });

  final String label;
  final Color color;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

String _profileMeta(AppLocalizations l10n, MineProfileSnapshot profile) {
  final age = profile.age == null
      ? l10n.mineProfileUnknownValue
      : l10n.mineProfileAgeYears(profile.age!);
  final sex = switch (profile.sexAtBirth) {
    'female' => l10n.mineProfileSexFemale,
    'male' => l10n.mineProfileSexMale,
    _ => l10n.mineProfileUnknownValue,
  };
  final height = profile.heightCm == null
      ? l10n.mineProfileUnknownValue
      : l10n.mineProfileHeightCm(profile.heightCm!.round());
  final weight = profile.weightKg == null
      ? l10n.mineProfileUnknownValue
      : l10n.mineProfileWeightKg(profile.weightKg!.round());

  return l10n.mineProfileMeta(age, sex, height, weight);
}

const _mineGreen = AppColorTokens.cyanDeep;
