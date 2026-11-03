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

  /// `resolve` 的分档由 `WindowSizeClass` 决定（`fluid_adaptive`），因此这里
  /// 固定的是**档位边界**而不是具体取值：边界挪动会让所有页面的留白整体换档，
  /// 而这在人工截图上不一定看得出来。
  ///
  /// 阈值取 `ResponsiveBreakpoints.standard`：600 / 840 / 1200。
  group('LayoutScaleResolver.resolve boundary', () {
    LayoutScale resolve(double w) => LayoutScaleResolver.resolve(w);

    test('below 600 uses the phone tier', () {
      expect(resolve(0).maxContentWidth, 560);
      expect(resolve(599).maxContentWidth, 560);
    });

    test('600 switches to the tablet tier (M3 medium)', () {
      expect(resolve(600).maxContentWidth, 760);
      expect(resolve(839).maxContentWidth, 760);
    });

    test('840 switches to the small-desktop tier (M3 expanded)', () {
      expect(resolve(840).maxContentWidth, 1040);
      expect(resolve(1199).maxContentWidth, 1040);
    });

    test('1200 switches to the desktop tier (M3 large)', () {
      // 桌面档与「小桌面」档共用同一个内容宽度上限（1040）：整个应用在
      // ≥ 840 宽度上只有一个内容列，见 layout_scale.dart 的 _desktop 注释。
      // 因此档位边界只能靠纵向节奏断言，不能再拿 maxContentWidth 当分档信号。
      expect(resolve(1200).maxContentWidth, 1040);
      expect(resolve(2560).maxContentWidth, 1040);
      expect(
        resolve(1200).heroVerticalPadding,
        greaterThan(resolve(1199).heroVerticalPadding),
      );
      expect(
        resolve(1200).sectionVerticalPadding,
        greaterThan(resolve(1199).sectionVerticalPadding),
      );
    });

    test('padding follows the tier, not the raw width', () {
      // 相邻档位的留白必须不同，否则这条链等于没分档。
      expect(
        resolve(599).pageHorizontalPadding,
        isNot(resolve(600).pageHorizontalPadding),
      );
      expect(
        resolve(839).pageHorizontalPadding,
        isNot(resolve(840).pageHorizontalPadding),
      );
      // 小桌面与桌面共用同一水平留白（都是 Spacing.xl3 = 24），
      // 两者只靠纵向节奏区分。
      expect(
        resolve(1199).pageHorizontalPadding,
        resolve(1200).pageHorizontalPadding,
      );
      expect(
        resolve(1199).sectionVerticalPadding,
        isNot(resolve(1200).sectionVerticalPadding),
      );
    });
  });
}
