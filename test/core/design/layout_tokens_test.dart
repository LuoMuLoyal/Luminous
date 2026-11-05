import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('LayoutScaleResolver.resolve', () {
    test('returns mobile scale for width < 600', () {
      final scale = LayoutScaleResolver.resolve(320);
      expect(scale.pageHorizontalPadding, equals(Spacing.lg));
      expect(scale.maxContentWidth, equals(560));
    });

    test('returns large-mobile scale for width 600-839', () {
      final scale = LayoutScaleResolver.resolve(768);
      expect(scale.pageHorizontalPadding, equals(Spacing.xl));
      expect(scale.maxContentWidth, equals(760));
    });

    test('returns small-desktop scale for width 840-1199', () {
      final scale = LayoutScaleResolver.resolve(1024);
      expect(scale.pageHorizontalPadding, equals(Spacing.xl3));
      expect(scale.maxContentWidth, equals(1040));
    });

    test('returns desktop scale for width >= 1200', () {
      final scale = LayoutScaleResolver.resolve(1440);
      expect(scale.pageHorizontalPadding, equals(Spacing.xl3));
      // 桌面档与「小桌面」档共用 1040 的内容宽度上限（≥ 840 只有一个内容列），
      // 档位切换看纵向节奏：桌面档的 section 留白是 Spacing.xl6。
      expect(scale.maxContentWidth, equals(1040));
      expect(scale.sectionVerticalPadding, equals(Spacing.xl6));
    });

    test('returns desktop scale for width exactly 1200', () {
      final scale = LayoutScaleResolver.resolve(1200);
      expect(scale.maxContentWidth, equals(1040));
      expect(scale.sectionVerticalPadding, equals(Spacing.xl6));
    });

    test('returns mobile scale for width exactly 0', () {
      final scale = LayoutScaleResolver.resolve(0);
      expect(scale.maxContentWidth, equals(560));
    });

    test('card padding increases on larger screens', () {
      final phone = LayoutScaleResolver.resolve(375);
      final desktop = LayoutScaleResolver.resolve(1440);
      expect(desktop.cardPadding, greaterThanOrEqualTo(phone.cardPadding));
    });

    test('section vertical padding grows with screen size', () {
      final phone = LayoutScaleResolver.resolve(375);
      final desktop = LayoutScaleResolver.resolve(1440);
      expect(
        desktop.sectionVerticalPadding,
        greaterThan(phone.sectionVerticalPadding),
      );
    });

    test('desktop spacing steps down toward the card radius', () {
      // 页边距 → 卡内边距 → 圆角构成递减：大圆角必须配更大的内边距，
      // 否则卡片看起来廉价。圆角取 Forui 的 borderRadius.lg = 14。
      const cardRadius = 14.0;
      for (final width in [1024.0, 1440.0, 2560.0]) {
        final scale = LayoutScaleResolver.resolve(width);
        expect(
          scale.pageHorizontalPadding,
          greaterThan(scale.cardPadding),
          reason: '$width: 页边距应大于卡内边距',
        );
        expect(
          scale.cardPadding,
          greaterThan(cardRadius),
          reason: '$width: 卡内边距应大于圆角（否则大圆角显廉价）',
        );
      }
    });
  });
}
