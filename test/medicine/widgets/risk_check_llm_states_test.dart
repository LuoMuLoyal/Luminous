// AI Analysis tab (`FTabEntry` llm) states: which failure lands on
// `LlmUnavailableState` ("AI analysis is not configured") and whether the
// not-configured / empty / loading / error states stay layout-safe at the
// narrow widths the app still supports.
//
// The unavailable state used to be entered for *any* failure of
// `POST /medicine/risk-check`, so an offline device or a runtime LLM failure
// was reported as missing configuration. Only the server's
// `DEPENDENCY_UNAVAILABLE` (503) answer may claim that now.
//
// Layout cases mirror `test/a11y/compact_text_scale_sweep_test.dart` (360x800
// and 320x720 at the app's largest text scale 1.3) with the overflow-collector
// idiom of `test/core/widgets/date_picker_test.dart`.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/medicine/presentation/pages/risk_check.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import '../../helpers/test_helpers.dart';

/// Records-only repository whose `runCheck` always fails with [failure].
class _FailingRunRepository implements MedicineRiskCheckRepository {
  _FailingRunRepository(this.failure);

  final LucentFailure failure;

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords() =>
      TaskEither.right(const MedicineRiskCheckRecords());

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  ) => TaskEither.left(failure);

  @override
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) => TaskEither.right(const MedicineRiskCheckResult());
}

/// Repository whose records read never settles (page-level loading state).
class _PendingRecordsRepository implements MedicineRiskCheckRepository {
  final Completer<MedicineRiskCheckRecords> _pending =
      Completer<MedicineRiskCheckRecords>();

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords() {
    return TaskEither(
      () async =>
          Right<LucentFailure, MedicineRiskCheckRecords>(await _pending.future),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  ) => TaskEither.right(
    MedicineRiskCheckRecord(
      checkType: type,
      result: const MedicineRiskCheckResult(),
      riskScore: 0,
      riskLevel: MedicineRiskLevel.safe,
      stale: false,
      createdAt: DateTime(2026, 7, 27),
      updatedAt: DateTime(2026, 7, 27),
    ),
  );

  @override
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) => TaskEither.right(const MedicineRiskCheckResult());
}

/// Repository whose records read fails (page-level error state).
class _FailingRecordsRepository implements MedicineRiskCheckRepository {
  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords() =>
      TaskEither.left(
        const LucentFailure(
          kind: LucentFailureKind.server,
          message: 'records unavailable',
          statusCode: 500,
        ),
      );

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  ) => TaskEither.right(
    MedicineRiskCheckRecord(
      checkType: type,
      result: const MedicineRiskCheckResult(),
      riskScore: 0,
      riskLevel: MedicineRiskLevel.safe,
      stale: false,
      createdAt: DateTime(2026, 7, 27),
      updatedAt: DateTime(2026, 7, 27),
    ),
  );

  @override
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) => TaskEither.right(const MedicineRiskCheckResult());
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required MedicineRiskCheckRepository repository,
  double textScale = 1.0,
  bool showToaster = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        medicineRiskCheckRepositoryProvider.overrideWithValue(repository),
      ],
      child: TestForuiApp(
        showToaster: showToaster,
        home: scaledForTextScale(const MedicineRiskCheckPage(), textScale),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Switches to the AI Analysis tab (FTabs animates, so settle two frames).
Future<void> _openLlmTab(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(find.text(l10n.medicineRiskCheckTabLlm));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Taps the AI tab's run button and lets the failure land.
///
/// The run reports through the provider's async state, so the page's branch
/// (unavailable state or failure toast) only shows a few frames after the tap.
Future<void> _runLlm(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(find.text(l10n.medicineRiskCheckRunLlm));
  for (var i = 0; i < 4; i += 1) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Opens the AI Analysis tab and taps its run button.
Future<void> _openLlmTabAndRun(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await _openLlmTab(tester, l10n);
  await _runLlm(tester, l10n);
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  group('AI Analysis tab — failure branches', () {
    testWidgets(
      'shows the unavailable state for a dependency-unavailable 503',
      (tester) async {
        setCompactPhoneScreenSize(tester);
        await _pumpPage(
          tester,
          repository: _FailingRunRepository(
            const LucentFailure(
              kind: LucentFailureKind.server,
              message: 'LLM analysis model is not configured',
              code: 'DEPENDENCY_UNAVAILABLE',
              statusCode: 503,
            ),
          ),
        );

        await _openLlmTabAndRun(tester, l10n);

        expect(find.text(l10n.medicineRiskCheckLlmUnavailable), findsOneWidget);
      },
    );

    testWidgets('keeps the retryable empty state for a connectivity failure', (
      tester,
    ) async {
      setCompactPhoneScreenSize(tester);
      await _pumpPage(
        tester,
        repository: _FailingRunRepository(
          LucentFailure.network(
            message: 'offline',
            networkErrorCode: NetworkErrorCode.connectionError,
          ),
        ),
        showToaster: true,
      );

      await _openLlmTabAndRun(tester, l10n);

      // 离线不是「未配置」:保持可重试的空态,并把失败提示出来。
      expect(find.text(l10n.medicineRiskCheckLlmUnavailable), findsNothing);
      expect(find.text(l10n.medicineRiskCheckLlmEmptyTitle), findsOneWidget);
      expect(
        find.text(NetworkErrorL10n.map(NetworkErrorCode.connectionError, l10n)),
        findsOneWidget,
      );

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
    });

    testWidgets('keeps the retryable empty state for a validation failure', (
      tester,
    ) async {
      setCompactPhoneScreenSize(tester);
      await _pumpPage(
        tester,
        repository: _FailingRunRepository(
          const LucentFailure(
            kind: LucentFailureKind.business,
            message: 'candidate is static-only',
            code: 'VALIDATION_FAILED',
            statusCode: 400,
          ),
        ),
        showToaster: true,
      );

      await _openLlmTabAndRun(tester, l10n);

      expect(find.text(l10n.medicineRiskCheckLlmUnavailable), findsNothing);
      expect(find.text(l10n.medicineRiskCheckLlmEmptyTitle), findsOneWidget);
      expect(find.text('candidate is static-only'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
    });
  });

  group('AI Analysis tab — layout at the narrow widths @1.3', () {
    const viewports = <(String, void Function(WidgetTester))>[
      ('compact 360x800', setCompactPhoneScreenSize),
      ('narrow 320x720', setNarrowPhoneScreenSize),
    ];

    /// Pumps [repository], opens the AI tab, taps run when [runLlm] and asserts
    /// that nothing overflowed.
    ///
    /// [selectLlmTab] is false for the page-level loading/error states: they
    /// replace the tabs, so there is no AI tab to open.
    Future<void> expectNoOverflow(
      WidgetTester tester,
      MedicineRiskCheckRepository repository, {
      required String state,
      bool selectLlmTab = true,
      bool runLlm = false,
    }) async {
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            medicineRiskCheckRepositoryProvider.overrideWithValue(repository),
          ],
          child: TestForuiApp(
            home: scaledForTextScale(const MedicineRiskCheckPage(), 1.3),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      if (runLlm) {
        await _openLlmTabAndRun(tester, l10n);
      } else if (selectLlmTab) {
        await _openLlmTab(tester, l10n);
      }

      // Restore before asserting: an assertion raised while the custom
      // `FlutterError.onError` is installed would mask the overflow reason.
      FlutterError.onError = previous;
      expect(
        overflows,
        isEmpty,
        reason:
            '$state: '
            '${overflows.map((d) => d.exceptionAsString()).join('\n---\n')}',
      );
    }

    for (final (label, apply) in viewports) {
      testWidgets('$label — LLM empty state', (tester) async {
        apply(tester);
        await expectNoOverflow(
          tester,
          _FailingRunRepository(
            const LucentFailure(
              kind: LucentFailureKind.server,
              message: 'unused',
              statusCode: 500,
            ),
          ),
          state: 'LLM empty ($label)',
        );
        expect(find.text(l10n.medicineRiskCheckLlmEmptyTitle), findsOneWidget);
      });

      testWidgets('$label — LLM not-configured state', (tester) async {
        apply(tester);
        await expectNoOverflow(
          tester,
          _FailingRunRepository(
            const LucentFailure(
              kind: LucentFailureKind.server,
              message: 'LLM analysis model is not configured',
              code: 'DEPENDENCY_UNAVAILABLE',
              statusCode: 503,
            ),
          ),
          state: 'LLM not-configured ($label)',
          runLlm: true,
        );
        expect(find.text(l10n.medicineRiskCheckLlmUnavailable), findsOneWidget);
      });

      testWidgets('$label — page loading state', (tester) async {
        apply(tester);
        await expectNoOverflow(
          tester,
          _PendingRecordsRepository(),
          state: 'page loading ($label)',
          selectLlmTab: false,
        );
      });

      testWidgets('$label — page error state', (tester) async {
        apply(tester);
        // 记录读取走 riverpod 默认的指数退避自动重试(10 次 / 上限 6.4s,合计约
        // 40s);先把假时钟推过重试链,页面才落到 StateErrorView。
        await expectNoOverflow(
          tester,
          _FailingRecordsRepository(),
          state: 'page error ($label)',
          selectLlmTab: false,
        );
        await tester.pump(const Duration(seconds: 60));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text(l10n.medicineErrorTitle), findsOneWidget);
      });
    }
  });
}
