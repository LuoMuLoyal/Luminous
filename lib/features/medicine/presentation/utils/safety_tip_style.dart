import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

IconData medicineSafetyTipIcon(String category) {
  return switch (category) {
    'alcohol' => SemanticIcons.safetyAlcohol,
    'caffeine' => SemanticIcons.recordCaffeine,
    'timing' => SemanticIcons.statusPending,
    'storage' => SemanticIcons.recordSymptom,
    'food' => SemanticIcons.recordMeal,
    'pregnancy' => SemanticIcons.profileCondition,
    'allergy' => SemanticIcons.safetyAllergyShot,
    'driving' => SemanticIcons.safetyDriving,
    _ => SemanticIcons.aiTip,
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
