import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_colors.dart';
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

AppColors medicineSafetyTipColor(String category, FColors colors) {
  return switch (category) {
    'alcohol' => AppColors.primary,
    'caffeine' => AppColors.primary,
    'timing' => AppColors.primary,
    'storage' => AppColors.primary,
    'food' => AppColors.primary,
    'pregnancy' => AppColors.primary,
    'allergy' => AppColors.destructive,
    'driving' => AppColors.primary,
    _ => AppColors.primary,
  };
}
