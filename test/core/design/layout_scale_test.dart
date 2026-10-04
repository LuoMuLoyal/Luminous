import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/layout/layout_scale.dart';

/// 生效字号按「缩放后的可用文字宽度」收口：真机与模拟器的换行数量/纵向节奏
/// 因此接近一致，而不是靠一个固定宽度阈值（393dp 曾落在 360dp 阈值之外）。
void main() {
  group('LayoutScaleResolver.effectiveTextScale', () {
    test(
      'keeps the user tier when the scaled text width clears the baseline',
      () {
        // Pixel 8 Pro 模拟器（约 448dp）在 1.3 档下可用文字宽度仍高于基线。
        expect(LayoutScaleResolver.effectiveTextScale(448, 1.3), 1.3);
      },
    );

    test(
      'caps a wide tier by the available text width on narrower devices',
      () {
        // 393dp 真机：保基线后上限约 1.14，比原来的 1.3 更接近模拟器观感。
        final scale = LayoutScaleResolver.effectiveTextScale(393, 1.3);
        expect(scale, lessThan(1.3));
        expect(scale, closeTo((393 - 28) / 320, 0.001));
      },
    );

    test('never drops a large tier below standard', () {
      expect(LayoutScaleResolver.effectiveTextScale(320, 1.3), 1.0);
      expect(LayoutScaleResolver.effectiveTextScale(200, 1.3), 1.0);
    });

    test('never enlarges the chosen tier and leaves small tiers untouched', () {
      expect(LayoutScaleResolver.effectiveTextScale(448, 1.0), 1.0);
      expect(LayoutScaleResolver.effectiveTextScale(448, 0.85), 0.85);
      expect(LayoutScaleResolver.effectiveTextScale(320, 0.85), 0.85);
    });
  });
}
