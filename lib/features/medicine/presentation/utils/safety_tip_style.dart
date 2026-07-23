import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';

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

SemanticColor medicineSafetyTipColor(String category, FColors colors) {
  return switch (category) {
    'alcohol' => SemanticColor.primary,
    'caffeine' => SemanticColor.primary,
    'timing' => SemanticColor.primary,
    'storage' => SemanticColor.primary,
    'food' => SemanticColor.primary,
    'pregnancy' => SemanticColor.primary,
    'allergy' => SemanticColor.destructive,
    'driving' => SemanticColor.primary,
    _ => SemanticColor.primary,
  };
}
