import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/pages/barcode_scanner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import '../helpers/mocks/scan.dart';
import '../helpers/test_forui_app.dart';

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

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/scan/barcode',
      routes: [
        GoRoute(
          path: '/scan/barcode',
          builder: (_, _) => const BarcodeScannerPage(),
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
      ],
    );
  }

  Future<void> pumpPage(WidgetTester tester) async {
    final router = buildRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [scanRepositoryProvider.overrideWithValue(mockRepo)],
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

      await tester.tap(find.byIcon(SemanticIcons.safetyAllergy));
      await tester.pump(const Duration(milliseconds: 150));

      expect(fakeScanner.toggleTorchCalls, 1);
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
    testWidgets('single result navigates to medicine detail', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) async => const [ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊')],
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('medicine-detail:cn:med-1'), findsOneWidget);
      verify(() => mockRepo.search('6901234567890')).called(1);
      expect(fakeScanner.stopCalls, 1);
    });

    testWidgets('multiple results show candidate picker sheet', (tester) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) async => const [
          ScanSearchResult(id: 'med-1', name: '药品甲'),
          ScanSearchResult(id: 'med-2', name: '药品乙'),
        ],
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.scanCandidateSheetTitle), findsOneWidget);
      expect(find.text('药品甲'), findsOneWidget);
      expect(find.text('药品乙'), findsOneWidget);
    });

    testWidgets('candidate selection navigates to medicine detail', (
      tester,
    ) async {
      when(() => mockRepo.search('6901234567890')).thenAnswer(
        (_) async => const [
          ScanSearchResult(id: 'med-1', name: '药品甲'),
          ScanSearchResult(id: 'med-2', name: '药品乙'),
        ],
      );
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.scanCandidateSheetTitle), findsOneWidget);

      await tester.tap(find.text('药品乙'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('medicine-detail:cn:med-2'), findsOneWidget);
    });

    testWidgets('empty result shows toast and resumes scanning', (
      tester,
    ) async {
      when(
        () => mockRepo.search('6901234567890'),
      ).thenAnswer((_) async => const <ScanSearchResult>[]);
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));

      // Scanning resumed -> guide hint visible again and camera restarted.
      expect(find.text(l10n.scanGuideHint), findsOneWidget);
      expect(fakeScanner.startCalls, 2);
    });

    testWidgets('search error shows toast and resumes scanning', (
      tester,
    ) async {
      when(
        () => mockRepo.search('6901234567890'),
      ).thenThrow(Exception('network down'));
      await pumpPage(tester);

      await emitBarcode(tester, '6901234567890');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(l10n.scanGuideHint), findsOneWidget);
      expect(fakeScanner.startCalls, 2);
    });

    testWidgets('barcode without raw value is ignored', (tester) async {
      await pumpPage(tester);

      await emitBarcode(tester, null);

      verifyNever(() => mockRepo.search('6901234567890'));
    });
  });
}
