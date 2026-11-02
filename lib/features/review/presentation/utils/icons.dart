import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';

/// Resolves a review domain icon name (a kebab-case Lucide name) to a glyph.
///
/// `ReviewMetric` / `ReviewFinding` / `ReviewExportAction` / `ReviewPatternCard`
/// store icon *identity* as a `String` so the `domain/` layer stays free of
/// `flutter/material` (clean-layers R1/R2). The concrete `IconData` is resolved
/// here, in the presentation layer.
IconData reviewIcon(String? name, {IconData fallback = defaultReviewIcon}) {
  if (name == null) return fallback;
  return LucideIconBridge.resolve(name, fallback: fallback);
}

/// Glyph used when a review entity carries no icon name.
const defaultReviewIcon = SemanticIcons.reportInsight;
