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
    _ => Color(0xFF0F766E),
  };
  final warning = switch (palette) {
    FColors colors => colors.primaryForeground,
    Color color => color,
    _ => Color(0xFFF59E0B),
  };
  final destructive = switch (palette) {
    FColors colors => colors.destructive,
    Color color => color,
    _ => Color(0xFFB45309),
  };
  return switch (category) {
    'alcohol' => Color(0xFF16A34A),
    'caffeine' => Color(0xFFB45309),
    'timing' => Color(0xFF16A34A),
    'storage' => Color(0xFF0F766E),
    'food' => success,
    'pregnancy' => warning,
    'allergy' => destructive,
    'driving' => Color(0xFF14B8A6),
    _ => Color(0xFF16A34A),
  };
}
