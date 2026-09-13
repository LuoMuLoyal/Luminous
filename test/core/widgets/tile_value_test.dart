import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/tile_value.dart';

import '../../helpers/test_forui_app.dart';

/// The group is laid out inside a fixed-width box so the assertions are about
/// relative placement, not about whatever the test surface happens to be.
const _groupWidth = 300.0;

/// Forui's `FTileContentStyle.suffixedPadding.right` — the gap the tile keeps
/// between its content and the group's trailing edge, i.e. how far the chevron
/// normally sits from that edge.
const _tileRightInset = 13.0;

/// Forui's `FTileContentStyle.suffixIconSpacing` — the gap between the value and
/// the chevron.
const _suffixIconSpacing = 5.0;

void main() {
  testWidgets('pins the value and the chevron to the group trailing edge', (
    tester,
  ) async {
    await _pump(
      tester,
      children: [
        _row(key: 'r1', title: '登录密码', value: '已设置'),
        // Navigation row: no value slot at all.
        _row(key: 'r2', title: '登录设备'),
      ],
    );

    final group = _rect(tester, find.byType(FTileGroup));
    final firstChevron = _chevron(tester, 'r1');
    final value = _rect(tester, find.text('已设置'));

    expect(group.right - firstChevron.right, closeTo(_tileRightInset, 0.5));
    // The value hugs the chevron instead of sitting next to the title.
    expect(firstChevron.left - value.right, closeTo(_suffixIconSpacing, 0.5));

    // Omitting the value slot changes nothing about the chevron's position.
    expect(_chevron(tester, 'r2').right, closeTo(firstChevron.right, 0.5));
  });

  testWidgets('caps the value at 55% and never lets a long title starve it', (
    tester,
  ) async {
    const longTitle = '出生日期(YYYY-MM-DD)';
    const longValue = 'user.with.a.very.long.address@example.com';
    await _pump(
      tester,
      children: [_row(key: 'r1', title: longTitle, value: longValue)],
    );

    final group = _rect(tester, find.byType(FTileGroup));
    final chevron = _chevron(tester, 'r1');
    final value = _rect(tester, find.text(longValue));
    final title = _rect(tester, find.text(longTitle));

    expect(group.right - chevron.right, closeTo(_tileRightInset, 0.5));
    // A bare `Text` as `details` would let the title claim the whole row and
    // collapse the value to zero width; the cap keeps both readable.
    expect(value.width, greaterThan(0));
    expect(title.width, greaterThan(0));
    expect(value.width, lessThanOrEqualTo(_groupWidth * 0.55 + 0.5));
  });
}

FTile _row({required String key, required String title, String? value}) =>
    FTile(
      key: Key(key),
      title: Text(title),
      details: value == null ? null : AppTileValue(value),
      suffix: const Icon(SemanticIcons.actionNext),
      onPress: _noop,
    );

Future<void> _pump(
  WidgetTester tester, {
  required List<FTileMixin> children,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(393, 852);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  await tester.pumpWidget(
    TestForuiApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: _groupWidth,
            child: FTileGroup(
              physics: const NeverScrollableScrollPhysics(),
              divider: FItemDivider.full,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _rect(WidgetTester tester, Finder finder) => tester.getRect(finder);

Rect _chevron(WidgetTester tester, String key) => tester.getRect(
  find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byIcon(SemanticIcons.actionNext),
  ),
);

void _noop() {}
