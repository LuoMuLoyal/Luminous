import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_safety_tip_style.dart';

void main() {
  group('medicineSafetyTipIcon', () {
    test('returns wine for alcohol', () {
      expect(medicineSafetyTipIcon('alcohol'), FLucideIcons.wine);
    });
    test('returns coffee for caffeine', () {
      expect(medicineSafetyTipIcon('caffeine'), FLucideIcons.coffee);
    });
    test('returns clock3 for timing', () {
      expect(medicineSafetyTipIcon('timing'), FLucideIcons.clock3);
    });
    test('returns thermometer for storage', () {
      expect(medicineSafetyTipIcon('storage'), FLucideIcons.thermometer);
    });
    test('returns utensils for food', () {
      expect(medicineSafetyTipIcon('food'), FLucideIcons.utensils);
    });
    test('returns heartPulse for pregnancy', () {
      expect(medicineSafetyTipIcon('pregnancy'), FLucideIcons.heartPulse);
    });
    test('returns syringe for allergy', () {
      expect(medicineSafetyTipIcon('allergy'), FLucideIcons.syringe);
    });
    test('returns car for driving', () {
      expect(medicineSafetyTipIcon('driving'), FLucideIcons.car);
    });
    test('returns lightbulb as default', () {
      expect(medicineSafetyTipIcon('unknown'), FLucideIcons.lightbulb);
    });
  });

  group('medicineSafetyTipColor', () {
    final colors = FThemes.neutral.light.touch.colors;

    test('returns green for alcohol', () {
      expect(
        medicineSafetyTipColor('alcohol', colors),
        const Color(0xFF16A34A),
      );
    });
    test('returns amber for caffeine', () {
      expect(
        medicineSafetyTipColor('caffeine', colors),
        const Color(0xFFB45309),
      );
    });
    test('returns green for timing', () {
      expect(
        medicineSafetyTipColor('timing', colors),
        const Color(0xFF16A34A),
      );
    });
    test('returns teal for storage', () {
      expect(
        medicineSafetyTipColor('storage', colors),
        const Color(0xFF0F766E),
      );
    });
    test('returns primary for food', () {
      expect(medicineSafetyTipColor('food', colors), colors.primary);
    });
    test('returns primaryForeground for pregnancy', () {
      expect(
        medicineSafetyTipColor('pregnancy', colors),
        colors.primaryForeground,
      );
    });
    test('returns destructive for allergy', () {
      expect(medicineSafetyTipColor('allergy', colors), colors.destructive);
    });
    test('returns teal for driving', () {
      expect(
        medicineSafetyTipColor('driving', colors),
        const Color(0xFF14B8A6),
      );
    });
    test('returns green as default', () {
      expect(
        medicineSafetyTipColor('unknown', colors),
        const Color(0xFF16A34A),
      );
    });
  });
}
