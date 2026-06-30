import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_safety_tip_style.dart';

void main() {
  group('medicineSafetyTipIcon', () {
    test('returns alcohol icon for alcohol', () {
      expect(medicineSafetyTipIcon('alcohol'), Icons.local_drink_outlined);
    });
    test('returns coffee for caffeine', () {
      expect(medicineSafetyTipIcon('caffeine'), Icons.coffee_rounded);
    });
    test('returns schedule for timing', () {
      expect(medicineSafetyTipIcon('timing'), Icons.schedule_rounded);
    });
    test('returns thermostat for storage', () {
      expect(medicineSafetyTipIcon('storage'), Icons.thermostat_rounded);
    });
    test('returns restaurant for food', () {
      expect(medicineSafetyTipIcon('food'), Icons.restaurant_rounded);
    });
    test('returns pregnant for pregnancy', () {
      expect(medicineSafetyTipIcon('pregnancy'), Icons.pregnant_woman_rounded);
    });
    test('returns healing for allergy', () {
      expect(medicineSafetyTipIcon('allergy'), Icons.healing_rounded);
    });
    test('returns drive_eta for driving', () {
      expect(medicineSafetyTipIcon('driving'), Icons.drive_eta_rounded);
    });
    test('returns lightbulb as default', () {
      expect(medicineSafetyTipIcon('unknown'), Icons.lightbulb_outline_rounded);
    });
  });

  group('medicineSafetyTipColor', () {
    final surface = AppThemeSurface.light;

    test('returns link for alcohol', () {
      expect(medicineSafetyTipColor('alcohol', surface), surface.link);
    });
    test('returns warningDeep for caffeine', () {
      expect(medicineSafetyTipColor('caffeine', surface), surface.warningDeep);
    });
    test('returns link for timing', () {
      expect(medicineSafetyTipColor('timing', surface), surface.link);
    });
    test('returns teal for storage', () {
      expect(medicineSafetyTipColor('storage', surface), surface.teal);
    });
    test('returns success for food', () {
      expect(medicineSafetyTipColor('food', surface), surface.success);
    });
    test('returns warning for pregnancy', () {
      expect(medicineSafetyTipColor('pregnancy', surface), surface.warning);
    });
    test('returns error for allergy', () {
      expect(medicineSafetyTipColor('allergy', surface), surface.error);
    });
    test('returns accent for driving', () {
      expect(medicineSafetyTipColor('driving', surface), surface.accent);
    });
    test('returns link as default', () {
      expect(medicineSafetyTipColor('unknown', surface), surface.link);
    });
  });
}
