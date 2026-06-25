import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report_repository.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';
import '../today/today_test_helpers.dart';

void main() {
  testWidgets(
    'Report page renders contract-backed sections for signed-in user',
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
            reportRepositoryProvider.overrideWithValue(
              const MockReportRepository(),
            ),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('zh'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.tabReport), findsOneWidget);
      final startLabel = DateFormat(
        'M月d日',
        'zh',
      ).format(DateTime.parse('2026-06-06'));
      final endLabel = DateFormat(
        'M月d日',
        'zh',
      ).format(DateTime.parse('2026-06-12'));
      expect(find.text('$startLabel - $endLabel'), findsOneWidget);
      expect(find.byKey(const Key('report-snapshot-status')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('report-snapshot-status')),
          matching: find.text(l10n.reportSnapshotStatus),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-generate-action')), findsOneWidget);
      expect(find.byKey(const Key('report-sync-action')), findsOneWidget);
      expect(find.text(l10n.reportScoreTitle), findsOneWidget);

      final scrollable = find.byType(Scrollable).first;
      final keys = <String>[
        'report-score-hero',
        'report-metrics-grid',
        'report-trend-section',
        'report-findings-section',
        'report-ai-summary-section',
        'report-export-section',
        'report-patterns-section',
        'report-reference-notice',
      ];

      for (final key in keys) {
        final finder = find.byKey(Key(key));
        await tester.scrollUntilVisible(finder, 260, scrollable: scrollable);
        await tester.pump(const Duration(milliseconds: 250));
        expect(finder, findsOneWidget);
      }

      expect(find.text(l10n.reportReferenceNotice), findsOneWidget);
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
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
      ),
    );

    await tester.pump();

    expect(repo.fetchCalled, isTrue);
    expect(find.byType(AppInlineSkeletonBlock), findsWidgets);

    repo.complete(MockReportRepository.previewDashboard);
    await tester.pumpAndSettle();
    expect(find.byType(AppInlineSkeletonBlock), findsNothing);
  });

  testWidgets('Report page renders signed-out placeholder with login notice', (
    tester,
  ) async {
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
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('report-signed-out-notice')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('report-signed-out-notice')),
        matching: find.text(l10n.authNotSignedIn),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report-signed-out-notice')),
        matching: find.text(l10n.reportSignedOutInlineHint),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report-signed-out-notice')),
        matching: find.text(l10n.authGoLogin),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('report-snapshot-status')), findsOneWidget);
    expect(find.text(l10n.reportScoreTitle), findsOneWidget);
    expect(find.byType(AppStateErrorView), findsNothing);
  });

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
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
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
          reportRepositoryProvider.overrideWithValue(
            const MockReportRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          lucentDataExportApiProvider.overrideWithValue(exportApi),
          externalUrlLauncherProvider.overrideWithValue(launcher),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
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
        ..latestResponse = DataExportLatestResponseDto(
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
            reportRepositoryProvider.overrideWithValue(
              const MockReportRepository(),
            ),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
            lucentDataExportApiProvider.overrideWithValue(exportApi),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('zh'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportPage(),
          ),
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

  testWidgets('Generate action triggers dashboard refresh via loading state', (
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
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
      ),
    );

    await tester.pump();
    expect(repo.fetchCount, 1);

    await tester.tap(find.byKey(const Key('report-generate-action')));
    await tester.pump();
    expect(repo.fetchCount, 2);

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
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
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
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('report-generate-action')), findsOneWidget);
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
          reportRepositoryProvider.overrideWithValue(repo),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(repo.fetchCount, 1);

    await tester.tap(find.byKey(const Key('report-sync-action')));
    await tester.pumpAndSettle();
    expect(repo.fetchCount, 2);
  });
}

class _PendingReportRepository implements ReportRepository {
  final _pending = Completer<ReportDashboard>();
  bool fetchCalled = false;

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) {
    fetchCalled = true;
    return _pending.future;
  }

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

class _FakeReportDataExportApi extends DataExportApi {
  _FakeReportDataExportApi() : super(Dio());

  int createCallCount = 0;
  int getLatestCallCount = 0;
  DataExportLatestResponseDto? latestResponse;

  @override
  Future<Response<DataExportRequestResponseDto>>
  dataExportControllerCreateRequestV1({
    required CreateDataExportRequestDto createDataExportRequestDto,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCallCount += 1;
    return Response<DataExportRequestResponseDto>(
      data: DataExportRequestResponseDto(
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
      ),
      requestOptions: RequestOptions(path: '/api/v1/user/data-export-requests'),
      statusCode: 200,
    );
  }

  @override
  Future<Response<DataExportLatestResponseDto>>
  dataExportControllerGetLatestRequestV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    getLatestCallCount += 1;
    return Response<DataExportLatestResponseDto>(
      data:
          latestResponse ??
          DataExportLatestResponseDto(
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
          ),
      requestOptions: RequestOptions(
        path: '/api/v1/user/data-export-requests/latest',
      ),
      statusCode: 200,
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

  void complete(ReportDashboard dashboard) {
    _pending.complete(dashboard);
  }
}

class _ThrowingReportRepository implements ReportRepository {
  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    throw Exception('Test error');
  }
}

class _EmptyReportRepository implements ReportRepository {
  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    return _emptyDashboard;
  }

  static const _emptyDashboard = ReportDashboard(
    range: ReportDashboardRange.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
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
