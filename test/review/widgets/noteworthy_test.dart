import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/noteworthy.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpNoteworthy(
    WidgetTester tester, {
    required List<ReviewFinding> findings,
    String startDate = '2026-08-01',
    String endDate = '2026-08-07',
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewNoteworthySection(
              findings: findings,
              l10n: l10n,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  ReviewFinding finding({
    ReviewInsightKind kind = ReviewInsightKind.sleep,
    String title = '咖啡因影响睡眠',
    String body = '下午摄入咖啡后睡眠时长下降',
  }) {
    return ReviewFinding(
      kind: kind,
      icon: SemanticIcons.reportInsight,
      color: SemanticColor.warning,
      title: title,
      body: body,
    );
  }

  testWidgets('no findings shows the abstain placeholder', (tester) async {
    await pumpNoteworthy(tester, findings: const []);

    expect(find.text('值得注意'), findsNothing);
    expect(find.text('这段时间没有新增值得注意的变化。'), findsOneWidget);
  });

  testWidgets('renders finding cards with title, body and window', (
    tester,
  ) async {
    await pumpNoteworthy(tester, findings: [finding()]);

    expect(find.text('值得注意'), findsOneWidget);
    expect(find.text('咖啡因影响睡眠'), findsOneWidget);
    expect(find.text('下午摄入咖啡后睡眠时长下降'), findsOneWidget);
    expect(find.text('2026-08-01 → 2026-08-07'), findsOneWidget);
    expect(find.text('这段时间没有新增值得注意的变化。'), findsNothing);
  });

  testWidgets('limits to two cards and aggregates title/body for mixed set', (
    tester,
  ) async {
    await pumpNoteworthy(
      tester,
      findings: [
        finding(title: '咖啡因影响睡眠', body: '下午咖啡后睡眠时长下降'),
        finding(
          kind: ReviewInsightKind.hydration,
          title: '饮水提升',
          body: '最近饮水记录趋于稳定',
        ),
        finding(
          kind: ReviewInsightKind.medication,
          title: '用药稳定',
          body: '连续按时用药',
        ),
      ],
    );

    // 只展示前两张。
    expect(find.text('咖啡因影响睡眠'), findsOneWidget);
    expect(find.text('饮水提升'), findsOneWidget);
    expect(find.text('用药稳定'), findsNothing);
  });
}
