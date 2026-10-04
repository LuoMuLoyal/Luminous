import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/pages/barcode_scanner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import '../auth/test_helpers.dart';
import '../helpers/mocks/health_context.dart';
import '../helpers/mocks/scan.dart';
import '../helpers/test_forui_app.dart';
// Prefixed: the auth test helpers below also export session notifiers.
import '../helpers/test_helpers.dart' as screen;

void main() {
  late FakePermissionHandlerPlatform fakePermission;
  late FakeMobileScannerPlatform fakeScanner;
  late MockScanRepository mockRepo;
  late AppLocalizations l10n;
  late PermissionHandlerPlatform originalPermission;
  late MobileScannerPlatform originalScanner;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    originalPermission = PermissionHandlerPlatform.instance;
    originalScanner = MobileScannerPlatform.instance;
  });

  setUp(() {
    fakePermission = FakePermissionHandlerPlatform(
      status: PermissionStatus.granted,
    );
    fakeScanner = FakeMobileScannerPlatform();
    mockRepo = MockScanRepository();
    PermissionHandlerPlatform.instance = fakePermission;
    MobileScannerPlatform.instance = fakeScanner;
  });

  tearDown(() async {
    PermissionHandlerPlatform.instance = originalPermission;
    MobileScannerPlatform.instance = originalScanner;
    await fakeScanner.close();
  });

  GoRouter buildRouter({double textScale = 1.0}) {
    return GoRouter(
      initialLocation: '/scan/barcode',
      routes: [
        GoRoute(
          path: '/scan/barcode',
          // Toasts (added-to-box / precheck unavailable) need an FToaster
          // above the page, mirroring the production bootstrap.
          builder: (_, _) => screen.scaledForTextScale(
            const FToaster(child: BarcodeScannerPage()),
            textScale,
          ),
        ),
        GoRoute(
          path: '/medicine/search',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('search-page'))),
        ),
        GoRoute(
          path: '/medicine/detail/:source/:id',
          builder: (_, state) => Scaffold(
            body: Center(
              child: Text(
                'medicine-detail:${state.pathParameters['source']}:'
                '${state.pathParameters['id']}',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/medicine/reminders/:medicineId',
          builder: (_, state) => Scaffold(
            body: Center(
              child: Text(
                'medicine-reminders:${state.pathParameters['medicineId']}',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (_, state) => Scaffold(
            body: Text("login-page:${state.uri.queryParameters['return-to']}"),
          ),
        ),
      ],
    );
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    List<Override> overrides = const [],
    double textScale = 1.0,
  }) async {
    final router = buildRouter(textScale: textScale);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanRepositoryProvider.overrideWithValue(mockRepo),
          ...overrides,
        ],
        child: TestForuiRouterApp(routerConfig: router),
      ),
    );
    // Let _initScanner() resolve and the camera controller start.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Bounded pumps through the async detect chain (avoids pumpAndSettle,
  /// which hangs on the FCircularProgress spinner while scanning).
  Future<void> flushAsync(WidgetTester tester, [int times = 6]) async {
    for (var i = 0; i < times; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> emitBarcode(WidgetTester tester, String? rawValue) async {
    fakeScanner.barcodes.add(
      BarcodeCapture(
        barcodes: [Barcode(rawValue: rawValue, type: BarcodeType.text)],
      ),
    );
    await flushAsync(tester);
  }

  /// Stub snapshot with a single current medicine (cn source) in the box.
  HealthContextSnapshot boxSnapshotWith(CurrentMedicineItem item) {
    return testHealthSnapshot(currentMedicines: [item]);
  }

  CurrentMedicineItem boxItem({
    String id = 'box-med-1',
    String sourceRefId = 'med-1',
    String displayName = '阿莫西林胶囊',
  }) {
    return CurrentMedicineItem(
      id: id,
      source: 'cn',
      sourceRefId: sourceRefId,
      displayName: displayName,
      strengthText: null,
      doseText: null,
      route: null,
      startedAt: null,
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-08-16T00:00:00.000Z',
      updatedAt: '2026-08-16T00:00:00.000Z',
    );
  }

  group('BarcodeScannerPage - permission', () {
    testWidgets(
      'shows error view when camera permission is permanently denied',
      (tester) async {
        fakePermission.status = PermissionStatus.permanentlyDenied;
        await pumpPage(tester);

        expect(find.text(l10n.scanPermissionDeniedTitle), findsOneWidget);
        expect(find.text(l10n.scanPermissionDeniedHint), findsOneWidget);

        await tester.tap(find.text(l10n.scanPermissionOpenSettings));
        await tester.pump(const Duration(milliseconds: 150));
        expect(fakePermission.openAppSettingsCalls, 1);
      },
    );

    testWidgets('shows error view when permission request is denied', (
      tester,
    ) async {
      fakePermission.status = PermissionStatus.denied;
      fakePermission.requestResult = PermissionStatus.denied;
      await pumpPage(tester);

      expect(find.text(l10n.scanPermissionDeniedTitle), findsOneWidget);
    });

    testWidgets('re-initialises scanner on resume after permission restored', (
      tester,
    ) async {
      fakePermission.status = PermissionStatus.permanentlyDenied;
      await pumpPage(tester);
      expect(find.text(l10n.scanPermissionDeniedTitle), findsOneWidget);

      // User grants permission in system settings, then returns to the app.
      fakePermission.status = PermissionStatus.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MobileScanner), findsOneWidget);
      expect(fakeScanner.startCalls, 1);
    });
  });

  group('BarcodeScannerPage - camera rendering', () {
    testWidgets('renders scanner with guide hint when granted', (tester) async {
      await pumpPage(tester);

      expect(find.byType(MobileScanner), findsOneWidget);
      expect(find.text(l10n.scanGuideHint), findsOneWidget);
      expect(find.text(l10n.scanManualSearchAction), findsOneWidget);
      expect(fakeScanner.startCalls, 1);
    });

    testWidgets('torch button toggles the torch', (tester) async {
      await pumpPage(tester);

      // Off state shows the flashlight-off icon.
      expect(find.byIcon(FLucideIcons.flashlightOff), findsOneWidget);

      await tester.tap(find.byIcon(FLucideIcons.flashlightOff));
      await tester.pump(const Duration(milliseconds: 150));

      expect(fakeScanner.toggleTorchCalls, 1);
      expect(find.byIcon(FLucideIcons.flashlight), findsOneWidget);

      // Toggling again returns to the off state.
      await tester.tap(find.byIcon(FLucideIcons.flashlight));
      await tester.pump(const Duration(milliseconds: 150));

      expect(fakeScanner.toggleTorchCalls, 2);
      expect(find.byIcon(FLucideIcons.flashlightOff), findsOneWidget);
    });

    testWidgets('manual search button navigates to search page', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.text(l10n.scanManualSearchAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('search-page'), findsOneWidget);
    });
  });

  group('BarcodeScannerPage - detection', () {
    testWidgets('single result shows the scan result sheet instead of '
        'navigating directly', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊'),
        ]),
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      // The result sheet replaces the direct medicine-detail jump.
      expect(find.text(l10n.scanBarcodeResultTitle), findsOneWidget);
      expect(find.text('阿莫西林胶囊'), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);
      expect(find.text(l10n.scanViewInstructionsAction), findsOneWidget);
      expect(find.textContaining('medicine-detail:'), findsNothing);
      verify(() => mockRepo.search('6901234567890')).called(1);
      expect(fakeScanner.stopCalls, 1);
    });

    testWidgets('single result view instructions opens medicine detail', (
      tester,
    ) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊'),
        ]),
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text(l10n.scanViewInstructionsAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('medicine-detail:cn:med-1'), findsOneWidget);
    });

    testWidgets('single result add to box shows auth dialog when signed out', (
      tester,
    ) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊'),
        ]),
      );
      await pumpPage(
        tester,
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
      );

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);

      // Cancel keeps the user on the scan page with the sheet still open.
      await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
      expect(find.byType(MobileScanner), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);
    });

    testWidgets('single result add to box writes cn medicine through the '
        'shared loop', (tester) async {
      final fakeRepo = FakeHealthContextRepository()
        ..reflectCreatedMedicine = true;
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊'),
        ]),
      );
      await pumpPage(
        tester,
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextRepositoryProvider.overrideWithValue(fakeRepo),
          medicineRiskCheckRepositoryProvider.overrideWithValue(
            FakeMedicineRiskCheckRepository(clearRiskCheckResult),
          ),
        ],
      );

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final input = fakeRepo.createdCurrentMedicine;
      expect(input, isNotNull);
      expect(input!.source, HealthMedicineSource.cn);
      expect(input.sourceRefId, 'med-1');
      expect(input.displayName, '阿莫西林胶囊');

      // The sheet stays open so the success toast is visible on top.
      expect(find.text(l10n.scanBarcodeResultTitle), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddedToBoxToast), findsOneWidget);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('already added result shows added state and opens reminder '
        'detail with the box record id', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊'),
        ]),
      );
      await pumpPage(
        tester,
        overrides: [
          healthContextSnapshotProvider.overrideWith(
            (ref) async => boxSnapshotWith(boxItem()),
          ),
        ],
      );

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      // Added state: no "add to box", but the already-added badge plus the
      // reminder detail action.
      expect(find.text(l10n.medicineSearchAlreadyAddedLabel), findsOneWidget);
      expect(find.text(l10n.scanViewReminderAction), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsNothing);

      await tester.tap(find.text(l10n.scanViewReminderAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Must carry the drugbox record id, not the medicine DB product id.
      expect(find.text('medicine-reminders:box-med-1'), findsOneWidget);
    });

    testWidgets('sheet flips to the added state after a successful add '
        '(live dedup, no reopen)', (tester) async {
      // F-3 P2-1: the sheet derives the added state live from the snapshot
      // provider. After the shared loop creates the medicine and emits on
      // the DataChangeBus, the snapshot re-fetch must flip the sheet into
      // the「已加入」state — the add button disappears, so it cannot be tapped
      // again to duplicate the record.
      final fakeRepo = FakeHealthContextRepository()
        ..reflectCreatedMedicine = true;
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊'),
        ]),
      );
      await pumpPage(
        tester,
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextRepositoryProvider.overrideWithValue(fakeRepo),
          medicineRiskCheckRepositoryProvider.overrideWithValue(
            FakeMedicineRiskCheckRepository(clearRiskCheckResult),
          ),
          // Mirror the production provider: re-fetch from the repository when
          // the cross-feature data change bus bumps these topics (the shared
          // add-to-box loop emits `currentMedicines` after a successful add).
          healthContextSnapshotProvider.overrideWith((ref) async {
            ref.watch(
              dataChangeVersionProvider(DataChangeTopic.currentMedicines),
            );
            ref.watch(dataChangeVersionProvider(DataChangeTopic.healthContext));
            final result = await ref
                .read(healthContextRepositoryProvider)
                .fetchHealthContext()
                .run();
            return result.fold(
              (failure) => throw failure,
              (snapshot) => snapshot,
            );
          }),
        ],
      );

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      // Not added yet: the primary action adds to the box.
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);

      await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
      await tester.pump();
      await flushAsync(tester);

      // Without reopening the sheet, the live snapshot watch flipped the
      // primary action into the disabled added state + reminder detail.
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsNothing);
      expect(find.text(l10n.medicineSearchAlreadyAddedLabel), findsOneWidget);
      expect(find.text(l10n.scanViewReminderAction), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddedToBoxToast), findsOneWidget);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('multiple results show candidate picker sheet', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '药品甲'),
          ScanSearchResult(id: 'med-2', name: '药品乙'),
        ]),
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.scanCandidateSheetTitle), findsOneWidget);
      expect(find.text('药品甲'), findsOneWidget);
      expect(find.text('药品乙'), findsOneWidget);
    });

    testWidgets('candidate selection opens the result sheet and can view '
        'instructions', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          ScanSearchResult(id: 'med-1', name: '药品甲'),
          ScanSearchResult(id: 'med-2', name: '药品乙'),
        ]),
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.scanCandidateSheetTitle), findsOneWidget);

      await tester.tap(find.text('药品乙'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // The picker is replaced by the result sheet for the picked candidate.
      expect(find.text(l10n.scanCandidateSheetTitle), findsNothing);
      expect(find.text(l10n.scanBarcodeResultTitle), findsOneWidget);
      expect(find.text('药品乙'), findsOneWidget);
      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);

      await tester.tap(find.text(l10n.scanViewInstructionsAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('medicine-detail:cn:med-2'), findsOneWidget);
    });

    // ── Failure / retry contract ─────────────────────────────────
    //
    // A failed attempt emits exactly one failure signal (the toast), leaves the
    // camera stopped, and never re-arms itself; only the explicit「重试」button
    // starts a new attempt. These three cases replace the previous
    //「…resumes scanning」assertions, which pinned the removed rapid-retry
    // behaviour (`startCalls == 2` right after the failure toast).

    testWidgets('empty result: one failure toast, camera stays stopped, and no '
        'automatic re-recognition within the window', (tester) async {
      when(
        () => mockRepo.search('6901234567890'),
      ).thenAnswer((_) => TaskEither.right(const <ScanSearchResult>[]));
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));

      // Exactly one failure signal.
      expect(find.text(l10n.scanBarcodeNotFoundToast), findsOneWidget);
      // The camera was stopped for the search and is NOT restarted.
      expect(fakeScanner.stopCalls, 1);
      expect(fakeScanner.startCalls, 1);
      expect(find.text(l10n.scanGuideHint), findsOneWidget);
      // Recovery is an explicit user action.
      expect(find.text(l10n.scanRetryAction), findsOneWidget);

      // Frames that keep arriving with the unrecognised barcode still inside
      // the scan frame must not start another recognition: over a 10s window
      // neither the repository nor the camera is touched again. This is the
      // regression the rapid-retry loop produced (a search per frame, as fast
      // as the round trip).
      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(seconds: 5));
      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(seconds: 5));

      verify(() => mockRepo.search('6901234567890')).called(1);
      expect(fakeScanner.stopCalls, 1);
      expect(fakeScanner.startCalls, 1);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('search Left: one failure toast, camera stays stopped, and no '
        'automatic re-recognition within the window', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.left(
          LucentFailure.network(
            message: 'network down',
            networkErrorCode: NetworkErrorCode.connectionError,
          ),
        ),
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(l10n.scanRecognitionFailedToast), findsOneWidget);
      expect(fakeScanner.stopCalls, 1);
      expect(fakeScanner.startCalls, 1);
      expect(find.text(l10n.scanRetryAction), findsOneWidget);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(seconds: 5));

      verify(() => mockRepo.search('6901234567890')).called(1);
      expect(fakeScanner.startCalls, 1);

      // Drain the failed-toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('frames arriving while a recognition is in flight do not start '
        'another recognition', (tester) async {
      final gate = Completer<List<ScanSearchResult>>();
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither<LucentFailure, List<ScanSearchResult>>(
          () async => Right(await gate.future),
        ),
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 50));

      // In flight:「识别中…」and the camera is stopped.
      expect(find.text(l10n.scanRecognizingHint), findsOneWidget);
      expect(fakeScanner.stopCalls, 1);

      // More frames of the same barcode while the repository call is open.
      await emitBarcode(tester, '6901234567890');
      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => mockRepo.search('6901234567890')).called(1);
      expect(fakeScanner.stopCalls, 1);

      // The single in-flight attempt is the one that resolves into the one
      // failure toast (mocktail reports a call as verified only once, hence
      // the single `verify` above).
      gate.complete(const <ScanSearchResult>[]);
      await flushAsync(tester);

      expect(find.text(l10n.scanBarcodeNotFoundToast), findsOneWidget);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('failed attempt re-arms only through the explicit retry '
        'button, which allows a new recognition', (tester) async {
      when(
        () => mockRepo.search('6901234567890'),
      ).thenAnswer((_) => TaskEither.right(const <ScanSearchResult>[]));
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeScanner.startCalls, 1);
      expect(find.text(l10n.scanRetryAction), findsOneWidget);

      await tester.tap(find.text(l10n.scanRetryAction));
      await tester.pump();

      // The explicit tap re-arms the camera exactly once and the retry
      // affordance disappears while scanning again.
      expect(fakeScanner.startCalls, 2);
      expect(find.text(l10n.scanRetryAction), findsNothing);

      // A new barcode now starts a second attempt.
      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockRepo.search('6901234567890')).called(2);
      expect(fakeScanner.stopCalls, 2);
      expect(find.text(l10n.scanBarcodeNotFoundToast), findsOneWidget);

      // Drain the toast auto-dismiss timer.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('barcode without raw value is ignored', (tester) async {
      await pumpPage(tester);

      await emitBarcode(tester, null);

      verifyNever(() => mockRepo.search('6901234567890'));
    });
  });

  // ── Compact width + largest app text scale ──────────────────────
  //
  // The narrow-width layout pass (360 dp / 320 dp @ the app's largest
  // accessibility scale, 1.3) did not cover the scan page or its result sheet.
  // Same collector idiom as test/a11y/compact_text_scale_sweep_test.dart; the
  // failure-state bottom bar is the newest layout here, so it is swept too.
  group('BarcodeScannerPage - compact width @ textScale 1.3', () {
    /// Applies [viewport], runs [body], and asserts no `RenderFlex overflowed`
    /// error was reported while it ran.
    Future<void> expectNoOverflow(
      WidgetTester tester,
      void Function(WidgetTester) viewport,
      Future<void> Function() body,
    ) async {
      viewport(tester);
      final overflows = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) {
          overflows.add(details);
        } else {
          previous?.call(details);
        }
      };
      try {
        await body();
      } finally {
        // Restore before asserting: a failure raised while the custom handler
        // is installed would surface as a binding error instead of the reason.
        FlutterError.onError = previous;
      }
      expect(
        overflows,
        isEmpty,
        reason: overflows.map((d) => d.exceptionAsString()).join('\n---\n'),
      );
    }

    Future<void> pumpFailureState(WidgetTester tester) async {
      when(
        () => mockRepo.search('6901234567890'),
      ).thenAnswer((_) => TaskEither.right(const <ScanSearchResult>[]));
      await pumpPage(tester, textScale: _sweepTextScale);
      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(l10n.scanRetryAction), findsOneWidget);

      // Drain the toast auto-dismiss timer before leaving the zone.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('scan page failure state fits at 360x800', (tester) async {
      await expectNoOverflow(
        tester,
        screen.setCompactPhoneScreenSize,
        () async {
          await pumpFailureState(tester);
        },
      );
    });

    testWidgets('scan page failure state fits at 320x720', (tester) async {
      await expectNoOverflow(tester, screen.setNarrowPhoneScreenSize, () async {
        await pumpFailureState(tester);
      });
    });

    Future<void> pumpResultSheet(WidgetTester tester, {required bool added}) {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) => TaskEither.right(const [
          // A real cn product name/subtitle pair: long enough to wrap.
          ScanSearchResult(
            id: 'med-1',
            name: '复方氨酚烷胺片(对乙酰氨基酚/金刚烷胺/人工牛黄)',
            subtitle: '12片/盒 · 国药准字H20003781',
          ),
        ]),
      );
      return pumpPage(
        tester,
        textScale: _sweepTextScale,
        overrides: [
          if (added)
            healthContextSnapshotProvider.overrideWith(
              (ref) async => boxSnapshotWith(boxItem()),
            ),
        ],
      ).then((_) async {
        await emitBarcode(tester, '6901234567890');
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text(l10n.scanBarcodeResultTitle), findsOneWidget);
      });
    }

    testWidgets('result sheet fits at 360x800', (tester) async {
      await expectNoOverflow(
        tester,
        screen.setCompactPhoneScreenSize,
        () async {
          await pumpResultSheet(tester, added: false);
        },
      );
    });

    testWidgets('result sheet (already-added state) fits at 320x720', (
      tester,
    ) async {
      await expectNoOverflow(tester, screen.setNarrowPhoneScreenSize, () async {
        await pumpResultSheet(tester, added: true);
      });
    });
  });
}

/// The app's largest accessibility font scale (`FontSizePreference.extraLarge`).
const double _sweepTextScale = 1.3;

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}
