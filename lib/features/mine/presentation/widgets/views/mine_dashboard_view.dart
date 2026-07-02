import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_sections.dart';

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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop ? _buildDesktopLayout() : _buildMobileLayout();

    final scopedContent = AppSkeletonScope(
      isLoading: isLoading,
      child: content,
    );
    if (isLoading) {
      return scopedContent;
    }

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 220)),
        SlideEffect(
          begin: Offset(0, 0.02),
          end: Offset.zero,
          duration: Duration(milliseconds: 220),
        ),
      ],
      child: scopedContent,
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!dashboard.account.isAuthenticated) ...[
          const MineSignedOutNotice(key: Key('mine-signed-out-notice')),
          const SizedBox(height: AppSpacingTokens.md),
        ],
        MineAccountHero(
          key: const Key('mine-account-header'),
          dashboard: dashboard,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MineStatusOverview(
          key: const Key('mine-status-overview'),
          dashboard: dashboard,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        MineArchiveSection(
          key: const Key('mine-archive-section'),
          dashboard: dashboard,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MinePrivacyNoticeSection(
          key: const Key('mine-privacy-notice'),
          notice: dashboard.privacyNotice,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!dashboard.account.isAuthenticated) ...[
                const MineSignedOutNotice(key: Key('mine-signed-out-notice')),
                const SizedBox(height: AppSpacingTokens.lg),
              ],
              MineAccountHero(
                key: const Key('mine-account-header'),
                dashboard: dashboard,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              MineArchiveSection(
                key: const Key('mine-archive-section'),
                dashboard: dashboard,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              MinePrivacyNoticeSection(
                key: const Key('mine-privacy-notice'),
                notice: dashboard.privacyNotice,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MineStatusOverview(
                key: const Key('mine-status-overview'),
                dashboard: dashboard,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
