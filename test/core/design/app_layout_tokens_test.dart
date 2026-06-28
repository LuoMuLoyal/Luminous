import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_layout_tokens.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

void main() {
  group('AppLayoutTokens.resolve', () {
    test('returns mobile scale for width < 600', () {
      final scale = AppLayoutTokens.resolve(320);
      expect(scale.pageHorizontalPadding, equals(AppSpacingTokens.md));
      expect(scale.maxContentWidth, equals(560));
    });

    test('returns large-mobile scale for width 600-959', () {
      final scale = AppLayoutTokens.resolve(768);
      expect(scale.pageHorizontalPadding, equals(AppSpacingTokens.lg));
      expect(scale.maxContentWidth, equals(760));
    });

    test('returns tablet scale for width 960-1199', () {
      final scale = AppLayoutTokens.resolve(1024);
      expect(scale.pageHorizontalPadding, equals(AppSpacingTokens.xl));
      expect(scale.maxContentWidth, equals(1040));
    });

    test('returns desktop scale for width >= 1200', () {
      final scale = AppLayoutTokens.resolve(1440);
      expect(scale.pageHorizontalPadding, equals(AppSpacingTokens.xl));
      expect(scale.maxContentWidth, equals(1400));
    });

    test('returns desktop scale for width exactly 1200', () {
      final scale = AppLayoutTokens.resolve(1200);
      expect(scale.maxContentWidth, equals(1400));
    });

    test('returns mobile scale for width exactly 0', () {
      final scale = AppLayoutTokens.resolve(0);
      expect(scale.maxContentWidth, equals(560));
    });

    test('card padding increases on larger screens', () {
      final phone = AppLayoutTokens.resolve(375);
      final desktop = AppLayoutTokens.resolve(1440);
      expect(desktop.cardPadding, greaterThanOrEqualTo(phone.cardPadding));
    });

    test('section vertical padding grows with screen size', () {
      final phone = AppLayoutTokens.resolve(375);
      final desktop = AppLayoutTokens.resolve(1440);
      expect(
        desktop.sectionVerticalPadding,
        greaterThan(phone.sectionVerticalPadding),
      );
    });
  });
}
