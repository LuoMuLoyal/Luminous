import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/kv_test_store.dart';
import '../../helpers/test_forui_app.dart';

/// Regression coverage for the sign-in hint banner: it is a **single row** —
/// lock icon, message and action button never split across lines.
///
/// Two earlier bugs are guarded here:
/// - the message used to absorb all compression (4-line wrap on a narrow phone
///   with a large font tier);
/// - the "does it fit on one line?" pre-check measured the button by its
///   `maxWidth` (160) instead of its real width, so on a 480dp screen it
///   wrongly fell back to a two-row layout (observed on the HarmonyOS shell,
///   2026-11-04). Space is now redistributed by truncating the message.
void main() {
  setUp(() {
    KvTestStore.install();
  });

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  /// Pumps the banner at [width] under [textScale], mirroring the real devices
  /// that surfaced the two bugs above.
  Future<void> pumpBanner(
    WidgetTester tester, {
    required double width,
    required double textScale,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SignInHintBanner(onSignIn: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Message and action must share the same visual row: their vertical extents
  /// overlap. A two-row fallback puts them on disjoint bands.
  void expectSingleRow(WidgetTester tester) {
    final messageBox = tester.getRect(find.text(l10n.statePreviewSignInHint));
    final actionBox = tester.getRect(find.text(l10n.statePreviewSignInAction));
    expect(
      messageBox.top < actionBox.bottom && actionBox.top < messageBox.bottom,
      isTrue,
      reason: 'the banner must stay on one row',
    );
  }

  testWidgets('stays on one row at 393dp with the large font tier', (
    tester,
  ) async {
    await pumpBanner(tester, width: 393, textScale: 1.15);

    final message = tester.widget<Text>(find.text(l10n.statePreviewSignInHint));
    expect(message.maxLines, 1, reason: 'copy truncates instead of wrapping');
    expect(message.overflow, TextOverflow.ellipsis);

    // The message renders as a single line. Measuring the laid-out paragraph
    // is the invariant that actually broke: the old layout squeezed it into
    // 4 lines and pushed the banner taller.
    final lineCount = _renderedLineCount(
      tester,
      find.text(l10n.statePreviewSignInHint),
    );
    expect(
      lineCount,
      1,
      reason: 'message must not wrap onto multiple lines on a narrow phone',
    );
    expectSingleRow(tester);
  });

  testWidgets('no overflow at the narrowest supported width', (tester) async {
    await pumpBanner(tester, width: 320, textScale: 1.3);

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.statePreviewSignInHint), findsOneWidget);
    expect(find.text(l10n.statePreviewSignInAction), findsOneWidget);
    expectSingleRow(tester);
  });

  testWidgets('keeps message and action side by side on a wide screen', (
    tester,
  ) async {
    await pumpBanner(tester, width: 600, textScale: 1.0);

    expectSingleRow(tester);
  });

  testWidgets('action button stays on one line at the narrowest width', (
    tester,
  ) async {
    await pumpBanner(tester, width: 320, textScale: 1.3);

    final action = tester.widget<Text>(
      find.text(l10n.statePreviewSignInAction),
    );
    expect(action.maxLines, 1);
    expect(action.overflow, TextOverflow.ellipsis);
  });
}

/// Number of lines the [Text] identified by [finder] actually laid out.
///
/// Uses the rendered paragraph height divided by the font's line height, which
/// is stable regardless of the exact copy or locale.
int _renderedLineCount(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final lineHeight = paragraph.text.style?.fontSize == null
      ? paragraph.size.height
      : (paragraph.text.style!.fontSize! *
            (paragraph.text.style!.height ?? 1.2));
  return (paragraph.size.height / lineHeight).round();
}
