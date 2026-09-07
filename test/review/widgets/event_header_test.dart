import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/widgets/sections/event_header.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpHeader(
    WidgetTester tester,
    EventHeaderSection header,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(body: SingleChildScrollView(child: header)),
      ),
    );
    await tester.pump();
  }

  testWidgets('active event shows ongoing chip and offers today check-in', (
    tester,
  ) async {
    var goTodayCheckInTapped = false;
    await pumpHeader(
      tester,
      EventHeaderSection(
        event: _activeEvent,
        todayCheckIn: null,
        onGoTodayCheckIn: () => goTodayCheckInTapped = true,
      ),
    );

    expect(find.text('感冒观察'), findsOneWidget);
    expect(find.text(l10n.reviewReviewStatusActive), findsOneWidget);
    // 今日尚未确认：渲染「去今日 check-in」浅链接，而非旧的 check-in/end 按钮。
    expect(find.byKey(const Key('review-go-today-check-in')), findsOneWidget);
    // 关联用药与开始日期。
    expect(find.text('关联 2 种用药'), findsOneWidget);
    expect(find.textContaining('开始于'), findsOneWidget);
    expect(find.textContaining('至今'), findsNothing);

    await tester.tap(find.byKey(const Key('review-go-today-check-in')));
    expect(goTodayCheckInTapped, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('active event already checked in shows the done-today line', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      EventHeaderSection(
        event: _activeEvent,
        todayCheckIn: const ReviewTodayCheckIn(
          date: '2026-08-13',
          outcome: ReviewEventOutcome.improved,
          updatedAt: '2026-08-13T08:00:00.000Z',
        ),
        onGoTodayCheckIn: () {},
      ),
    );

    // 已确认今日 check-in：不再渲染去 check-in 入口，改为一行确认文案。
    expect(find.byKey(const Key('review-go-today-check-in')), findsNothing);
    expect(find.text('今天已确认：好转'), findsOneWidget);
  });

  testWidgets(
    'active event without today check-in shows the go-check-in action',
    (tester) async {
      await pumpHeader(
        tester,
        EventHeaderSection(
          event: _activeEvent,
          todayCheckIn: null,
          onGoTodayCheckIn: () {},
        ),
      );

      // 今日未确认：渲染「去今日 check-in」浅链接。旧的 check-in/end 动作已移除。
      expect(find.byKey(const Key('review-go-today-check-in')), findsOneWidget);
    },
  );

  testWidgets('ended event shows the confirmed outcome and no check-in', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      EventHeaderSection(
        event: _endedEvent,
        todayCheckIn: null,
        onGoTodayCheckIn: () {},
      ),
    );

    expect(find.text(l10n.reviewReviewStatusEnded), findsOneWidget);
    expect(find.text(l10n.reviewReviewOutcomeLabel), findsOneWidget);
    expect(find.text(l10n.reviewReviewOutcomeImproved), findsOneWidget);
    // 无任何动作：ended 头部不再渲染去 check-in 入口。
    expect(find.byKey(const Key('review-go-today-check-in')), findsNothing);
    expect(find.textContaining('结束于'), findsOneWidget);
  });
}

const _activeEvent = ReviewEvent(
  id: 'evt-active',
  kind: ReviewEventKind.symptom,
  title: '感冒观察',
  status: ReviewEventStatus.active,
  startedAt: '2026-08-01T00:00:00.000Z',
  endedAt: null,
  outcome: null,
  currentMedicineIds: ['med-1', 'med-2'],
);

const _endedEvent = ReviewEvent(
  id: 'evt-ended',
  kind: ReviewEventKind.symptom,
  title: '感冒观察',
  status: ReviewEventStatus.ended,
  startedAt: '2026-08-01T00:00:00.000Z',
  endedAt: '2026-08-10T00:00:00.000Z',
  outcome: ReviewEventOutcome.improved,
  currentMedicineIds: ['med-1'],
);
