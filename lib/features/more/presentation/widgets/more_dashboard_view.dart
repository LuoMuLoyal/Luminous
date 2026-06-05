import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/more/domain/entities/more_dashboard.dart';
import 'package:luminous/features/more/presentation/widgets/more_dashboard_panels.dart';
import 'package:luminous/features/more/presentation/widgets/more_dashboard_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MoreDashboardView extends StatelessWidget {
  const MoreDashboardView({super.key, required this.dashboard});

  final MoreDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    final primary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoreEmergencySection(
          key: const Key('more-emergency-section'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MoreFamilySection(
          key: const Key('more-family-section'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MoreAiToolsSection(
          key: const Key('more-ai-section'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MoreDeviceSection(
          key: const Key('more-device-section'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MoreKnowledgeSection(
          key: const Key('more-knowledge-section'),
          dashboard: dashboard,
          typography: typography,
          surface: surface,
          isDesktop: isDesktop,
        ),
        if (!isDesktop) ...[
          const SizedBox(height: AppSpacingTokens.md),
          MoreEnvironmentSection(
            key: const Key('more-environment-section'),
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
                width: 320,
                child: Column(
                  children: [
                    MoreEnvironmentPanel(
                      key: const Key('more-environment-panel'),
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    MoreRecentPanel(
                      key: const Key('more-recent-panel'),
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    MoreQuickEntriesPanel(
                      key: const Key('more-quick-panel'),
                      dashboard: dashboard,
                      typography: typography,
                      surface: surface,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    MoreCareNotePanel(
                      key: const Key('more-note-panel'),
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

class MoreErrorView extends StatelessWidget {
  const MoreErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.moreErrorTitle,
      description: l10n.moreErrorDescription,
      icon: Icons.more_horiz_rounded,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
    );
  }
}
