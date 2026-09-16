import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/symptom_quick_entry_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  List<RecordFastChoice> choices() =>
      recordFastEntryChoicesFor(DailyRecordKind.symptom, l10n);

  /// Opens the real sheet entry point and collects the outcome once it pops.
  Future<List<SymptomQuickEntryOutcome?>> openSheet(
    WidgetTester tester, {
    String initialSeverity = 'mild',
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final captured = <SymptomQuickEntryOutcome?>[];
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Center(
            child: FButton(
              key: const Key('open-symptom-sheet'),
              onPress: () async {
                captured.add(
                  await showSymptomQuickEntrySheet(
                    context,
                    recordDate: DateTime(2026, 9, 14),
                    choices: choices(),
                    initialSeverity: initialSeverity,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-symptom-sheet')));
    await tester.pumpAndSettle();
    return captured;
  }

  testWidgets('renders the shared surface, severity row and symptom chips', (
    tester,
  ) async {
    await openSheet(tester);

    expect(find.byType(SheetSurface), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SheetSurface),
        matching: find.byType(SafeArea),
      ),
      findsNothing,
    );

    final route = ModalRoute.of(tester.element(find.byType(SheetSurface)));
    expect(route, isA<FModalSheetRoute<SymptomQuickEntryOutcome>>());
    expect(
      (route! as FModalSheetRoute<SymptomQuickEntryOutcome>).mainAxisMaxRatio,
      isNull,
    );

    // 四档严重度（含「无法判断」）与目录里的症状都在。
    for (final label in ['轻度', '中度', '重度', '无法判断']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final choice in choices()) {
      expect(find.text(choice.label), findsOneWidget);
    }
  });

  testWidgets('single tap returns one choice with the selected severity', (
    tester,
  ) async {
    final captured = await openSheet(tester, initialSeverity: 'mild');

    await tester.tap(find.byKey(const Key('symptom-quick-severity-severe')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-choice-headache')));
    await tester.pumpAndSettle();

    final outcome = captured.single;
    expect(outcome, isA<SymptomQuickEntrySelection>());
    final selection = outcome! as SymptomQuickEntrySelection;
    expect(selection.severity, 'severe');
    expect(selection.choices, hasLength(1));
    expect(recordFastChoiceCode(selection.choices.single), 'headache');
  });

  testWidgets('multi-select confirms every selected symptom', (tester) async {
    final captured = await openSheet(tester);

    await tester.tap(
      find.byKey(const Key('symptom-quick-multi-select-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-choice-headache')));
    await tester.tap(find.byKey(const Key('symptom-quick-choice-fever')));
    await tester.pumpAndSettle();

    // 确认按钮带数量，未选时不可点。
    expect(find.text(l10n.recordSymptomRecordCount(2)), findsOneWidget);
    await tester.tap(find.byKey(const Key('symptom-quick-confirm-action')));
    await tester.pumpAndSettle();

    final selection = captured.single! as SymptomQuickEntrySelection;
    expect(selection.choices.map(recordFastChoiceCode), ['headache', 'fever']);
  });

  testWidgets('back leaves multi-select without recording', (tester) async {
    final captured = await openSheet(tester);

    await tester.tap(
      find.byKey(const Key('symptom-quick-multi-select-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-choice-headache')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-back-action')));
    await tester.pumpAndSettle();

    expect(captured, isEmpty, reason: '返回只是退出多选，不该产生结果');
    expect(
      find.byKey(const Key('symptom-quick-multi-select-action')),
      findsOneWidget,
    );
  });

  testWidgets('more returns the create-page outcome', (tester) async {
    final captured = await openSheet(tester);

    await tester.tap(find.byKey(const Key('symptom-quick-more-action')));
    await tester.pumpAndSettle();

    expect(captured.single, isA<SymptomQuickEntryMore>());
  });

  testWidgets('cancel returns null', (tester) async {
    final captured = await openSheet(tester);

    await tester.tap(find.byKey(const Key('symptom-quick-cancel-action')));
    await tester.pumpAndSettle();

    expect(captured.single, isNull);
  });

  testWidgets('「其它」reveals an inline input and returns the typed name', (
    tester,
  ) async {
    final captured = await openSheet(tester);

    await tester.tap(find.byKey(const Key('symptom-quick-choice-other')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('symptom-quick-other-field')), findsOneWidget);

    // 输入为空时保存置灰。
    final saveButton = tester.widget<FButton>(
      find.byKey(const Key('symptom-quick-other-save-action')),
    );
    expect(saveButton.onPress, isNull);

    await tester.enterText(
      find.byKey(const Key('symptom-quick-other-field')),
      '偏头痛',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-other-save-action')));
    await tester.pumpAndSettle();

    final selection = captured.single! as SymptomQuickEntrySelection;
    expect(selection.customLabel, '偏头痛');
    expect(recordFastChoiceCode(selection.choices.single), 'other');
  });

  testWidgets('「其它」is unavailable while multi-selecting', (tester) async {
    await openSheet(tester);

    await tester.tap(
      find.byKey(const Key('symptom-quick-multi-select-action')),
    );
    await tester.pumpAndSettle();

    final otherChip = tester.widget<FButton>(
      find.byKey(const Key('symptom-quick-choice-other')),
    );
    expect(otherChip.onPress, isNull);
  });

  testWidgets('「其它」Back clears the draft so the next open starts empty', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.byKey(const Key('symptom-quick-choice-other')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('symptom-quick-other-field')),
      '偏头痛',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('symptom-quick-other-back-action')));
    await tester.pumpAndSettle();

    // 再次点开「其它」:上一次的草稿不该还在,否则要先手动删干净才能保存。
    await tester.tap(find.byKey(const Key('symptom-quick-choice-other')));
    await tester.pumpAndSettle();

    // 空输入 ⇒ 内容不显示,保存置灰。
    expect(find.text('偏头痛'), findsNothing);
    final saveButton = tester.widget<FButton>(
      find.byKey(const Key('symptom-quick-other-save-action')),
    );
    expect(saveButton.onPress, isNull);
  });

  testWidgets('leaving multi-select clears any「其它」draft', (tester) async {
    await openSheet(tester);

    await tester.tap(find.byKey(const Key('symptom-quick-choice-other')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('symptom-quick-other-field')),
      '偏头痛',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-other-back-action')));
    await tester.pumpAndSettle();

    // 进多选再退回单选,草稿同样应当被清掉。
    await tester.tap(
      find.byKey(const Key('symptom-quick-multi-select-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('symptom-quick-back-action')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('symptom-quick-choice-other')));
    await tester.pumpAndSettle();

    expect(find.text('偏头痛'), findsNothing);
  });
}
