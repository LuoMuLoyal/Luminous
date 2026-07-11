import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/ocr_entry_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    RecordOcrImagePicker? pickImage,
    RecordOcrRecognizer? recognizeText,
  }) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showRecordOcrEntrySheet(
                context,
                pickImage: pickImage ?? (_) async => null,
                recognizeText: recognizeText ??
                    (_, __) async => '',
              ),
              child: const Text('open-sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders title and close button', (tester) async {
    await pumpSheet(tester);

    expect(find.text(l10n.recordOcrEntryTitle), findsOneWidget);
    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
  });

  testWidgets('renders camera and gallery options', (tester) async {
    await pumpSheet(tester);

    expect(find.text(l10n.recordOcrCameraAction), findsOneWidget);
    expect(find.text(l10n.recordOcrGalleryAction), findsOneWidget);
  });

  testWidgets('close button dismisses sheet', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byIcon(FLucideIcons.x));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recordOcrEntryTitle), findsNothing);
  });

  testWidgets('returns null when image picker returns null', (tester) async {
    String? result;

    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showRecordOcrEntrySheet(
                  context,
                  pickImage: (_) async => null,
                  recognizeText: (_, __) async => '',
                );
              },
              child: const Text('open-sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('shows recognized text after recognition', (tester) async {
    await pumpSheet(
      tester,
      pickImage: (_) async => XFile('test.jpg'),
      recognizeText: (_, __) async => 'Recognized text content',
    );

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    expect(find.text('Recognized text content'), findsOneWidget);
  });

  testWidgets('shows use text button after recognition', (tester) async {
    await pumpSheet(
      tester,
      pickImage: (_) async => XFile('test.jpg'),
      recognizeText: (_, __) async => 'Some text',
    );

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recordVoiceUseText), findsOneWidget);
  });

  testWidgets('use text button returns recognized text', (tester) async {
    String? result;

    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showRecordOcrEntrySheet(
                  context,
                  pickImage: (_) async => XFile('test.jpg'),
                  recognizeText: (_, __) async => 'Final text',
                );
              },
              child: const Text('open-sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.recordVoiceUseText));
    await tester.pumpAndSettle();

    expect(result, 'Final text');
  });

  testWidgets('shows empty candidates message when recognition returns empty', (tester) async {
    await pumpSheet(
      tester,
      pickImage: (_) async => XFile('test.jpg'),
      recognizeText: (_, __) async => '',
    );

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    expect(find.text(l10n.recordNlpEmptyCandidatesToast), findsOneWidget);
  });

  testWidgets('use text button disabled when recognized text is empty', (tester) async {
    await pumpSheet(
      tester,
      pickImage: (_) async => XFile('test.jpg'),
      recognizeText: (_, __) async => '',
    );

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    // Use text button should be present but disabled
    final button = tester.widget<FButton>(
      find.ancestor(
        of: find.text(l10n.recordVoiceUseText),
        matching: find.byType(FButton),
      ),
    );
    expect(button.onPress, isNull);
  });

  testWidgets('use text button disabled when recognized text is whitespace', (tester) async {
    await pumpSheet(
      tester,
      pickImage: (_) async => XFile('test.jpg'),
      recognizeText: (_, __) async => '   ',
    );

    await tester.tap(find.text(l10n.recordOcrCameraAction));
    await tester.pumpAndSettle();

    final button = tester.widget<FButton>(
      find.ancestor(
        of: find.text(l10n.recordVoiceUseText),
        matching: find.byType(FButton),
      ),
    );
    expect(button.onPress, isNull);
  });

  testWidgets('gallery option triggers pickAndRecognize', (tester) async {
    var galleryCalled = false;

    await pumpSheet(
      tester,
      pickImage: (source) async {
        if (source == ImageSource.gallery) galleryCalled = true;
        return XFile('gallery.jpg');
      },
      recognizeText: (_, __) async => 'Gallery text',
    );

    await tester.tap(find.text(l10n.recordOcrGalleryAction));
    await tester.pumpAndSettle();

    expect(galleryCalled, isTrue);
    expect(find.text('Gallery text'), findsOneWidget);
  });
}
