import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/presentation/utils/safety_tip_style.dart';

void main() {
  group('medicineSafetyTipIcon', () {
    test('returns wine for alcohol', () {
      expect(medicineSafetyTipIcon('alcohol'), SemanticIcons.safetyAlcohol);
    });
    test('returns coffee for caffeine', () {
      expect(medicineSafetyTipIcon('caffeine'), SemanticIcons.recordCaffeine);
    });
    test('returns clock3 for timing', () {
      expect(medicineSafetyTipIcon('timing'), SemanticIcons.statusPending);
    });
    test('returns thermometer for storage', () {
      expect(medicineSafetyTipIcon('storage'), SemanticIcons.recordSymptom);
    });
    test('returns utensils for food', () {
      expect(medicineSafetyTipIcon('food'), SemanticIcons.recordMeal);
    });
    test('returns heartPulse for pregnancy', () {
      expect(
        medicineSafetyTipIcon('pregnancy'),
        SemanticIcons.profileCondition,
      );
    });
    test('returns syringe for allergy', () {
      expect(medicineSafetyTipIcon('allergy'), SemanticIcons.safetyAllergyShot);
    });
    test('returns car for driving', () {
      expect(medicineSafetyTipIcon('driving'), SemanticIcons.safetyDriving);
    });
    test('returns lightbulb as default', () {
      expect(medicineSafetyTipIcon('unknown'), SemanticIcons.aiTip);
    });
  });

  group('medicineSafetyTipColor', () {
    final colors = FTheme.neutral.light.touch.colors;
    test('returns primary for alcohol', () {
      expect(medicineSafetyTipColor('alcohol', colors), SemanticColor.primary);
    });
    test('returns primary for caffeine', () {
      expect(medicineSafetyTipColor('caffeine', colors), SemanticColor.primary);
    });
    test('returns primary for timing', () {
      expect(medicineSafetyTipColor('timing', colors), SemanticColor.primary);
    });
    test('returns primary for storage', () {
      expect(medicineSafetyTipColor('storage', colors), SemanticColor.primary);
    });
    test('returns primary for food', () {
      expect(medicineSafetyTipColor('food', colors), SemanticColor.primary);
    });
    test('returns primary for pregnancy', () {
      expect(
        medicineSafetyTipColor('pregnancy', colors),
        SemanticColor.primary,
      );
    });
    test('returns destructive for allergy', () {
      expect(
        medicineSafetyTipColor('allergy', colors),
        SemanticColor.destructive,
      );
    });
    test('returns primary for driving', () {
      expect(medicineSafetyTipColor('driving', colors), SemanticColor.primary);
    });
    test('returns primary as default', () {
      expect(medicineSafetyTipColor('unknown', colors), SemanticColor.primary);
    });
  });
}
