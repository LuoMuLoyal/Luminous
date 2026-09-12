import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account_hero.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account_security.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/ai_privacy.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/archive.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/notifications_reminders.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/status_alerts.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync_failed_banner.dart';

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

    // No entrance animation here: the surrounding transition already brings this
    // view in (page state switch fade-through / tab branch cross-fade), and
    // stacking a second fade + rise on top of it delayed the visible appearance
    // and read as the content drifting upwards.
    return SkeletonScope(isLoading: isLoading, child: content);
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MineSyncFailedBanner(),
        const SizedBox(height: Spacing.lg),
        MineAccountHero(
          key: const Key('mine-account-header'),
          dashboard: dashboard,
        ),
        if (dashboard.alerts.isNotEmpty) ...[
          const SizedBox(height: Spacing.xl),
          MineStatusAlertsSection(alerts: dashboard.alerts),
        ],
        const SizedBox(height: Spacing.xl),
        MineArchiveSection(dashboard: dashboard),
        const SizedBox(height: Spacing.xl),
        const MineAiPrivacySection(),
        const SizedBox(height: Spacing.xl),
        const MineNotificationsReminderSection(),
        const SizedBox(height: Spacing.xl),
        MineAccountSecuritySection(account: dashboard.account),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: sync banner + account hero + archive + notifications.
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MineSyncFailedBanner(),
              const SizedBox(height: Spacing.lg),
              MineAccountHero(
                key: const Key('mine-account-header'),
                dashboard: dashboard,
              ),
              if (dashboard.alerts.isNotEmpty) ...[
                const SizedBox(height: Spacing.xl),
                MineStatusAlertsSection(alerts: dashboard.alerts),
              ],
              const SizedBox(height: Spacing.xl),
              MineArchiveSection(dashboard: dashboard),
              const SizedBox(height: Spacing.xl),
              const MineNotificationsReminderSection(),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xl),
        // Right: AI privacy + account security.
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MineAiPrivacySection(),
              const SizedBox(height: Spacing.xl),
              MineAccountSecuritySection(account: dashboard.account),
            ],
          ),
        ),
      ],
    );
  }
}
