import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/account_hero.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/account_security.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/ai_privacy.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/notifications_reminders.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/archive/archive.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync/status_alerts.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync/sync_failed_banner.dart';

/// The `mine` surface.
///
/// Mobile renders the surface's layout through [ComponentHostSliver]: the page
/// no longer knows which sections exist, so adding or reordering one never
/// touches this file. Desktop keeps its hand-written two-column split (the
/// component layout is a single ordered list and cannot express a sidebar), but
/// every section reads its own data, so the columns pass no data slices either.
class MineDashboardView extends ConsumerWidget {
  const MineDashboardView({super.key, this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final Widget content = isDesktop
        ? _buildDesktopLayout()
        : _buildMobileLayout(ref);

    // No entrance animation here: the surrounding transition already brings this
    // view in (page state switch fade-through / tab branch cross-fade), and
    // stacking a second fade + rise on top of it delayed the visible appearance
    // and read as the content drifting upwards.
    return SkeletonScope(isLoading: isLoading, child: content);
  }

  Widget _buildMobileLayout(WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.mine));
    // `ComponentHost`, not `ComponentHostSliver`: the mine page mounts this view
    // as a single child of a further box context (the page-state transition and
    // the ListView above it), so a sliver here would be laid out as a box child.
    return ComponentHost(
      surface: SurfaceId.mine,
      layout: layout,
      spacing: Spacing.xl,
    );
  }

  Widget _buildDesktopLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: sync banner + account hero + archive + notifications.
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MineSyncFailedBanner(),
              SizedBox(height: Spacing.lg),
              MineAccountHero(key: Key('mine-account-header')),
              SizedBox(height: Spacing.xl),
              MineStatusAlertsSection(),
              SizedBox(height: Spacing.xl),
              MineArchiveSection(),
              SizedBox(height: Spacing.xl),
              MineNotificationsReminderSection(),
            ],
          ),
        ),
        SizedBox(width: Spacing.xl),
        // Right: AI privacy + account security.
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MineAiPrivacySection(),
              SizedBox(height: Spacing.xl),
              MineAccountSecuritySection(),
            ],
          ),
        ),
      ],
    );
  }
}
