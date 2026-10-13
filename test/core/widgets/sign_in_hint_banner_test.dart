import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_forui_app.dart';

/// Regression coverage for the sign-in hint banner on narrow phones with a
/// large app font tier.
///
/// Real-device report: on a 393dp phone the "sign in to see your real data"
/// message wrapped onto four lines and pushed the whole banner taller, because
/// icon + message + button shared a single [Row] and the message — the only
/// flex child — absorbed all the compression.
void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  /// Pumps the banner at [width] under [textScale], mirroring the real device
  /// (393dp, large tier) that surfaced the bug.
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

  testWidgets('message stays on one line at 393dp with the large font tier', (
    tester,
  ) async {
    await pumpBanner(tester, width: 393, textScale: 1.15);

    final message = tester.widget<Text>(find.text(l10n.statePreviewSignInHint));
    expect(message.maxLines, isNull, reason: 'copy must not be hard-clamped');

    // The message renders as a single line. Measuring the laid-out paragraph
    // is the invariant that actually broke: on the buggy single-Row layout the
    // message was squeezed into 4 lines and the banner grew to fit them.
    final lineCount = _renderedLineCount(
      tester,
      find.text(l10n.statePreviewSignInHint),
    );
    expect(
      lineCount,
      1,
      reason: 'message must not wrap onto multiple lines on a narrow phone',
    );
  });

  testWidgets('no overflow at the narrowest supported width', (tester) async {
    await pumpBanner(tester, width: 320, textScale: 1.3);

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.statePreviewSignInHint), findsOneWidget);
    expect(find.text(l10n.statePreviewSignInAction), findsOneWidget);
  });

  testWidgets('keeps message and action side by side on a wide screen', (
    tester,
  ) async {
    await pumpBanner(tester, width: 600, textScale: 1.0);

    final messageBox = tester.getRect(find.text(l10n.statePreviewSignInHint));
    final actionBox = tester.getRect(find.text(l10n.statePreviewSignInAction));

    // Same visual row: their vertical extents overlap.
    expect(
      messageBox.top < actionBox.bottom && actionBox.top < messageBox.bottom,
      isTrue,
      reason: 'wide layouts keep the compact single-row presentation',
    );
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
