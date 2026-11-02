import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/layout/surface.dart';

/// 桌面端的层次全部来自三层底色的亮度差：
/// `sidebar < scaffold < card`。边框只是这层关系之上的装饰。
///
/// 这里固定的是**相对顺序**而不是具体色值——色值会随主题族调整，
/// 但顺序一旦反了（侧边栏比页面亮、卡片比页面暗），层次就没了，
/// 而这在浅色截图上不一定看得出来。
void main() {
  /// Flutter 的 luminance 是线性化后的相对亮度，可直接比较明暗。
  double lum(Color c) => c.computeLuminance();

  group('SurfaceTokens light', () {
    final colors = FTheme.neutral.light.desktop.colors;

    test('sidebar is deeper than the scaffold', () {
      expect(
        lum(SurfaceTokens.sidebarBackground(colors)),
        lessThan(lum(SurfaceTokens.scaffoldBackground(colors))),
      );
    });

    test('card is brighter than the scaffold', () {
      expect(
        lum(colors.card),
        greaterThan(lum(SurfaceTokens.scaffoldBackground(colors))),
      );
    });

    test('three tiers are strictly ordered sidebar < scaffold < card', () {
      final sidebar = lum(SurfaceTokens.sidebarBackground(colors));
      final scaffold = lum(SurfaceTokens.scaffoldBackground(colors));
      final card = lum(colors.card);

      expect(sidebar, lessThan(scaffold));
      expect(scaffold, lessThan(card));
    });

    test('sidebar differs from the scaffold enough to be visible', () {
      // 同色是这次修复要消除的那类回归；0.005 的亮度差约等于肉眼可辨的
      // 一档灰（#F4F4F5 vs #FAFAFA），更小就等于没分档。
      final delta =
          (lum(SurfaceTokens.scaffoldBackground(colors)) -
                  lum(SurfaceTokens.sidebarBackground(colors)))
              .abs();
      expect(delta, greaterThan(0.005));
    });
  });

  group('SurfaceTokens dark', () {
    final colors = FTheme.neutral.dark.desktop.colors;

    test('sidebar is deeper than the scaffold', () {
      expect(
        lum(SurfaceTokens.sidebarBackground(colors)),
        lessThan(lum(SurfaceTokens.scaffoldBackground(colors))),
      );
    });

    test('card is brighter than the scaffold', () {
      expect(
        lum(colors.card),
        greaterThan(lum(SurfaceTokens.scaffoldBackground(colors))),
      );
    });

    test('sidebar differs from the scaffold enough to be visible', () {
      // 暗色模式下可用的亮度区间本身极窄（background 0.003 → card 0.009），
      // 绝对阈值不适用。改成按「主题可用区间的一个比例」要求：
      // 侧边栏与页面至少隔开整段 background→card 区间的 20%，
      // 这样主题族怎么调，判据都跟着走。
      final lo = lum(colors.background);
      final hi = lum(colors.card);
      final span = hi - lo;
      final delta =
          (lum(SurfaceTokens.scaffoldBackground(colors)) -
                  lum(SurfaceTokens.sidebarBackground(colors)))
              .abs();
      expect(span, greaterThan(0), reason: 'dark background→card 必须构成区间');
      expect(delta, greaterThan(span * 0.2));
    });
  });
}
