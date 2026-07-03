import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

IconData medicineSafetyTipIcon(String category) {
  return switch (category) {
    'alcohol' => FLucideIcons.wine,
    'caffeine' => FLucideIcons.coffee,
    'timing' => FLucideIcons.clock3,
    'storage' => FLucideIcons.thermometer,
    'food' => FLucideIcons.utensils,
    'pregnancy' => FLucideIcons.heartPulse,
    'allergy' => FLucideIcons.syringe,
    'driving' => FLucideIcons.car,
    _ => FLucideIcons.lightbulb,
  };
}

Color medicineSafetyTipColor(String category, Object palette) {
  final success = switch (palette) {
    FColors colors => colors.primary,
    Color color => color,
    _ => FThemes.neutral.light.touch.colors.primary,
  };
  final warning = switch (palette) {
    FColors colors => colors.primaryForeground,
    Color color => color,
    _ => FThemes.neutral.light.touch.colors.primary,
  };
  final destructive = switch (palette) {
    FColors colors => colors.destructive,
    Color color => color,
    _ => FThemes.neutral.light.touch.colors.primary,
  };
  return switch (category) {
    'alcohol' => FThemes.neutral.light.touch.colors.primary,
    'caffeine' => FThemes.neutral.light.touch.colors.primary,
    'timing' => FThemes.neutral.light.touch.colors.primary,
    'storage' => FThemes.neutral.light.touch.colors.primary,
    'food' => success,
    'pregnancy' => warning,
    'allergy' => destructive,
    'driving' => FThemes.neutral.light.touch.colors.primary,
    _ => FThemes.neutral.light.touch.colors.primary,
  };
}
