import 'package:flutter/material.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

IconData medicineSafetyTipIcon(String category) {
  return switch (category) {
    'alcohol' => Icons.local_drink_outlined,
    'caffeine' => Icons.coffee_rounded,
    'timing' => Icons.schedule_rounded,
    'storage' => Icons.thermostat_rounded,
    'food' => Icons.restaurant_rounded,
    'pregnancy' => Icons.pregnant_woman_rounded,
    'allergy' => Icons.healing_rounded,
    'driving' => Icons.drive_eta_rounded,
    _ => Icons.lightbulb_outline_rounded,
  };
}

Color medicineSafetyTipColor(String category, AppThemeSurface surface) {
  return switch (category) {
    'alcohol' => surface.link,
    'caffeine' => surface.warningDeep,
    'timing' => surface.link,
    'storage' => surface.teal,
    'food' => surface.success,
    'pregnancy' => surface.warning,
    'allergy' => surface.error,
    'driving' => surface.accent,
    _ => surface.link,
  };
}
