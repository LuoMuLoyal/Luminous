import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';

void main() {
  group('isImperialUnitSystem', () {
    test('returns true for imperial', () {
      expect(isImperialUnitSystem('imperial'), isTrue);
    });

    test('returns false for metric', () {
      expect(isImperialUnitSystem('metric'), isFalse);
    });

    test('returns false when unset (null)', () {
      expect(isImperialUnitSystem(null), isFalse);
    });

    test('returns false for unknown values', () {
      expect(isImperialUnitSystem(''), isFalse);
      expect(isImperialUnitSystem('IMPERIAL'), isFalse);
      expect(isImperialUnitSystem('unknown'), isFalse);
    });
  });

  group('weightInLb', () {
    test('returns null for null input', () {
      expect(weightInLb(null), isNull);
    });

    test('converts kg to lb with the exact factor', () {
      // 1 kg = 2.2046226218 lb.
      expect(weightInLb(1), closeTo(2.2046226218, 1e-9));
      expect(weightInLb(60), closeTo(132.277357308, 1e-9));
      expect(weightInLb(0), 0);
    });

    test('display rounds the same way as kg', () {
      // 60 kg → 132.277… lb → round to 132, matching the kg row's round().
      expect(weightInLb(60)!.round(), 132);
    });
  });

  group('waterInFlOz', () {
    test('converts ml to fl oz with the exact factor', () {
      // 1 ml = 0.0338140227 fl oz.
      expect(waterInFlOz(1), closeTo(0.0338140227, 1e-9));
      expect(waterInFlOz(550), closeTo(18.597712485, 1e-9));
      expect(waterInFlOz(2000), closeTo(67.6280454, 1e-9));
      expect(waterInFlOz(0), 0);
    });

    test('display keeps one decimal place', () {
      expect(waterInFlOz(550).toStringAsFixed(1), '18.6');
      expect(waterInFlOz(2000).toStringAsFixed(1), '67.6');
    });
  });
}
