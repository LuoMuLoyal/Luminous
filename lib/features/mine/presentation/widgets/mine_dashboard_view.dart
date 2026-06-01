import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_theme_sheet.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class MineDashboardView extends StatelessWidget {
  const MineDashboardView({super.key, required this.dashboard});

  final MineDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final isCompact = width < AppBreakpoints.mobile;
    final typography = isCompact
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    final primary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AccountHeaderSection(
          key: const Key('mine-account-header'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _HealthSummarySection(
          key: const Key('mine-health-summary'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          l10n: l10n,
          isCompact: isCompact,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _ProfileGridSection(
          key: const Key('mine-profile-grid'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          l10n: l10n,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _PlanCenterSection(
          key: const Key('mine-plan-center'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          l10n: l10n,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _ReportPrivacySection(
          key: const Key('mine-report-privacy'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
        ),
        if (!isDesktop) ...[
          const SizedBox(height: AppSpacingTokens.md),
          _SettingsSection(
            key: const Key('mine-settings'),
            title: l10n.mineSettingsSectionTitle,
            dashboard: dashboard,
            typography: typography,
            surface: surface,
          ),
        ],
      ],
    );

    final content = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: primary),
              const SizedBox(width: AppSpacingTokens.lg),
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    _StatusPanel(
                      key: const Key('mine-status-panel'),
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    _OnboardingPanel(
                      key: const Key('mine-onboarding-panel'),
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    _QuickEntriesPanel(
                      key: const Key('mine-quick-entries-panel'),
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    _SettingsSection(
                      key: const Key('mine-settings-panel'),
                      title: l10n.mineSettingsPanelTitle,
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                    ),
                  ],
                ),
              ),
            ],
          )
        : primary;

    return content
        .animate()
        .fadeIn(duration: 240.ms)
        .slideY(begin: 0.02, end: 0, duration: 260.ms);
  }
}

class MineLoadingView extends StatelessWidget {
  const MineLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Shimmer.fromColors(
      baseColor: surface.canvas.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: surface.canvasSoft2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SkeletonBlock(height: 154),
          SizedBox(height: AppSpacingTokens.md),
          _SkeletonBlock(height: 218),
          SizedBox(height: AppSpacingTokens.md),
          _SkeletonBlock(height: 248),
          SizedBox(height: AppSpacingTokens.md),
          _SkeletonBlock(height: 220),
          SizedBox(height: AppSpacingTokens.md),
          _SkeletonBlock(height: 180),
        ],
      ),
    );
  }
}

class MineErrorView extends StatelessWidget {
  const MineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.mineErrorTitle,
      description: l10n.mineErrorDescription,
      icon: Icons.person_search_outlined,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
    );
  }
}
class _AccountHeaderSection extends StatelessWidget {
  const _AccountHeaderSection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.isDesktop,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final account = dashboard.account;
    final completion = dashboard.completion;

    return MineSectionSurface(
      typography: typography,
      surface: surface,
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: _AccountProfileBlock(
                    account: account,
                    typography: typography,
                    surface: surface,
                  ),
                ),
                Container(
                  width: 1,
                  height: 88,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.lg,
                  ),
                  color: surface.hairline,
                ),
                Expanded(
                  child: _CompletionInlineCard(
                    completion: completion,
                    typography: typography,
                    surface: surface,
                    title: mineCopy(l10n, completion.titleKey),
                    subtitle: mineCopy(l10n, completion.subtitleKey),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountProfileBlock(
                  account: account,
                  typography: typography,
                  surface: surface,
                ),
                const SizedBox(height: AppSpacingTokens.md),
                _CompletionInlineCard(
                  completion: completion,
                  typography: typography,
                  surface: surface,
                  title: mineCopy(l10n, completion.titleKey),
                  subtitle: mineCopy(l10n, completion.subtitleKey),
                ),
              ],
            ),
    );
  }
}

class _AccountProfileBlock extends StatelessWidget {
  const _AccountProfileBlock({
    required this.account,
    required this.typography,
    required this.surface,
  });

  final MineAccount account;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD9C8), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(color: surface.hairline),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 38,
            color: Color(0xFF2D3A4A),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      mineCopy(l10n, account.displayNameKey),
                      style: typography.displaySm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  MineStatusBadge(
                    label: mineCopy(l10n, account.statusKey),
                    color: const Color(0xFF159B55),
                    typography: typography,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                account.email,
                style: typography.bodyMd.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 14,
                    color: Color(0xFFFF8A00),
                  ),
                  const SizedBox(width: AppSpacingTokens.xxs),
                  Expanded(
                    child: Text(
                      mineCopy(l10n, account.metaKey),
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompletionInlineCard extends StatelessWidget {
  const _CompletionInlineCard({
    required this.completion,
    required this.typography,
    required this.surface,
    required this.title,
    required this.subtitle,
  });

  final MineCompletion completion;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            MineProgressRing(
              progress: completion.progress,
              color: const Color(0xFF159B55),
            ),
            const SizedBox(width: AppSpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: typography.bodyMdStrong),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    completion.percentLabel,
                    style: typography.displayMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    subtitle,
                    style: typography.bodySm.copyWith(color: surface.body),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: surface.mute),
          ],
        ),
      ),
    );
  }
}

class _HealthSummarySection extends StatelessWidget {
  const _HealthSummarySection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.isCompact,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final metrics = dashboard.summary.metrics;

    return MineSectionSurface(
      title: l10n.mineSummaryTitle,
      trailing: Text(
        mineCopy(l10n, dashboard.summary.updatedAtKey),
        style: typography.bodySm.copyWith(color: surface.body),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            gridDelegate: isCompact
                ? const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacingTokens.sm,
                    mainAxisSpacing: AppSpacingTokens.sm,
                    mainAxisExtent: 104,
                  )
                : const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppSpacingTokens.sm,
                    mainAxisSpacing: AppSpacingTokens.sm,
                    childAspectRatio: 1.15,
                  ),
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: metric.softColor,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(
                    color: metric.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MineIconBadge(
                        icon: metric.icon,
                        color: metric.accent,
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                        size: isCompact ? 28 : 34,
                        iconSize: isCompact ? 16 : 18,
                      ),
                      SizedBox(
                        height: isCompact
                            ? AppSpacingTokens.xxs
                            : AppSpacingTokens.sm,
                      ),
                      Text(
                        metric.value,
                        style: (isCompact
                                ? typography.bodyMdStrong
                                : typography.displayMd)
                            .copyWith(
                          color: metric.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isCompact) const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        mineCopy(l10n, metric.titleKey),
                        style: typography.caption.copyWith(color: surface.body),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showMineToast(
                context,
                mineCopy(l10n, dashboard.summary.completeActionKey),
              ),
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6EC),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(color: const Color(0xFFFFD7A8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: Color(0xFFFF8A00),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          mineCopy(l10n, dashboard.summary.missingInfoKey),
                          style: typography.bodySm.copyWith(
                            color: const Color(0xFFAB570A),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Text(
                        mineCopy(l10n, dashboard.summary.completeActionKey),
                        style: typography.bodySmStrong.copyWith(
                          color: const Color(0xFFFF8A00),
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.xxs),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFFFF8A00),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGridSection extends StatelessWidget {
  const _ProfileGridSection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.isDesktop,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final entries = dashboard.profileEntries;

    return MineSectionSurface(
      title: l10n.mineProfileTitle,
      typography: typography,
      surface: surface,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: isDesktop
            ? const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: AppSpacingTokens.sm,
                mainAxisSpacing: AppSpacingTokens.sm,
                childAspectRatio: 1.7,
              )
            : const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacingTokens.sm,
                mainAxisSpacing: AppSpacingTokens.sm,
                mainAxisExtent: 108,
              ),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showMineToast(
                context,
                mineCopy(l10n, entry.titleKey),
              ),
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvas,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: isDesktop
                      ? Row(
                          children: [
                            MineIconBadge(
                              icon: entry.icon,
                              color: entry.accent,
                              backgroundColor: entry.softColor,
                              size: 38,
                              iconSize: 20,
                            ),
                            const SizedBox(width: AppSpacingTokens.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mineCopy(l10n, entry.titleKey),
                                    style: typography.bodySmStrong,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacingTokens.xxs),
                                  Text(
                                    mineCopy(l10n, entry.subtitleKey),
                                    style: typography.caption.copyWith(
                                      color: surface.body,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: surface.mute,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MineIconBadge(
                              icon: entry.icon,
                              color: entry.accent,
                              backgroundColor: entry.softColor,
                              size: 34,
                              iconSize: 18,
                            ),
                            const SizedBox(height: AppSpacingTokens.xxs),
                            Text(
                              mineCopy(l10n, entry.titleKey),
                              style: typography.caption.copyWith(
                                fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }
}

class _PlanCenterSection extends StatelessWidget {
  const _PlanCenterSection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.isDesktop,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final entries = dashboard.planEntries;

    return MineSectionSurface(
      title: l10n.minePlansTitle,
      trailing: MineTextAction(
        label: l10n.minePlansViewAll,
        typography: typography,
        surface: surface,
        onTap: () => showMineToast(context, l10n.minePlansViewAll),
      ),
      typography: typography,
      surface: surface,
      child: isDesktop
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: AppSpacingTokens.sm,
                mainAxisSpacing: AppSpacingTokens.sm,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _PlanCard(
                  entry: entry,
                  typography: typography,
                  surface: surface,
                  l10n: l10n,
                );
              },
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < entries.length; index += 1)
                    Padding(
                      padding: EdgeInsets.only(
                        right: index == entries.length - 1
                            ? 0
                            : AppSpacingTokens.sm,
                      ),
                      child: SizedBox(
                        width: 136,
                        child: _PlanCard(
                          entry: entries[index],
                          typography: typography,
                          surface: surface,
                          l10n: l10n,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.entry,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MinePlanEntry entry;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, entry.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: entry.softColor,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: entry.accent.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MineIconBadge(
                  icon: entry.icon,
                  color: entry.accent,
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  size: 38,
                  iconSize: 20,
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  mineCopy(l10n, entry.titleKey),
                  style: typography.bodySmStrong,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                 Text(
                   mineCopy(l10n, entry.statusKey),
                   style: typography.caption.copyWith(
                     color: entry.accent,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
                const SizedBox(height: AppSpacingTokens.md),
                 Text(
                   mineCopy(l10n, entry.detailKey),
                   style: typography.caption.copyWith(color: surface.body),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportPrivacySection extends StatelessWidget {
  const _ReportPrivacySection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compactStack = width < 360;

    return compactStack
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionCard(
                card: dashboard.reportCard,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              _ActionCard(
                card: dashboard.privacyCard,
                typography: typography,
                surface: surface,
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ActionCard(
                  card: dashboard.reportCard,
                  typography: typography,
                  surface: surface,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: _ActionCard(
                  card: dashboard.privacyCard,
                  typography: typography,
                  surface: surface,
                ),
              ),
            ],
          );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.card,
    required this.typography,
    required this.surface,
  });

  final MineActionCard card;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, card.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level2,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MineIconBadge(
                  icon: card.icon,
                  color: card.accent,
                  backgroundColor: card.softColor,
                  size: 46,
                  iconSize: 24,
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  mineCopy(l10n, card.titleKey),
                  style: typography.displaySm,
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  mineCopy(l10n, card.bodyKey),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  mineCopy(l10n, card.metaKey),
                  style: typography.caption.copyWith(color: surface.body),
                ),
                const SizedBox(height: AppSpacingTokens.md),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: card.accent.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                    border: Border.all(
                      color: card.accent.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.md,
                      vertical: AppSpacingTokens.sm,
                    ),
                    child: Text(
                      mineCopy(l10n, card.actionKey),
                      style: typography.bodySmStrong.copyWith(
                        color: card.accent,
                      ),
                    ),
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

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return MineSectionSurface(
      title: l10n.mineStatusPanelTitle,
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (var index = 0; index < dashboard.statusEntries.length; index += 1)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == dashboard.statusEntries.length - 1
                    ? 0
                    : AppSpacingTokens.md,
              ),
              child: Row(
                children: [
                  Icon(
                    dashboard.statusEntries[index].color ==
                            const Color(0xFFFF8A00)
                        ? Icons.auto_awesome_outlined
                        : Icons.check_circle_outline_rounded,
                    size: 18,
                    color: dashboard.statusEntries[index].color,
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      mineCopy(l10n, dashboard.statusEntries[index].titleKey),
                      style: typography.bodySm,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Text(
                    mineCopy(l10n, dashboard.statusEntries[index].valueKey),
                    style: typography.bodySmStrong.copyWith(
                      color: dashboard.statusEntries[index].color,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final completed = dashboard.onboardingEntries
        .where((entry) => entry.completed)
        .length;
    final progress = completed / dashboard.onboardingEntries.length;

    return MineSectionSurface(
      title: l10n.mineOnboardingTitle,
      typography: typography,
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < dashboard.onboardingEntries.length; index += 1)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == dashboard.onboardingEntries.length - 1
                    ? 0
                    : AppSpacingTokens.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    dashboard.onboardingEntries[index].completed
                        ? Icons.check_box_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: dashboard.onboardingEntries[index].completed
                        ? const Color(0xFF159B55)
                        : surface.hairlineStrong,
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      mineCopy(
                        l10n,
                        dashboard.onboardingEntries[index].titleKey,
                      ),
                      style: typography.bodySm,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacingTokens.md),
          Text(
            l10n.mineOnboardingProgress(
              completed,
              dashboard.onboardingEntries.length,
            ),
            style: typography.bodySmStrong.copyWith(
              color: const Color(0xFF159B55),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: surface.canvasSoft2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF159B55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickEntriesPanel extends StatelessWidget {
  const _QuickEntriesPanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return MineSectionSurface(
      title: l10n.mineQuickEntriesTitle,
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (var index = 0; index < dashboard.quickEntries.length; index += 1)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == dashboard.quickEntries.length - 1
                    ? 0
                    : AppSpacingTokens.sm,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => showMineToast(
                    context,
                    mineCopy(l10n, dashboard.quickEntries[index].titleKey),
                  ),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface.canvas,
                      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                      border: Border.all(color: surface.hairline),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacingTokens.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            dashboard.quickEntries[index].icon,
                            size: 20,
                            color: surface.body,
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mineCopy(
                                    l10n,
                                    dashboard.quickEntries[index].titleKey,
                                  ),
                                  style: typography.bodySmStrong,
                                ),
                                const SizedBox(height: AppSpacingTokens.xxs),
                                Text(
                                  mineCopy(
                                    l10n,
                                    dashboard.quickEntries[index].subtitleKey,
                                  ),
                                  style: typography.caption.copyWith(
                                    color: surface.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection({
    super.key,
    required this.title,
    required this.dashboard,
    required this.typography,
    required this.surface,
  });

  final String title;
  final MineDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme =
        ref.watch(appThemeControllerProvider).value ??
            AppThemeModePreference.system;

    return MineSectionSurface(
      title: title,
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (var index = 0; index < dashboard.settings.length; index += 1)
            MineSettingRow(
              icon: dashboard.settings[index].icon,
              title: mineCopy(l10n, dashboard.settings[index].titleKey),
              value: _settingValue(l10n, dashboard.settings[index], currentTheme),
              typography: typography,
              surface: surface,
              onTap: () => _onSettingTap(context, ref, l10n, dashboard.settings[index]),
              showDivider: index < dashboard.settings.length - 1,
            ),
        ],
      ),
    );
  }

  String? _settingValue(
    AppLocalizations l10n,
    MineSettingItem item,
    AppThemeModePreference currentTheme,
  ) {
    if (item.titleKey != MineCopyKey.settingsThemeTitle) {
      return item.valueKey == null ? null : mineCopy(l10n, item.valueKey!);
    }
    return switch (currentTheme) {
      AppThemeModePreference.system => l10n.mineThemeModeSystem,
      AppThemeModePreference.light => l10n.mineThemeModeLight,
      AppThemeModePreference.dark => l10n.mineThemeModeDark,
    };
  }

  void _onSettingTap(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    MineSettingItem item,
  ) {
    if (item.titleKey == MineCopyKey.settingsThemeTitle) {
      showModalBottomSheet(
        context: context,
        builder: (_) => const ThemeModeSheet(),
      );
    } else {
      showMineToast(context, mineCopy(l10n, item.titleKey));
    }
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: SizedBox(height: height, width: double.infinity),
    );
  }
}

