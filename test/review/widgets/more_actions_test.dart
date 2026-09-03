import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/review/data/providers/review.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';
import 'package:luminous/features/review/presentation/pages/legacy_dashboard_compat.dart';
import 'package:luminous/features/review/presentation/pages/page.dart';
import 'package:luminous/features/review/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/export.dart';
import 'package:luminous/features/review/presentation/widgets/sheets/more_actions.dart';
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
      expect(find.byType(ReviewExportSection), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.text(l10n.reviewExportHospitalTitle), findsNothing);
      expect(find.text(l10n.reviewExportMonthlyTitle), findsNothing);
      expect(find.text(l10n.reviewExportPrintTitle), findsNothing);
      expect(find.text(l10n.reviewExportClinicShareTitle), findsNothing);

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
              child: ReviewMoreActionsSheet(
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

      expect(find.text(l10n.reviewMoreTitle), findsOneWidget);
      expect(find.byKey(const Key('more-visit-summary')), findsOneWidget);
      expect(find.text(l10n.reviewMoreVisitSummaryTitle), findsOneWidget);
      expect(find.text(l10n.reviewMoreVisitSummarySubtitle), findsOneWidget);
      expect(find.byKey(const Key('more-share-management')), findsOneWidget);
      expect(find.text(l10n.reviewMoreShareManagementTitle), findsOneWidget);
      expect(find.text(l10n.reviewMoreShareManagementSubtitle), findsOneWidget);
      expect(find.byKey(const Key('more-pdf')), findsOneWidget);
      expect(find.text(l10n.reviewMorePdfTitle), findsOneWidget);
      expect(find.byKey(const Key('more-print')), findsOneWidget);
      expect(find.text(l10n.reviewMorePrintTitle), findsOneWidget);
      expect(find.byKey(const Key('more-legacy-report')), findsOneWidget);
      expect(find.text(l10n.reviewMoreLegacyTitle), findsOneWidget);

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
            child: ReviewMoreActionsSheet(
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
                  showReviewMoreActionsSheet(
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.reviewMoreTitle), findsOneWidget);
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('more-visit-summary')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // More sheet 已关闭，诊所摘要预览打开并渲染脱敏内容。
    expect(find.byKey(const Key('more-visit-summary')), findsNothing);
    expect(find.text(l10n.reviewClinicSummaryGeneratedAt), findsOneWidget);
    expect(find.text('Lumi'), findsOneWidget);
  });

  testWidgets(
    'PDF and print entries start the export flow with password re-auth',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await pumpPage(
        tester,
        signedIn: true,
        current: reviewActive(),
        history: reviewHistoryPage(const []),
      );

      // PDF 入口 → 导出流程的密码再认证弹窗。
      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('more-pdf')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('more-pdf')), findsNothing);
      expect(
        find.text(l10n.authSensitiveActionPasswordDialogTitle),
        findsOneWidget,
      );
      final cancelButton = find.text(l10n.authCancelAction);
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text(l10n.authSensitiveActionPasswordDialogTitle),
        findsNothing,
      );

      // 打印/下载入口 → 同样的验证环节。
      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('more-print')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(l10n.authSensitiveActionPasswordDialogTitle),
        findsOneWidget,
      );
      final printCancelButton = find.text(l10n.authCancelAction);
      await tester.ensureVisible(printCancelButton);
      await tester.tap(printCancelButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text(l10n.authSensitiveActionPasswordDialogTitle),
        findsNothing,
      );
    },
  );

  testWidgets(
    'PDF export failure shows the export failed toast after password re-auth',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final exportController = _ThrowingDataExportController();

      await pumpPage(
        tester,
        signedIn: true,
        current: reviewActive(),
        history: reviewHistoryPage(const []),
        overrides: [
          // 固定返回密码，越过密码确认弹窗进入导出请求。
          sensitiveActionPasswordPromptProvider.overrideWithValue(
            (_, {title, message, label}) async => 'test-password',
          ),
          dataExportControllerProvider.overrideWith(() => exportController),
        ],
        withToaster: true,
      );

      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('more-pdf')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // PDF 入口以 monthly 输入发起导出；请求失败经 Failure 分支弹 toast。
      expect(exportController.lastInput, reviewMonthlyPdfExportRequest);
      expect(find.textContaining(l10n.reviewExportFailedToast), findsOneWidget);

      // Toast 的 1800ms FakeTimer 在 pump 时钟前进后触发移除。
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 300));
    },
  );

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('more-pdf')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

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
        initialLocation: Routes.review,
        routes: [
          GoRoute(
            path: Routes.review,
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const ReviewPage()),
          ),
          GoRoute(
            path: Routes.reviewLegacyDashboard,
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
            reviewDashboardProvider.overrideWith(
              (ref, query) => Completer<ReviewDashboard>().future,
            ),
            userSettingsControllerProvider.overrideWith(
              () => _FakeUserSettingsController(),
            ),
          ],
          child: TestForuiRouterApp(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const Key('review-more-action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
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
        userSettingsControllerProvider.overrideWith(
          () => _FakeUserSettingsController(),
        ),
        ...overrides,
      ],
      // FToaster 与生产装配一致（MaterialApp builder 之下、页面之上），
      // 让导出失败的 toast 断言可用。
      child: TestForuiApp(
        home: withToaster
            ? const FToaster(child: ReviewPage())
            : const ReviewPage(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

class _FakeUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: false,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      passwordReauthenticationRequired: true,
    );
  }
}

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({this.current, this.page});

  EventReview? current;
  ReviewEventPage? page;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() =>
      TaskEither.right(current);

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) => TaskEither.right(page ?? const ReviewEventPage(items: [], total: 0));

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    throw UnimplementedError();
  }
}

/// 记录输入并抛错的导出控制器，验证 Failure toast 分支。
class _ThrowingDataExportController extends DataExportController {
  DataExportRequestInput? lastInput;

  @override
  Future<DataExportRequestDataDto?> build() async => null;

  @override
  Future<DataExportRequestDataDto?> requestExport(
    DataExportRequestInput input, {
    required String password,
  }) async {
    lastInput = input;
    throw Exception('export failed in test');
  }
}

ClinicSummaryResponseDtoCoverageCheckIns _checkInsCoverage() {
  return ClinicSummaryResponseDtoCoverageCheckIns(
    state: ClinicSummaryResponseDtoCoverageCheckInsStateEnum.observed,
    coverage: ClinicSummaryResponseDtoCoverageCheckInsCoverageEnum.none,
    sources: const [ClinicSummaryResponseDtoCoverageCheckInsSourcesEnum.manual],
    observedCount: 0,
    expectedCount: null,
    windowStart: null,
    windowEnd: null,
  );
}

ClinicSummaryResponseDtoCoverageWater _waterCoverage() {
  return ClinicSummaryResponseDtoCoverageWater(
    state: ClinicSummaryResponseDtoCoverageWaterStateEnum.observed,
    coverage: ClinicSummaryResponseDtoCoverageWaterCoverageEnum.none,
    sources: const [ClinicSummaryResponseDtoCoverageWaterSourcesEnum.manual],
    observedCount: 0,
    expectedCount: null,
    windowStart: null,
    windowEnd: null,
  );
}

ClinicSummaryResponseDtoCoverageSleep _sleepCoverage() {
  return ClinicSummaryResponseDtoCoverageSleep(
    state: ClinicSummaryResponseDtoCoverageSleepStateEnum.observed,
    coverage: ClinicSummaryResponseDtoCoverageSleepCoverageEnum.none,
    sources: const [ClinicSummaryResponseDtoCoverageSleepSourcesEnum.manual],
    observedCount: 0,
    expectedCount: null,
    windowStart: null,
    windowEnd: null,
  );
}

ClinicSummaryResponseDtoCoverage _coverage() {
  return ClinicSummaryResponseDtoCoverage(
    checkIns: _checkInsCoverage(),
    water: _waterCoverage(),
    dose: _checkInsCoverage(),
    sleep: _sleepCoverage(),
  );
}

ClinicSummaryResponseDto _clinicDto() {
  return ClinicSummaryResponseDto(
    generatedAt: '2026-08-13T09:00:00',
    scopeLabel: 'last_7_days',
    start: '2026-08-07T00:00:00',
    end: '2026-08-13T00:00:00',
    selectedFields: const [],
    coverage: _coverage(),
    dataRange: 'last_7_days',
    profile: ClinicSummaryResponseDtoProfile(
      nickname: 'Lumi',
      age: 30,
      sexAtBirth: 'male',
      bloodType: 'A',
    ),
    allergies: const <ClinicSummaryResponseDtoAllergiesInner>[],
    conditions: const <ClinicSummaryResponseDtoConditionsInner>[],
    currentMedicines: const <ClinicSummaryResponseDtoCurrentMedicinesInner>[],
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
