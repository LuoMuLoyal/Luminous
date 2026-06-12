import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report_repository.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Report page renders contract-backed sections for signed-in user', (
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
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          reportRepositoryProvider.overrideWithValue(
            const MockReportRepository(),
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
    expect(find.text(l10n.reportWeekDateRange), findsOneWidget);
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
  });

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

  testWidgets('Report page asks signed-out user to login', (tester) async {
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

    expect(find.text(l10n.authNotSignedIn), findsOneWidget);
    expect(find.text(l10n.authLoginRequiredPrompt), findsOneWidget);
    expect(find.text(l10n.authGoLogin), findsOneWidget);
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
}

class _PendingReportRepository implements ReportRepository {
  final _pending = Completer<ReportDashboard>();
  bool fetchCalled = false;

  @override
  Future<ReportDashboard> fetchDashboard() {
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
    Completer<ReportDashboard>()..complete(MockReportRepository.previewDashboard),
  ];

  @override
  Future<ReportDashboard> fetchDashboard() {
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
