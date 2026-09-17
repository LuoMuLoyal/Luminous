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

  group('kgToLb', () {
    test('converts with the exact factor', () {
      expect(kgToLb(1), closeTo(2.2046226218, 1e-6));
      expect(kgToLb(60), closeTo(132.277357308, 1e-6));
      expect(kgToLb(0), 0);
    });
  });

  group('lbToKg', () {
    test('converts with the exact factor', () {
      expect(lbToKg(1), closeTo(0.45359237, 1e-6));
      expect(lbToKg(132.277357308), closeTo(60, 1e-6));
      expect(lbToKg(0), 0);
    });

    test('round-trips with kgToLb', () {
      expect(lbToKg(kgToLb(60)), closeTo(60, 1e-6));
      expect(lbToKg(kgToLb(72.5)), closeTo(72.5, 1e-6));
    });
  });

  group('cmToFeetInches', () {
    test('splits centimetres into feet and inches', () {
      expect(cmToFeetInches(150), (feet: 4, inches: 11));
      expect(cmToFeetInches(160), (feet: 5, inches: 3));
      expect(cmToFeetInches(182.88), (feet: 6, inches: 0));
      expect(cmToFeetInches(260), (feet: 8, inches: 6));
    });

    test('carries a rounded 12 inches into the next foot', () {
      // 59.5 in ≈ 151.13 cm → 4 ft 11.5 in → rounds up to 5 ft 0 in.
      expect(cmToFeetInches(59.5 * 2.54), (feet: 5, inches: 0));
    });

    test('round-trips with feetInchesToCm', () {
      final cm = feetInchesToCm(5, 7);
      expect(cmToFeetInches(cm), (feet: 5, inches: 7));
    });
  });

  group('feetInchesToCm', () {
    test('converts feet and inches to centimetres', () {
      expect(feetInchesToCm(5, 7), closeTo(170.18, 1e-6));
      expect(feetInchesToCm(6, 0), closeTo(182.88, 1e-6));
      expect(feetInchesToCm(0, 0), closeTo(0, 1e-9));
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
