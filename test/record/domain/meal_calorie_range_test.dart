import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/constants/meal_calorie_range.dart';

void main() {
  group('roundToHundreds', () {
    test('rounds to the nearest hundred', () {
      expect(roundToHundreds(549), 500);
      expect(roundToHundreds(550), 600);
      expect(roundToHundreds(1234), 1200);
    });

    test('clamps negatives to zero', () {
      // 区间是展示用的量级提示,负值只可能来自上流数据异常;
      // 钳到 0 比显示「-100–300」更不容易被误读。
      expect(roundToHundreds(-1), 0);
      expect(roundToHundreds(-250), 0);
    });
  });

  group('formatCoarseCalorieRange', () {
    test('coarsens both ends and joins with an en dash', () {
      expect(formatCoarseCalorieRange(min: 520, max: 780), '500–800');
    });

    test('keeps a single value when both ends are equal', () {
      expect(formatCoarseCalorieRange(min: 600, max: 600), '600–600');
    });

    test('clamps a negative lower bound to zero', () {
      expect(formatCoarseCalorieRange(min: -50, max: 420), '0–400');
    });
  });
}
