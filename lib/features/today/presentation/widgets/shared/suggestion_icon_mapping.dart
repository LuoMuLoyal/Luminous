import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// Maps backend suggestion icon strings to Flutter [IconData].
///
/// When the backend introduces a new icon name not listed here, the fallback
/// [SemanticIcons.aiEntry] is used. To add support for a new icon, simply add
/// an entry to [_mapping].
class SuggestionIconMapping {
  SuggestionIconMapping._();

  static const IconData _fallback = SemanticIcons.aiEntry;

  /// Canonical mapping from backend icon string → [IconData].
  static const Map<String, IconData> _mapping = {
    'droplets': SemanticIcons.recordWater,
    'moon': SemanticIcons.recordMoon,
    'activity': SemanticIcons.recordActivity,
    'coffee': SemanticIcons.recordCaffeine,
    'user': SemanticIcons.profileUser,
    'clipboard': SemanticIcons.recordClipboard,
    'alert-triangle': SemanticIcons.statusWarning,
    'pill': SemanticIcons.recordMedicine,
    'trending-up': SemanticIcons.reportTrend,
    'lightbulb': SemanticIcons.aiTip,
    'info': SemanticIcons.statusInfo,
  };

  /// Resolves a backend icon string to [IconData].
  ///
  /// Returns [_fallback] when [icon] is not recognised.
  static IconData resolve(String icon) {
    return _mapping[icon] ?? _fallback;
  }
}
