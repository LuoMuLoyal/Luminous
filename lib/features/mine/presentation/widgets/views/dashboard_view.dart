import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/sections.dart';

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
    final isDesktop = width >= Breakpoints.desktop;

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
        FadeEffect(duration: DurationTokens.widgetFadeIn),
        SlideEffect(
          begin: Offset(0, 0.02),
          end: Offset.zero,
          duration: DurationTokens.widgetFadeIn,
        ),
      ],
      child: scopedContent,
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineAccountHero(
          key: const Key('mine-account-header'),
          dashboard: dashboard,
        ),
        const SizedBox(height: Spacing.level5),
        MineArchiveSection(
          key: const Key('mine-archive-section'),
          dashboard: dashboard,
        ),
        const SizedBox(height: Spacing.level5),
        const MineAiPrivacySection(),
        const SizedBox(height: Spacing.level5),
        const MineNotificationsReminderSection(),
        const SizedBox(height: Spacing.level5),
        MineAccountSecuritySection(account: dashboard.account),
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
              MineAccountHero(
                key: const Key('mine-account-header'),
                dashboard: dashboard,
              ),
              const SizedBox(height: Spacing.level5),
              MineArchiveSection(
                key: const Key('mine-archive-section'),
                dashboard: dashboard,
              ),
              const SizedBox(height: Spacing.level5),
              const MineNotificationsReminderSection(),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level5),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MineAiPrivacySection(),
              const SizedBox(height: Spacing.level5),
              MineAccountSecuritySection(account: dashboard.account),
            ],
          ),
        ),
      ],
    );
  }
}
