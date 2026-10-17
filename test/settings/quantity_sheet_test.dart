import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/dialog/edit_sheet.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/quantity_sheet.dart';

import '../helpers/test_forui_app.dart';

Future<void> _pump(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    TestForuiApp(
      home: Scaffold(body: Center(child: body)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HeightPickerSheetBody (metric)', () {
    testWidgets('leaves an in-range value untouched', (tester) async {
      final slot = SheetValueSlot<double>(170);
      await _pump(
        tester,
        HeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['cm'],
        ),
      );

      // 打开 sheet 不应改写用户当前的身高。
      expect(slot.value, 170);
    });

    testWidgets('clamps an over-range value back into the wheel', (
      tester,
    ) async {
      final slot = SheetValueSlot<double>(260);
      await _pump(
        tester,
        HeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['cm'],
        ),
      );

      // 260 超出滚轮上限 250:显示已 clamp,slot 也必须跟着改写,否则用户
      // 不动滚轮直接确认会把 260 原样回写。
      expect(slot.value, 250);
    });

    testWidgets('clamps an under-range value back into the wheel', (
      tester,
    ) async {
      final slot = SheetValueSlot<double>(10);
      await _pump(
        tester,
        HeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['cm'],
        ),
      );

      expect(slot.value, 50);
    });

    testWidgets('keeps the wheel on the value the user scrolled to', (
      tester,
    ) async {
      final slot = SheetValueSlot<double>(170);
      await _pump(
        tester,
        HeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['cm'],
        ),
      );

      final picker = find.byKey(const Key('quantity-sheet-picker'));
      await tester.drag(picker, const Offset(0, -150));
      await tester.pumpAndSettle();

      // 滚轮必须真的动了,否则这条断言在回弹 bug 下也会通过。
      expect(slot.value, isNot(170));
      // 选中项要对得上槽里的值:回弹 bug 下滚轮会动画回打开 sheet 时的索引,
      // 槽里却已经是新值,两者不一致。
      final selected = find.text('${slot.value.round()} cm');
      expect(selected, findsOneWidget);
      expect(
        (tester.getCenter(selected).dy - tester.getCenter(picker).dy).abs(),
        lessThan(8),
      );
    });
  });

  group('HeightPickerSheetBody (imperial)', () {
    testWidgets('leaves an in-range value untouched', (tester) async {
      // 180cm ≈ 5'11",在 1..8 ft 之内,不该被改写。
      final slot = SheetValueSlot<double>(180);
      await _pump(
        tester,
        HeightPickerSheetBody(
          slot: slot,
          imperial: true,
          suffixes: const ['ft', 'in'],
        ),
      );

      expect(slot.value, 180);
    });

    testWidgets('clamps a value above the tallest wheel entry', (tester) async {
      // 280cm = 9'2" —— 滚轮最高 8ft,越界。
      final slot = SheetValueSlot<double>(280);
      await _pump(
        tester,
        HeightPickerSheetBody(
          slot: slot,
          imperial: true,
          suffixes: const ['ft', 'in'],
        ),
      );

      expect(slot.value, lessThan(280));
      expect(slot.value, greaterThan(240));
    });
  });

  group('WeightPickerSheetBody (metric)', () {
    testWidgets('leaves an in-range value untouched', (tester) async {
      final slot = SheetValueSlot<double>(60);
      await _pump(
        tester,
        WeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['kg'],
        ),
      );

      expect(slot.value, 60);
    });

    testWidgets('clamps an over-range value instead of echoing it', (
      tester,
    ) async {
      final slot = SheetValueSlot<double>(900);
      await _pump(
        tester,
        WeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['kg'],
        ),
      );

      expect(slot.value, 500);
    });

    testWidgets('keeps the wheel on the value the user scrolled to', (
      tester,
    ) async {
      final slot = SheetValueSlot<double>(60);
      await _pump(
        tester,
        WeightPickerSheetBody(
          slot: slot,
          imperial: false,
          suffixes: const ['kg'],
        ),
      );

      final picker = find.byKey(const Key('quantity-sheet-picker'));
      await tester.drag(picker, const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(slot.value, isNot(60));
      final selected = find.text('${slot.value.round()} kg');
      expect(selected, findsOneWidget);
      expect(
        (tester.getCenter(selected).dy - tester.getCenter(picker).dy).abs(),
        lessThan(8),
      );
    });
  });

  group('WeightPickerSheetBody (imperial)', () {
    testWidgets('does not rewrite an in-range value', (tester) async {
      // 滚轮按整数磅取值。若打开 sheet 就无条件回写,60kg 会静默变成
      // 59.87kg(132lb),比原来的越界回写 bug 更隐蔽。
      final slot = SheetValueSlot<double>(60);
      await _pump(
        tester,
        WeightPickerSheetBody(
          slot: slot,
          imperial: true,
          suffixes: const ['lb'],
        ),
      );

      expect(slot.value, 60);
    });

    testWidgets('clamps an over-range value', (tester) async {
      final slot = SheetValueSlot<double>(900);
      await _pump(
        tester,
        WeightPickerSheetBody(
          slot: slot,
          imperial: true,
          suffixes: const ['lb'],
        ),
      );

      expect(slot.value, lessThan(900));
      expect(slot.value, greaterThan(400));
    });
  });
}
