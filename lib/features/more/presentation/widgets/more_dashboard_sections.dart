import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/more/domain/entities/more_dashboard.dart';
import 'package:luminous/features/more/presentation/widgets/more_components.dart';
import 'package:luminous/features/more/presentation/widgets/more_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MoreEmergencySection extends StatelessWidget {
  const MoreEmergencySection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.isDesktop,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ToolSection(
      title: l10n.moreEmergencySectionTitle,
      items: dashboard.emergencyTools,
      typography: typography,
      surface: surface,
      isDesktop: isDesktop,
      mobileLayout: _MobileSectionLayout.list,
    );
  }
}

class MoreFamilySection extends StatelessWidget {
  const MoreFamilySection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.isDesktop,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ToolSection(
      title: l10n.moreFamilySectionTitle,
      items: dashboard.familyTools,
      typography: typography,
      surface: surface,
      isDesktop: isDesktop,
      mobileLayout: _MobileSectionLayout.list,
    );
  }
}

class MoreAiToolsSection extends StatelessWidget {
  const MoreAiToolsSection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.isDesktop,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ToolSection(
      title: l10n.moreAiSectionTitle,
      items: dashboard.aiTools,
      typography: typography,
      surface: surface,
      isDesktop: isDesktop,
      mobileLayout: _MobileSectionLayout.grid,
    );
  }
}

class MoreDeviceSection extends StatelessWidget {
  const MoreDeviceSection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.isDesktop,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ToolSection(
      title: l10n.moreDeviceSectionTitle,
      items: dashboard.deviceTools,
      typography: typography,
      surface: surface,
      isDesktop: isDesktop,
      mobileLayout: _MobileSectionLayout.grid,
    );
  }
}

class MoreKnowledgeSection extends StatelessWidget {
  const MoreKnowledgeSection({
    super.key,
    required this.dashboard,
    required this.typography,
    required this.surface,
    required this.isDesktop,
  });

  final MoreDashboard dashboard;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ToolSection(
      title: l10n.moreKnowledgeSectionTitle,
      items: dashboard.knowledgeTools,
      typography: typography,
      surface: surface,
      isDesktop: isDesktop,
      mobileLayout: _MobileSectionLayout.grid,
    );
  }
}

class MoreEnvironmentSection extends StatelessWidget {
  const MoreEnvironmentSection({
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
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < AppBreakpoints.mobile ? 2 : 4;

    return MoreSectionSurface(
      title: l10n.moreEnvironmentSectionTitle,
      trailing: MoreTextAction(
        label: l10n.moreEnvironmentMoreAction,
        typography: typography,
        surface: surface,
        onTap: () => showMoreToast(context, l10n.moreEnvironmentMoreAction),
      ),
      typography: typography,
      surface: surface,
      planned: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dashboard.environment.metrics.length + 1,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacingTokens.sm,
          mainAxisSpacing: AppSpacingTokens.sm,
          mainAxisExtent: crossAxisCount == 4 ? 92 : 108,
        ),
        itemBuilder: (context, index) {
          if (index < dashboard.environment.metrics.length) {
            final metric = dashboard.environment.metrics[index];
            return MoreEnvironmentMetricTile(
              icon: metric.icon,
              color: metric.accent,
              backgroundColor: metric.softColor,
              title: moreCopy(l10n, metric.titleKey),
              value: moreCopy(l10n, metric.valueKey),
              valueColor: metric.valueColor,
              typography: typography,
              surface: surface,
            );
          }

          final adviceCard = dashboard.environment.adviceCard;
          final title = moreCopy(l10n, adviceCard.titleKey);
          final action = moreCopy(l10n, adviceCard.actionKey!);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showMoreToast(context, title),
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvasSoft,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoreIconBadge(
                        icon: adviceCard.icon,
                        color: adviceCard.accent,
                        backgroundColor: adviceCard.softColor,
                        size: 34,
                        iconSize: 18,
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: typography.caption.copyWith(color: surface.body),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        action,
                        style: typography.bodySmStrong.copyWith(
                          color: adviceCard.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

enum _MobileSectionLayout { list, grid }

class _ToolSection extends StatelessWidget {
  const _ToolSection({
    required this.title,
    required this.items,
    required this.typography,
    required this.surface,
    required this.isDesktop,
    required this.mobileLayout,
  });

  final String title;
  final List<MoreToolItem> items;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isDesktop;
  final _MobileSectionLayout mobileLayout;

  @override
  Widget build(BuildContext context) {
    return MoreSectionSurface(
      title: title,
      typography: typography,
      surface: surface,
      planned: true,
      child: isDesktop
          ? _DesktopToolGrid(
              items: items,
              typography: typography,
              surface: surface,
            )
          : switch (mobileLayout) {
              _MobileSectionLayout.list => _MobileToolList(
                items: items,
                typography: typography,
                surface: surface,
              ),
              _MobileSectionLayout.grid => _MobileToolGrid(
                items: items,
                typography: typography,
                surface: surface,
              ),
            },
    );
  }
}

class _DesktopToolGrid extends StatelessWidget {
  const _DesktopToolGrid({
    required this.items,
    required this.typography,
    required this.surface,
  });

  final List<MoreToolItem> items;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 820
            ? 3
            : constraints.maxWidth > 520
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacingTokens.md,
            mainAxisSpacing: AppSpacingTokens.md,
            mainAxisExtent: 114,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final title = moreCopy(l10n, item.titleKey);

            return MoreFeatureCard(
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
        );
      },
    );
  }
}

class _MobileToolList extends StatelessWidget {
  const _MobileToolList({
    required this.items,
    required this.typography,
    required this.surface,
  });

  final List<MoreToolItem> items;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        for (var index = 0; index < items.length; index += 1)
          MoreListActionTile(
            icon: items[index].icon,
            color: items[index].accent,
            backgroundColor: items[index].softColor,
            title: moreCopy(l10n, items[index].titleKey),
            subtitle: moreCopy(l10n, items[index].subtitleKey),
            typography: typography,
            surface: surface,
            onTap: () =>
                showMoreToast(context, moreCopy(l10n, items[index].titleKey)),
            showDivider: index != items.length - 1,
          ),
      ],
    );
  }
}

class _MobileToolGrid extends StatelessWidget {
  const _MobileToolGrid({
    required this.items,
    required this.typography,
    required this.surface,
  });

  final List<MoreToolItem> items;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < 360 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacingTokens.sm,
        mainAxisSpacing: AppSpacingTokens.sm,
        mainAxisExtent: crossAxisCount == 3 ? 128 : 118,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
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
    );
  }
}
