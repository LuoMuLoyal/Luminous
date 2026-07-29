import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late String tempImagePath;

  setUpAll(() {
    // Create a minimal PNG file for Image.file to load
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/test_recognize_image.png');
    // 1x1 transparent PNG
    tempFile.writeAsBytesSync([
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
  });

  tearDownAll(() {
    File(tempImagePath).deleteSync();
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    required List<MedicineMatchResult> results,
    VoidCallback? onRetake,
  }) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MedicineRecognizeDialog(
            imagePath: tempImagePath,
            methodLabel: 'OCR',
            results: results,
            onRetake: onRetake ?? () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('MedicineRecognizeDialog', () {
    testWidgets('renders dialog title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(tester, results: []);

      expect(find.text(l10n.scanResultTitle), findsWidgets);
    });

    testWidgets('renders no result message when results empty', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(tester, results: []);

      expect(find.text(l10n.scanNoResultTitle), findsOneWidget);
    });

    testWidgets('renders top result name', (tester) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: '阿莫西林胶囊',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-1',
          ),
        ],
      );

      expect(find.text('阿莫西林胶囊'), findsWidgets);
    });

    testWidgets('renders top result approval number', (tester) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: '阿莫西林胶囊',
            approvalNumber: '国药准字H12345678',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-1',
          ),
        ],
      );

      expect(find.text('国药准字H12345678'), findsOneWidget);
    });

    testWidgets('renders confidence percentage', (tester) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: 'Test',
            confidence: 0.85,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-1',
          ),
        ],
      );

      expect(find.textContaining('85%'), findsOneWidget);
    });

    testWidgets('renders retake button', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(tester, results: []);

      expect(find.text(l10n.scanRetakeAction), findsOneWidget);
    });

    testWidgets('renders confirm button', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: 'Test',
            confidence: 0.9,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-1',
          ),
        ],
      );

      expect(find.text(l10n.scanConfirmDetailAction), findsOneWidget);
    });

    testWidgets('shows candidate list expander when multiple results', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: '药品A',
            confidence: 0.9,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-1',
          ),
          const MedicineMatchResult(
            name: '药品B',
            confidence: 0.8,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-2',
          ),
        ],
      );

      expect(find.textContaining('从列表选择其他匹配'), findsOneWidget);
    });

    testWidgets('does not show candidate list expander for single result', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: '药品A',
            confidence: 0.9,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-1',
          ),
        ],
      );

      expect(find.textContaining('从列表选择其他匹配'), findsNothing);
    });

    testWidgets('expands candidate list on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: '药品A',
            confidence: 0.9,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-1',
          ),
          const MedicineMatchResult(
            name: '药品B',
            confidence: 0.8,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-2',
          ),
        ],
      );

      // Candidate list not visible initially
      expect(find.byIcon(SemanticIcons.actionExpand), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionCollapse), findsNothing);

      // Tap to expand
      await tester.tap(find.textContaining('从列表选择其他匹配'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.byIcon(SemanticIcons.actionCollapse), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionExpand), findsNothing);
    });

    testWidgets('candidate list shows sorted results by confidence', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: 'LowConfidence',
            confidence: 0.5,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-low',
          ),
          const MedicineMatchResult(
            name: 'HighConfidence',
            confidence: 0.95,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-high',
          ),
        ],
      );

      // Expand candidate list
      await tester.tap(find.textContaining('从列表选择其他匹配'));
      await tester.pumpAndSettle();

      // HighConfidence should appear (sorted first by confidence desc)
      expect(find.text('HighConfidence'), findsWidgets);
      expect(find.text('LowConfidence'), findsWidgets);
    });

    testWidgets('deduplicates results by name in candidate list', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: 'SameDrug',
            confidence: 0.9,
            matchType: MedicineMatchType.approvalNumber,
            id: 'med-1',
          ),
          const MedicineMatchResult(
            name: 'SameDrug',
            confidence: 0.8,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-2',
          ),
        ],
      );

      // With dedup, there's only 1 unique name, so no expander
      expect(find.textContaining('从列表选择其他匹配'), findsNothing);
    });

    testWidgets('renders source label', (tester) async {
      await pumpDialog(
        tester,
        results: [
          const MedicineMatchResult(
            name: 'Test',
            confidence: 0.9,
            matchType: MedicineMatchType.nameFuzzy,
            id: 'med-1',
          ),
        ],
      );

      expect(find.textContaining('OCR'), findsOneWidget);
    });
  });
}
