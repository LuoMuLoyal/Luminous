import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineDashboardView extends StatelessWidget {
  const MineDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
  });

  final MineDashboard dashboard;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!dashboard.account.isAuthenticated) ...[
          MineSignedOutNotice(
            key: const Key('mine-signed-out-notice'),
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.md),
        ],
        MineAccountHero(
          key: const Key('mine-account-header'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MineStatusOverview(
          key: const Key('mine-status-overview'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        MineArchiveSection(
          key: const Key('mine-archive-section'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        MineCampusServiceSection(
          key: const Key('mine-campus-section'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        MinePrivacySection(
          key: const Key('mine-privacy-section'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        MineReminderSection(
          key: const Key('mine-reminder-section'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        MineSettingsSection(
          key: const Key('mine-settings-section'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MinePrivacyNoticeSection(
          key: const Key('mine-privacy-notice'),
          notice: dashboard.privacyNotice,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
      ],
    );

    final scopedContent = AppSkeletonScope(
      isLoading: isLoading,
      child: content,
    );
    if (isLoading) {
      return scopedContent;
    }

    return scopedContent
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.02, end: 0);
  }
}
