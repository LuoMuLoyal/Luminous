import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('LayoutScaleResolver.resolve', () {
    test('returns mobile scale for width < 600', () {
      final scale = LayoutScaleResolver.resolve(320);
      expect(scale.pageHorizontalPadding, equals(Spacing.level4));
      expect(scale.maxContentWidth, equals(560));
    });

    test('returns large-mobile scale for width 600-959', () {
      final scale = LayoutScaleResolver.resolve(768);
      expect(scale.pageHorizontalPadding, equals(Spacing.level5));
      expect(scale.maxContentWidth, equals(760));
    });

    test('returns tablet scale for width 960-1199', () {
      final scale = LayoutScaleResolver.resolve(1024);
      expect(scale.pageHorizontalPadding, equals(Spacing.level6));
      expect(scale.maxContentWidth, equals(1040));
    });

    test('returns desktop scale for width >= 1200', () {
      final scale = LayoutScaleResolver.resolve(1440);
      expect(scale.pageHorizontalPadding, equals(Spacing.level6));
      expect(scale.maxContentWidth, equals(1400));
    });

    test('returns desktop scale for width exactly 1200', () {
      final scale = LayoutScaleResolver.resolve(1200);
      expect(scale.maxContentWidth, equals(1400));
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
  });
}
