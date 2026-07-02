import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

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
    _ => AppColorTokens.cyanDeep,
  };
  final warning = switch (palette) {
    FColors colors => colors.primaryForeground,
    Color color => color,
    _ => AppColorTokens.warning,
  };
  final destructive = switch (palette) {
    FColors colors => colors.destructive,
    Color color => color,
    _ => AppColorTokens.warningDeep,
  };
  return switch (category) {
    'alcohol' => AppColorTokens.gradientDevelopStart,
    'caffeine' => AppColorTokens.warningDeep,
    'timing' => AppColorTokens.gradientDevelopStart,
    'storage' => AppColorTokens.cyanDeep,
    'food' => success,
    'pregnancy' => warning,
    'allergy' => destructive,
    'driving' => AppColorTokens.gradientDevelopEnd,
    _ => AppColorTokens.gradientDevelopStart,
  };
}
