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
