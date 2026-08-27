import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/review/presentation/utils/review_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

/// TestForuiApp 加载 AppLocalizations（zh），顺带初始化 intl 的 zh 日期符号，
/// 与真实运行时一致。
void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return capturedContext;
  }

  testWidgets('reviewShortDateLabel formats a valid contract date', (
    tester,
  ) async {
    final context = await pumpContext(tester);

    final label = reviewShortDateLabel(context, '2026-08-02');
    expect(label, contains('月'));
    expect(label, contains('2'));
  });

  testWidgets(
    'reviewShortDateLabel falls back to the raw string when unparsable',
    (tester) async {
      final context = await pumpContext(tester);

      expect(reviewShortDateLabel(context, 'not-a-date'), 'not-a-date');
      expect(reviewShortDateLabel(context, ''), '');
    },
  );

  testWidgets(
    'reviewTrendDirectionLabel shows unknown instead of flat when direction is missing',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(
        reviewTrendDirectionLabel(l10n, 'up'),
        l10n.reviewReviewChangeDirectionUp,
      );
      expect(
        reviewTrendDirectionLabel(l10n, 'down'),
        l10n.reviewReviewChangeDirectionDown,
      );
      expect(
        reviewTrendDirectionLabel(l10n, 'flat'),
        l10n.reviewReviewChangeDirectionFlat,
      );
      expect(
        reviewTrendDirectionLabel(l10n, null),
        l10n.reviewReviewChangeDirectionUnknown,
      );
      expect(
        reviewTrendDirectionLabel(l10n, 'sideways'),
        l10n.reviewReviewChangeDirectionUnknown,
      );
    },
  );
}
