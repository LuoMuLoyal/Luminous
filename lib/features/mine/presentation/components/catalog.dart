import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/mine/presentation/providers/surface.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/account_hero.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/account_security.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/ai_privacy.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/account/notifications_reminders.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/archive/archive.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync/status_alerts.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync/sync_failed_banner.dart';

/// Components of the `mine` surface.
///
/// Each one is an adapter around an existing section widget: the section keeps
/// its implementation and reads its own data from `mineSurfaceStateProvider`,
/// the adapter owns the id and the "nothing to show right now" answer. Ids are
/// `<domain>.<view>` and never mention `mine` — the same component must be
/// mountable on another surface later (`account.hero` worth showing elsewhere,
/// for instance).
///
/// `build` returning `null` means "skip me and my spacing"; this is what removes
/// the `SizedBox.shrink()` placeholders the hand-written page needed.
const accountSyncBannerId = ComponentId('sync.banner');
const accountHeroId = ComponentId('account.hero');
const profileAlertsId = ComponentId('profile.alerts');
const archiveSummaryId = ComponentId('archive.summary');
const privacyNoticeId = ComponentId('privacy.notice');
const reminderSettingsId = ComponentId('reminder.settings');
const accountSecurityId = ComponentId('account.security');

/// Surface definition: what `mine` may host and what it shows by default.
///
/// The default layout is the pre-composition mobile section order, so this is a
/// pure refactor — a user who never edits anything sees the same page. The order
/// matches the hand-written `_buildMobileLayout()` exactly:
///
///   1. sync banner          → `sync.banner`
///   2. account hero         → `account.hero`
///   3. profile alerts       → `profile.alerts`
///   4. archive summary      → `archive.summary`
///   5. AI privacy notice    → `privacy.notice`
///   6. reminder settings    → `reminder.settings`
///   7. account security     → `account.security`
///
/// That order is the acceptance criterion for the composable-tabs refactor: the
/// default layout must render identically to the previous hardcoded list. Golden
/// coverage for it is added once every tab has been registered, so it is asserted
/// here in prose rather than in a golden that later tab changes would churn.
const mineSurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.mine,
  available: [
    accountSyncBannerId,
    accountHeroId,
    profileAlertsId,
    archiveSummaryId,
    privacyNoticeId,
    reminderSettingsId,
    accountSecurityId,
  ],
  defaultLayout: SurfaceLayout(
    placements: [
      ComponentPlacement(id: accountSyncBannerId),
      ComponentPlacement(id: accountHeroId),
      ComponentPlacement(id: profileAlertsId),
      ComponentPlacement(id: archiveSummaryId),
      ComponentPlacement(id: privacyNoticeId),
      ComponentPlacement(id: reminderSettingsId),
      ComponentPlacement(id: accountSecurityId),
    ],
  ),
);

/// Registers every `mine` component into [registry].
void registerMineComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _SyncBannerComponent());
  registry.registerDescriptor(const _AccountHeroComponent());
  registry.registerDescriptor(const _ProfileAlertsComponent());
  registry.registerDescriptor(const _ArchiveSummaryComponent());
  registry.registerDescriptor(const _PrivacyNoticeComponent());
  registry.registerDescriptor(const _ReminderSettingsComponent());
  registry.registerDescriptor(const _AccountSecurityComponent());
}

class _SyncBannerComponent extends ComponentDescriptor<NoComponentConfig> {
  const _SyncBannerComponent();

  @override
  ComponentId get id => accountSyncBannerId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // The banner already answers "nothing pending" with a shrink box, but the
    // host would still reserve its spacing; returning null removes both.
    // Loading and error both keep the banner, matching its previous behaviour.
    final failedCount = ref.watch(mineSyncFailedCountProvider).value;
    if (failedCount != null && failedCount <= 0) return null;
    return const MineSyncFailedBanner();
  }
}

class _AccountHeroComponent extends ComponentDescriptor<NoComponentConfig> {
  const _AccountHeroComponent();

  @override
  ComponentId get id => accountHeroId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const MineAccountHero(key: Key('mine-account-header'));
  }
}

class _ProfileAlertsComponent extends ComponentDescriptor<NoComponentConfig> {
  const _ProfileAlertsComponent();

  @override
  ComponentId get id => profileAlertsId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // Hide the card only when the data is present and there are genuinely no
    // alerts. While loading or after a failed read the section stays, so a
    // failure is never mistaken for "your profile has no incomplete items".
    final dashboard = ref.watch(mineSurfaceStateProvider).dataOrNull;
    if (dashboard != null && dashboard.alerts.isEmpty) return null;
    return const MineStatusAlertsSection();
  }
}

class _ArchiveSummaryComponent extends ComponentDescriptor<NoComponentConfig> {
  const _ArchiveSummaryComponent();

  @override
  ComponentId get id => archiveSummaryId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const MineArchiveSection();
  }
}

class _PrivacyNoticeComponent extends ComponentDescriptor<NoComponentConfig> {
  const _PrivacyNoticeComponent();

  @override
  ComponentId get id => privacyNoticeId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const MineAiPrivacySection();
  }
}

class _ReminderSettingsComponent extends ComponentDescriptor<NoComponentConfig> {
  const _ReminderSettingsComponent();

  @override
  ComponentId get id => reminderSettingsId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const MineNotificationsReminderSection();
  }
}

class _AccountSecurityComponent extends ComponentDescriptor<NoComponentConfig> {
  const _AccountSecurityComponent();

  @override
  ComponentId get id => accountSecurityId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const MineAccountSecuritySection();
  }
}
