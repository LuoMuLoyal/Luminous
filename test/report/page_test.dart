import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/report/data/repositories/mock.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report.dart';
import 'package:luminous/features/report/presentation/pages/page.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';
import '../helpers/test_forui_app.dart';
import '../today/test_helpers.dart';

void main() {
  testWidgets(
    'Report page renders readiness-first layout for signed-in ready mobile state',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            suggestionHistoryProvider.overrideWith(
              (ref) => Future.value(_testSuggestionHistory),
            ),
            reportRepositoryProvider.overrideWithValue(
              _FixedReportRepository(_readyDashboard),
            ),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
          ],
          child: const TestForuiApp(home: ReportPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.tabReport), findsOneWidget);
      final now = DateTime.now();
      final startLabel = DateFormat(
        'M月d日',
        'zh',
      ).format(now.subtract(const Duration(days: 7)));
      final endLabel = DateFormat('M月d日', 'zh').format(now);
      expect(find.text('$startLabel - $endLabel'), findsOneWidget);
      expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
      expect(find.byKey(const Key('report-snapshot-status')), findsNothing);
      expect(
        find.byKey(const Key('report-top-generate-action')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-top-sync-action')), findsOneWidget);
      expect(find.text(l10n.reportScoreTitle), findsOneWidget);

      final scrollable = find.byType(Scrollable).first;
      final keys = <String>[
        'report-readiness-card',
        'report-score-hero',
        'report-trend-section',
        'report-findings-section',
        'report-suggestion-history-section',
        'report-ai-summary-section',
        'report-export-section',
        'report-patterns-section',
      ];

      for (final key in keys) {
        final finder = find.byKey(Key(key));
        await tester.scrollUntilVisible(finder, 260, scrollable: scrollable);
        await tester.pump(const Duration(milliseconds: 250));
        expect(finder, findsOneWidget);
      }

      expect(find.byKey(const Key('report-reference-notice')), findsNothing);
    },
  );

  testWidgets('Report sync shows skeleton while fetching latest dashboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _PendingReportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pump();

    expect(repo.fetchCalled, isTrue);
    expect(find.byType(AppInlineSkeletonBlock), findsWidgets);

    repo.complete(MockReportRepository.previewDashboard);
    await tester.pumpAndSettle();
    expect(find.byType(AppInlineSkeletonBlock), findsNothing);
  });

  testWidgets(
    'Report page renders signed-out mobile preview without full locked sections',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedOutAuthSessionNotifier.new),
            userSettingsControllerProvider.overrideWith(
              DisabledUserSettingsController.new,
            ),
          ],
          child: const TestForuiApp(home: ReportPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure metric cards and other sections fit within the viewport without overflow.
      expect(tester.takeException(), isNull);

      expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
      expect(find.byKey(const Key('report-signed-out-notice')), findsNothing);
      expect(find.byKey(const Key('report-snapshot-status')), findsNothing);
      expect(find.text(l10n.reportScoreTitle), findsOneWidget);
      expect(find.byKey(const Key('report-ai-summary-section')), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.byKey(const Key('report-patterns-section')), findsNothing);
      expect(
        find.byKey(const Key('report-suggestion-history-section')),
        findsNothing,
      );
      expect(find.byType(AppStateErrorView), findsNothing);
    },
  );

  testWidgets(
    'Report page renders signed-in insufficient mobile state without summary export and patterns',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            suggestionHistoryProvider.overrideWith(
              (ref) => Future.value(_testSuggestionHistory),
            ),
            reportRepositoryProvider.overrideWithValue(
              _FixedReportRepository(MockReportRepository.previewDashboard),
            ),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
          ],
          child: const TestForuiApp(home: ReportPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
      expect(find.byKey(const Key('report-score-hero')), findsOneWidget);
      expect(find.byKey(const Key('report-trend-section')), findsOneWidget);
      expect(find.byKey(const Key('report-findings-section')), findsOneWidget);
      expect(
        find.byKey(const Key('report-suggestion-history-section')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-ai-summary-section')), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.byKey(const Key('report-patterns-section')), findsNothing);
    },
  );

  testWidgets('Report page supports pull-to-refresh on mobile', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _RefreshableReportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(repo.fetchCount, 1);

    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    repo.completeNext(MockReportRepository.previewDashboard);
    await tester.pumpAndSettle();

    expect(repo.fetchCount, 2);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('Report hospital export opens the latest download url', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final exportApi = _FakeReportDataExportApi();
    final launcher = _FakeExternalUrlLauncher();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(
            _FixedReportRepository(_readyDashboard),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(dataExportApi: exportApi),
          ),
          externalUrlLauncherProvider.overrideWithValue(launcher),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = find.byType(Scrollable).first;
    final exportSection = find.byKey(const Key('report-export-section'));
    await tester.scrollUntilVisible(exportSection, 260, scrollable: scrollable);
    await tester.pumpAndSettle();

    await tester.tap(find.text('给校医院'));
    await tester.pumpAndSettle();

    expect(exportApi.createCallCount, 1);
    expect(exportApi.getLatestCallCount, 2);
    expect(
      launcher.openedUri?.toString(),
      'https://example.com/export-ready.pdf',
    );
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets(
    'Report export card shows latest export status for matching kind',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final exportApi = _FakeReportDataExportApi()
        ..latestResponse = const DataExportLatestResponseDto(
          code: 0,
          message: 'ok',
          data: DataExportRequestDataDto(
            id: 'req-monthly',
            kind: DataExportKind.monthly,
            format: DataExportFormat.pdf,
            range: DataExportRange.last30Days,
            status: DataExportStatus.processing,
            requestedAt: '2026-06-12T00:00:00.000Z',
          ),
        );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            suggestionHistoryProvider.overrideWith(
              (ref) => Future.value(_testSuggestionHistory),
            ),
            reportRepositoryProvider.overrideWithValue(
              _FixedReportRepository(_readyDashboard),
            ),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
            lucentClientProvider.overrideWithValue(
              _FakeLucentClient(dataExportApi: exportApi),
            ),
          ],
          child: const TestForuiApp(home: ReportPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final scrollable = find.byType(Scrollable).first;
      final exportSection = find.byKey(const Key('report-export-section'));
      await tester.scrollUntilVisible(
        exportSection,
        260,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.text('处理中'), findsWidgets);
    },
  );

  testWidgets('Generate action is disabled while dashboard is loading', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final repo = _CountingPendingReportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pump();
    expect(repo.fetchCount, 1);
    expect(find.byType(ReportSkeletonView), findsOneWidget);
    expect(find.byKey(const Key('report-top-generate-action')), findsNothing);
    expect(repo.fetchCount, 1);

    repo.complete(MockReportRepository.previewDashboard);
    await tester.pumpAndSettle();
  });

  testWidgets('Error state shows AppStateErrorView with retry', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    final repo = _ThrowingReportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppStateErrorView), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Empty data renders without crash', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final repo = _EmptyReportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
    expect(find.byKey(const Key('report-ai-summary-section')), findsNothing);
    expect(find.byKey(const Key('report-export-section')), findsNothing);
    expect(find.byKey(const Key('report-patterns-section')), findsNothing);
  });

  testWidgets('Sync action triggers dashboard refresh', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final repo = _RefreshableReportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          suggestionHistoryProvider.overrideWith(
            (ref) => Future.value(_testSuggestionHistory),
          ),
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(repo.fetchCount, 1);

    await tester.tap(find.byKey(const Key('report-top-sync-action')));
    await tester.pumpAndSettle();
    expect(repo.fetchCount, 2);
  });

  testWidgets(
    'Report desktop keeps readiness and suggestion history but hides snapshot status',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 1000);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            suggestionHistoryProvider.overrideWith(
              (ref) => Future.value(_testSuggestionHistory),
            ),
            reportRepositoryProvider.overrideWithValue(
              _FixedReportRepository(_readyDashboard),
            ),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
          ],
          child: const TestForuiApp(home: ReportPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byKey(const PageStorageKey<String>('report-desktop-scroll')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
      expect(
        find.byKey(const Key('report-suggestion-history-section')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-snapshot-status')), findsNothing);
    },
  );
}

const _testSuggestionHistory = TodaySuggestionHistory(
  items: [
    TodaySuggestionHistoryItem(
      id: 'suggestion-1',
      date: '2026-07-07',
      type: TodaySuggestionType.behaviorAdvice,
      title: '建议减少晚间咖啡因',
      reason: '最近 3 天睡前 6 小时内摄入咖啡因，建议提前调整。',
      ruleId: 'rule-1',
      ruleVersion: '1.0.0',
      triggerType: TodaySuggestionTriggerType.timer,
      lifecycleState: TodaySuggestionLifecycleState.active,
      confidence: TodaySuggestionConfidence.high,
      generatedAt: '2026-07-07T08:00:00.000Z',
    ),
    TodaySuggestionHistoryItem(
      id: 'suggestion-2',
      date: '2026-07-06',
      type: TodaySuggestionType.coverage,
      title: '补充今天的饮水记录',
      reason: '当前饮水记录偏少，建议补录以完善趋势判断。',
      ruleId: 'rule-2',
      ruleVersion: '1.0.0',
      triggerType: TodaySuggestionTriggerType.event,
      lifecycleState: TodaySuggestionLifecycleState.expired,
      confidence: TodaySuggestionConfidence.medium,
      generatedAt: '2026-07-06T08:00:00.000Z',
    ),
  ],
  total: 2,
  startDate: '2026-06-12',
  endDate: '2026-07-12',
);

final _readyDashboard = MockReportRepository.previewDashboard.copyWith(
  score: const ReportHealthScore(
    value: 86,
    maxValue: 100,
    status: ReportStatus.good,
    summary: '最近 7 天整体记录稳定，报告可以正常查看。',
  ),
  metrics: MockReportRepository.previewDashboard.metrics
      .map(
        (metric) => metric.copyWith(
          status: ReportStatus.stable,
          value: switch (metric.kind) {
            ReportDataKind.medication => '92',
            ReportDataKind.sleep => '7.6',
            ReportDataKind.water => '1.8',
            ReportDataKind.general => '78',
          },
          delta: '+0.2',
        ),
      )
      .toList(growable: false),
);

class _PendingReportRepository implements ReportRepository {
  final _pending = Completer<ReportDashboard>();
  bool fetchCalled = false;

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) {
    fetchCalled = true;
    return _pending.future;
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());

  void complete(ReportDashboard dashboard) {
    _pending.complete(dashboard);
  }
}

class _RefreshableReportRepository implements ReportRepository {
  _RefreshableReportRepository();

  int fetchCount = 0;
  final List<Completer<ReportDashboard>> _pending = [
    Completer<ReportDashboard>()
      ..complete(MockReportRepository.previewDashboard),
  ];

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) {
    fetchCount += 1;
    if (_pending.isEmpty) {
      final completer = Completer<ReportDashboard>()
        ..complete(MockReportRepository.previewDashboard);
      _pending.add(completer);
    }
    return _pending.removeAt(0).future;
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());

  void completeNext(ReportDashboard dashboard) {
    if (_pending.isEmpty) {
      _pending.add(Completer<ReportDashboard>());
    }
    _pending.first.complete(dashboard);
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _FakeExternalUrlLauncher extends ExternalUrlLauncher {
  Uri? openedUri;

  @override
  Future<bool> open(Uri uri) async {
    openedUri = uri;
    return true;
  }
}

class _FakeReportDataExportApi implements DataExportApi {
  _FakeReportDataExportApi();

  int createCallCount = 0;
  int getLatestCallCount = 0;
  DataExportLatestResponseDto? latestResponse;

  @override
  Future<DataExportRequestResponseDto> dataExportControllerCreateRequestV1({
    required CreateDataExportRequestDto body,
  }) async {
    createCallCount += 1;
    return const DataExportRequestResponseDto(
      code: 0,
      message: 'ok',
      data: DataExportRequestDataDto(
        id: 'req-report',
        kind: DataExportKind.hospital,
        format: DataExportFormat.pdf,
        range: DataExportRange.last7Days,
        status: DataExportStatus.completed,
        requestedAt: '2026-06-15T08:00:00.000Z',
        completedAt: '2026-06-15T08:01:00.000Z',
        downloadUrl: null,
        fileName: 'report.pdf',
        fileSizeBytes: 1024,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<DataExportLatestResponseDto>
  dataExportControllerGetLatestRequestV1() async {
    getLatestCallCount += 1;
    return latestResponse ??
        const DataExportLatestResponseDto(
          code: 0,
          message: 'ok',
          data: DataExportRequestDataDto(
            id: 'req-report',
            kind: DataExportKind.hospital,
            format: DataExportFormat.pdf,
            range: DataExportRange.last7Days,
            status: DataExportStatus.completed,
            requestedAt: '2026-06-15T08:00:00.000Z',
            completedAt: '2026-06-15T08:01:00.000Z',
            downloadUrl: 'https://example.com/export-ready.pdf',
            fileName: 'report.pdf',
            fileSizeBytes: 1024,
            errorMessage: null,
          ),
        );
  }
}

class _CountingPendingReportRepository implements ReportRepository {
  int fetchCount = 0;
  final _pending = Completer<ReportDashboard>();

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) {
    fetchCount++;
    return _pending.future;
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());

  void complete(ReportDashboard dashboard) {
    _pending.complete(dashboard);
  }
}

class _ThrowingReportRepository implements ReportRepository {
  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    throw Exception('Test error');
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());
}

class _EmptyReportRepository implements ReportRepository {
  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    return _emptyDashboard;
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());

  static const _emptyDashboard = ReportDashboard(
    range: ReportDashboardRange.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: '2026-07-07T14:32:00.000Z',
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.stable,
      summary: '',
    ),
    metrics: [],
    trends: [],
    findings: [],
    exportActions: [],
    patterns: [],
    aiSummaryEnabled: false,
  );
}

class _FixedReportRepository implements ReportRepository {
  const _FixedReportRepository(this.dashboard);

  final ReportDashboard dashboard;

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    final now = DateTime.now();
    final startDate =
        query.startDate ??
        switch (query.range) {
          ReportDashboardRange.last30Days => now.subtract(
            const Duration(days: 30),
          ),
          ReportDashboardRange.custom => now.subtract(const Duration(days: 7)),
          ReportDashboardRange.last7Days => now.subtract(
            const Duration(days: 7),
          ),
        };
    final endDate = query.endDate ?? now;

    return dashboard.copyWith(
      range: query.range,
      startDate: _dateOnly(startDate),
      endDate: _dateOnly(endDate),
    );
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());
}

String _dateOnly(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

/// A [LucentClient] subclass that returns a fake [DataExportApi].
class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.dataExportApi}) : super(Dio());

  final DataExportApi dataExportApi;

  @override
  DataExportApi get dataExport => dataExportApi;
}
