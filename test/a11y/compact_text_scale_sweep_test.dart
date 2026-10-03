// Compact-width + largest-app-text-scale overflow sweep.
//
// The app ignores the OS font scale and applies its own accessibility font
// size (`lib/core/accessibility/settings.dart`, `PrefKeys.accessibilityFontSize`)
// as `MediaQuery.textScaler` in `lib/app/bootstrap.dart`. The largest setting
// is `extraLarge` = 1.3. Combined with the narrowest real logical widths the
// app supports (360 dp, 320 dp) that is the real-device worst case for
// `RenderFlex overflowed` regressions, and no per-feature test covers it.
//
// Each case pumps a page at one viewport with `MediaQuery.textScaler =
// TextScaler.linear(1.3)`, collecting every `FlutterError` whose message
// contains `overflowed`. Cases that still overflow today are parked in the
// `known-overflows` group (skipped) with a `// KNOWN (fix pending): <site>`
// comment; remove `_knownOverflowSkip` once the layout fixes land.
//
// Only ever asserts on the collector — it never edits `lib/**`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/pages/page.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail.dart';
import 'package:luminous/features/medicine/presentation/pages/page.dart'
    as medicine;
import 'package:luminous/features/medicine/presentation/pages/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/page.dart' as mine;
import 'package:luminous/features/mine/presentation/pages/sync_failures.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/pages/create.dart';
import 'package:luminous/features/record/presentation/pages/page.dart'
    as record;
import 'package:luminous/features/record/presentation/pages/quick_entry_reorder.dart';
import 'package:luminous/features/record/presentation/pages/quick_entry_settings.dart';
import 'package:luminous/features/review/data/providers/review.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';
import 'package:luminous/features/review/presentation/pages/page.dart'
    as review;
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/settings/presentation/pages/about.dart';
import 'package:luminous/features/settings/presentation/pages/accessibility.dart';
import 'package:luminous/features/settings/presentation/pages/advanced.dart';
import 'package:luminous/features/settings/presentation/pages/ai.dart';
import 'package:luminous/features/settings/presentation/pages/data_export.dart';
import 'package:luminous/features/settings/presentation/pages/data_storage.dart';
import 'package:luminous/features/settings/presentation/pages/dnd.dart';
import 'package:luminous/features/settings/presentation/pages/feature_flags.dart';
import 'package:luminous/features/settings/presentation/pages/help.dart';
import 'package:luminous/features/settings/presentation/pages/language.dart';
import 'package:luminous/features/settings/presentation/pages/notification.dart';
import 'package:luminous/features/settings/presentation/pages/page.dart'
    as settings;
import 'package:luminous/features/settings/presentation/pages/profile.dart';
import 'package:luminous/features/settings/presentation/pages/sleep_reminder.dart';
import 'package:luminous/features/settings/presentation/pages/theme.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/package_info.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/presentation/pages/page.dart' as today;
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/mocks/health_context.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';
import '../today/test_helpers.dart';

/// The app's largest accessibility font scale (`FontSizePreference.extraLarge`).
const double _textScale = 1.3;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  _registerSweep(known: false);

  // Sites that used to overflow at this viewport/scale combination and have
  // since been fixed (mobile timeline badge row, image-attachment buttons,
  // risk-check tab Column). They are registered here so they stay covered as
  // real regressions; `_runKnownOverflows` must stay `true`.
  group(
    'previously-overflowing sites',
    () => _registerSweep(known: true),
    skip: _runKnownOverflows ? null : _knownOverflowSkipReason,
  );
}

/// 这些站点已修复;置回 `false` 只应在再次出现已知未修溢出时临时使用。
const bool _runKnownOverflows = true;

const String _knownOverflowSkipReason =
    'KNOWN (fix pending): pages below overflow at 360x800/320x720 @ 1.3; '
    'see the per-case comments for the responsible site.';

// ── Sweep plumbing ──────────────────────────────────────────────

typedef _Pump = Future<void> Function(WidgetTester tester, double scale);

class _SweepCase {
  const _SweepCase(this.name, this.pump, {this.knownSites = const {}});

  final String name;
  final _Pump pump;

  /// Viewport label (`_Viewport.label`) -> responsible site, for viewport/scale
  /// combinations that are known to overflow today. Cases without an entry run
  /// in the always-green sweep; entries land in the skipped `known-overflows`
  /// group.
  final Map<String, String> knownSites;

  bool isKnownFor(String viewportLabel) =>
      knownSites.containsKey(viewportLabel);
}

class _Viewport {
  const _Viewport(this.label, this.apply);

  final String label;
  final void Function(WidgetTester tester) apply;
}

const List<_Viewport> _viewports = <_Viewport>[
  _Viewport('compact 360x800', setCompactPhoneScreenSize),
  _Viewport('narrow 320x720', setNarrowPhoneScreenSize),
];

void _registerSweep({required bool known}) {
  for (final viewport in _viewports) {
    final cases = _sweepCases
        .where((c) => c.isKnownFor(viewport.label) == known)
        .toList();
    if (cases.isEmpty) {
      continue;
    }
    group('${viewport.label} @ textScale $_textScale', () {
      for (final testCase in cases) {
        testWidgets(testCase.name, (tester) async {
          viewport.apply(tester);
          final overflows = <FlutterErrorDetails>[];
          final previous = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.exceptionAsString().contains('overflowed')) {
              overflows.add(details);
            } else {
              previous?.call(details);
            }
          };
          addTearDown(() => FlutterError.onError = previous);

          await testCase.pump(tester, _textScale);
          // Restore *before* asserting: an assertion failure raised while a
          // custom `FlutterError.onError` is still installed makes the test
          // binding fail with "_pendingExceptionDetails != null" instead of
          // reporting the overflow reason.
          FlutterError.onError = previous;
          _expectNoOverflow(overflows);
        });
      }
    });
  }
}

void _expectNoOverflow(List<FlutterErrorDetails> overflows) {
  expect(
    overflows,
    isEmpty,
    reason: overflows.map((d) => d.exceptionAsString()).join('\n---\n'),
  );
}

/// Pump the app and let one or two bounded pulses of fake time drain the
/// page's async providers. `pumpAndSettle` is deliberately avoided: shimmer
/// skeletons animate forever and would time the sweep out.
Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

// ── Case registry ───────────────────────────────────────────────
//
// Ordered by page, mirroring the shell tabs first.

const List<_SweepCase> _sweepCases = <_SweepCase>[
  _SweepCase('TodayPage', _pumpToday),
  _SweepCase('RecordPage', _pumpRecord, knownSites: _recordPageKnown),
  _SweepCase('MedicinePage', _pumpMedicine),
  _SweepCase('ReviewPage', _pumpReview),
  _SweepCase('MinePage', _pumpMine),
  _SweepCase('AssistantPage', _pumpAssistant),
  _SweepCase('SettingsPage', _pumpSettings),
  _SweepCase(
    'RecordCreatePage',
    _pumpRecordCreate,
    knownSites: _recordCreateKnown,
  ),
  _SweepCase('QuickEntrySettingsPage', _pumpQuickEntrySettings),
  _SweepCase('QuickEntryReorderPage', _pumpQuickEntryReorder),
  _SweepCase('MedicineDetailPage (cn)', _pumpMedicineDetail),
  _SweepCase('MedicineDetailPage (drugbank)', _pumpMedicineDetailDrugbank),
  _SweepCase(
    'MedicineRiskCheckPage',
    _pumpMedicineRiskCheck,
    knownSites: _riskCheckKnown,
  ),
  _SweepCase('SyncFailuresPage', _pumpSyncFailures),
  _SweepCase('ProfilePage', _pumpProfile),
  _SweepCase('AllergyEditPage', _pumpAllergyEdit),
  _SweepCase('ConditionEditPage', _pumpConditionEdit),
  _SweepCase('CurrentMedicineEditPage', _pumpCurrentMedicineEdit),
  _SweepCase('AccessibilitySettingsPage', _pumpAccessibility),
  _SweepCase('AboutSettingsPage', _pumpAbout),
  _SweepCase('NotificationSettingsPage', _pumpNotification),
  _SweepCase('DataStorageSettingsPage', _pumpDataStorage),
  _SweepCase('AdvancedSettingsPage', _pumpAdvanced),
  _SweepCase('HelpSettingsPage', _pumpHelp),
  _SweepCase('LanguageSettingsPage', _pumpLanguage),
  _SweepCase('ThemeSettingsPage', _pumpTheme),
  _SweepCase('DndSettingsPage', _pumpDnd),
  _SweepCase('SleepReminderSettingsPage', _pumpSleepReminder),
  _SweepCase('FeatureFlagsSettingsPage', _pumpFeatureFlags),
  _SweepCase('AiSettingsPage', _pumpAiSettings),
  _SweepCase('DataExportPage', _pumpDataExport),
];

// ── Known overflow sites (fix pending) ──────────────────────────
//
// Measured with this sweep at app text scale 1.3. Each entry parks that
// case/viewport combination in the skipped `known-overflows` group.

// KNOWN (fix pending): record timeline trailing FBadge ("AI 识别", 103 dp wide
// at 1.3) + chevron do not fit: `mobile_timeline.dart:231` Row overflows on the
// right at 320 dp. 360 dp fits.
const Map<String, String> _recordPageKnown = <String, String>{
  'narrow 320x720':
      'mobile_timeline.dart:231 Row — trailing FBadge + chevron (overflows right)',
};

// KNOWN (fix pending): the two image-attachment FButtons ("选择图片" / "拍照")
// in `image_attachment_field.dart:87,101` each get a 126 dp button / 102 dp
// content Row from the Wrap, so the icon+label row overflows on the right at
// 320 dp. 360 dp fits.
const Map<String, String> _recordCreateKnown = <String, String>{
  'narrow 320x720':
      'image_attachment_field.dart:87,101 FButton content Row (overflows right)',
};

// KNOWN (fix pending): CheckTabContent's non-scrollable Column
// (`check_tab_content.dart:96`) inside `FTabs(expands: true)` is taller than
// the tab viewport at 1.3 — 30 px at 360 dp, 156 px at 320 dp.
const Map<String, String> _riskCheckKnown = <String, String>{
  'compact 360x800':
      'check_tab_content.dart:96 Column (overflows bottom by 30)',
  'narrow 320x720':
      'check_tab_content.dart:96 Column (overflows bottom by 156)',
};

// ── Tabs ────────────────────────────────────────────────────────

Future<void> _pumpToday(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        activeHealthEventProvider.overrideWith(_NoActiveHealthEvent.new),
        todayRepositoryProvider.overrideWithValue(const MockTodayRepository()),
        todaySuggestionProvider.overrideWith(StaticTodaySuggestionNotifier.new),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const today.TodayPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpRecord(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        recordRepositoryProvider.overrideWithValue(
          const MockRecordRepository(),
        ),
        dailyRecordRepositoryProvider.overrideWithValue(
          _FakeDailyRecordRepository(),
        ),
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => testHealthSnapshot(),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const record.RecordPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpMedicine(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        notificationUnreadCountProvider.overrideWith((ref) async => 0),
        medicineWorkspaceRepositoryProvider.overrideWithValue(
          const MockMedicineWorkspaceRepository(),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const medicine.MedicinePage(), scale),
      ),
    ),
  );
}

Future<void> _pumpReview(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
        reviewDashboardProvider.overrideWith(
          (ref, query) async => ReviewDashboard.signedOut(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => testHealthSnapshot(),
        ),
        dailyRecordListForDateProvider.overrideWith(
          (ref, date) async =>
              const DailyRecordListData(items: <DailyRecordItem>[], total: 0),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const review.ReviewPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpMine(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(testHealthSnapshot()),
        ),
        notificationUnreadCountProvider.overrideWith((ref) => 0),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const mine.MinePage(), scale),
      ),
    ),
  );
}

Future<void> _pumpAssistant(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        assistantRepositoryProvider.overrideWithValue(
          _FakeAssistantRepository(),
        ),
        dailyRecordRepositoryProvider.overrideWithValue(
          _FakeDailyRecordRepository(),
        ),
        userSettingsControllerProvider.overrideWith(
          _ReadyUserSettingsController.new,
        ),
      ],
      child: TestForuiRouterApp(
        routerConfig: GoRouter(
          initialLocation: '/assistant',
          routes: [
            GoRoute(
              path: '/assistant',
              builder: (context, state) =>
                  scaledForTextScale(const AssistantPage(), scale),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) =>
                  const Scaffold(body: Text('login-page')),
            ),
            GoRoute(
              path: '/settings/ai',
              builder: (context, state) => const Scaffold(body: Text('ai')),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pumpSettings(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(),
        ),
      ],
      child: TestForuiRouterApp(
        routerConfig: GoRouter(
          initialLocation: '/settings',
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) =>
                  scaledForTextScale(const settings.SettingsPage(), scale),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Record sub-pages ────────────────────────────────────────────

Future<void> _pumpRecordCreate(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        dailyRecordRepositoryProvider.overrideWithValue(
          _FakeDailyRecordRepository(),
        ),
      ],
      child: TestForuiRouterApp(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  scaledForTextScale(const RecordCreatePage(), scale),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const Scaffold(body: Text('home')),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pumpQuickEntrySettings(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const QuickEntrySettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpQuickEntryReorder(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const QuickEntryReorderPage(), scale),
      ),
    ),
  );
}

// ── Medicine sub-pages ──────────────────────────────────────────

Future<void> _pumpMedicineDetail(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        medicineDetailProvider(
          'cn',
          'cn_1',
        ).overrideWith((ref) async => _cnMedicineDetail),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => testHealthSnapshot(),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(
          const MedicineDetailPage(source: 'cn', id: 'cn_1'),
          scale,
        ),
      ),
    ),
  );
}

Future<void> _pumpMedicineDetailDrugbank(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        medicineDetailProvider(
          'drugbank',
          'DB01050',
        ).overrideWith((ref) async => _drugbankMedicineDetail),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => testHealthSnapshot(),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(
          const MedicineDetailPage(source: 'drugbank', id: 'DB01050'),
          scale,
        ),
      ),
    ),
  );
}

Future<void> _pumpMedicineRiskCheck(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        medicineRiskCheckRepositoryProvider.overrideWithValue(
          FakeMedicineRiskCheckRepository(clearRiskCheckResult),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const MedicineRiskCheckPage(), scale),
      ),
    ),
  );
}

// ── Mine / profile sub-pages ────────────────────────────────────

Future<void> _pumpSyncFailures(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        pendingSyncDaoProvider.overrideWithValue(_MockPendingSyncDao()),
        syncWorkerProvider.overrideWithValue(_MockSyncWorker()),
        syncFailedCountProvider.overrideWith((ref) async => 1),
        mineSyncFailedEntriesProvider.overrideWith(
          (ref) async => <PendingSyncEntry>[_pendingSyncEntry()],
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const SyncFailuresPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpProfile(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(testHealthSnapshot()),
        ),
      ],
      child: TestForuiRouterApp(
        routerConfig: GoRouter(
          initialLocation: '/profile',
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  scaledForTextScale(const ProfilePage(), scale),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Mine health-context edit sub-pages ──────────────────────────

Future<void> _pumpAllergyEdit(WidgetTester tester, double scale) {
  return _pumpHealthContextEdit(tester, scale, const AllergyEditPage());
}

Future<void> _pumpConditionEdit(WidgetTester tester, double scale) {
  return _pumpHealthContextEdit(tester, scale, const ConditionEditPage());
}

Future<void> _pumpCurrentMedicineEdit(WidgetTester tester, double scale) {
  return _pumpHealthContextEdit(tester, scale, const CurrentMedicineEditPage());
}

Future<void> _pumpHealthContextEdit(
  WidgetTester tester,
  double scale,
  Widget page,
) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(testHealthSnapshot()),
        ),
      ],
      child: TestForuiApp(home: scaledForTextScale(page, scale)),
    ),
  );
}

// ── Settings sub-pages ──────────────────────────────────────────
Future<void> _pumpAccessibility(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const AccessibilitySettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpAbout(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        appInfoProvider.overrideWith(
          (ref) async => const AppInfo(supportEmail: 'support@example.com'),
        ),
        packageInfoProvider.overrideWith((ref) async => _fakePackageInfo()),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const AboutSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpNotification(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(),
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const NotificationSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpDataStorage(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const DataStorageSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpAdvanced(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const AdvancedSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpHelp(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const HelpSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpLanguage(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const LanguageSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpTheme(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const ThemeSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpDnd(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const DndSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpSleepReminder(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const SleepReminderSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpFeatureFlags(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      child: TestForuiApp(
        home: scaledForTextScale(const FeatureFlagsSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpAiSettings(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        userSettingsControllerProvider.overrideWith(
          _ReadyUserSettingsController.new,
        ),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const AiSettingsPage(), scale),
      ),
    ),
  );
}

Future<void> _pumpDataExport(WidgetTester tester, double scale) {
  return _pumpApp(
    tester,
    ProviderScope(
      overrides: [
        dataExportControllerProvider.overrideWith(_StubExportController.new),
      ],
      child: TestForuiApp(
        home: scaledForTextScale(const DataExportPage(), scale),
      ),
    ),
  );
}

// ── Fakes ───────────────────────────────────────────────────────

class _NoActiveHealthEvent extends ActiveHealthEvent {
  @override
  Future<HealthEvent?> build() async => null;
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => TaskEither.right(
    const DailyRecordListData(items: <DailyRecordItem>[], total: 0),
  );

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      TaskEither.right(
        const DailyRecordSummaryData(summaries: <DailyRecordSummary>[]),
      );

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);
}

class _FakeReviewRepository implements ReviewRepository {
  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) => TaskEither.right(const ReviewEventPage(items: [], total: 0));

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) =>
      throw UnimplementedError();
}

class _FakeAssistantRepository implements AssistantRepository {
  static const AssistantCapabilities _capabilities = AssistantCapabilities(
    phase: 'phase_1',
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    assistantContext: AssistantContextAccess(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: true,
      currentMedicines: true,
    ),
    chatModelConfigured: true,
    interactiveChatReady: true,
    langGraphReady: true,
    streamingSupported: true,
    streamingTransport: 'sse',
    markdownRenderingRecommended: true,
    ragEnabled: false,
    tools: <AssistantToolCapability>[],
    updatedAt: null,
  );

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() =>
      TaskEither.right(_capabilities);

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() =>
      TaskEither.right(const <AssistantConversationSummary>[]);

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() =>
      TaskEither.right(false);

  @override
  TaskEither<LucentFailure, void> renameConversation({
    required String conversationId,
    required String title,
  }) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, void> deleteConversation(String conversationId) =>
      throw UnimplementedError();

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) => const Stream<AssistantGenerationEvent>.empty();

  @override
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  }) => const Stream<AssistantGenerationEvent>.empty();

  @override
  TaskEither<LucentFailure, String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) => TaskEither.right(null);
}

class _ReadyUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: true,
      dataSharingConsent: false,
      assistantEnabled: true,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      updatedAt: '2026-06-12T00:00:00.000Z',
    );
  }
}

class _StubExportController extends DataExportController {
  @override
  Future<DataExportRequestData?> build() async => null;
}

class _FakeNotificationPermissionService extends NotificationPermissionService {
  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async =>
      NotificationPermissionState.granted;

  @override
  Future<NotificationPermissionState> requestPermission() async =>
      NotificationPermissionState.granted;
}

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

class _MockSyncWorker extends Mock implements SyncWorker {}

PendingSyncEntry _pendingSyncEntry() => PendingSyncEntry(
  id: 'pending-1',
  entityType: 'daily_record',
  entityId: 'record-1',
  operation: 'update',
  payload: '{}',
  createdAt: DateTime(2026, 8, 2, 12, 0),
  retryCount: 5,
  maxRetry: 5,
  lastError: 'DioException [connectionError]: network unavailable',
  errorDetails: const PendingSyncErrorDetails(
    message: 'Connection timed out',
    networkErrorCode: NetworkErrorCode.connectionError,
    kind: LucentFailureKind.network,
    raw: 'DioException [connectionError]: network unavailable',
  ),
);

const MedicineDetail _cnMedicineDetail = MedicineDetail(
  id: 'cn_1',
  source: 'cn',
  name: '布洛芬片',
  subtitle: '0.2g*12片',
  kind: 'cnProduct',
  approvalNumber: '国药准字 H20013062',
  manufacturer: '石药集团欧意药业有限公司',
  indications: '用于缓解轻至中度疼痛',
  contraindications: '对本品过敏者禁用',
);

const MedicineDetail _drugbankMedicineDetail = MedicineDetail(
  id: 'DB01050',
  source: 'drugbank',
  name: 'Ibuprofen',
  subtitle: 'Small molecule',
  kind: 'drugbank',
  indication: 'For mild pain.',
  description: 'A nonsteroidal anti-inflammatory drug.',
  halfLife: '2 hours',
  drugInteractions: [
    MedicineDetailInteraction(
      drugbankId: 'DB00795',
      description: 'May increase bleeding risk.',
    ),
  ],
  structure: MedicineStructure(
    smiles: 'CC(=O)Oc1ccccc1C(=O)O',
    inchiKey: 'BSYNRYMUTXBXSQ-UHFFFAOYSA-N',
    formula: 'C9H8O4',
    molecularWeight: 180.1573,
    logP: 1.3101,
    polarSurfaceArea: 63.6,
    donorCount: 1,
    acceptorCount: 4,
    rotatableBondCount: 2,
    ruleOfFive: 1,
    veberRule: 0,
    salts: ['Acetylsalicylic acid'],
  ),
);

PackageInfo _fakePackageInfo() {
  return PackageInfo(
    appName: 'Luminous',
    packageName: 'com.example.luminous',
    version: '0.1.0',
    buildNumber: '1',
    buildSignature: '',
    installerStore: null,
  );
}
