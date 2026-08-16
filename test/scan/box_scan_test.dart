import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks/scan.dart';
import '../helpers/test_forui_app.dart';

void main() {
  late MockPaddleOcrEngine mockOcr;
  late FakeImagePickerPlatform fakePicker;
  late MockScanRepository mockRepo;
  late AppLocalizations l10n;
  late String tempImagePath;
  late ImagePickerPlatform originalPicker;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    registerFallbackValue('');

    // 1x1 transparent PNG for Image.file in the result dialog.
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/test_box_scan_image.png');
    tempFile.writeAsBytesSync(const [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);
    tempImagePath = tempFile.path;

    originalPicker = ImagePickerPlatform.instance;
  });

  tearDownAll(() {
    try {
      File(tempImagePath).deleteSync();
    } on FileSystemException {
      // Image.file may still hold the handle on Windows; temp file is harmless.
    }
  });

  setUp(() {
    mockOcr = MockPaddleOcrEngine();
    when(() => mockOcr.ensureInitialized()).thenAnswer((_) async {});
    fakePicker = FakeImagePickerPlatform(imagePath: tempImagePath);
    mockRepo = MockScanRepository();

    ImagePickerPlatform.instance = fakePicker;
  });

  tearDown(() {
    ImagePickerPlatform.instance = originalPicker;
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FButton(
                  onPress: () => showMedicineBoxScanSheet(context),
                  child: const Text('open-scan'),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/medicine/search',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('search-page'))),
        ),
      ],
    );
  }

  Future<void> pumpHarness(WidgetTester tester) async {
    final router = buildRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanRepositoryProvider.overrideWithValue(mockRepo),
          // Bypass the real PaddleOcr engine (process-wide native singleton)
          // — the flow is driven by a mock so widget tests never touch the
          // plugin.
          paddleOcrProvider.overrideWithValue(mockOcr),
        ],
        child: TestForuiRouterApp(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  /// Bounded pumps to get through dialogs and async processing without
  /// hanging on the FCircularProgress overlay animation.
  Future<void> flushAsync(WidgetTester tester, [int times = 8]) async {
    for (var i = 0; i < times; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  Future<void> openMethodPicker(WidgetTester tester) async {
    await pumpHarness(tester);
    await tester.tap(find.text('open-scan'));
    await flushAsync(tester);
  }

  group('showMedicineBoxScanSheet - method picker', () {
    testWidgets('renders OCR and AI options', (tester) async {
      await openMethodPicker(tester);

      expect(find.text(l10n.scanMethodPickerTitle), findsOneWidget);
      expect(find.text(l10n.scanMethodOcrTitle), findsOneWidget);
      expect(find.text(l10n.scanMethodAiTitle), findsOneWidget);
    });
  });

  group('showMedicineBoxScanSheet - OCR flow', () {
    testWidgets(
      'shows unavailable dialog when OCR engine fails to initialise',
      (tester) async {
        when(
          () => mockOcr.ensureInitialized(),
        ).thenThrow(StateError('ABI incompatible'));
        await openMethodPicker(tester);

        await tester.tap(find.text(l10n.scanMethodOcrTitle));
        await flushAsync(tester);

        expect(find.text(l10n.scanOcrUnavailableTitle), findsOneWidget);
        expect(find.text(l10n.scanOcrUnavailableMessage), findsOneWidget);
        // ImagePicker is never reached.
        expect(fakePicker.pickCalls, 0);
      },
    );

    testWidgets('matches OCR text and shows results dialog', (tester) async {
      when(() => mockOcr.recognize(any())).thenAnswer(
        (_) async => const [
          OcrTextBlock(
            text: '阿莫西林胶囊',
            confidence: 0.95,
            boundingBox: Rect.fromLTRB(0, 0, 100, 40),
            points: [
              Offset(0, 0),
              Offset(100, 0),
              Offset(100, 40),
              Offset(0, 40),
            ],
          ),
        ],
      );
      when(() => mockRepo.search('阿莫西林胶囊')).thenAnswer(
        (_) async => const [ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊')],
      );

      await openMethodPicker(tester);
      await tester.tap(find.text(l10n.scanMethodOcrTitle));
      await flushAsync(tester, 12);

      expect(fakePicker.pickCalls, 1);
      verify(() => mockOcr.recognize(tempImagePath)).called(1);
      // The result dialog renders the title twice (dialog header + card header).
      expect(find.text(l10n.scanResultTitle), findsWidgets);
      expect(find.text('阿莫西林胶囊'), findsWidgets);
      verify(() => mockRepo.search('阿莫西林胶囊')).called(1);
    });

    testWidgets(
      'dedupes repeated candidate queries before searching (one search call)',
      (tester) async {
        // Two OCR blocks with the same drug name: the extractor yields two
        // candidates with the same query, dedupeCandidates collapses them, so
        // the DB is searched once (F-4).
        when(() => mockOcr.recognize(any())).thenAnswer(
          (_) async => [
            const OcrTextBlock(
              text: '阿莫西林胶囊',
              confidence: 0.95,
              boundingBox: Rect.fromLTRB(0, 0, 200, 80),
              points: [
                Offset(0, 0),
                Offset(200, 0),
                Offset(200, 80),
                Offset(0, 80),
              ],
            ),
            const OcrTextBlock(
              text: '阿莫西林胶囊',
              confidence: 0.9,
              boundingBox: Rect.fromLTRB(0, 200, 200, 280),
              points: [
                Offset(0, 200),
                Offset(200, 200),
                Offset(200, 280),
                Offset(0, 280),
              ],
            ),
          ],
        );
        when(() => mockRepo.search('阿莫西林胶囊')).thenAnswer(
          (_) async => const [ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊')],
        );

        await openMethodPicker(tester);
        await tester.tap(find.text(l10n.scanMethodOcrTitle));
        await flushAsync(tester, 12);

        expect(find.text('阿莫西林胶囊'), findsWidgets);
        verify(() => mockRepo.search('阿莫西林胶囊')).called(1);
      },
    );

    testWidgets(
      'merges search results with the same medicine id into one dialog entry',
      (tester) async {
        // Two different candidate queries both resolve to the same medicine id
        // (with different display names): mergeSearchResults keeps only the
        // higher-confidence one, so the dialog shows a single entry (F-4).
        when(() => mockOcr.recognize(any())).thenAnswer(
          (_) async => [
            const OcrTextBlock(
              text: '阿莫西林胶囊',
              confidence: 0.95,
              boundingBox: Rect.fromLTRB(0, 0, 200, 80),
              points: [
                Offset(0, 0),
                Offset(200, 0),
                Offset(200, 80),
                Offset(0, 80),
              ],
            ),
            const OcrTextBlock(
              text: '阿莫西林颗粒',
              confidence: 0.9,
              boundingBox: Rect.fromLTRB(0, 200, 150, 260),
              points: [
                Offset(0, 200),
                Offset(150, 200),
                Offset(150, 260),
                Offset(0, 260),
              ],
            ),
          ],
        );
        when(() => mockRepo.search('阿莫西林胶囊')).thenAnswer(
          (_) async => const [ScanSearchResult(id: 'med-1', name: '阿莫西林胶囊')],
        );
        when(() => mockRepo.search('阿莫西林颗粒')).thenAnswer(
          (_) async => const [ScanSearchResult(id: 'med-1', name: '阿莫西林颗粒')],
        );

        await openMethodPicker(tester);
        await tester.tap(find.text(l10n.scanMethodOcrTitle));
        await flushAsync(tester, 12);

        // Merged by id: the higher-confidence name is kept, the other name is
        // gone, and no candidate list (single entry) is rendered.
        expect(find.text('阿莫西林胶囊'), findsOneWidget);
        expect(find.text('阿莫西林颗粒'), findsNothing);
        verify(() => mockRepo.search('阿莫西林胶囊')).called(1);
        verify(() => mockRepo.search('阿莫西林颗粒')).called(1);
      },
    );
  });

  group('showMedicineBoxScanSheet - AI flow', () {
    // The AI branch of _processPhoto (File.readAsBytes → compression →
    // upload) uses real dart:io I/O which never completes inside the
    // FakeAsync test zone, so it is excluded from widget tests (platform
    // bridging, per plan exclusion list). The picker-cancellation path is
    // covered below since it returns before any file I/O.
    testWidgets('cancelled photo pick leaves no dialog behind', (tester) async {
      fakePicker.imagePath = null;

      await openMethodPicker(tester);
      await tester.tap(find.text(l10n.scanMethodAiTitle));
      await flushAsync(tester);

      expect(fakePicker.pickCalls, 1);
      expect(find.text(l10n.scanResultTitle), findsNothing);
      expect(find.text(l10n.scanMethodPickerTitle), findsNothing);
    });
  });
}
