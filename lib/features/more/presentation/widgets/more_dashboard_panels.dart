import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/more/domain/entities/more_dashboard.dart';
import 'package:luminous/features/more/presentation/widgets/more_components.dart';
import 'package:luminous/features/more/presentation/widgets/more_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MoreEnvironmentPanel extends StatelessWidget {
  const MoreEnvironmentPanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final adviceCard = dashboard.environment.adviceCard;
    final adviceTitle = moreCopy(l10n, adviceCard.titleKey);

    return MoreSectionSurface(
      title: l10n.moreEnvironmentSectionTitle,
      planned: true,
      trailing: MoreTextAction(
        label: l10n.moreEnvironmentMoreAction,
        typography: typography,
        surface: surface,
        onTap: () => showMoreToast(context, l10n.moreEnvironmentMoreAction),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (
            var index = 0;
            index < dashboard.environment.metrics.length;
            index += 1
          )
            _EnvironmentRow(
              metric: dashboard.environment.metrics[index],
              typography: typography,
              surface: surface,
              showDivider: index != dashboard.environment.metrics.length - 1,
            ),
          const SizedBox(height: AppSpacingTokens.md),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showMoreToast(context, adviceTitle),
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvasSoft,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      MoreIconBadge(
                        icon: adviceCard.icon,
                        color: adviceCard.accent,
                        backgroundColor: adviceCard.softColor,
                        size: 42,
                        iconSize: 20,
                      ),
                      const SizedBox(width: AppSpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(adviceTitle, style: typography.bodyMdStrong),
                            const SizedBox(height: AppSpacingTokens.xxs),
                            Text(
                              moreCopy(l10n, adviceCard.bodyKey),
                              style: typography.bodySm.copyWith(
                                color: surface.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      OutlinedButton(
                        onPressed: () => showMoreToast(context, adviceTitle),
                        child: Text(moreCopy(l10n, adviceCard.actionKey!)),
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

class MoreRecentPanel extends StatelessWidget {
  const MoreRecentPanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MoreSectionSurface(
      title: l10n.moreRecentSectionTitle,
      typography: typography,
      surface: surface,
      planned: true,
      child: Column(
        children: [
          for (var index = 0; index < dashboard.recentItems.length; index += 1)
            Builder(
              builder: (context) {
                final item = dashboard.recentItems[index];
                final title = moreCopy(l10n, item.titleKey);

                return MoreRecentRow(
                  icon: item.icon,
                  color: item.accent,
                  backgroundColor: item.softColor,
                  title: title,
                  timeLabel: moreCopy(l10n, item.timeKey),
                  typography: typography,
                  surface: surface,
                  onTap: () => showMoreToast(context, title),
                  showDivider: index != dashboard.recentItems.length - 1,
                );
              },
            ),
          const SizedBox(height: AppSpacingTokens.sm),
          Align(
            alignment: Alignment.centerRight,
            child: MoreTextAction(
              label: l10n.moreRecentViewAllAction,
              typography: typography,
              surface: surface,
              onTap: () => showMoreToast(context, l10n.moreRecentViewAllAction),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreQuickEntriesPanel extends StatelessWidget {
  const MoreQuickEntriesPanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MoreSectionSurface(
      title: l10n.moreQuickSectionTitle,
      typography: typography,
      surface: surface,
      planned: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dashboard.quickEntries.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacingTokens.sm,
          mainAxisSpacing: AppSpacingTokens.sm,
          mainAxisExtent: 112,
        ),
        itemBuilder: (context, index) {
          final item = dashboard.quickEntries[index];
          final title = moreCopy(l10n, item.titleKey);

          return MoreCompactToolTile(
            icon: item.icon,
            color: item.accent,
            backgroundColor: item.softColor,
            title: title,
            subtitle: moreCopy(l10n, item.subtitleKey),
            typography: typography,
            surface: surface,
            onTap: () => showMoreToast(context, title),
          );
        },
      ),
    );
  }
}

class MoreCareNotePanel extends StatelessWidget {
  const MoreCareNotePanel({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MoreSectionSurface(
      title: l10n.moreCareNoteTitle,
      typography: typography,
      surface: surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EE),
              borderRadius: BorderRadius.circular(AppRadiusTokens.full),
            ),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacingTokens.xs),
              child: Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: Color(0xFF159B55),
              ),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              moreCopy(l10n, dashboard.careNoteBodyKey),
              style: typography.bodySm.copyWith(color: surface.body),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Icon(
            Icons.health_and_safety_outlined,
            size: 42,
            color: const Color(0xFF159B55).withValues(alpha: 0.28),
          ),
        ],
      ),
    );
  }
}

class _EnvironmentRow extends StatelessWidget {
  const _EnvironmentRow({
    required this.metric,
    required this.typography,
    required this.surface,
    required this.showDivider,
  });

  final MoreEnvironmentMetric metric;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
      child: Row(
        children: [
          MoreIconBadge(
            icon: metric.icon,
            color: metric.accent,
            backgroundColor: metric.softColor,
            size: 36,
            iconSize: 18,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              moreCopy(l10n, metric.titleKey),
              style: typography.bodyMd.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Text(
            moreCopy(l10n, metric.valueKey),
            style: typography.bodySmStrong.copyWith(color: metric.valueColor),
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
