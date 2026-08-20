import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/providers/security_elevation.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/report/data/providers/review.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';
import 'package:luminous/features/report/presentation/pages/legacy_dashboard_compat.dart';
import 'package:luminous/features/report/presentation/pages/page.dart';
import 'package:luminous/features/report/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/report/presentation/providers/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/sections/export.dart';
import 'package:luminous/features/report/presentation/widgets/sheets/more_actions.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import '../../helpers/test_helpers.dart';
import 'review_fixtures.dart';

/// Task 8：导出与就诊摘要迁入「更多」。
///
/// 锁定三件事：
/// 1. 回顾首屏没有四张导出卡（主路径回归约束）；
/// 2. 右上 More 打开后可见就诊摘要 / PDF / 打印下载 / 兼容历史报告四入口，
///    且不出现「分享给医生」类暗示文案；
/// 3. 各入口点击后触发对应流程（诊所摘要预览、导出 PIN 验证、legacy 路由）。
void main() {
  testWidgets(
    'review first screen has no export cards and shows the More entry',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await pumpPage(
        tester,
        signedIn: true,
        current: reviewActive(),
        history: reviewHistoryPage(const []),
      );

      // 主路径不渲染四张导出卡（导出区整体只在 legacy 兼容视图存在）。
      expect(find.byType(ReportExportSection), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.text(l10n.reportExportHospitalTitle), findsNothing);
      expect(find.text(l10n.reportExportMonthlyTitle), findsNothing);
      expect(find.text(l10n.reportExportPrintTitle), findsNothing);
      expect(find.text(l10n.reportExportClinicShareTitle), findsNothing);

      // 右上角有 More 入口。
      expect(find.byKey(const Key('review-more-action')), findsOneWidget);
    },
  );

  testWidgets(
    'More sheet lists visit summary, PDF, print and legacy report without doctor-implies copy',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportMoreActionsSheet(
                onVisitSummary: () async {},
                onShareManagement: () async {},
                onPdf: () async {},
                onPrint: () async {},
                onLegacyReport: () async {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(l10n.reportMoreTitle), findsOneWidget);
      expect(find.byKey(const Key('more-visit-summary')), findsOneWidget);
      expect(find.text(l10n.reportMoreVisitSummaryTitle), findsOneWidget);
      expect(find.text(l10n.reportMoreVisitSummarySubtitle), findsOneWidget);
      expect(find.byKey(const Key('more-share-management')), findsOneWidget);
      expect(find.text(l10n.reportMoreShareManagementTitle), findsOneWidget);
      expect(find.text(l10n.reportMoreShareManagementSubtitle), findsOneWidget);
      expect(find.byKey(const Key('more-pdf')), findsOneWidget);
      expect(find.text(l10n.reportMorePdfTitle), findsOneWidget);
      expect(find.byKey(const Key('more-print')), findsOneWidget);
      expect(find.text(l10n.reportMorePrintTitle), findsOneWidget);
      expect(find.byKey(const Key('more-legacy-report')), findsOneWidget);
      expect(find.text(l10n.reportMoreLegacyTitle), findsOneWidget);

      // 不暗示医生一定查看：sheet 内不出现「分享给医生」类文案。
      expect(find.textContaining('分享给医生'), findsNothing);
    },
  );

  testWidgets('tapping each More entry fires the matching callback', (
    tester,
  ) async {
    var visitTaps = 0;
    var shareManagementTaps = 0;
    var pdfTaps = 0;
    var printTaps = 0;
    var legacyTaps = 0;

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReportMoreActionsSheet(
              onVisitSummary: () async => visitTaps += 1,
              onShareManagement: () async => shareManagementTaps += 1,
              onPdf: () async => pdfTaps += 1,
              onPrint: () async => printTaps += 1,
              onLegacyReport: () async => legacyTaps += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('more-visit-summary')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('more-share-management')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('more-pdf')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('more-print')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('more-legacy-report')));
    await tester.pump();
    // 让 FTappable 的按压计时器（100ms）走完，避免测试结束时仍有挂起 Timer。
    await tester.pump(const Duration(milliseconds: 150));

    expect(visitTaps, 1);
    expect(shareManagementTaps, 1);
    expect(pdfTaps, 1);
    expect(printTaps, 1);
    expect(legacyTaps, 1);
  });

  testWidgets('showing the sheet and tapping an entry closes the sheet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    var visitTaps = 0;

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                unawaited(
                  showReportMoreActionsSheet(
                    context,
                    onVisitSummary: () async => visitTaps += 1,
                    onShareManagement: () async {},
                    onPdf: () async {},
                    onPrint: () async {},
                    onLegacyReport: () async {},
                  ),
                );
              },
              child: const Text('open-more'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-more'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('more-visit-summary')), findsOneWidget);

    await tester.tap(find.byKey(const Key('more-visit-summary')));
    await tester.pumpAndSettle();

    expect(visitTaps, 1);
    expect(find.byKey(const Key('more-visit-summary')), findsNothing);
  });

  testWidgets('More button on the report page opens the five-entry sheet', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await pumpPage(
      tester,
      signedIn: true,
      current: reviewActive(),
      history: reviewHistoryPage(const []),
    );

    await tester.tap(find.byKey(const Key('review-more-action')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.reportMoreTitle), findsOneWidget);
    expect(find.byKey(const Key('more-visit-summary')), findsOneWidget);
    expect(find.byKey(const Key('more-pdf')), findsOneWidget);
    expect(find.byKey(const Key('more-print')), findsOneWidget);
    expect(find.byKey(const Key('more-legacy-report')), findsOneWidget);
  });

  testWidgets('visit summary entry opens the clinic summary preview', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await pumpPage(
      tester,
      signedIn: true,
      current: reviewActive(),
      history: reviewHistoryPage(const []),
      overrides: [
        clinicSummaryPreviewProvider.overrideWith(
          (ref, fields) async => _clinicDto(),
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('review-more-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('more-visit-summary')));
    await tester.pumpAndSettle();

    // More sheet 已关闭，诊所摘要预览打开并渲染脱敏内容。
    expect(find.byKey(const Key('more-visit-summary')), findsNothing);
    expect(find.text(l10n.reportClinicSummaryGeneratedAt), findsOneWidget);
    expect(find.text('Lumi'), findsOneWidget);
  });

  testWidgets(
    'PDF and print entries start the export flow with PIN elevation',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await pumpPage(
        tester,
        signedIn: true,
        current: reviewActive(),
        history: reviewHistoryPage(const []),
        overrides: [
          userSettingsControllerProvider.overrideWith(
            _FakeUserSettingsController.new,
          ),
        ],
      );
      // 预载设置，让 showSecurityElevationDialog 读到 PIN 已启用（而不是
      // AsyncLoading 的“未启用”分支），进入验证弹窗。
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ReportPage)),
      );
      await container.read(userSettingsControllerProvider.future);
      await tester.pump();

      // PDF 入口 → 导出流程的 PIN 验证环节。
      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-pdf')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('more-pdf')), findsNothing);
      expect(find.text(l10n.securityElevationDialogTitle), findsOneWidget);
      await tester.tap(find.text(l10n.securityElevationDialogCancel));
      await tester.pumpAndSettle();
      expect(find.text(l10n.securityElevationDialogTitle), findsNothing);

      // 打印/下载入口 → 同样的验证环节。
      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-print')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.securityElevationDialogTitle), findsOneWidget);
      await tester.tap(find.text(l10n.securityElevationDialogCancel));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PDF export failure shows the export failed toast after PIN', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final exportController = _ThrowingDataExportController();

    await pumpPage(
      tester,
      signedIn: true,
      current: reviewActive(),
      history: reviewHistoryPage(const []),
      overrides: [
        // 持有有效 elevation token，直接越过 PIN 弹窗进入导出请求。
        securityElevationControllerProvider.overrideWith(
          _VerifiedElevationController.new,
        ),
        dataExportControllerProvider.overrideWith(() => exportController),
      ],
      withToaster: true,
    );

    await tester.tap(find.byKey(const Key('review-more-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('more-pdf')));
    await tester.pumpAndSettle();

    // PDF 入口以 monthly 输入发起导出；请求失败经 Failure 分支弹 toast。
    expect(exportController.lastInput, reportMonthlyPdfExportRequest);
    expect(find.textContaining(l10n.reportExportFailedToast), findsOneWidget);

    // Toast 自动移除计时器走完，避免测试结束时仍有挂起 Timer。
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();
    expect(find.textContaining(l10n.reportExportFailedToast), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed-out PDF entry shows the auth required dialog', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await pumpPage(
      tester,
      signedIn: false,
      current: null,
      history: reviewHistoryPage(const []),
    );

    await tester.tap(find.byKey(const Key('review-more-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('more-pdf')));
    await tester.pumpAndSettle();

    // 未登录点击导出入口：不发起导出，引导登录对话框出现。
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text(l10n.authNotSignedIn), findsOneWidget);
  });

  testWidgets(
    'legacy report entry opens the legacy dashboard compatibility page',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final router = GoRouter(
        initialLocation: Routes.report,
        routes: [
          GoRoute(
            path: Routes.report,
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const ReportPage()),
          ),
          GoRoute(
            path: Routes.reportLegacyDashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LegacyDashboardCompatPage(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            reviewRepositoryProvider.overrideWithValue(
              _FakeReviewRepository(
                current: reviewActive(),
                page: reviewHistoryPage(const []),
              ),
            ),
            healthContextSnapshotProvider.overrideWith(
              (ref) async => _healthContextSnapshot,
            ),
            dailyRecordListForDateProvider.overrideWith(
              (ref, date) async =>
                  const DailyRecordListData(items: [], total: 0),
            ),
            // 兼容页停留在 loading（骨架屏）即可，不依赖旧 dashboard 数据。
            reportDashboardProvider.overrideWith(
              (ref, query) => Completer<ReportDashboard>().future,
            ),
          ],
          child: TestForuiRouterApp(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-legacy-report')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(LegacyDashboardCompatPage), findsOneWidget);
      expect(find.byKey(const Key('more-legacy-report')), findsNothing);
    },
  );
}

Future<void> pumpPage(
  WidgetTester tester, {
  required bool signedIn,
  EventReview? current,
  ReviewEventPage? history,
  List<Override> overrides = const [],
  bool withToaster = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(
          signedIn
              ? SignedInAuthSessionNotifier.new
              : SignedOutAuthSessionNotifier.new,
        ),
        reviewRepositoryProvider.overrideWithValue(
          _FakeReviewRepository(current: current, page: history),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => _healthContextSnapshot,
        ),
        dailyRecordListForDateProvider.overrideWith(
          (ref, date) async => const DailyRecordListData(items: [], total: 0),
        ),
        ...overrides,
      ],
      // FToaster 与生产装配一致（MaterialApp builder 之下、页面之上），
      // 让导出失败的 toast 断言可用。
      child: TestForuiApp(
        home: withToaster
            ? const FToaster(child: ReportPage())
            : const ReportPage(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({this.current, this.page});

  EventReview? current;
  ReviewEventPage? page;

  @override
  Future<EventReview?> fetchCurrentReview() async => current;

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    return page ?? const ReviewEventPage(items: [], total: 0);
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    throw UnimplementedError();
  }
}

class _FakeUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: true,
      dataSharingConsent: false,
      assistantEnabled: false,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: false,
        dailyRecords: false,
        sleepRecords: false,
        currentMedicines: false,
      ),
      securityPin: SecurityPinSettings(enabled: true),
    );
  }
}

/// 直接持有有效 elevation token，让 `showSecurityElevationDialog` 跳过
/// PIN 弹窗返回 true，测试聚焦导出请求的 Failure 分支。
class _VerifiedElevationController extends SecurityElevationController {
  @override
  SecurityElevationState build() {
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));
    ref
        .read(securityElevationTokenHolderProvider)
        .set('test-elevation-token', expiresAt);
    return SecurityElevationVerified(expiresAt: expiresAt);
  }
}

/// 记录输入并抛错的导出控制器，验证 Failure toast 分支。
class _ThrowingDataExportController extends DataExportController {
  DataExportRequestInput? lastInput;

  @override
  Future<DataExportRequestDataDto?> build() async => null;

  @override
  Future<DataExportRequestDataDto?> requestExport([
    DataExportRequestInput input = reportHospitalPdfLast7DaysExportRequest,
  ]) async {
    lastInput = input;
    throw Exception('export failed in test');
  }
}

ClinicSummaryCoverageEntryDto _coverageEntry() {
  return ClinicSummaryCoverageEntryDto(
    state: ClinicSummaryCoverageEntryDtoStateEnum.observed,
    coverage: ClinicSummaryCoverageEntryDtoCoverageEnum.none,
    sources: const [ClinicSummaryCoverageEntryDtoSourcesEnum.manual],
    observedCount: 0,
    expectedCount: null,
    windowStart: null,
    windowEnd: null,
  );
}

ClinicSummaryCoverageDto _coverage() {
  return ClinicSummaryCoverageDto(
    checkIns: _coverageEntry(),
    water: _coverageEntry(),
    dose: _coverageEntry(),
    sleep: _coverageEntry(),
  );
}

ClinicSummaryDto _clinicDto() {
  return ClinicSummaryDto(
    generatedAt: '2026-08-13T09:00:00',
    scopeLabel: 'last_7_days',
    start: '2026-08-07T00:00:00',
    end: '2026-08-13T00:00:00',
    selectedFields: const [],
    coverage: _coverage(),
    dataRange: 'last_7_days',
    profile: ClinicSummaryProfileDto(
      nickname: 'Lumi',
      age: 30,
      sexAtBirth: 'male',
      bloodType: 'A',
    ),
    allergies: const <ClinicSummaryAllergyDto>[],
    conditions: const <ClinicSummaryConditionDto>[],
    currentMedicines: const <ClinicSummaryMedicineDto>[],
    findings: const [],
    disclaimer: '本摘要仅供参考，不构成医疗建议',
  );
}

const _healthContextSnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: null,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: 'Asia/Shanghai',
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
